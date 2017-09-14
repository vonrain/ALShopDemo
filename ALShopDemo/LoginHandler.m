//
//  LoginHandler.m

#import "LoginHandler.h"
#import "UICKeyChainStore.h"

typedef NS_ENUM(NSInteger, H5ResourceUpdateType){
    H5ResourceUpdateTypeNoNew = 0,
    H5ResourceUpdateTypeIsNewst = 1,
    H5ResourceUpdateTypeToUpdate = 2
};

@interface LoginHandler ()

@property(nonatomic,copy) NSString *financiaUrl;
@end

@implementation LoginHandler

+(instancetype)defaultStack {
    static LoginHandler *stack;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        stack = [[self alloc] init];
    });
    return stack;
}

-(void)startLogin{
//    [self sendUpdateVersionMessage];
}


- (BOOL)compareNewVersion:(NSString *)newVersion isGreaterThanOldVersion:(NSString *)oldVersion {
    
    if ([newVersion compare:oldVersion options:NSNumericSearch] == NSOrderedDescending) {
        return YES;
    }else
    {
        return NO;
    }
}

-(void)login{
    
    bussineDataService *bussineService = [bussineDataService sharedDataService];
    NSString *userName = nil;
    NSString *pwdStr = nil;
    NSMutableString *userName_str = [[NSMutableString alloc] initWithCapacity:0];
    
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"userName"] !=nil){
        userName = [[NSUserDefaults standardUserDefaults] objectForKey:@"userName"];
        
        if([userName length]>3 && [[userName substringToIndex:3] isEqualToString:@"QA_"]){
            
            NSString *tr=[NSString stringWithString:[userName substringFromIndex:3]];
            [userName_str setString:tr];
//            bussineService.httpCnctor.serviceUrl = QAservice_url;
//            bussineService.serversUrl = QAservice_url;
        }else if([userName length]>4&&[[userName substringToIndex:4] isEqualToString:@"UAT_"]){
//            bus.httpCnctor.serviceUrl=UATservice_url;
            NSString *tr=[NSString stringWithString:[userName substringFromIndex:4]];
            [userName_str setString:tr];

//            bussineService.httpCnctor.serviceUrl = UATservice_url;
//            bussineService.serversUrl = UATservice_url;

        }else if([userName length]>4&&[[userName substringToIndex:4] isEqualToString:@"DEV_"]){
            
            NSString *tr=[NSString stringWithString:[userName substringFromIndex:4]];
            [userName_str setString:tr];
//            bussineService.httpCnctor.serviceUrl = DEVservice_url;
            
        }else{
            
            [userName_str setString:userName];
//            bussineService.httpCnctor.serviceUrl = service_url;

        }

    }
//    else{
//#warning TEST需要设置默认地址，发布现网需要写现网的地址
//
//        bussineService.httpCnctor.serviceUrl = service_url;
//    }

    
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"passWord"]){
        pwdStr = [[NSUserDefaults standardUserDefaults] objectForKey:@"passWord"];
    }
    BOOL *canLogin = userName != nil && pwdStr != nil;
    
    bussineService.target = self;
    bussineService.IsHuanCun=NO;
    NSDictionary *data = [[NSDictionary alloc] initWithObjectsAndKeys:
                          [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:canLogin ? YES : NO],@"isLogin", nil],@"expand",
                          canLogin ? userName_str : @"",@"usercode",
                          canLogin ? pwdStr : @"",@"pwd",
                          [NSNumber numberWithBool:YES],@"isHouTai",
                          nil];
    self.sendDic = data;
    [bussineService login:data];
}


-(void)getStaticMessage
{
}

- (void)checkQRCodeLogin {

}


- (void)jumpToWoFinancialWithKey:(NSString *)key{
}

- (NSString *)stitchUrl:(NSString *)urlStr withKey:(NSString *)key {
    // 拼接url
//    str = @"/wo/goods/pageInit?gdsId=61468&skuId=62434&shopLocaleCode=9A&actionType=showScore";
    NSString *url = nil;
    NSRange range = [urlStr rangeOfString:@"?"];
    if (range.length != 0) {
//    if ([urlStr containsString:@"?"]) {
        url = [NSString stringWithFormat:@"%@&%@",urlStr,key];
    } else {
        url = [NSString stringWithFormat:@"%@?%@",urlStr,key];
    }
    return url;
}

-(void)Saveplace{
}

-(void)HandMessage
{
}

- (void)readBackMes{
}

-(void)getAddrMessage
{
}



- (void)checkH5Update:(NSDictionary *)parameter {
    
}

// 检查h5资源更新包
- (void)checkH5ResouseUpdate {
    bussineDataService *bussineService = [bussineDataService sharedDataServiceFive];
    bussineService.target = self;
}

- (void)uniqueIDForDevice {
    NSString *vendorID = [UICKeyChainStore stringForKey:@"www.xsss.cn.deviceId" service:nil];
    MyLog(@"VendorID from Keychain - %@",vendorID);
    
    if (vendorID){
        [[NSUserDefaults standardUserDefaults] setObject:vendorID forKey:@"vendorId"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    else{
        vendorID = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
        [UICKeyChainStore setString:vendorID forKey:@"www.xsss.cn.deviceId"  service:nil];
        
        [[NSUserDefaults standardUserDefaults] setObject:vendorID forKey:@"vendorId"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        MyLog(@"VendorID Local - %@",vendorID);
    }
}

#pragma mark -
#pragma mark AlertView
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

-(void)showSimpleAlertView:(NSString*)message
{
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"提示信息"
                                                    message:message
                                                   delegate:nil
                                          cancelButtonTitle:@"确定"
                                          otherButtonTitles:nil];
    [alert show];
}

#pragma mark -
#pragma mark HttpBackDelegate
- (void)requestDidFinished:(NSDictionary*)info
{
    MyLog(@"%@",info);
    NSString* oKCode = @"0000";
    NSString* bizCode = [info objectForKey:@"bussineCode"];
    NSString* errCode = [info objectForKey:@"errorCode"];
    NSString* msg = [info objectForKey:@"MSG"];
    
    [MBProgressHUD hideHUDForView:[AppDelegate shareMyApplication].window animated:YES];
    
     if([[LoginMessage getBizCode] isEqualToString:bizCode]){
            if([oKCode isEqualToString:errCode]){
                bussineDataService *bus=[bussineDataService sharedDataService];
                
                MyLog(@"cg0001数据  %@",bus.rspInfo);
                
                if([[bus.rspUserInfo allKeys]containsObject:@"hotSearchs"] && bus.rspUserInfo[@"hotSearchs"] != [NSNull null] && [bus.rspUserInfo[@"hotSearchs"] count] >0){
                }
                
                self.userInfoDic = bus.rspUserInfo;
                
                MyLog(@"  \n  \n 用户收获地址：%@  \n\n",bus.rspAddrInfo);
                
            }else{
                if([NSNull null] == [info objectForKey:@"MSG"]){
                    msg = @"登录异常！";
                }
                if(nil == msg){
                    msg = @"登录异常！";
                }
                [self showSimpleAlertView:msg];
            }
        }
    
}

- (void)requestFailed:(NSDictionary*)info
{
    NSString* bizCode = [info objectForKey:@"bussineCode"];
    NSString* msg = [info objectForKey:@"MSG"];
    [MBProgressHUD hideHUDForView:[AppDelegate shareMyApplication].window animated:YES];
    
   if([[LoginMessage getBizCode] isEqualToString:bizCode]){
        if([info objectForKey:@"MSG"] == [NSNull null]){
            msg = @"登录失败！";
        }
        if(nil == msg){
            msg = @"登录失败！";
        }
        [self showAlertViewTitle:@"提示"
                         message:msg
                        delegate:self
                             tag:10101
               cancelButtonTitle:@"确定"
               otherButtonTitles:nil];
        
    }
    
}

#pragma mark AlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    NSString *buttonTitle = [alertView buttonTitleAtIndex:buttonIndex];
    [alertView dismissWithClickedButtonIndex:buttonIndex animated:YES];
    if(alertView.tag==10101){
        if([buttonTitle isEqualToString:@"确定"]){
            return;
        }
    }else if(alertView.tag==10102){
        
    }else if(alertView.tag==10103){
        
    }else if(alertView.tag==10106){
        if([buttonTitle isEqualToString:@"确定"]){
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"passWord"];
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"logSelf"];
            //            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"remember"];
            [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:@"HuanCun"];
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"HuanCunXinxi"];
            //            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"firstLaunchLog"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            bussineDataService *bus=[bussineDataService sharedDataService];
            bus.IsTuisong=NO;
            bus.rspAddrInfo=nil;
            bus.rspAdInfo=nil;
            bus.rspStatInfo=nil;
            bus.rspUserInfo=nil;
            bus.rspInfo=nil;
            NSURL* url = [NSURL URLWithString:bus.updateUrl];
            if([[UIApplication sharedApplication] canOpenURL:url])
            {
                [[UIApplication sharedApplication] openURL:url];
                exit(0);
            }
        }else{
            [self login];
        }
    }else if (alertView.tag==20202){
        if([buttonTitle isEqualToString:@"确认"])
        {
            //打开iTunes  方法一
            if (_appstoreUrl == nil) {
                [_appstoreUrl setString:@""];
            }
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:_appstoreUrl]];
            exit(0);
        }
    }
}


- (BOOL)isLogin{
    
    bussineDataService *bus = [bussineDataService sharedDataService];
    BOOL isOrLogin = [bus.rspUserInfo[@"expand"][@"isLogin"] boolValue];
    return isOrLogin;
}

+ (void)showAlearView:(NSString *)message{
}


-(UIButton *)tabBarButton{
    if (!_tabBarButton) {
        
        _tabBarButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _tabBarButton.frame = CGRectMake(MainWidth - 80, MainHeight - 44-20 -99, 60, 80);
//        [ShopCarBtn setFrame:CGRectMake([UIScreen mainScreen].bounds.size.width-50-10, [UIScreen mainScreen].bounds.size.height-44-20-93, 40, 40)];
        _tabBarButton.backgroundColor = [UIColor clearColor];
        _tabBarButton.tag = 265;
        [_tabBarButton addTarget:self action:@selector(buttonEevn:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _tabBarButton;
}

- (void)removeBarButton{

    [self.tabBarButton removeFromSuperview];
}

-(void)buttonEevn:(id)sender{
}




+(void)clearWebViewCookie{
    //清除cookies
    NSHTTPCookie *cookie;
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (cookie in [storage cookies])
    {
        [storage deleteCookie:cookie];
    }
    
    //清除UIWebView的缓存
    //    [[NSURLCache sharedURLCache] removeAllCachedResponses];
}

- (NSString *)deviceId {
    if (_deviceId == nil) {
        NSString *vendorId = [[NSUserDefaults standardUserDefaults] objectForKey:@"vendorId"];
        if (vendorId == nil) {
            _deviceId =  [[[UIDevice currentDevice] identifierForVendor] UUIDString];
        }
        else{
            _deviceId = vendorId;
        }
    }
	return _deviceId;
}
@end
