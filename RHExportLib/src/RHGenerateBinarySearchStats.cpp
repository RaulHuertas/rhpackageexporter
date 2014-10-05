#include "ExportResult.hpp"
#include <vector>
#include <fstream>
#include <iostream>
#include <sstream>
#include <cstdint>
using namespace std;

std::uint32_t roundedUpPowerOfTwo(std::uint32_t x){
    x = x-1;
    x = x|(x>>1);
    x = x|(x>>2);
    x = x|(x>>4);
    x = x|(x>>8);
    x = x|(x>>16);
    return (x +1);
}

void  generateBinarySearchStats(
                    const ResultPackage& pack, 
                    const ExportResultStats& stats, 
                    const ExportOptions& opts 
){
    
    std::uint32_t numberOfEntries = pack.listOfURLs.size();
    std::uint32_t numberOfMemBloksToUse = roundedUpPowerOfTwo(numberOfEntries);
    cout<<"generateBinarySearchStats: Numero de tuplas: "<<numberOfEntries<<endl;
    cout<<"generateBinarySearchStats: Numero de memBlocks a usar: log2("<<numberOfMemBloksToUse<<")"<<endl;
    
    
}
