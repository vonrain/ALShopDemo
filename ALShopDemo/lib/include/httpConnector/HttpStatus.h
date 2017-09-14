//
//  HttpStatus.h
//  libHttpConnector
//
//  Created by wuyoujian on 06/26/12.
//  Copyright (c) 2012 asiainfo-linkage. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MessageDelegate.h"

@protocol HttpStatus <NSObject>

@optional
- (void)requestWillBeSent;
- (void)requestDidSend;
- (void)requestDidFinished:(id <MessageDelegate>)message;

//errorInfo: key:MESSAGE_OBJECT is id,key:STATUS_CODE is  string
- (void)requestFailed:(NSDictionary*)errorInfo;
//statusInfo: key:PERCENTAGE is NSNumber,key:SPEED is NSNumber
- (void)requestStatus:(NSDictionary*)statusInfo;


@end
