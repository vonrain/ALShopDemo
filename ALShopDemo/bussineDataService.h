//
//  bussineDataService.h


#import <Foundation/Foundation.h>
#import "httpConnector/HttpStatus.h"
#import "httpConnector/HttpConnector.h"
#import "message_def.h"

#define kForceUpdateTag         100
#define kLinkErrorTag           101
#define kTimeOutErrorTag        102
#define kSessionTimeOutTag      103


@protocol HttpBackDelegate<NSObject>

@required
//key: bussineCode value :; Key:errorCode, value: key:MSG, value:
- (void)requestDidFinished:(NSDictionary*)info;
//key: bussineCode value :; Key:errorCode, value: key:MSG, value:
- (void)requestFailed:(NSDictionary*)info;

@optional
//点击超时或者连接错误提示上的取消按钮的回调接口
- (void)cancelTimeOutAndLinkError;
@end

@interface bussineDataService : NSObject<UIAlertViewDelegate, HttpStatus>
{
    NSString*			receiveString;
	NSDictionary*		sendDataDic;
	NSString*			sendString;
	
    SEL sendMessageSelector;
    HttpConnector* httpCnctor;
    
    // 一般都是第一级的节点的键值对，例如：RspCode=0000 ,key:"RspCode" value:"0000"
    NSDictionary*       rspInfo;
    NSDictionary*       rspHouTaiInfo;//后台登录时候存放的数据
    NSDictionary *      rspStatInfo;//存放静态数据
    NSDictionary *      rspAdInfo;//首页的广告信息
    NSDictionary *      rspAddrInfo;//用户地址信息
    NSDictionary *      rspUserInfo;//登录返回用户信息
    NSMutableArray *    TaoCanArr;//纪录选择的套餐
    NSMutableDictionary *    HuanCunXinxiDic;
    int netWorkAccessTime;
}

//@property (nonatomic,assign) BOOL isLogin; //是否已

@property (nonatomic,weak) id<HttpBackDelegate> target;
@property (nonatomic,strong) HttpConnector* httpCnctor;
@property (nonatomic,assign) SEL sendMessageSelector;
@property (nonatomic,strong) NSString*		receiveString;
@property (nonatomic,strong) NSDictionary*	sendDataDic;
@property (nonatomic,strong) NSString*		sendString;
@property (nonatomic,strong) NSDictionary*  rspInfo;
@property (nonatomic,strong) NSDictionary*  rspHouTaiInfo;
@property (nonatomic,strong) NSDictionary*  rspStatInfo;
@property (nonatomic,strong) NSDictionary*  rspAdInfo;
@property (nonatomic,strong) NSDictionary*  rspAddrInfo;
@property (nonatomic,strong) NSDictionary*  rspUserInfo;
@property (nonatomic,strong) NSString *updateUrl;
@property (nonatomic,strong) NSMutableArray *TaoCanArr;
@property (nonatomic,strong) NSString*		serversUrl;
@property (assign)int  SelAddr;//记录选者的地址
@property (assign)BOOL IsTuisong;//判断是否推送过来的信息启动应用
@property (nonatomic,strong) NSDictionary* TuiSongDic;//记录推送过来的信息
@property (nonatomic,strong) NSString *DeviceToken;
@property (nonatomic,strong) NSString *ShopSelectStr;//纪录了从商品详情直接跳转购物车时候的
@property (assign)BOOL IsHuanCun;//判断是不是缓存进来的
@property (nonatomic,strong) NSString *LogInTime;//记录登录时的时间 如果后台第二天回来应用还在 那么后台重新登录
@property (nonatomic,strong) NSString* DangqingqiuStr;//当前请求报文，方便找错
@property (nonatomic,strong) NSString* ISNotHouTaiStr;//当前不是后台请求报文，方便找错
@property (assign)BOOL isFirstSearch;

+(bussineDataService *) sharedDataService;

/**
 *  取消请求
 */
- (void)cleanAllService;

#pragma mark
#pragma mark - 登陆模块
- (void)login:(NSDictionary *)paramters;

@end
