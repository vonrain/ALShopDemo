//
//  MessageDelegate.h
//  libHttpConnector
//


#import <Foundation/Foundation.h>

@protocol MessageDelegate <NSObject>

@required

- (NSString*)getBusinessCode;
- (NSString*)getRequest;
- (void)parseResponse:(NSString*)responseMessage;
- (BOOL)isHouTai;

@end
