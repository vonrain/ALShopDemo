//
//  DesCryptor.h
//  iOSLab
//
//  Created by mccoy on 11/10/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#ifndef __DES_CRYPTOR_H_
#define __DES_CRYPTOR_H_

#import <sys/types.h>

void DesEncrypt(const char* data, size_t dataSize, const char* cipher, char** encryptedData, size_t* encryptedDataSize, bool usePadding);
void DesDecrypt(const char* encryptedData, size_t encryptedDataSize, const char* cipher, char** data, size_t* dataSize);


#endif // __DES_CRYPTOR_H_
