//
//  YHLoadCenterView.h

#import <UIKit/UIKit.h>

@interface YHLoadCenterView : UIView
/**
 *  中间是文字
 *
 *  @param title 中间文字 中文一个字，字母两个字
 *
 *  @return <#return value description#>
 */
-(instancetype)initWithTitle:(NSString *)title;
/**
 *  中间是icon
 *
 *  @param image 中间的icon
 *
 *  @return <#return value description#>
 */
-(instancetype)initWithImage:(UIImage*)image;


-(instancetype)initWithMask;

@end
