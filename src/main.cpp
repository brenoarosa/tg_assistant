#include <iostream>
#include <signal.h>
#include <stdio.h>
#include <exception>
#include <libconfig.h++>

#include <tgbot/tgbot.h>

#include <EXTERN.h>
#include <perl.h>

using namespace std;
using namespace libconfig;
using namespace TgBot;

static PerlInterpreter *my_perl;  /***    The Perl interpreter    ***/

bool sigintGot = false;


int main(int argc, char **argv, char **env) {

    Config keys;

    // Read the file. If there is an error, report it and exit.

    try {
        keys.readFile("keys.cfg");
    }
    catch(const FileIOException &fioex) {
        std::cerr << "I/O error while reading keys file." << std::endl;
        return 1;
    }
    catch(const ParseException &pex) {
        std::cerr << "Parse error at " << pex.getFile() << ":" << pex.getLine()
                << " - " << pex.getError() << std::endl;
        return 2;
    }

    string token = keys.lookup("token");
    std::cout << "Hello World, this is C++!" << std::endl;
    std::cout << "Telegram Token -> [" << token << "]" << std::endl;

    // Bot setup

    Bot bot(token);

    bot.getEvents().onCommand("start", [&bot](Message::Ptr message) {
        bot.getApi().sendMessage(message->chat->id, "Hi!");
    });

    bot.getEvents().onUnknownCommand([&bot](Message::Ptr message) {
        bot.getApi().sendMessage(message->chat->id, "Sorry, I don't understand your command.");
    });

    bot.getEvents().onNonCommandMessage([&bot](Message::Ptr message) {
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

    // Main Loop
    signal(SIGINT, [](int s) {
        printf("SIGINT got");
        sigintGot = true;
    });

    try {
        printf("Bot username: %s\n", bot.getApi().getMe()->username.c_str());

        TgLongPoll longPoll(bot);
        while (!sigintGot) {
            longPoll.start();
        }
    } catch (exception& e) {
        printf("error: %s\n", e.what());
    }

    /*
    PERL_SYS_INIT3(&argc,&argv,&env);
    my_perl = perl_alloc();
    perl_construct(my_perl);
    PL_exit_flags |= PERL_EXIT_DESTRUCT_END;
    perl_parse(my_perl, NULL, argc, argv, (char **)NULL);
    perl_run(my_perl);
    perl_destruct(my_perl);
    perl_free(my_perl);
    PERL_SYS_TERM();
    */

    return 0;
}
