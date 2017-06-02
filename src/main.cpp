#include <iostream>
#include <signal.h>
#include <stdio.h>
#include <exception>
#include <libconfig.h++>

#include <tgbot/tgbot.h>

#include <EXTERN.h>
#include <perl.h>

#include "perlxsi.c"

using namespace std;
using namespace libconfig;
using namespace TgBot;

static PerlInterpreter *my_perl;  /***    The Perl interpreter    ***/

bool sigintGot = false;

int getToken(const string &filepath, string &token) {
    Config keys;

    // Read the file. If there is an error, report it and exit.
    try {
        keys.readFile(filepath.c_str());
    }
    catch(const FileIOException &fioex) {
        std::cerr << "Unable to find [" << filepath << "] configuration file." << std::endl;
        return 1;
    }
    catch(const ParseException &pex) {
        std::cerr << "Parse error at " << pex.getFile() << ":" << pex.getLine()
                  << " - " << pex.getError() << std::endl;
        return 2;
    }

    string _token = keys.lookup("token");
    token = _token;
    return 0;
}

void setupBot(Bot &bot) {
    bot.getEvents().onCommand("start", [&bot](Message::Ptr message) -> void {
        bot.getApi().sendMessage(message->chat->id, "Bip Bop! Getting the motor running...");
    });

    bot.getEvents().onUnknownCommand([&bot](Message::Ptr message) -> void {
        bot.getApi().sendMessage(message->chat->id, "Sorry, I don't understand your command.");
    });

    bot.getEvents().onNonCommandMessage([&bot](Message::Ptr message) -> void {
        bool from_group = ((message->chat->type == Chat::Type::Group) or (message->chat->type == Chat::Type::Supergroup));
        if (!from_group) {
            cout << "Private message from: " << message->from->username << endl;
            return;
        }
        cout << "Chat ID: " << message->chat->id << "\tID: " << message->messageId << endl;
        cout << message->from->username << ":\t" << message->text << endl;
        bot.getApi().sendMessage(message->chat->id, "Deleting: " + message->text);
        bot.getApi().deleteMessage(message->chat->id, message->messageId);
    });
}

int main(int argc, char **argv, char **env) {

    char *perl_argv[] = {"", "hello.pl"};
    PERL_SYS_INIT3(&argc,&argv,&env);
    my_perl = perl_alloc();
    perl_construct(my_perl);
    PL_exit_flags |= PERL_EXIT_DESTRUCT_END;
    perl_parse(my_perl, xs_init, 2, perl_argv, (char **)NULL);
    perl_run(my_perl);

    dSP;                                        /* initialize stack pointer      */
    ENTER;                                      /* everything created after here */
    SAVETMPS;                                   /* ...is a temporary variable.   */
    PUSHMARK(SP);                               /* remember the stack pointer    */
    XPUSHs(sv_2mortal(newSVpv("test", 4)));     /* push the base onto the stack  */
    PUTBACK;                                    /* make local stack pointer global */
    call_pv("validate", G_SCALAR);              /* call the function             */
    SPAGAIN;                                    /* refresh stack pointer         */
    int val = POPi;                                    /* pop the return value from stack */
    PUTBACK;
    FREETMPS;                                   /* free that return value        */
    LEAVE;                                      /* ...and the XPUSHed "mortal" args.*/

    perl_destruct(my_perl);
    perl_free(my_perl);
    PERL_SYS_TERM();

    std::cout << "Is spam: " << val << std::endl;

    string token = "";
    int status = getToken("keys.cfg", token);
    if (status) {
        std::cout << "Error in config file. Exitting..." << std::endl;
        return status;
    }

    std::cout << "Hello World, this is C++!" << std::endl;
    std::cout << "Telegram Token -> [" << token << "]" << std::endl;

    Bot bot(token);
    setupBot(bot);

    signal(SIGINT, [](int sig) -> void {
        std::cout << "Got SIGINT exitting after finishing current poll." << std::endl;
        sigintGot = true;
    });

    try {
        std::cout << "Bot username: " << bot.getApi().getMe()->username << std::endl;
        TgLongPoll longPoll(bot);
        // Main Loop
        while (!sigintGot) {
            longPoll.start();
        }
    } catch (exception& e) {
        std::cout << "Error: " << e.what() << std::endl;
    }

    return 0;
}
