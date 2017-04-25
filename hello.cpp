#include <iostream>
#include <libconfig.h++>

using namespace std;
using namespace libconfig;

int main(int argc, char *argv[]) {

    Config keys;
    // Read the file. If there is an error, report it and exit.
    try {
        keys.readFile("keys.cfg");
    }
    catch(const FileIOException &fioex) {
        std::cerr << "I/O error while reading file." << std::endl;
        return 1;
    }
    catch(const ParseException &pex) {
        std::cerr << "Parse error at " << pex.getFile() << ":" << pex.getLine()
                << " - " << pex.getError() << std::endl;
        return 2;
    }

    string id = keys.lookup("id");
    string hash = keys.lookup("hash");
    std::cout << "Hello World!" << std::endl;
    std::cout << "ID: " << id << "\tHash: " << hash << std::endl;
    return 0;
}
