//
//  DesToHexString.m
//  YNContactMgr
//
//  Created by wu youjian on 8/6/12.
//  Copyright (c) 2012 asiainfo-linkage. All rights reserved.
//

#import "DesCryptor.h"
#import "DesToHexString.h"

@implementation DesToHexString


+(NSString*)encrypt:(NSString*)encryptData withKey:(NSString*)key usePadding:(BOOL)used{
//    NSLog(@"befor encrypt:%@",encryptData);
	const char* dataBuffer = [encryptData UTF8String];
	const char* cipherBuffer = [key UTF8String];
	
	char* encryptedDataBuffer = NULL;
	size_t encryptedDataSize = 0;
	DesEncrypt(dataBuffer, strlen(dataBuffer), cipherBuffer, &encryptedDataBuffer, &encryptedDataSize, YES == used ? true : false);
	
	if (NULL != encryptedDataBuffer) {
		size_t encodeBufferSize = encryptedDataSize * 2;
		char* encodeBuffer = (char*)malloc(encodeBufferSize + 1);
		memset(encodeBuffer, 0x00, encodeBufferSize + 1);
		
		char* p = encodeBuffer;
		for (int i=0; i<encryptedDataSize; i++) {
			sprintf(p, "%02X", (unsigned char)encryptedDataBuffer[i]);
			
			p += 2;
		}
		free(encryptedDataBuffer);
		
		NSString* encryptedData = [NSString stringWithCString:encodeBuffer encoding:NSUTF8StringEncoding];
//        NSLog(@"en:%@",encryptedData);
		
		free(encodeBuffer);
        
        
//        NSLog(@"解密＝＝%@",[self decrypt:encryptedData withKey:des_key]);
//        NSLog(@"after encrypt:%@",[encryptedData dataUsingEncoding:NSUTF8StringEncoding]);
        return encryptedData;
	}
    
    return nil;
}

+(NSString*)decrypt:(NSString*)decryptData withKey:(NSString*)key{
	const char* encryptedDataBuffer = [decryptData UTF8String];
	
	size_t decodeBufferSize = strlen(encryptedDataBuffer) / 2;
	char* decodeBuffer = (char*)malloc(decodeBufferSize + 1);
	memset(decodeBuffer, 0x00, decodeBufferSize + 1);
	
	const char* p = encryptedDataBuffer;
	for (int i=0; i<decodeBufferSize; i++) {
		unsigned int byte = 0;
		sscanf(p, "%02X", &byte);
		decodeBuffer[i] = (unsigned char)byte;
		
		p += 2;
	}
	
	const char* cipherBuffer = [key UTF8String];
	
	char* dataBuffer = NULL;
	size_t dataBufferSize = 0;
	DesDecrypt(decodeBuffer, decodeBufferSize, cipherBuffer, &dataBuffer, &dataBufferSize);
	free(decodeBuffer);
	
	if (NULL != dataBuffer) {
		NSString* data = [NSString stringWithCString:dataBuffer encoding:NSUTF8StringEncoding];
       // NSLog(@"de:%@",data);
		
		free(dataBuffer);
        
        return data;
	}
    
    return nil;
}

@end
