//
//  DesToHexString.h
//  YNContactMgr
//
//  Created by wu youjian on 8/6/12.
//  Copyright (c) 2012 asiainfo-linkage. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DesToHexString : NSObject

+(NSString*)encrypt:(NSString*)encryptData withKey:(NSString*)key usePadding:(BOOL)used;
+(NSString*)decrypt:(NSString*)decryptData withKey:(NSString*)key;

@end
