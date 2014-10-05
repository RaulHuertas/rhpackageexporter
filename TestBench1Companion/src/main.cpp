#include "ExportOptions.hpp"
#include "Exporter.hpp"
#include "MurmurHasher.hpp"
#include "MurmurHash3.h"
#include "ExportResult.hpp"
#include <memory>
#include <cstdint>
#include <cstring>
using namespace std;



int main(int argc, char** argv){
    
    int dataMaxLen = 1024;
    std::unique_ptr<unsigned char[]> data(new unsigned char[dataMaxLen]);
    memset(data.get(), 0, dataMaxLen);
    
    std::uint32_t key = 0;
    std::uint32_t seed = 0;
    std::uint32_t salida = 0;
    int len = 4;
    cout<<"Probando 4 bytes 0-0-0-0"<<endl;
    cout<<"Seed = "<<hex<<seed<<endl;
    MurmurHash3_x86_32_Verbose(data.get(), 4, seed, &salida);
    cout<<"\033[22;32mResult: \033[22;30m"<<hex<<salida<<endl;
    
    cout<<"Probando 4 bytes 0-0-0-1"<<endl;
    data[0] = 1;
    cout<<"Seed = "<<hex<<seed<<endl;
    MurmurHash3_x86_32_Verbose(data.get(), 4, seed, &salida);
    cout<<"\033[22;32mResult: \033[22;30m"<<hex<<salida<<endl;
    
    cout<<"Probando 4 bytes 0-0-0-2"<<endl;
    data[0] = 2;
    cout<<"Seed = "<<hex<<seed<<endl;
    MurmurHash3_x86_32_Verbose(data.get(), 4, seed, &salida);
    cout<<"\033[22;32mResult: \033[22;30m"<<hex<<salida<<endl;
    
    cout<<"Probando 4 bytes 0-0-0-3"<<endl;
    data[0] = 3;
    cout<<"Seed = "<<hex<<seed<<endl;
    MurmurHash3_x86_32_Verbose(data.get(), 4, seed, &salida);
    cout<<"\033[22;32mResult: \033[22;30m"<<hex<<salida<<endl;
    
    memset(data.get(), 0, dataMaxLen);
    cout<<"Probando 4 bytes 0x80-0-0-0"<<endl;    
    data[3] = 0x80;
    cout<<"Seed = "<<hex<<seed<<endl;
    MurmurHash3_x86_32_Verbose(data.get(), 4, seed, &salida);
    cout<<"\033[22;32mResult: \033[22;30m"<<hex<<salida<<endl;
    
    memset(data.get(), 0, dataMaxLen);
    cout<<"Probando 4 bytes 0x40-0-0-0"<<endl;    
    data[3] = 0x40;
    cout<<"Seed = "<<hex<<seed<<endl;
    MurmurHash3_x86_32_Verbose(data.get(), 4, seed, &salida);
    cout<<"\033[22;32mResult: \033[22;30m"<<hex<<salida<<endl;
    
    memset(data.get(), 0, dataMaxLen);
    cout<<"Probando 4 bytes 0xC0-0-0-0"<<endl;    
    data[3] = 0xC0;
    cout<<"Seed = "<<hex<<seed<<endl;
    MurmurHash3_x86_32_Verbose(data.get(), 4, seed, &salida);
    cout<<"\033[22;32mResult: \033[22;30m"<<hex<<salida<<endl;
    
    memset(data.get(), 0, dataMaxLen);
    cout<<"Probando 4 bytes 0x20-0-0-0"<<endl;    
    data[3] = 0x20;
    cout<<"Seed = "<<hex<<seed<<endl;
    MurmurHash3_x86_32_Verbose(data.get(), 4, seed, &salida);
    cout<<"\033[22;32mResult: \033[22;30m"<<hex<<salida<<endl;
    
    memset(data.get(), 0, dataMaxLen);
    cout<<"Probando 4 bytes 0xFF-0xFF-0xFF-0xFF"<<endl;    
    data[0] = 0xFFU;data[1] = 0xFFU;data[2] = 0xFFU;data[3] = 0xFFU;
    cout<<"Seed = "<<hex<<seed<<endl;
    MurmurHash3_x86_32_Verbose(data.get(), 4, seed, &salida);
    cout<<"\033[22;32mResult: \033[22;30m"<<hex<<salida<<endl;
    
    memset(data.get(), 0, dataMaxLen);
    cout<<"Probando 4 bytes 0xF0-0xF0-0xF0-0xF0"<<endl;    
    data[0] = 0xF0U;data[1] = 0xF0U;data[2] = 0xF0U;data[3] = 0xF0U;
    cout<<"Seed = "<<hex<<seed<<endl;
    MurmurHash3_x86_32_Verbose(data.get(), 4, seed, &salida);
    cout<<"\033[22;32mResult: \033[22;30m"<<hex<<salida<<endl;
    
    memset(data.get(), 0, dataMaxLen);
    cout<<"Probando 4 bytes 0x0F-0x0F-0x0F-0x0F"<<endl;    
    data[0] = 0x0F;data[1] = 0x0F;data[2] = 0x0F;data[3] = 0x0F;
    cout<<"Seed = "<<hex<<seed<<endl;
    MurmurHash3_x86_32_Verbose(data.get(), 4, seed, &salida);
    cout<<"\033[22;32mResult: \033[22;30m"<<hex<<salida<<endl;
    
    memset(data.get(), 0, dataMaxLen);
    cout<<"Probando 4 bytes 0xCC-0xCC-0xCC-0xCC"<<endl;    
    data[0] = 0x0F;data[1] = 0x0F;data[2] = 0x0F;data[3] = 0x0F;
    cout<<"Seed = "<<hex<<seed<<endl;
    MurmurHash3_x86_32_Verbose(data.get(), 4, seed, &salida);
    cout<<"\033[22;32mResult: \033[22;30m"<<hex<<salida<<endl;
    
    memset(data.get(), 0, dataMaxLen);
    cout<<"Probando 4 bytes 0xCC-0xCC-0xCC-0xCC"<<endl;    
    data[0] = 0xCC;data[1] = 0xCC;data[2] = 0xCC;data[3] = 0xCC;
    cout<<"Seed = "<<hex<<seed<<endl;
    MurmurHash3_x86_32_Verbose(data.get(), 4, seed, &salida);
    cout<<"\033[22;32mResult: \033[22;30m"<<hex<<salida<<endl;
    
    cout<<"PRUEBAS MULTIBYTE"<<endl;    
    cout<<"Probando 8 bytes 0xde-0xf9-0x62-0x23-0x2a-0x40-0xf1-0xfb"<<endl;    
    data[0] = 0xde;data[1] = 0xf9;data[2] = 0x62;data[3] = 0x23;
    data[4] = 0x2a;data[5] = 0x40;data[6] = 0xf1;data[7] = 0xfb;
    seed = 0;
    cout<<"Seed = "<<hex<<seed<<endl;
    MurmurHash3_x86_32_Verbose(data.get(), 8, seed, &salida);
    cout<<"\033[22;32mResult: \033[22;30m"<<hex<<salida<<endl;
    
    cout<<"Probando 12 bytes 0xde-0xf9-0x62-0x23-0x2a-0x40-0xf1-0xfb-0xab-0xcd-0x12-0x34"<<endl;    
    data[0] = 0xde;data[1] = 0xf9;data[2] = 0x62;data[3] = 0x23;
    data[4] = 0x2a;data[5] = 0x40;data[6] = 0xf1;data[7] = 0xfb;
    data[8] = 0xab;data[9] = 0xcd;data[10] = 0x12;data[11] = 0x34;
    seed = 0;
    cout<<"Seed = "<<hex<<seed<<endl;
    MurmurHash3_x86_32_Verbose(data.get(), 12, seed, &salida);
    cout<<"\033[22;32mResult: \033[22;30m"<<hex<<salida<<endl;
    
    cout<<"Probando 1 bytes 0xde"<<endl;    
    data[0] = 0xde;
    seed = 0;
    cout<<"Seed = "<<hex<<seed<<endl;
    MurmurHash3_x86_32_Verbose(data.get(), 1, seed, &salida);
    cout<<"\033[22;32mResult: \033[22;30m"<<hex<<salida<<endl;
    
    return 0;
}