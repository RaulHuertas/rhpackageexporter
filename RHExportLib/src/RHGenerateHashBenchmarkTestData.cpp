#include "ExportResult.hpp"
#include <vector>
#include <fstream>
#include <iostream>
#include <sstream>

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
    std::vector<std::string> urls;
    for(size_t i = 0; i<nTuplas; i++){
        const auto& tupla = pack.listOfURLs[i];       
        int lengthOfUrl = tupla.url.length();
        file.write((char*)&tupla.hash, 4);
        file.write((char*)&lengthOfUrl, 4);
        
        //file.write((char*)tupla.url.c_str(), lengthOfUrl);
        urls.push_back(tupla.url);
    }
    
    for(size_t i = 0; i<nTuplas; i++){        
        file.write((char*)urls[i].c_str(), urls[i].length() );    
    }
    
    file.flush();
    file.close();
    
    ostringstream hashsArray;
    hashsArray<<"constant simulationSeed : std_logic_vector(31 downto 0) := x\"";
    hashsArray.fill('0');
    hashsArray.width(sizeof(HashType32)*2);
    hashsArray<<std::hex<<stats.exportSeed<<"\";\r\n";
    hashsArray<<"constant nTuplas : std_logic_vector(31 downto 0) := x\"";
    hashsArray.fill('0');
    hashsArray.width(sizeof(HashType32)*2);
    hashsArray<<std::hex<<nTuplas<<"\";\r\n";
    hashsArray<<std::dec;
    hashsArray<<"type referencesArray_t is array (0 to ";
    hashsArray<<(nTuplas-1);
    hashsArray<<") of std_logic_vector(31 downto 0);\r\n";
    //Grabar lso resultados de referencia
    hashsArray<<"constant resultsBank : referencesArray_t := ( ";
    for(size_t i = 0; i<nTuplas; i++){
        const auto& tupla = pack.listOfURLs[i];  
        hashsArray<<"x\"";
        hashsArray.fill('0');
        hashsArray.width(sizeof(HashType32)*2);
        hashsArray<<std::hex<<tupla.hash;
        hashsArray<<"\"";
        if(i!=(nTuplas-1)){
            hashsArray<<",";
        }
    }    
    hashsArray<<");\r\n";
    //Grabar las longitudes de cada referencia
    hashsArray<<"constant entrysLengths : referencesArray_t := ( ";
    int totalBytesToTest = 0;
    for(size_t i = 0; i<nTuplas; i++){
        const auto& tupla = pack.listOfURLs[i];  
        hashsArray<<"x\"";
        hashsArray.fill('0');
        hashsArray.width(sizeof(HashType32)*2);
        totalBytesToTest+=tupla.url.length();
        hashsArray<<std::hex<<tupla.url.length();
        hashsArray<<"\"";
        if(i!=(nTuplas-1)){
            hashsArray<<",";
        }
    }    
    hashsArray<<");\r\n";
    //Grabar el array de datos
    hashsArray<<"type referencesDataArray_t is array (0 to ";
    hashsArray<<std::dec;
    hashsArray<<(totalBytesToTest-1);
    hashsArray<<") of std_logic_vector(7 downto 0);\r\n";
    hashsArray<<"constant dataBank : referencesDataArray_t := ( ";
    int byteStored = 0;
    for(size_t i = 0; i<nTuplas; i++){
        const auto& tupla = pack.listOfURLs[i];  
        for(size_t b = 0; b<tupla.url.length(); b++){
            hashsArray<<"x\"";
            hashsArray.fill('0');
            hashsArray.width(sizeof(unsigned char)*2);
            //totalBytesToTest+=tupla.url.length();
            hashsArray<<std::hex<<(unsigned int)tupla.url[b];
            hashsArray<<"\"";
            if(byteStored!=(totalBytesToTest-1)){
                hashsArray<<",";
            }   
            byteStored++;
        }
    }    
    hashsArray<<");\r\n";
    hashsArray<<"\r\n";
    
    
    string ResultVCA = hashsArray.str();
    //cout<<"ResultVCA: "<<ResultVCA<<endl;
    //cout<<"ResultVCA_File: "<<opts.HashGenerationBenchMarkFile_VHDL_Code_Array<<endl;
    ofstream fileVCA;
    fileVCA.open(opts.HashGenerationBenchMarkFile_VHDL_Code_Array, ios::out|ios::trunc);
    //fileVCA.write(ResultVCA.c_str(),ResultVCA.length());
    fileVCA<<ResultVCA;
    fileVCA.close();
    
}