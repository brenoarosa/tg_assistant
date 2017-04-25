#include <iostream>
#include <libconfig.h++>

#include <EXTERN.h>
#include <perl.h>

using namespace std;
using namespace libconfig;

static PerlInterpreter *my_perl;  /***    The Perl interpreter    ***/

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

    string id = keys.lookup("id");
    string hash = keys.lookup("hash");
    std::cout << "Hello World, this is C++!" << std::endl;
    std::cout << "Telegram Token -> ID: [" << id << "]\tHash: [" << hash << "]" << std::endl;

    PERL_SYS_INIT3(&argc,&argv,&env);
    my_perl = perl_alloc();
    perl_construct(my_perl);
    PL_exit_flags |= PERL_EXIT_DESTRUCT_END;
    perl_parse(my_perl, NULL, argc, argv, (char **)NULL);
    perl_run(my_perl);
    perl_destruct(my_perl);
    perl_free(my_perl);
    PERL_SYS_TERM();

    return 0;
}
