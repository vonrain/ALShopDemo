//
//  YHLoadCenterView.m


#import "YHLoadCenterView.h"
#import "Masonry.h"
//#import <pop/POP.h>

#define Width  30.0f
#define KShapeLayerMargin 0.0f
#define KShapelayerLineWidth 2.0f
#define KShapeLayerWidth  30.0f
#define KShapeLayerRadius  (KShapeLayerWidth/2)
#define KAnimationDurationTime 1.2f

@interface YHLoadCenterView()
{
    CAShapeLayer *bottomShapeLayer;
    CAShapeLayer *ovalShapeLayer;
}

@property (nonatomic,strong) CABasicAnimation *startAnimation;
@property (nonatomic,strong) CABasicAnimation *endAnimation;
@property (nonatomic,strong) CAAnimationGroup *groupAnimation;
@property (nonatomic,strong) UILabel          *centerLabel;
@property (nonatomic,strong) NSString         *title;
@property (nonatomic,strong) UIImageView      *iconImage;

@end

@implementation YHLoadCenterView

-(instancetype)initWithTitle:(NSString *)title{
    if (self=[super init]) {
        self.frame                          = CGRectMake(0, 0, Width, Width);
        self.backgroundColor=[UIColor whiteColor];
        [self centerLabel];
        [self addSubview:_centerLabel];
        self.title                          = title;
        [self setLabelFrame];
        [self addShapLayer];
    }
    return self;
}
-(instancetype)initWithImage:(UIImage *)image{
    if (self=[super init]) {
    self.frame                              = CGRectMake(0, 0, Width, Width);

        [self iconImage];
        [self addSubview:_iconImage];
        self.iconImage.image                = image;
        [self setImageViewFrame];
        [self addShapLayer];
    }
    return self;
}

-(instancetype)initWithMask{
    if (self=[super init]) {
        self.frame = CGRectMake(0, 0, MainWidth, MainHeight);
//        UIColor *color = [UIColor blackColor];
//        self.backgroundColor = [color colorWithAlphaComponent:0.3];
        
//        self.frame = CGRectMake(0, 0, 80, 80);
        
        NSMutableArray *array = [[NSMutableArray alloc] initWithObjects:[UIImage imageNamed:@"bank1.png"],
                                 [UIImage imageNamed:@"bank2.png"],
                                 [UIImage imageNamed:@"bank3.png"],
                                 nil];
        
//        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 80, 80)];
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(MainWidth/2 -60, MainHeight/2-53, 120, 106)];
        
        imageView.animationImages = array;
        imageView.animationDuration = 1.0f;
        imageView.animationRepeatCount = 0;
        [imageView startAnimating];
        [self addSubview:imageView];
    }
    return self;
}

-(void)setTitle:(NSString *)title{
    _title                                  = title;
    if (_title) {
    _centerLabel.text                       = _title;
    }

}
-(void)setLabelFrame{
    [_centerLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@(KShapelayerLineWidth*2));
        make.left.equalTo(@(KShapelayerLineWidth*2));
        make.right.equalTo(@(-KShapelayerLineWidth*2));
        make.bottom.equalTo(@(-KShapelayerLineWidth*2));
    }];
}
-(void)setImageViewFrame{
    [_iconImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@(KShapelayerLineWidth*2));
        make.left.equalTo(@(KShapelayerLineWidth*2));
        make.right.equalTo(@(-KShapelayerLineWidth*2));
        make.bottom.equalTo(@(-KShapelayerLineWidth*2));
    }];
}
-(void)didMoveToSuperview{
    [super didMoveToSuperview];
    [self setUpUI];

}
-(void)setUpUI{
    bottomShapeLayer.frame                  = self.bounds;
    bottomShapeLayer.path=[UIBezierPath bezierPathWithOvalInRect:self.bounds].CGPath;
    ovalShapeLayer.frame                    = self.bounds;
    ovalShapeLayer.path=[UIBezierPath bezierPathWithOvalInRect:self.bounds].CGPath;
}
-(void)addShapLayer{
    /// 底部的灰色layer
    bottomShapeLayer                        = [CAShapeLayer layer];
    bottomShapeLayer.strokeColor            = [UIColor colorWithRed:229/255.0 green:229/255.0 blue:229/255.0 alpha:1].CGColor;
    bottomShapeLayer.fillColor              = [UIColor clearColor].CGColor;
    bottomShapeLayer.lineWidth              = KShapelayerLineWidth;
    bottomShapeLayer.path                   = [UIBezierPath
                             bezierPathWithRoundedRect:CGRectMake(KShapeLayerMargin, 0, KShapeLayerWidth, KShapeLayerWidth) cornerRadius:KShapeLayerRadius].CGPath;
//    [self.layer addSublayer:bottomShapeLayer];
    /// 橘黄色的layer
    ovalShapeLayer                          = [CAShapeLayer layer];
    ovalShapeLayer.strokeColor              = [UIColor colorWithRed:1.000 green:0.467 blue:0.004 alpha:1.000].CGColor;
    ovalShapeLayer.fillColor                = [UIColor clearColor].CGColor;
    ovalShapeLayer.lineWidth                = KShapelayerLineWidth;
    ovalShapeLayer.path                     = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(KShapeLayerMargin, 0,KShapeLayerWidth, KShapeLayerWidth) cornerRadius:KShapeLayerRadius].CGPath;
    [self.layer addSublayer:bottomShapeLayer];
    [self.layer addSublayer:ovalShapeLayer];
    [self addAnimationWithLaye:ovalShapeLayer];
}
-(void)addAnimationWithLaye:(CAShapeLayer *)layer{
    /// 起点动画
    CABasicAnimation * strokeStartAnimation = [CABasicAnimation animationWithKeyPath:@"strokeStart"];
    strokeStartAnimation.fromValue          = @(-1);
    strokeStartAnimation.toValue            = @(1.0);

    /// 终点动画
    CABasicAnimation * strokeEndAnimation   = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    strokeEndAnimation.fromValue            = @(0.0);
    strokeEndAnimation.toValue              = @(1.0);

    /// 组合动画
    CAAnimationGroup *animationGroup        = [CAAnimationGroup animation];
    animationGroup.animations               = @[strokeStartAnimation,strokeEndAnimation];
    animationGroup.duration                 = KAnimationDurationTime;
    animationGroup.repeatCount              = CGFLOAT_MAX;
    animationGroup.fillMode                 = kCAFillModeBoth;
    animationGroup.removedOnCompletion      = NO;

   [layer addAnimation:animationGroup forKey:nil];

    //旋转动画
    CABasicAnimation *rotateAnimation=[CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    rotateAnimation.fromValue=@(0);
    rotateAnimation.toValue=@(M_PI);
    rotateAnimation.repeatCount             = CGFLOAT_MAX;
    rotateAnimation.duration                = KAnimationDurationTime*4;
    [layer addAnimation:rotateAnimation forKey:nil];

}

-(UILabel *)centerLabel{
    if (!_centerLabel) {
        _centerLabel = [UILabel new];
        _centerLabel.textColor = [UIColor redColor];
        _centerLabel.font = [UIFont systemFontOfSize:14.0f];
     //   _centerLabel.backgroundColor=[UIColor cyanColor];
        _centerLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _centerLabel;
}
-(UIImageView *)iconImage{
    if (!_iconImage) {
        _iconImage = [UIImageView new];
        _iconImage.contentMode   = UIViewContentModeScaleAspectFill;
        _iconImage.clipsToBounds = YES;
    }
    return _iconImage;
}

-(void)dealloc{
    NSLog(@"dealloc");
    [self.layer removeAllAnimations];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
