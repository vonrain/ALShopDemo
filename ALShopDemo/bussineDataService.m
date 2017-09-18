//
//  bussineDataService.m


#import "bussineDataService.h"
#import "AppDelegate.h"
#import "MBProgressHUD.h"
#import "UIDevice-Reachability.h"
#import "DesToHexString.h"

#define SESSION_ID_KEY @"AIWEGKEY"
#define MAX_NETWORK_ACCESS 3

@implementation bussineDataService

@synthesize httpCnctor;
@synthesize sendMessageSelector;
@synthesize receiveString;
@synthesize sendDataDic;
@synthesize sendString;
@synthesize rspInfo;
@synthesize rspHouTaiInfo;
@synthesize rspStatInfo;
@synthesize rspAdInfo;
@synthesize rspAddrInfo;
@synthesize rspUserInfo;
@synthesize updateUrl;
@synthesize SelAddr;
@synthesize TaoCanArr;
@synthesize IsTuisong;
@synthesize TuiSongDic;
@synthesize DeviceToken;
@synthesize ShopSelectStr;
@synthesize IsHuanCun;
@synthesize LogInTime;
@synthesize DangqingqiuStr;
@synthesize ISNotHouTaiStr;
@synthesize serversUrl;


- (void)cleanAllService {
    self.IsTuisong = NO;
    self.rspAddrInfo = nil;
    self.rspAdInfo = nil;
    self.rspStatInfo = nil;
    self.rspUserInfo = nil;
    self.rspInfo = nil;
    self.IsHuanCun= NO;
//    self.httpCnctor.serviceUrl = nil;
    self.isFirstSearch = NO;
    self.serversUrl = service_url;
    [self.httpCnctor cancelRequest];
    

}

#pragma mark -
#pragma mark bussineDataService inferface

// 单实例模式
static bussineDataService *sharedBussineDataService = nil;

+(bussineDataService*)sharedDataService {
    
    @synchronized ([bussineDataService class]) {
        if (sharedBussineDataService == nil) {
			sharedBussineDataService = [[bussineDataService alloc] initShared];
            return sharedBussineDataService;
        }
    }
    
    return sharedBussineDataService;
}

-(id)initShared
{
	if (self = [super init]) {
        HuanCunXinxiDic = [[NSMutableDictionary alloc] initWithCapacity:0];
		HttpConnector* _httpConnector = [[HttpConnector alloc] init];
        self.IsTuisong=NO;
        self.IsHuanCun=YES;
        self.SelAddr=0;
        _httpConnector.isPostXML = NO;
		_httpConnector.statusDelegate = self;
        _httpConnector.allowCompressed = YES;
        
        self.serversUrl = service_url;
        
		_httpConnector.serviceUrl = self.serversUrl;
        [_httpConnector setTimeout:120];
        [self setHttpCnctor:_httpConnector];
	}
	
	return self;
}

- (void)sharedSendMessage:(id <MessageDelegate>)msg synchronously:(BOOL)isSynchronous
{
    
    if (!self.httpCnctor.serviceUrl || ![self.httpCnctor.serviceUrl isEqualToString:[bussineDataService sharedDataService].httpCnctor.serviceUrl]) {
         self.httpCnctor.serviceUrl = [bussineDataService sharedDataService].httpCnctor.serviceUrl;
    }
    self.httpCnctor.serviceUrl = self.serversUrl;
    self.httpCnctor.allowCompressed = YES;

    NSDictionary *dictionary = [userDefault dictionaryRepresentation];
    NSString *sessionId = @"";
    
    if([[dictionary allKeys] containsObject:@"sessionId"] && [userDefault objectForKey:@"sessionId"] != [NSNull null] && [userDefault objectForKey:@"sessionId"] != nil && [userDefault objectForKey:@"sessionId"] != NULL && [[userDefault objectForKey:@"sessionId"] length] > 0) {
        
        sessionId = [NSString stringWithFormat:@"%@",[userDefault objectForKey:@"sessionId"]];
        
    }
    
    
    MyLog(@"请求的地址：%@   ----- sessionId：%@",self.httpCnctor.serviceUrl,sessionId);
    [self.httpCnctor sendMessage:msg synchronously:NO SessionId:sessionId];
}

-(NSDictionary*)handleRspInfo:(message *) msg
{
    
    NSString* rspCode = [msg getRspcode];
    NSString* bussineCode = msg.bizCode;
    
    NSString* rspDesc = [msg getMSG];
    //key: bussineCode value :; Key:errorCode, value: key:MSG, value:
    NSMutableDictionary* rspDic = [[NSMutableDictionary alloc] initWithCapacity:0];
    [rspDic setObject:msg forKey:@"MESSAGE_OBJECT"];
    [rspDic setObject:rspCode forKey:@"errorCode"];
    [rspDic setObject:bussineCode forKey:@"bussineCode"];
    if (rspDesc != nil) {
        [rspDic setObject:rspDesc forKey:@"MSG"];
    }
    
    if ([rspCode isEqualToString:@"0001"]) {
        
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"提示"
                                                            message:@"登录超时，请重新登录！"//Session 过期
                                                           delegate:self
                                                  cancelButtonTitle:@"确定"
                                                  otherButtonTitles:nil];
        alertView.tag = kSessionTimeOutTag;
        [alertView show];
        return nil;
    }
    
    return rspDic;
}

-(void)noticeUI:(NSDictionary*)rspDic
{
    if (rspDic == nil) {
        return;
    }
    NSString* rspCode = [rspDic objectForKey:@"errorCode"];
    id<MessageDelegate> msg = [rspDic objectForKey:@"MESSAGE_OBJECT"];
    
    if ([rspCode isEqualToString:@"0001"]) {
        
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"提示"
                                                            message:@"Session 过期，请重新登陆！"
                                                           delegate:self
                                                  cancelButtonTitle:@"确定"
                                                  otherButtonTitles:nil];
        alertView.tag = kSessionTimeOutTag;
        [alertView show];
        return;
    }
    
    if([rspCode isEqualToString:@"0000"]){
        {
            if (nil != self.target && [self.target respondsToSelector:@selector(requestDidFinished:)]) {
                [self.target performSelector:@selector(requestDidFinished:) withObject:rspDic];
            }
        }
    }
    else {
        if ([rspDic[@"errorCode"] isEqualToString:@"9999"]) {
            if (nil != self.target && [self.target respondsToSelector:@selector(requestFailed:)]) {
                [self.target performSelector:@selector(requestFailed:) withObject:rspDic];
            }
            return;
        }
    }
}

- (void)readySharedSendMessage:(NSString*)messageClaseName
                         param:(NSDictionary*)parameters
                       funName:(NSString*)funName
                 synchronously:(BOOL)synchronously
{
    Class class =  NSClassFromString(messageClaseName);
    message* messageObject = (message*)[[class alloc] init];
    messageObject.requestInfo = parameters;
    
    /*保存请求*/
    self.DangqingqiuStr = [message hexStringDes:[messageObject getRequest] withEncrypt:NO];
    
    SEL selector = NSSelectorFromString(funName);
    [self setSendMessageSelector:selector];
    self.sendDataDic = parameters;
#ifdef MAX_NETWORK_ACCESS
    if(netWorkAccessTime == 0){
        netWorkAccessTime = MAX_NETWORK_ACCESS;
    } else {
        netWorkAccessTime--;
    }
    MyLog(@"Access net time:%d",netWorkAccessTime);
#endif
    [self sharedSendMessage:messageObject synchronously:synchronously];
}

#pragma mark
#pragma mark - 登录
- (void)login:(NSDictionary *)paramters
{
    if ([[UIDevice currentDevice] networkAvailable]) {
        [self readySharedSendMessage:@"LoginMessage"
                               param:paramters
                             funName:@"login:"
                       synchronously:NO];
    }
}

- (void)loginFinished:(id<MessageDelegate>)msg
{
    LoginMessage *Msg = msg;
    NSDictionary *rspDic = [self handleRspInfo:Msg];
    NSString* rspCode = [Msg getRspcode];
    if([rspCode isEqualToString:@"0000"]){
        self.rspUserInfo = Msg.rspInfo;
        [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%@",[self.rspUserInfo objectForKey:@"sessionId"]] forKey:@"sessionId"];
        [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%@",
                                                         [DesToHexString encrypt:[self.rspUserInfo objectForKey:@"sessionId"] withKey:SESSION_ID_KEY usePadding:YES]]
                                                         forKey:@"sessionId_encrypt"];
        
        [[NSUserDefaults standardUserDefaults] synchronize];
        self.rspInfo = Msg.rspInfo;
    }
    [self noticeUI:rspDic];
}

#pragma mark -
#pragma mark http 回调接口
- (void)requestDidFinished:(id<MessageDelegate>)msg
{
    netWorkAccessTime = 0;
    if ([[msg getBusinessCode] isEqualToString:LOGIN_BIZCODE]) {
        [self loginFinished:msg];
    }
}

- (void)requestFailed:(NSDictionary*)errorInfo
{
    MyLog(@"失败信息 %@",errorInfo);
    id<MessageDelegate> msg = [errorInfo objectForKey:@"MESSAGE_OBJECT"];
    
    NSString* errorCode = [errorInfo objectForKey:@"STATUS_CODE"];
    MyLog(@" 请求失败提示信息 %@",errorCode);
    NSString* bussineCode = [msg getBusinessCode];
    NSString* rspDesc = [message getRespondDescription:errorCode];
    
    NSMutableDictionary* rspDic = [[NSMutableDictionary alloc] initWithCapacity:0];
    [rspDic setObject:errorCode forKey:@"errorCode"];
    [rspDic setObject:bussineCode forKey:@"bussineCode"];
    if (rspDesc != nil) {
        [rspDic setObject:rspDesc forKey:@"MSG"];
    }
    
    if (([[message getNetLinkErrorCode] isEqualToString:errorCode] ||
         [[message getTimeOutErrorCode] isEqualToString:errorCode])&&
        netWorkAccessTime > 1) {
        //如果是网络连接错误，再重试两次
        if ([self respondsToSelector:sendMessageSelector]) {
            [self performSelector:sendMessageSelector withObject:sendDataDic];
        }
        return;
    }
    netWorkAccessTime = 0;
    if (nil != self.target && [self.target respondsToSelector:@selector(requestFailed:)]) {
        [self.target performSelector:@selector(requestFailed:) withObject:rspDic];
    }
    
    if ([[message getNetLinkErrorCode] isEqualToString:errorCode]) {
        
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"提示"
                                                            message:rspDesc
                                                           delegate:self
                                                  cancelButtonTitle:@"取消"
                                                  otherButtonTitles:@"重试",nil];
        alertView.tag = kLinkErrorTag;
        [alertView show];
        
        return;
    }
    
    if ([[message getTimeOutErrorCode] isEqualToString:errorCode]) {
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"提示"
                                                            message:rspDesc
                                                           delegate:self
                                                  cancelButtonTitle:@"取消"
                                                  otherButtonTitles:@"重试",nil];
        alertView.tag = kTimeOutErrorTag;
        [alertView show];
        
        return;
    }
}

@end
