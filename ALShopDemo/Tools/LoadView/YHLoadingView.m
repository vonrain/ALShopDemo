//
//  YHLoadingView.m

#import "YHLoadingView.h"
#import "YHLoadCenterView.h"
#import "Masonry.h"

#define Width  30.0f

@interface YHLoadingView ()

@property(nonatomic,strong)YHLoadCenterView*centerView;

@end
@implementation YHLoadingView

+ (YHLoadingView*)sharedInstance {
    static dispatch_once_t once;
    static YHLoadingView *sharedInstance;
    dispatch_once(&once, ^ {
        sharedInstance = [[YHLoadingView alloc] init];
    });
    return sharedInstance;
}

+(void)showWithView:(UIView *)view title:(NSString *)title{
    [[YHLoadingView sharedInstance] showWithView:view title:title];
}

+(void)showWithView:(UIView *)view image:(UIImage *)image{
    [[YHLoadingView sharedInstance] showWithView:view image:image];
}

+(void)showWithView:(UIView *)view {
    [[YHLoadingView sharedInstance] showWithView:view isBank:YES];
}
+(void)hidden{
    [[YHLoadingView sharedInstance] hidden];
}
-(void)showWithView:(UIView *)view title:(NSString *)title{
    if (self) {
        if (self.centerView) {
            [self.centerView removeFromSuperview];
        }
//        self.center=view.center;
        [view addSubview:self];
        self.centerView=[[YHLoadCenterView alloc]initWithTitle:title];
        self.centerView.center=view.center;
        [view addSubview:self.centerView];
   
    }
}
-(void)showWithView:(UIView *)view image:(UIImage *)image{
    if (self) {
        if (self.centerView) {
            [self.centerView removeFromSuperview];
        }
//        self.center=view.center;
        [view addSubview:self];
        self.centerView=[[YHLoadCenterView alloc]initWithImage:image];
        self.centerView.center=view.center;
        [view addSubview:self.centerView];

   
    }
}

-(void)showWithView:(UIView *)view isBank:(BOOL)isBank{
    if (self) {
        if (self.centerView) {
            [self.centerView removeFromSuperview];
        }
        self.center=view.center;
        [view addSubview:self];
        self.centerView=[[YHLoadCenterView alloc] initWithMask];
        self.centerView.center=view.center;
        [view addSubview:self.centerView];
    }
}

-(void)hidden{
    if (self) {
        [self.centerView removeFromSuperview];
        [self removeFromSuperview];
    }
}
-(instancetype)init{
    if (self=[super init]) {
        self.frame=CGRectMake(0, 60, CGRectGetWidth([UIScreen mainScreen].bounds),  CGRectGetHeight([UIScreen mainScreen].bounds));
      //  self.backgroundColor=[UIColor cyanColor];
    }
    return self;
}

-(void)dealloc{
    NSLog(@"dealloc");
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
