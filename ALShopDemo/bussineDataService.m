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

// 单实例模式
static bussineDataService *sharedBussineDataServiceOne = nil;
+(bussineDataService *) sharedDataServiceOne {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{

        sharedBussineDataServiceOne = [[bussineDataService alloc] initSharedTwo];
    });
    sharedBussineDataServiceOne.serversUrl = [bussineDataService sharedDataService].httpCnctor.serviceUrl;
    return sharedBussineDataServiceOne;

}
// 单实例模式
static bussineDataService *sharedBussineDataServiceTwo = nil;
+(bussineDataService *) sharedDataServiceTwo {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        sharedBussineDataServiceTwo = [[bussineDataService alloc] initSharedTwo];
    });
    sharedBussineDataServiceTwo.serversUrl = [bussineDataService sharedDataService].httpCnctor.serviceUrl;
    return sharedBussineDataServiceTwo;
}
// 单实例模式
static bussineDataService *sharedBussineDataServiceThree = nil;
+(bussineDataService *) sharedDataServiceThree {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        sharedBussineDataServiceThree = [[bussineDataService alloc] initSharedTwo];
    });
    sharedBussineDataServiceThree.serversUrl = [bussineDataService sharedDataService].httpCnctor.serviceUrl;
    return sharedBussineDataServiceThree;
    
}
// 单实例模式
static bussineDataService *sharedBussineDataServiceFour = nil;
+(bussineDataService *) sharedDataServiceFour {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        sharedBussineDataServiceFour = [[bussineDataService alloc] initSharedTwo];
    });
    sharedBussineDataServiceFour.serversUrl = [bussineDataService sharedDataService].httpCnctor.serviceUrl;
    return sharedBussineDataServiceFour;
    
}

// 单实例模式
static bussineDataService *sharedBussineDataServiceFive = nil;
+(bussineDataService *) sharedDataServiceFive {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        sharedBussineDataServiceFive = [[bussineDataService alloc] initSharedTwo];
    });
    sharedBussineDataServiceFive.serversUrl = [bussineDataService sharedDataService].httpCnctor.serviceUrl;
    return sharedBussineDataServiceFive;
    
}

// 单实例模式
static bussineDataService *sharedBussineDataServiceSix = nil;
+(bussineDataService *) sharedDataServiceSix {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        sharedBussineDataServiceSix = [[bussineDataService alloc] initSharedTwo];
    });
    sharedBussineDataServiceSix.serversUrl = [bussineDataService sharedDataService].httpCnctor.serviceUrl;
    return sharedBussineDataServiceSix;
    
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
        
        if ([[NSUserDefaults standardUserDefaults] objectForKey:@"userName"]) {
            NSString* str = [[NSString alloc] initWithString:[[NSUserDefaults standardUserDefaults] objectForKey:@"userName"]];
            if([str length]>3&&[[str substringToIndex:3] isEqualToString:@"QA_"]){
                self.serversUrl = QAservice_url;
                
                
            }else if([str length]>4&&[[str substringToIndex:4] isEqualToString:@"UAT_"]){
                self.serversUrl = UATservice_url;
                
            }else if([str length]>4&&[[str substringToIndex:4] isEqualToString:@"DEV_"]){
               self.serversUrl  = [[NSUserDefaults standardUserDefaults] objectForKey:@"DEVurlServer"] != nil ? [[NSUserDefaults standardUserDefaults] objectForKey:@"DEVurlServer"] : DEVservice_url;
                
            }else{
                self.serversUrl = service_url;
            }
        }else{
            self.serversUrl = service_url;
        }

		_httpConnector.serviceUrl = self.serversUrl;
        [_httpConnector setTimeout:120];
        [self setHttpCnctor:_httpConnector];
	}
	
	return self;
}

-(id)initSharedTwo
{
    if (self = [super init]) {
        HuanCunXinxiDic = [[NSMutableDictionary alloc] initWithCapacity:0];
        HttpConnector* _httpConnector = [[HttpConnector alloc] init];
        self.IsTuisong=NO;
        self.IsHuanCun=YES;
        self.SelAddr=0;
        _httpConnector.serviceUrl = [bussineDataService sharedDataService].httpCnctor.serviceUrl;
        self.serversUrl = [bussineDataService sharedDataService].httpCnctor.serviceUrl;
        _httpConnector.isPostXML = NO;
        _httpConnector.statusDelegate = self;
        _httpConnector.allowCompressed = YES;
        [_httpConnector setTimeout:120];
        [self setHttpCnctor:_httpConnector];
    }
    
    return self;
}

-(void)wait:(NSTimer*)time
{
    NSString* str = [[NSString alloc] initWithString:(NSString*)time.userInfo];
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
   
    
    if([msg isHouTai]){
#ifdef STATIC_XML
        NSString* xmlFile = [[NSString alloc] initWithString:[[NSBundle mainBundle]
                                                              pathForResource:[msg getBusinessCode]
                                                              ofType:@"json"]];
        
        [self.httpCnctor sendMessage_static:msg xmlFile:xmlFile];
        [xmlFile release];
#else
        MyLog(@"请求的地址：%@   ----- sessionId：%@",self.httpCnctor.serviceUrl,sessionId);
        [self.httpCnctor sendMessage:msg synchronously:NO SessionId:sessionId];
#endif
    }
    else{
        
        UIViewController *myView = nil;
        if ([[self.sendDataDic allKeys] containsObject:@"Fist"]) {
        }
        else{
            
            if (self.sendMessageSelector == NSSelectorFromString(@"sendH5Request:") && self.isFirstSearch) {
                self.isFirstSearch = NO;
            }else
                
                if ([[self.sendDataDic allKeys] containsObject:@"woeogBank"]) {
                    [YHLoadingView showWithView:[[self.sendDataDic allKeys] containsObject:@"myView"] ? [self.sendDataDic [@"myView"] view] : [AppDelegate shareMyApplication].window];
                    
                }
                else{
                    
                    [YHLoadingView showWithView:[[self.sendDataDic allKeys] containsObject:@"myView"] ? [self.sendDataDic [@"myView"] view] : [AppDelegate shareMyApplication].window image:[UIImage imageNamed:@"loadImage"]];
                }
        }
        
        
        
#ifdef STATIC_XML
        NSString* xmlFile = [[NSString alloc] initWithString:[[NSBundle mainBundle]
                                                              pathForResource:[msg getBusinessCode]
                                                              ofType:@"json"]];
            
        [self.httpCnctor sendMessage_static:msg xmlFile:xmlFile];
        [xmlFile release];
#else
        MyLog(@"\n\n\n请求的地址：%@  ~~~~ sessionId: %@  \n\n",self.httpCnctor.serviceUrl,sessionId);
        [self.httpCnctor sendMessage:msg synchronously:NO SessionId:sessionId];
#endif
    }
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
         UIViewController *myView = nil;
        if ([[self.sendDataDic allKeys] containsObject:@"Fist"]) {
            
        }
        else {
//            [[self.sendDataDic allKeys] containsObject:@"Fist"] ? [myView view] :
             [MBProgressHUD hideHUDForView: [[self.sendDataDic allKeys] containsObject:@"myView"] ? [self.sendDataDic [@"myView"] view] :  [AppDelegate shareMyApplication].window animated:YES];
            [YHLoadingView hidden];
        }
        
       
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

-(void)Saveplace{
}

-(void)noticeUI:(NSDictionary*)rspDic
{
    if (rspDic == nil) {
        return;
    }
    NSString* rspCode = [rspDic objectForKey:@"errorCode"];
    id<MessageDelegate> msg = [rspDic objectForKey:@"MESSAGE_OBJECT"];
    
    if(![msg isHouTai]){
         UIViewController *myView = nil;
        if ([[self.sendDataDic allKeys] containsObject:@"Fist"]) {
            
            bussineDataService *bus = nil;
            bus = [bussineDataService sharedDataService];
            
            [bus removeHUD];
        }
        else {
//            [[self.sendDataDic allKeys] containsObject:@"Fist"] ? [myView view] : 
            [MBProgressHUD hideHUDForView:[[self.sendDataDic allKeys] containsObject:@"myView"] ? [self.sendDataDic [@"myView"] view] : [AppDelegate shareMyApplication].window animated:YES];
            [YHLoadingView hidden];
        }
        
        
    }
    
    
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
        if([msg isHouTai]){/*后台设置*/
            
            if ([rspDic[@"errorCode"] isEqualToString:@"9999"]) {
                if (nil != self.target && [self.target respondsToSelector:@selector(requestFailed:)]) {
                    [self.target performSelector:@selector(requestFailed:) withObject:rspDic];
                }
                return;
            }

        }
        else{
            if (nil != self.target && [self.target respondsToSelector:@selector(requestFailed:)]) {
                [self.target performSelector:@selector(requestFailed:) withObject:rspDic];
            }
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
    if([messageObject isHouTai]){
        
    }
    else{
        self.ISNotHouTaiStr = [message hexStringDes:[messageObject getRequest] withEncrypt:NO];
    }
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

- (void)readyUploadPhotoMessage:(NSString*)messageClaseName
                          param:(NSDictionary*)parameters
                        funName:(NSString*)funName
                  synchronously:(BOOL)synchronously
                            url:(NSString*)url
                        postKey:(NSString*)key
{
//    NSString *imgUrl = [self.httpCnctor.serviceUrl stringByReplacingOccurrencesOfString:@"json.do" withString:url];
    NSString *imgUrl = [self.httpCnctor.serviceUrl substringToIndex:[self.httpCnctor.serviceUrl rangeOfString:@"mapp"].location+4];
    imgUrl = [imgUrl stringByAppendingString:url];
    self.httpCnctor.serviceUrl = imgUrl;//image_service_url;
    self.httpCnctor.allowCompressed = NO;
    Class class =  NSClassFromString(messageClaseName);
    message* messageObject = (message*)[[class alloc] init];
    messageObject.requestInfo = parameters;
    SEL selector = NSSelectorFromString(funName);
    [self setSendMessageSelector:selector];
    self.sendDataDic = parameters;
    //    [self sharedSendMessage:messageObject synchronously:synchronously];
    [self.httpCnctor uploadPhotoMessage:messageObject synchronously:NO SessionId:@"" PostKey:key];
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
        
        if([self.rspUserInfo objectForKey:@"expand"]!=[NSNull null]){
            if(([[self.rspUserInfo objectForKey:@"expand"] objectForKey:@"NEW_YEAR_STYLE"]!=[NSNull null])&&([[self.rspUserInfo objectForKey:@"expand"] objectForKey:@"NEW_YEAR_STYLE"]!=nil)){
                //&&([[[self.rspUserInfo objectForKey:@"expand"] objectForKey:@"FAIR_ON_OF"] boolValue]
                
                [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%@",[[self.rspUserInfo objectForKey:@"expand"] objectForKey:@"NEW_YEAR_STYLE"]] forKey:@"NEW_YEAR_STYLE"];
            }
        }
//        [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%@",@"1"] forKey:@"NEW_YEAR_STYLE"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        if([msg isHouTai]){
            self.rspHouTaiInfo = Msg.rspInfo;
        }else
            self.rspInfo = Msg.rspInfo;
    }
    [self noticeUI:rspDic];
}

#pragma mark
#pragma mark - H5的NET请求
- (void)sendH5Request:(NSDictionary *)paramters
{
    if ([[UIDevice currentDevice] networkAvailable]) {
        [self readySharedSendMessage:@"SendH5RequestMessage"
                               param:paramters
                             funName:@"sendH5Request:"
                       synchronously:NO];
    }
}

- (void)sendH5RequestFinished:(id<MessageDelegate>)msg
{
//    SendH5RequestMessage *H5mgs = msg;
//    MyLog(@"%@",H5mgs);
//    
//    NSString* rspCode = [H5mgs getRspcode];
//    NSMutableDictionary* rspDic = [[[NSMutableDictionary alloc] initWithCapacity:0] autorelease];
////    [rspDic setObject:@"0000" forKey:@"errorCode"];
//    [rspDic setObject:rspCode forKey:@"errorCode"];
//    [rspDic setObject:[H5mgs getBusinessCode] forKey:@"bussineCode"];
//    
//    self.rspInfo = H5mgs.rspInfo;
//    receiveString = H5mgs.responseInfo;
//    if (H5mgs.jsonRspData!= nil) {
//        [rspDic setObject:H5mgs.jsonRspData forKey:@"receiveData"];
//    }
//
//    H5ParamModel *context = H5mgs.h5ParamModel;
//    [rspDic setObject:context forKey:@"context"];
//    [context release];
//
//    if (nil != self.target && [self.target respondsToSelector:@selector(requestDidFinished:)]) {
//        [self.target performSelector:@selector(requestDidFinished:) withObject:rspDic];
//    }
    
}




#pragma mark -
#pragma mark http 回调接口
- (void)requestDidFinished:(id<MessageDelegate>)msg
{
    netWorkAccessTime = 0;
    if([msg isHouTai]){
//        NSLog(@"后台");
    }else{
        
        
        UIViewController *myView = nil;
        if ([[self.sendDataDic allKeys] containsObject:@"Fist"]) {
            bussineDataService *bus = nil;
            bus = [bussineDataService sharedDataService];
            
            [bus removeHUD];
        }
        else {
//            [[self.sendDataDic allKeys] containsObject:@"Fist"] ? [myView view] : 
             [MBProgressHUD hideHUDForView:[[self.sendDataDic allKeys] containsObject:@"myView"] ? [self.sendDataDic [@"myView"] view] : [AppDelegate shareMyApplication].window animated:YES];
            
            [YHLoadingView hidden];
        }
        
        
//        NSLog(@"不是后台");
    }
    
    if ([[msg getBusinessCode] isEqualToString:LOGIN_BIZCODE]) {
        [self loginFinished:msg];
    }
}

- (void)requestFailed:(NSDictionary*)errorInfo
{
    
    MyLog(@"失败信息 %@",errorInfo);
	id<MessageDelegate> msg = [errorInfo objectForKey:@"MESSAGE_OBJECT"];
    if([msg isHouTai]){
        
        MyLog(@"后台");
    }else{
        
        MyLog(@"不是后台");
         UIViewController *myView = nil;
        if ([[self.sendDataDic allKeys] containsObject:@"Fist"]) {
            bussineDataService *bus = nil;
            bus = [bussineDataService sharedDataService];
            
            [bus removeHUD];
        }
        else {
//            [[self.sendDataDic allKeys] containsObject:@"Fist"] ? [myView view] :
            [MBProgressHUD hideHUDForView:[[self.sendDataDic allKeys] containsObject:@"myView"] ? [self.sendDataDic [@"myView"] view] : [AppDelegate shareMyApplication].window animated:YES];
            
            [YHLoadingView hidden];
        }
        
        
        
        
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
        
        if (nil != self.target && [self.target respondsToSelector:@selector(requestFailed:)]) {
            [self.target performSelector:@selector(requestFailed:) withObject:rspDic];
        }
        
	}
}

#pragma mark -
#pragma mark alertview delegate
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
	if (kForceUpdateTag == alertView.tag) {
        // 强制升级
        if (alertView.cancelButtonIndex == buttonIndex)
            {
//                [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"passWord"];
//                [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"logSelf"];
//                [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:@"HuanCun"];
//                [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"HuanCunXinxi"];
//                [[NSUserDefaults standardUserDefaults] synchronize];
                self.IsTuisong=NO;
                self.rspAddrInfo=nil;
                self.rspAdInfo=nil;
                self.rspStatInfo=nil;
                self.rspUserInfo=nil;
                self.rspInfo=nil;
//                NSLog(@"updateUrl:%@",self.updateUrl);
                NSURL* url = [NSURL URLWithString:self.updateUrl];
                if([[UIApplication sharedApplication] canOpenURL:url])
                {
                [[UIApplication sharedApplication] openURL:url];
                }
                exit(0);
            }
        }
    
    if (kLinkErrorTag == alertView.tag || kTimeOutErrorTag == alertView.tag) {
        //超时或者连接错误，重试
        if (buttonIndex == alertView.firstOtherButtonIndex) {
            if ([self respondsToSelector:sendMessageSelector]) {
                [self performSelector:sendMessageSelector withObject:sendDataDic];
            }
        }
        
        if (buttonIndex == alertView.cancelButtonIndex) {
            if (nil != self.target && [self.target respondsToSelector:@selector(cancelTimeOutAndLinkError)]) {
                [self.target cancelTimeOutAndLinkError];
            }
        }
    }
    
    if (kSessionTimeOutTag == alertView.tag) {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"passWord"];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"logSelf"];
        [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:@"HuanCun"];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"HuanCunXinxi"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        bussineDataService *bus=[bussineDataService sharedDataService];
        bus.IsTuisong=NO;
        bus.rspAddrInfo=nil;
        bus.rspAdInfo=nil;
        bus.rspStatInfo=nil;
        bus.rspUserInfo=nil;
        bus.rspInfo=nil;
        bus.IsHuanCun=NO;
        [bus.httpCnctor cancelRequest];
        
    }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    NSString *buttonTitle = [alertView buttonTitleAtIndex:buttonIndex];
    [alertView dismissWithClickedButtonIndex:buttonIndex animated:YES];
    if(alertView.tag==202){
        if([buttonTitle isEqualToString:@"签到"]){
        }
    }else if(alertView.tag==50505||alertView.tag==40404){
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"passWord"];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"logSelf"];
        [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:@"HuanCun"];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"HuanCunXinxi"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        bussineDataService *bus=[bussineDataService sharedDataService];
        bus.IsTuisong=NO;
        bus.rspAddrInfo=nil;
        bus.rspAdInfo=nil;
        bus.rspStatInfo=nil;
        bus.rspUserInfo=nil;
        bus.rspInfo=nil;
        [bus.httpCnctor cancelRequest];
        bus.IsHuanCun=NO;
//        [(AppDelegate *)[UIApplication sharedApplication].delegate relogin];
    }else if(alertView.tag==10106){
        if([buttonTitle isEqualToString:@"立即更新"]){
//            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"passWord"];
//            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"logSelf"];
//            [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:@"HuanCun"];
//            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"HuanCunXinxi"];
//            [[NSUserDefaults standardUserDefaults] synchronize];
            self.IsTuisong=NO;
            self.rspAddrInfo=nil;
            self.rspAdInfo=nil;
            self.rspStatInfo=nil;
            self.rspUserInfo=nil;
            self.rspInfo=nil;
            
            bussineDataService *bus=[bussineDataService sharedDataService];
            NSURL* url = [NSURL URLWithString:bus.updateUrl];
            if([[UIApplication sharedApplication] canOpenURL:url])
            {
                [[UIApplication sharedApplication] openURL:url];
                exit(0);
            }
        }else{
          // 升级选项，点击取消，直接展示首页，没有登录操作了 
        }
    }else if(alertView.tag==20205){
        if([buttonTitle isEqualToString:@"查看"]){
        }
    }
}

-(void)showAlertViewTitle:(NSString*)title message:(NSString*)message delegate:(id)delegate tag:(NSInteger)tag cancelButtonTitle:(NSString*)cancelButtonTitle otherButtonTitles:(NSString*)otherButtonTitles,...
{
    NSMutableArray* argsArray = [[NSMutableArray alloc] initWithCapacity:0];
    
    id arg;
    va_list argList;
    if(nil != otherButtonTitles){
        va_start(argList, otherButtonTitles);
        while ((arg = va_arg(argList,id))) {
            [argsArray addObject:arg];
        }
        va_end(argList);
    }
    
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:message
                                                   delegate:delegate
                                          cancelButtonTitle:cancelButtonTitle
                                          otherButtonTitles:otherButtonTitles,nil];
    alert.tag = tag;
    for(int i = 0; i < [argsArray count]; i++){
        [alert addButtonWithTitle:[argsArray objectAtIndex:i]];
    }
    [alert show];
}

- (void)tagsAliasCallback:(int)iResCode tags:(NSSet*)tags alias:(NSString*)alias {
    //    [self showSimpleAlertView:[NSString stringWithFormat:@"rescode: %d, \ntags: %@, \nalias: %@\n", iResCode, tags , alias]];
    NSLog(@"rescode: %d, \ntags: %@, \nalias: %@\n", iResCode, tags , alias);
}

//获取当前时间
- (NSString *)getLoctionTime {
    NSDate *senddate               = [NSDate date];
    
    NSDateFormatter *dateformatter = [[NSDateFormatter alloc] init];
    
    [dateformatter setDateFormat:@"YYYYMMdd"];
    
    NSString *locationString       = [dateformatter stringFromDate:senddate];
    
    NSLog(@"locationString:%@",locationString);
    
    return  locationString;
}



//MBProgressHUD 的使用方式，只对外两个方法，可以随时使用(但会有警告！)，其中窗口的 alpha 值 可以在源程序里修改。
- (void)showHUD:(NSString *)msg toWindowView:(UIView *)view{
    
    if (loadView == nil) {
        loadView = [[YHLoadCenterView alloc]initWithImage:[UIImage imageNamed:@"loadImage"]];
        
        loadView.center = view.center;
//        loadView.centerY -= 70;
    }
    
    [view addSubview:loadView];
    
}

- (void)removeHUD{
    
    if (loadView) {
        [loadView removeFromSuperview];
        loadView = nil;
    }
    
        
}


@end
