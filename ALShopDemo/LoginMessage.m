//
//  LoginMessage.m
//  EsayBuy
//
//  Created by 颜 梁坚 on 13-8-20.
//  Copyright (c) 2013年 asiainfo-linkage. All rights reserved.
//

#import "LoginMessage.h"
#import "GTMBase64.h"
#import "UIDevice-Hardware.h"

@implementation LoginMessage


- (NSString *)getRequest
{
    NSDictionary *headerData = [[NSDictionary alloc] initWithObjectsAndKeys:LOGIN_BIZCODE,@"bizCode",nil];
    
    UIDevice* iDevice = [UIDevice currentDevice];
	NSString* model = [ComponentsFactory filterSpace:[iDevice localizedModel]];
	NSString* udid = [ComponentsFactory getUUID];
    
	NSString* BundleVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    
    NSString *usercode = [self.requestInfo objectForKey:@"usercode"];
    NSString *pwd = [self.requestInfo objectForKey:@"pwd"];
    float version = [[[UIDevice currentDevice] systemVersion] floatValue];

    bussineDataService *bus=[bussineDataService sharedDataService];
    NSString *remarkS=[[NSString alloc] initWithFormat:@"{\"IOS_version\":\"%lf\",\"Device\":\"%@\",\"App_version\":\"%@\",\"width\":\"%lf\",\"height\":\"%lf\",\"token\":\"%@\"}",version,[[UIDevice currentDevice] platformString],BundleVersion,[UIScreen mainScreen].bounds.size.width,[UIScreen mainScreen].bounds.size.height,bus.DeviceToken];
//    NSLog(@"~~~~~上传的报文%@",remarkS);
    
    NSString *requestClass = [[NSString alloc] initWithFormat:JSON_BODY_REUEST,[LOGIN_BIZCODE uppercaseString]];
    NSDictionary *bodyData = [[NSDictionary alloc] initWithObjectsAndKeys:
                              [self.requestInfo objectForKey:@"expand"]==nil?[NSNull null]:[self.requestInfo objectForKey:@"expand"],@"expand",
                              requestClass,@"@class",
                              USER_SVC,@"svc",
                              usercode,@"usercode",
                              [GTMBase64 stringByEncodingData:[LoginMessage geteSHAEncryptedPaylod:pwd]],@"pwd",
                              bus.DeviceToken==nil?@"":bus.DeviceToken,@"imsi",
                              udid,@"imei",
                              BundleVersion,@"version",
                              USER_BRAND,@"brand",
                              @"1",@"os",
                              remarkS,@"remark",
                              model,@"model",nil];
    
    NSString *requestStr = [self getRequestJSONFromHeader:headerData
                                                 withBody:bodyData];
    MyLog(@"登录报文:%@",requestStr);
	return [message hexStringDes:requestStr withEncrypt:YES];
}


-(void)parseOther
{
    [super parseOther];
    [self parseMessage];
}

- (void)parseResponse:(NSString *)responseMessage
{
    [self parse:responseMessage];
}

+ (NSString*)getBizCode
{
    return LOGIN_BIZCODE;
}

- (NSString*)getBusinessCode
{
	return LOGIN_BIZCODE;
}

-(void)parseMessage
{
    //需要解析在此处解析
//    NSArray *keyArray = [[NSArray alloc] initWithObjects:nil];
//    if (self.rspInfo != nil && [self.rspInfo isKindOfClass:[NSDictionary class]]) {
//        NSMutableDictionary *rInfo = [[NSMutableDictionary alloc] initWithCapacity:0];
//        NSInteger cnt = [keyArray count];
//        for (int i=0; i<cnt; i++) {
//            NSString *keyStr = [keyArray objectAtIndex:i];
//            NSString *valueStr = [rspInfo objectForKey:keyStr];
//            if (valueStr) {
//                [rInfo setObject:valueStr forKey:keyStr];
//            }
//        }
//        if ([rInfo count] > 0) {
//            self.rspInfo = rInfo;
//        }
//        [rInfo release];
//    }
//    [keyArray release];
}

@end
