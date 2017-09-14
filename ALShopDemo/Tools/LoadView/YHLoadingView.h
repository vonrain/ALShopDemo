//
//  YHLoadingView.h

#import <UIKit/UIKit.h>

@interface YHLoadingView : UIView

/**
 * 文字loading
 *
 *  @param view  supperview
 *  @param title 标题
 */
+(void) showWithView:(UIView*)view title:(NSString *)title;
/**
 *  tupianloading
 *
 *  @param view  supperview
 *  @param image logo
 */
+(void) showWithView:(UIView*)view image:(UIImage*)image;

+(void)showWithView:(UIView *)view;
+(void) hidden;

@end
