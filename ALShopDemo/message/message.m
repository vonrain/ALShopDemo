//
//  message.m
//  
//

#import "message.h"
#import <CommonCrypto/CommonDigest.h>
#import "DesToHexString.h"
#import "ComponentsFactory.h"
#import "ASI/ASIHTTP.h"
#import "GTMBase64.h"
//#import "JSONKit.h"



//这些私有接口，具体的项目要对应修改
@interface message (private)
@end

@implementation message

@synthesize jsonRspData;
@synthesize rspCode;
@synthesize rspDesc;
@synthesize rspInfo;
@synthesize requestInfo;
@synthesize bizCode;
@synthesize responseInfo;

@synthesize compressed;
@synthesize responseCompressed;

-(id)init
{
    if (self = [super init])
    {
    }
    return self;
}


#pragma mark -
#pragma mark help
+(NSData *) geteSHAEncryptedPaylod:(NSString *)message{
    
    const char *cStr = [message UTF8String];
    unsigned char result[CC_SHA1_DIGEST_LENGTH];
    CC_SHA1(cStr, strlen(cStr), result);
//    NSString *s = [NSString stringWithFormat: @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X", result[0], result[1], result[2], result[3], result[4], result[5], result[6], result[7], result[8], result[9], result[10], result[11], result[12], result[13], result[14], result[15], result[16], result[17], result[18], result[19] ];
    NSData *shaRes = [NSData dataWithBytes:result length:CC_SHA1_DIGEST_LENGTH];
    return shaRes;
}

+(NSString*)md5Encode:(NSString*)str
{
    const char *cStr = [str UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5( cStr, strlen(cStr), result );
    NSString *string = [NSString stringWithFormat:
						@"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
						result[0], result[1], result[2], result[3], result[4], result[5], result[6], result[7],
						result[8], result[9], result[10], result[11], result[12], result[13], result[14], result[15]
						];
    return [string lowercaseString];
}

+(NSString*)getDeviceCode
{
    NSString* macAdrr = [ComponentsFactory MacAddress];
    NSString* md5Adrr = [message md5Encode:macAdrr];
    
    return  md5Adrr;
}


+(NSString*)hexStringDes:(NSString*)str withEncrypt:(BOOL)bEncrypt{
    NSString* returnStr = nil;
    if (bEncrypt) {
        return [DesToHexString encrypt:[str stringByReplacingOccurrencesOfString:@"\n" withString:@""] withKey:des_key usePadding:YES];
    }else {
        return [DesToHexString decrypt:[str stringByReplacingOccurrencesOfString:@"\n" withString:@""] withKey:des_key];
    }
    
    return  returnStr;
}

#pragma mark -
#pragma mark implementation


#pragma mark -
#pragma mark 解析返回报文内容
+(NSString*)getRespondDescription:(NSString*)resCode
{
	NSDictionary* codeAndDes = [NSDictionary dictionaryWithObjectsAndKeys:
								@"正确",					@"0000",
								@"用户名不存在",			@"0001",
								@"密码错误",				@"0002",
								@"无权限",				@"0003",
								@"版本过低",				@"0004",
								@"手机挂失",				@"0005",
								@"服务器内部错误",			@"0006",
								@"访问异常",				@"0007",
								@"业务不存在",			@"0008",
								@"SessionID过期",		@"0009",
								@"数据错误",				@"0010",
								@"未知错误",				@"9999",
								@"网络连接错误",			@"8888",
								@"连接超时",				@"5555",
                                @"服务器报文异常",			@"6666",
                                @"可选升级",              @"7777",
                                @"检测版本异常",           @"4444",
								nil];
	
	NSArray* keys = [codeAndDes allKeys];
	for (NSString* key in keys) {
		if ([key isEqualToString:resCode]) {
			NSString* desc = [NSString stringWithString:[codeAndDes objectForKey:key]];
			return desc;
		}
	}
	
	NSString* desc = [NSString stringWithString:[codeAndDes objectForKey:@"9999"]];
	return desc;
}

+(NSString*)getNetLinkErrorCode{
    return @"8888";
}


+(NSString*)getTimeOutErrorCode{
    return @"5555";
}


- (void)parseOther{
}

-(void)parseMessage{
}

- (BOOL)isHouTai{
    if([requestInfo objectForKey:@"isHouTai"]==nil){
        return NO;
    }else
        return [[requestInfo objectForKey:@"isHouTai"] boolValue];
}

- (void)parse:(NSString *)responseMessage {
    NSString* responseStr = nil;
#ifdef STATIC_XML
    responseStr = responseMessage;
#else
    //可以进行解密
    MyLog(@"解密开始+========================");

    responseStr = responseMessage;
    responseStr = [message hexStringDes:responseMessage withEncrypt:NO];
#endif
//    NSLog(@"responseStr=%@",responseStr);
    MyLog(@"解密结束+========================");

	if (nil != responseMessage) {
        self.responseInfo = responseStr;
		NSData* responseData = [responseStr dataUsingEncoding:NSUTF8StringEncoding];
		if (nil != responseData) {
            //解析应答报文
            NSMutableDictionary *dic = nil;
            dic = [NSJSONSerialization JSONObjectWithData:responseData
                                                  options:NSJSONReadingMutableContainers
                                                    error:nil];
            
            
            MyLog(@"====================== 服务端返回的data：%@  \n ================",dic);

            MyLog(@"JSON转换 结束 \n 服务端返回数据  %@",dic);
            
            self.jsonRspData = dic;
			[self parseRspcodeSubItemsToRspInfo];
            [self parseOther];
		}
	}
}

/*解析1级结构*/
-(void)parseRspcodeSubItemsToRspInfo
{
    NSDictionary *tempDict = [self.jsonRspData objectForKey:@"body"];
	self.rspInfo = tempDict;
}


- (NSString *)getJSONHeader:(NSDictionary *)headData
{
    
    MyLog(@"服务端head  %@",headData);
    
    NSString *biz_Code = [headData objectForKey:@"bizCode"];
    self.bizCode = biz_Code;
    NSString *headerJSON = [NSString stringWithFormat:JSON_HEADER,biz_Code];
    return headerJSON;
}

- (NSString *)getRequestJSONFromHeader:(NSDictionary *)headDic withBody:(NSDictionary *)bodyDic
{
    //组装JSON header节点
    NSString *headJSON = [self getJSONHeader:headDic];
    
    //组装JSON body节点
    NSData *bodyData = nil;
    
    if ([NSJSONSerialization isValidJSONObject:bodyDic]) {
        NSError *error;
        bodyData = [NSJSONSerialization dataWithJSONObject:bodyDic
                                                   options:NSJSONWritingPrettyPrinted
                                                     error:&error];
    }
    
    NSString *bodyJSON = [[NSString alloc] initWithData:bodyData
                                               encoding:NSUTF8StringEncoding];
    
//    NSLog(@"%@",bodyJSON);
    NSString *requestJSON = [NSString stringWithFormat:JSON_TEMP,headJSON,bodyJSON];
    
    return requestJSON;
}

-(NSString *)getRspcode
{
    if (self.jsonRspData == nil) {
        self.rspCode = @"6666";
		return self.rspCode;
    }
    
	NSDictionary *json_respon_header = [self.jsonRspData objectForKey:@"header"];
	if ([json_respon_header count] == 0) {
		self.rspCode = @"0010";
		return self.rspCode;
	}
	self.rspCode = [json_respon_header objectForKey:@"respCode"];
	return self.rspCode;
}

-(NSString *)getMSG
{
    NSDictionary *json_respon_header = [self.jsonRspData objectForKey:@"header"];
	self.rspDesc = [json_respon_header objectForKey:@"respMsg"];
	return self.rspDesc;
}

+ (NSString*)getBizCode
{
    return nil;
}

#pragma mark -
#pragma mark MessageDelegate
#pragma 不要使用基类message做业务
- (NSString*)getBusinessCode
{
    return @"000000";
}

- (NSString*)getRequest
{
    return @"";
}

- (NSString*)getWaitMessage
{
    return @"";
}

- (void)parseResponse:(NSString*)responseMessage
{
}

@end
