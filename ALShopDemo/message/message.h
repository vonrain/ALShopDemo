

#import <Foundation/Foundation.h>
#import "httpConnector/MessageDelegate.h"

#define JSON_BODY_REUEST   @"com.ailk.gx.mapp.model.req.%@Request"

#define JSON_TEMP @"{\"@class\":\"com.ailk.gx.mapp.model.GXCDatapackage\",\"header\":{%@},\"body\":%@}"

#define JSON_HEADER @"\"@class\":\"com.ailk.gx.mapp.model.GXCHeader\",\"bizCode\":\"%@\",\"identityId\":null,\"respCode\":null,\"respMsg\":null,\"mode\":\"1\",\"sign\":null"

#define JSON_RESPCODE    @"respCode"
#define JSON_RESPMSG     @"respMsg"

#define CGBASISREQUEST    @"CGBASIS"

@interface message : NSObject<MessageDelegate>{
	NSString* rspCode;
	NSString* rspDesc;
    
    NSString* responseInfo;
    
    NSDictionary *jsonRspData;
    
    //返回包体解析存储字典及发送包体字典
    NSDictionary *rspInfo;
    NSDictionary *requestInfo;
    NSString *requestH5Info;
    
    NSString* bizCode;
    
    BOOL compressed;
    BOOL responseCompressed;
    
}

@property(nonatomic, strong)NSDictionary *jsonRspData;
@property(nonatomic, strong)NSString* rspCode;
@property(nonatomic, strong)NSString* rspDesc;
@property(nonatomic, strong)NSDictionary *rspInfo;
@property(nonatomic, strong)NSDictionary *requestInfo;
//@property(nonatomic, retain)NSString *requestH5Info;
@property(nonatomic, strong)NSString* bizCode;
@property(nonatomic, strong)NSString* responseInfo;
@property(nonatomic, assign)BOOL compressed;
@property(nonatomic, assign)BOOL responseCompressed;


//公共解析部分
+(NSString*)getNetLinkErrorCode;
+(NSString*)getTimeOutErrorCode;
-(NSString*)getRspcode;
-(NSString*)getMSG;
+(NSString*)getRespondDescription:(NSString*)resCode;
//如果一个接口返回的报文只有第一级节点，可以调用此接口解析
//这样所有的数据都存储在：rspInfo中
-(void)parseRspcodeSubItemsToRspInfo;


- (void)parse:(NSString *)responseMessage;
//除了有第一级节点的报文，还有其他的报文，就必备重载这个函数
- (void)parseOther;
-(void)parseMessage;

//help
-(NSString *)getJSONHeader:(NSDictionary *)headData;
-(NSString *)getRequestJSONFromHeader:(NSDictionary *)headDic withBody:(NSDictionary *)bodyDic;
+(NSString*)getDeviceCode;
+(NSString*)getBizCode;
//加密
+(NSData *) geteSHAEncryptedPaylod:(NSString *)message;
+(NSString*)md5Encode:(NSString*)str;
+(NSString*)hexStringDes:(NSString*)str withEncrypt:(BOOL)bEncrypt;


@end
