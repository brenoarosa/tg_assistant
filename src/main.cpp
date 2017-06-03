#include <iostream>
#include <signal.h>
#include <stdio.h>
#include <exception>
#include <libconfig.h++>

#include <tgbot/tgbot.h>

#include <EXTERN.h>
#include <perl.h>

#include "perlxsi.h"

using namespace std;
using namespace libconfig;
using namespace TgBot;

bool exit_flag = false;

int get_token(const string &filepath, string &token) {
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

    token = (const char*) keys.lookup("token");
    return 0;
}

bool is_spam_message(const string message, const string spam_func="validate") {
    dSP;                                                                /* initialize stack pointer      */
    ENTER;                                                              /* everything created after here */
    SAVETMPS;                                                           /* ...is a temporary variable.   */
    PUSHMARK(SP);                                                       /* remember the stack pointer    */
    XPUSHs(sv_2mortal(newSVpv(message.c_str(), message.length())));     /* push the message onto the stack  */
    PUTBACK;                                                            /* make local stack pointer global */
    call_pv(spam_func.c_str(), G_SCALAR);                               /* call the function             */
    SPAGAIN;                                                            /* refresh stack pointer         */
    bool is_spam = (bool) POPi;                                         /* pop the return value from stack */
    PUTBACK;
    FREETMPS;                                                           /* free that return value        */
    LEAVE;                                                              /* ...and the XPUSHed "mortal" args.*/
    return is_spam;
}

void setup_bot(Bot &bot) {
    bot.getEvents().onCommand("start", [&bot](Message::Ptr message) -> void {
        bot.getApi().sendMessage(message->chat->id, "Bip Bop! Getting the motor running...");
    });

    bot.getEvents().onUnknownCommand([&bot](Message::Ptr message) -> void {
        bot.getApi().sendMessage(message->chat->id, "Sorry, I don't understand your command.");
    });

    bot.getEvents().onNonCommandMessage([&bot](Message::Ptr message) -> void {
        bool from_group = ((message->chat->type == Chat::Type::Group) or (message->chat->type == Chat::Type::Supergroup));
        if (!from_group) {
            cout << "[" << message->from->username << "]\t" << message->text << endl;
            // ignore for now, maybe block user
            return;
        }

        // Log message
        cout << "[" << message->chat->title << "]" << endl;
        cout << ">> " << message->from->username << ":\t" << message->text << endl;

        if(is_spam_message(message->text)) {
            bot.getApi().sendMessage(message->chat->id, "Deleting: " + message->text);
            bot.getApi().deleteMessage(message->chat->id, message->messageId);
        }
    });
}

void setup_perl(PerlInterpreter *perl_int, const string module_path="hello.pl") {
    perl_construct(perl_int);
    PL_exit_flags |= PERL_EXIT_DESTRUCT_END;

    char *perl_argv[] = {strdup(""), strdup(module_path.c_str())};
    perl_parse(perl_int, xs_init, 2, perl_argv, (char **)NULL);
    perl_run(perl_int);
}

void destroy_perl(PerlInterpreter *perl_int) {
    perl_destruct(perl_int);
    perl_free(perl_int);
    PERL_SYS_TERM();
}

int main(int argc, char **argv, char **env) {

    std::cout << "Starting Bot..." << std::endl;

    PERL_SYS_INIT3(&argc,&argv,&env);
    PerlInterpreter *perl_int = perl_alloc();
    setup_perl(perl_int);

    string token = "";
    int status = get_token("keys.cfg", token);
    if (status) {
        std::cout << "Error in config file. Aborting..." << std::endl;
        std::cout << "Could no find [keys.cfg] file with token." << std::endl;
        return status;
    }

    std::cout << "Telegram Token ~> [" << token << "]" << std::endl;

    Bot bot(token);
    setup_bot(bot);

    signal(SIGINT, [](int sig) -> void {
        std::cout << "SIGINT! Exitting after current poll..." << std::endl;
        exit_flag = true;
    });

    try {
        std::cout << "Up and running as @" << bot.getApi().getMe()->username << std::endl;
        TgLongPoll longPoll(bot);
        // Main Loop
        while (!exit_flag) {
            longPoll.start();
        }
    } catch (exception& e) {
        std::cout << "Error: " << e.what() << std::endl;
    }

    destroy_perl(perl_int);
    return 0;
}
