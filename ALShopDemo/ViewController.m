//
//  ViewController.m
//  ALShopDemo
//
//  Created by allen on 9/11/17.
//  Copyright © 2017 allen. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()<HttpBackDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)Login {
    bussineDataService *bussineService = [bussineDataService sharedDataService];
    bussineService.target = self;
    bussineService.IsHuanCun=NO;
    NSDictionary *data = [[NSDictionary alloc] initWithObjectsAndKeys:
                          [NSDictionary dictionaryWithObjectsAndKeys:@(NO),@"isLogin", nil],@"expand",
                          @"",@"usercode",
                          @"",@"pwd",
                          [NSNumber numberWithBool:YES],@"isHouTai",
                          nil];
    [bussineService login:data];
    
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    UITouch *touch =  [touches anyObject];
    
    [self Login];
    if(touch.tapCount == 2)
        
    {
        
        self.view.backgroundColor = [UIColor redColor];
        
    }

}
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
            MyLog(@"\n\n用户登录信息：%@\n\n ",bus.rspUserInfo);
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
        [self showSimpleAlertView:msg];
    }
}

#pragma mark AlertViewDelegate

-(void)showSimpleAlertView:(NSString*)message
{
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"提示信息"
                                                    message:message
                                                   delegate:nil
                                          cancelButtonTitle:@"确定"
                                          otherButtonTitles:nil];
    [alert show];
}
@end
