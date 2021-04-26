#include <iostream>
#include <string.h>
#include <zlib.h>

#include "datafile.h"
#include "filestream.h"

using namespace std;

DataFile * _compress(DataFile * df, int level);

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

    DataFile * outputFile = _compress(inputFile, 5);

    FileOutputStream * os = new FileOutputStream(pszOutputFilename);

    os->open();
    os->write(outputFile);
    os->close();

    delete inputFile;
    delete outputFile;
    delete is;
    delete os;

    return 0;
}

DataFile * _compress(DataFile * df, int level)
{
    uint8_t *          outputData;
    uint32_t           outputDataLength;
    int                zlib_err;

    outputDataLength = df->getDataLength();

    outputData = (uint8_t *)malloc(outputDataLength);

    zlib_err = compress2(
                    outputData, 
                    (uLongf *)&outputDataLength, 
                    df->getData(), 
                    (uLongf)df->getDataLength(), 
                    level);

    if (zlib_err != Z_OK) {
        cout << "zlib returned " << zlib_err << endl;
        return NULL;
    }

    DataFile * compressedFile = new DataFile(outputData, outputDataLength);

    return compressedFile;
}
