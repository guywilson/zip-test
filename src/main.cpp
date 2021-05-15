#include <iostream>
#include <string.h>
#include <zlib.h>

#include "datafile.h"
#include "filestream.h"

using namespace std;

int main(int argc, char **argv)
{
    int             i;
    char *          pszInputFilename;
    char *          pszOutputFilename;

    if (argc > 1) {
        for (i = 1;i < argc;i++) {
            if (argv[i][0] == '-' && argv[i][1] == 'i') {
                pszInputFilename = strdup(&argv[i + 1][0]);
            }
            else if (argv[i][0] == '-' && argv[i][1] == 'o') {
                pszOutputFilename = strdup(&argv[i + 1][0]);
            }
        }
    }
    else {
        return -1;
    }

    FileInputStream * is = new FileInputStream(pszInputFilename);

    is->open();
    DataFile * inputFile = is->read();
    is->close();

    FileZippedOutputStream * os = new FileZippedOutputStream(pszOutputFilename);

    DataFile * outputFile = new DataFile(inputFile);

    os->open();
    os->write(outputFile);
    os->close();

    delete inputFile;
    delete outputFile;
    delete is;
    delete os;

    return 0;
}
