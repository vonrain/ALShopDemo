//
//  HttpConnector.h
//  libHttpConnector
//
//  Created by wuyoujian on 06/26/12.
//  Copyright (c) 2012 asiainfo-linkage. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MessageDelegate.h"


@class ASIFormDataRequest;

@interface HttpConnector : NSObject {
	NSString* serviceUrl;
	CFAbsoluteTime lastActionTime;
	int timeout;
	
	id statusDelegate;
    
    NSString*			receiveString;
	NSData*				receiveData;
    
    ASIFormDataRequest* httpRequest;
}

@property(nonatomic,retain)NSString* serviceUrl;
@property(nonatomic,assign)int timeout;
@property(nonatomic,assign)id statusDelegate;
@property(nonatomic,retain)NSString*    receiveString;
@property(nonatomic,retain)NSData*		receiveData;
@property(nonatomic,retain)ASIFormDataRequest* httpRequest;
@property(nonatomic,assign)BOOL allowCompressed;
@property(nonatomic,assign)BOOL isPostXML;


+ (id)sharedHttpConnector;
-(void)cancelRequest;

- (void)sendMessage:(id <MessageDelegate>)message synchronously:(BOOL)isSynchronous SessionId:(NSString *)SessionStr;

- (void)sendMessage_static:(id <MessageDelegate>)message xmlFile:(NSString*)file;

- (void)uploadPhotoMessage:(id <MessageDelegate>)message synchronously:(BOOL)isSynchronous SessionId:(NSString *)SessionStr PostKey:(NSString*)postKey;


@end
