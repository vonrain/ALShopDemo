//
//  LoginHandler.h
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "bussineDataService.h"

@interface LoginHandler : NSObject<HttpBackDelegate,UIAlertViewDelegate>



@property(nonatomic,strong) UIButton *tabBarButton;
@property(nonatomic,copy) NSString *touchEvenURL;
@property (nonatomic, strong) NSMutableString *appstoreUrl;

@property (nonatomic, copy) NSString *activeButtonJumpUrl;
@property (nonatomic, copy) NSString *activeButtonImgUrl;
@property (nonatomic, copy) NSString *QRCodeToken;
@property (nonatomic, assign) BOOL hasQRToken;
@property (nonatomic, assign) BOOL hasActive;
@property (nonatomic, assign) BOOL isNoJumpUrl;

@property(nonatomic, strong) NSDictionary   *sendDic;

//只提供无网络情况下提示
@property (nonatomic,strong) UIAlertView *alertView;


@property (nonatomic,copy) NSString *deviceId;

@property (nonatomic,strong) NSDictionary *userInfoDic;



+(instancetype)defaultStack;

//全局变量判断是否登录;
- (BOOL)isLogin;

-(void)startLogin;

- (void)checkH5ResouseUpdate;

- (void)checkQRCodeLogin;

+ (void)showAlearView:(NSString *)message;

-(void)removeBarButton;

+(void)clearWebViewCookie;

// 设置deviceId
- (void)uniqueIDForDevice;
@end
