//
//  SMAlertView.h
//  SMAlertView
//
//  Created by WWLy on 13/02/2017.
//  Copyright © 2017 WWLy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SMAlertViewButton.h"


typedef NSAttributedString* (^SMAttributedFormatBlock)(NSString *value);
typedef void (^SMDismissBlock)(void);
typedef void (^SMDismissAnimationCompletionBlock)(void);
typedef void (^SMForceHideBlock)(void);

@interface SMAlertView : UIViewController

/**
 提示框样式
 */
typedef NS_ENUM(NSInteger, SMAlertViewStyle)
{
    SMAlertViewStyleSuccess,
    SMAlertViewStyleError,
    SMAlertViewStyleNotice,
    SMAlertViewStyleWarning,
    SMAlertViewStyleInfo,
    SMAlertViewStyleQuestion,
    SMAlertViewStyleCustom
};

/**
 提示框显示动画类型
 */
typedef NS_ENUM(NSInteger, SMAlertViewShowAnimation)
{
    SMAlertViewShowAnimationFadeIn,
    SMAlertViewShowAnimationSlideInFromBottom,
    SMAlertViewShowAnimationSlideInFromTop,
    SMAlertViewShowAnimationSlideInFromLeft,
    SMAlertViewShowAnimationSlideInFromRight,
    SMAlertViewShowAnimationSlideInFromCenter,
    SMAlertViewShowAnimationSlideInToCenter,
    SMAlertViewShowAnimationSimplyAppear
};

/**
 提示框移除动画类型
 */
typedef NS_ENUM(NSInteger, SMAlertViewHideAnimation)
{
    SMAlertViewHideAnimationFadeOut,
    SMAlertViewHideAnimationSlideOutToBottom,
    SMAlertViewHideAnimationSlideOutToTop,
    SMAlertViewHideAnimationSlideOutToLeft,
    SMAlertViewHideAnimationSlideOutToRight,
    SMAlertViewHideAnimationSlideOutToCenter,
    SMAlertViewHideAnimationSlideOutFromCenter,
    SMAlertViewHideAnimationSimplyDisappear
};

/** Alert background styles
 *
 * Set SMAlertView background type.
 */
typedef NS_ENUM(NSInteger, SMAlertViewBackground)
{
    SMAlertViewBackgroundShadow,
    SMAlertViewBackgroundBlur,
    SMAlertViewBackgroundTransparent
};

/** Content view corner radius
 *
 * A float value that replaces the standard content viuew corner radius.
 */
@property CGFloat cornerRadius;

/** 主标题
 *
 * The text displayed as title.
 */
@property UILabel *titleLabel;

/** 副标题
 *
 * Holds the textview.
 */
@property UITextView *textView;

/** Set text attributed format block
 *
 * Holds the attributed string.
 */
@property (nonatomic, copy) SMAttributedFormatBlock attributedFormatBlock;

/** 点击按钮外移除
 *
 * (Default: NO)
 */
@property (nonatomic, assign) BOOL shouldDismissOnTapOutside;

/**
 设置完成按钮的样式
 */
@property (nonatomic, copy) CompleteButtonFormatBlock completeButtonFormatBlock;

/**
 设置按钮的样式
 */
@property (nonatomic, copy) ButtonFormatBlock buttonFormatBlock;

/** Set force hide block.
 *
 * When set force hideview method invocation.
 */
@property (nonatomic, copy) SMForceHideBlock forceHideBlock;

/** 提示框类型
 *
 * (Default: Custom)
 */
@property (nonatomic, assign)  SMAlertViewStyle alertViewStyle;

/** 显示动画类型
 *
 * (Default: SlideInFromTop)
 */
@property (nonatomic) SMAlertViewShowAnimation showAnimationType;

/** Hide animation type
 *
 * Holds the hide animation type.
 * (Default: FadeOut)
 */
@property (nonatomic) SMAlertViewHideAnimation hideAnimationType;

/** Set SMAlertView background type.
 *
 * SMAlertView background type.
 * (Default: Shadow)
 */
@property (nonatomic) SMAlertViewBackground backgroundType;

/** Set custom color to SMAlertView.
 *
 * SMAlertView custom color.
 * (Buttons, top circle and borders)
 */
@property (nonatomic, strong) UIColor *customViewColor;

/** Set custom color to SMAlertView background.
 *
 * SMAlertView background custom color.
 */
@property (nonatomic, strong) UIColor *backgroundViewColor;

/** Set status bar hidden.
 *
 * Status bar hidden
 */
@property (nonatomic) BOOL statusBarHidden;

/** Set status bar style.
 *
 * Status bar style
 */
@property (nonatomic) UIStatusBarStyle statusBarStyle;

/** 水平排列按钮
 *
 * Horizontal aligment instead of vertically if YES
 */
@property (nonatomic) BOOL horizontalButtons;

/** Initialize SMAlertView using a new window.
 *
 * Init with new window
 */
- (instancetype)initWithNewWindow;

/** Initialize SMAlertView using a new window.
 *
 * Init with new window with custom width
 */
- (instancetype)initWithNewWindowWidth:(CGFloat)windowWidth;

/**
 开始移除时触发

 @param dismissBlock dismissBlock
 */
- (void)alertIsDismissed:(SMDismissBlock)dismissBlock;

/**
 移除动画完成后触发

 @param dismissAnimationCompletionBlock dismissAnimationCompletionBlock
 */
- (void)alertDismissAnimationIsCompleted:(SMDismissAnimationCompletionBlock)dismissAnimationCompletionBlock;

/** Hide SMAlertView
 *
 * Hide SMAlertView using animation and removing from super view.
 */
- (void)hideView;

/** SMAlertView visibility
 *
 * Returns if the alert is visible or not.
 */
- (BOOL)isVisible;

/** Add a custom UIView
 *
 * @param customView UIView object to be added above the first SMButton.
 */
- (UIView *)addCustomView:(UIView *)customView;

/** Set Title font family and size
 *
 * @param titleFontFamily The family name used to displayed the title.
 * @param size Font size.
 */
- (void)setTitleFontFamily:(NSString *)titleFontFamily withSize:(CGFloat)size;

/** Set Text field font family and size
 *
 * @param bodyTextFontFamily The family name used to displayed the text field.
 * @param size Font size.
 */
- (void)setBodyTextFontFamily:(NSString *)bodyTextFontFamily withSize:(CGFloat)size;

/** Set Buttons font family and size
 *
 * @param buttonsFontFamily The family name used to displayed the buttons.
 * @param size Font size.
 */
- (void)setButtonsTextFontFamily:(NSString *)buttonsFontFamily withSize:(CGFloat)size;

/** Add a Button with a title and a block to handle when the button is pressed.
 *
 * @param title The text displayed on the button.
 * @param action A block of code to be executed when the button is pressed.
 */
- (SMAlertViewButton *)addButton:(NSString *)title actionBlock:(SMActionBlock)action;

/** Add a Button with a title, a target and a selector to handle when the button is pressed.
 *
 * @param title The text displayed on the button.
 * @param target Add target for particular event.
 * @param selector A method to be executed when the button is pressed.
 */
- (SMAlertViewButton *)addButton:(NSString *)title target:(id)target selector:(SEL)selector;


/**
 显示提示框

 @param vc 需要显示在上面的控制器
 @param color 按钮颜色, custom时有效
 @param title 主标题
 @param subTitle 副标题
 @param completeText 完成按钮文字
 */
- (void)showTitle:(UIViewController *)vc color:(UIColor *)color title:(NSString *)title subTitle:(NSString *)subTitle completeText:(NSString *)completeText;


@end
