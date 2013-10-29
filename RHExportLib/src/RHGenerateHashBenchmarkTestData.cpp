#include "ExportResult.hpp"
#include <vector>
#include <fstream>
#include <iostream>

using namespace std;


void generateHashBenchmarkTestData(
    const ResultPackage& pack, 
    const ExportResultStats& stats, 
    const ExportOptions& opts 
){
    
    int code = 1;//hash typo Murmur3
    const int nTuplas = pack.listOfURLs.size();
    ofstream file;
    file.open(opts.HashGenerationBenchMarkFile, ios::out|ios::binary|ios::trunc);
    file.write((char*)&code, 4 );
    file.write((char*)&stats.exportSeed, 4 );
    file.write((char*)&nTuplas, 4 );    
    cout<<"generateHashBenchmarkTestData: Numero de tuplas a exportar: "<<nTuplas<<endl;
    for(size_t i = 0; i<nTuplas; i++){
        const auto& tupla = pack.listOfURLs[i];       
        int lengthOfUrl = tupla.url.length();
        file.write((char*)&tupla.hash, 4);
        file.write((char*)&lengthOfUrl, 4);
        file.write((char*)tupla.url.c_str(), lengthOfUrl);
    }
        
    file.flush();
    file.close();
    
}