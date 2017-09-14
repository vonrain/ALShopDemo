//
//  DesCryptor.cpp
//  iOSLab
//
//  Created by mccoy on 11/10/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <stdlib.h>
#import <string.h>
#import <stdio.h>
#import <CommonCrypto/CommonCryptor.h>
#import "DesCryptor.h"


void DesEncrypt(const char* data, size_t dataSize, const char* cipher, char** encryptedData, size_t* encryptedDataSize, bool usePadding) {
	if (NULL != data && NULL != cipher) {
		size_t blockCount = 0;
		blockCount = dataSize / 8 + 1;
		
		size_t bufferSize = blockCount * 8;
		char* buffer = (char*)malloc(bufferSize);
		memset(buffer, 0x00, bufferSize);
		
		char iv[8] = "\0";
		for (int i=0; i<blockCount; i++) {
			char dataBlock[8 + 1] = "\0";
			
			memcpy(dataBlock, data + i * 8, 8);
			
			if (blockCount-1 == i && true == usePadding) {
				int paddingValue = blockCount * 8 - dataSize;
				if (0 < paddingValue && 8 > paddingValue) {
					memset(dataBlock+(8-paddingValue), paddingValue, paddingValue);
				}else if(paddingValue == 8){
                    memset(dataBlock+(8-paddingValue), 0x00, paddingValue);
                }
			}
			
			size_t encryptedBlockSize = 0;
			if (kCCSuccess == CCCrypt(kCCEncrypt,
									  kCCAlgorithmDES,
									  kCCOptionECBMode,
									  cipher,
									  8,
									  iv,
									  dataBlock,
									  8,
									  buffer + i * 8,
									  8,
									  &encryptedBlockSize)) {
			} else {
				break;
			}
		}
		
		if (NULL != encryptedData) {
			*encryptedData = buffer;
		}
		
		if (NULL != encryptedDataSize) {
			*encryptedDataSize = bufferSize;
		}
	}
}


void DesDecrypt(const char* encryptedData, size_t encryptedDataSize, const char* cipher, char** data, size_t* dataSize) {
	if (NULL != encryptedData && NULL != cipher) {
		size_t blockCount = encryptedDataSize / 8;
		
		size_t bufferSize = blockCount * 8;
		char* buffer = (char*)malloc(bufferSize + 1);
		memset(buffer, 0x00, bufferSize + 1);
		
		size_t __dataSize = 0;
		
		char iv[8] = "\0";
		for (int i=0; i<blockCount; i++) {
			char encryptedDataBlock[8] = "\0";
			memcpy(encryptedDataBlock, encryptedData + i * 8, 8);
			
			size_t blockSize = 0;
			if (kCCSuccess == CCCrypt(kCCDecrypt,
									  kCCAlgorithmDES,
									  kCCOptionECBMode,
									  cipher,
									  8,
									  iv,
									  encryptedDataBlock,
									  8,
									  buffer + i * 8,
									  8,
									  &blockSize)) {
				
				__dataSize += blockSize;
			} else {
				break;
			}
		}
		
		int paddingValue = 0;
		if (8 >= (paddingValue = buffer[__dataSize - 1])) {
			__dataSize -= paddingValue;
			
			buffer[__dataSize] = '\0';
		}
		
		if (NULL != data) {
			*data = buffer;
		}
		
		if (NULL != dataSize) {
			*dataSize = __dataSize;
		}
	}
}
