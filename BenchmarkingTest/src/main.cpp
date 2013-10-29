#include <iostream>
#include <fstream>
#include <string>
#include <vector>
#include "RHExportLib.h"
#include "Exporter.hpp"


using namespace std;

class TestPair{
public:
    string test;
    HashType32 expectedResult;
};

int main(int argc, char** argv){

    if(argc!=2){
        cout<<argv[0]<<": "<<"Indique el archivo a usar"<<endl;
        exit(0);
    }

    fstream file;
    file.open(argv[1], ios::binary|ios::in );
    int code = 0;
    HashType32 seed;
    int numberOfTests = 0;
    file.read((char*)&code, 4);
    file.read((char*)&seed, 4);
    file.read((char*)&numberOfTests, 4);
    vector<TestPair> tests;
    tests.reserve(numberOfTests);   
    int testLen = 0;
    int maxURLLen = -1;
    for(size_t e = 0; e<numberOfTests;e++){        
        tests.resize(tests.size()+1);
        file.read( (char*)&tests[e].expectedResult, 4 );        
        file.read( (char*)&testLen, 4 );
        tests[e].test.resize(testLen);
        file.read( (char*)&tests[e].test[0], testLen );
        if(testLen>maxURLLen){
            maxURLLen = testLen;
        }
    }
    file.close();
    //Valores leidos
    
    cout<<"Test leidos("<<numberOfTests<<"):"<<endl;
    cout<<"Semilla de los hash: "<<seed<<endl;
    for(const auto& test:tests){
        cout<<"   HASH: "<<test.expectedResult<<", STRING: "<<test.test<<endl;
    }
    cout<<"Max URL Len: "<<maxURLLen<<endl;
    
}

