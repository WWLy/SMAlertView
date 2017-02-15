//
//  SMAlertView.m
//  SMAlertView
//
//  Created by WWLy on 13/02/2017.
//  Copyright © 2017 WWLy. All rights reserved.
//

#import "SMAlertView.h"
#import "SMAlertViewDefine.h"
#import "UIImage+ImageEffects.h"

#define KEYBOARD_HEIGHT 80
#define PREDICTION_BAR_HEIGHT 40
#define ADD_BUTTON_PADDING 10.0f
#define DEFAULT_WINDOW_WIDTH 240

@interface SMAlertView () <UIGestureRecognizerDelegate>

@property (strong, nonatomic) NSMutableArray                    * customViews;
@property (strong, nonatomic) NSMutableArray                    * buttons;
@property (strong, nonatomic) UIView                            * contentView;
@property (strong, nonatomic) UIWindow                          * previousWindow;
@property (strong, nonatomic) UIImageView                       * backgroundView;
@property (strong, nonatomic) UITapGestureRecognizer            * gestureRecognizer;
@property (strong, nonatomic) NSString                          * titleFontFamily;
@property (strong, nonatomic) NSString                          * bodyTextFontFamily;
@property (strong, nonatomic) NSString                          * buttonsFontFamily;
@property (strong, nonatomic) UIWindow                          * SMAlertWindow;
@property (copy,   nonatomic) SMDismissBlock                    dismissBlock;
@property (copy,   nonatomic) SMDismissAnimationCompletionBlock dismissAnimationCompletionBlock;
@property (weak,   nonatomic) UIViewController                  * rootViewController;
@property (weak,   nonatomic) id<UIGestureRecognizerDelegate> restoreInteractivePopGestureDelegate;
@property (assign, nonatomic) BOOL                              canAddObservers;
@property (assign, nonatomic) BOOL                              usingNewWindow;
@property (assign, nonatomic) BOOL                              restoreInteractivePopGestureEnabled;
@property (nonatomic        ) CGFloat                           backgroundOpacity;
@property (nonatomic        ) CGFloat                           titleFontSize;
@property (nonatomic        ) CGFloat                           bodyFontSize;
@property (nonatomic        ) CGFloat                           buttonsFontSize;
@property (nonatomic        ) CGFloat                           windowHeight;
@property (nonatomic        ) CGFloat                           windowWidth;
@property (nonatomic        ) CGFloat                           subTitleHeight;
@property (nonatomic        ) CGFloat                           subTitleY;

@end

@implementation SMAlertView

CGFloat kTitleTop;
CGFloat kTitleHeight;
CGFloat kSubTitleTop;


#pragma mark - Initialization

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:@"NSCoding not supported"
                                 userInfo:nil];
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        [self setupViewWindowWidth:DEFAULT_WINDOW_WIDTH];
    }
    return self;
}

- (instancetype)initWithWindowWidth:(CGFloat)windowWidth
{
    self = [super init];
    if (self)
    {
        [self setupViewWindowWidth:windowWidth];
    }
    return self;
}

- (instancetype)initWithNewWindow
{
    self = [self initWithWindowWidth:DEFAULT_WINDOW_WIDTH];
    if(self)
    {
        [self setupNewWindow];
    }
    return self;
}

- (instancetype)initWithNewWindowWidth:(CGFloat)windowWidth
{
    self = [self initWithWindowWidth:windowWidth];
    if(self)
    {
        [self setupNewWindow];
    }
    return self;
}



#pragma mark - Setup view

- (void)setupViewWindowWidth:(CGFloat)windowWidth
{
    // Default values
    kTitleTop                      = 0.0f;
    kTitleHeight                   = 40.0f;
    kSubTitleTop                   = 0.0f;
    self.subTitleY                 = 70.0f;
    self.subTitleHeight            = 90.0f;
    self.windowWidth               = windowWidth;
    self.windowHeight              = 148.0f;
    self.shouldDismissOnTapOutside = NO;
    self.usingNewWindow            = NO;
    self.canAddObservers           = YES;
    self.alertViewStyle            = SMAlertViewStyleCustom;
    self.hideAnimationType         = SMAlertViewHideAnimationFadeOut;
    self.showAnimationType         = SMAlertViewShowAnimationFadeIn;
    self.backgroundType            = SMAlertViewBackgroundShadow;
    
    // Font
    _titleFontFamily    = @"HelveticaNeue";
    _bodyTextFontFamily = @"HelveticaNeue";
    _buttonsFontFamily  = @"HelveticaNeue-Bold";
    _titleFontSize      = 20.0f;
    _bodyFontSize       = 14.0f;
    _buttonsFontSize    = 14.0f;
    
    // Init
    _titleLabel     = [[UILabel alloc] init];
    _textView       = [[UITextView alloc] init];
    _contentView    = [[UIView alloc] init];
    _backgroundView = [[UIImageView alloc]initWithFrame:[self mainScreenFrame]];
    _buttons        = [[NSMutableArray alloc] init];
    _customViews    = [[NSMutableArray alloc] init];
    
    // Add Subviews
    [self.view addSubview:_contentView];
    
    // Background View
    _backgroundView.userInteractionEnabled = YES;
    
    // TitleLabel
    _titleLabel.numberOfLines = 1;
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    _titleLabel.font          = [UIFont fontWithName:_titleFontFamily size:_titleFontSize];
    _titleLabel.frame         = CGRectMake(12.0f, kTitleTop, _windowWidth - 24.0f, kTitleHeight);
    
    // TextView
    _textView.editable                    = NO;
    _textView.allowsEditingTextAttributes = YES;
    _textView.textAlignment               = NSTextAlignmentCenter;
    _textView.font                        = [UIFont fontWithName:_bodyTextFontFamily size:_bodyFontSize];
    _textView.frame                       = CGRectMake(12.0f, _subTitleY, _windowWidth - 24.0f, _subTitleHeight);

    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        _textView.textContainerInset = UIEdgeInsetsZero;
        _textView.textContainer.lineFragmentPadding = 0;
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    // Content View
    _contentView.backgroundColor     = [UIColor redColor];
    _contentView.layer.cornerRadius  = 5.0f;
    _contentView.layer.masksToBounds = YES;
    _contentView.layer.borderWidth   = 0.5f;
    [_contentView addSubview:_textView];
    
    CGRect position   = [self.contentView convertRect:self.titleLabel.frame toView:self.view];
    _titleLabel.frame = position;
    [self.view addSubview:_titleLabel];
    
    // Colors
    self.backgroundViewColor       = [UIColor whiteColor];
    _titleLabel.textColor          = UIColorFromHEX(0x4D4D4D);         // Dark Grey
    _textView.textColor            = UIColorFromHEX(0x4D4D4D);         // Dark Grey
    _contentView.layer.borderColor = UIColorFromHEX(0xCCCCCC).CGColor; // Light Grey
}

- (void)setupNewWindow
{
    // Create a new one to show the alert
    UIWindow *alertWindow = [[UIWindow alloc] initWithFrame:[self mainScreenFrame]];
    alertWindow.windowLevel = UIWindowLevelAlert;
    alertWindow.backgroundColor = [UIColor clearColor];
    alertWindow.rootViewController = self;
    self.SMAlertWindow = alertWindow;
    
    self.usingNewWindow = YES;
}

#pragma mark - Modal Validation

- (BOOL)isModal
{
    return (_rootViewController != nil && _rootViewController.presentingViewController);
}

#pragma mark - View Cycle

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    CGSize sz = [self mainScreenFrame].size;
    if([self isModal] && !_usingNewWindow)
    {
        sz = _rootViewController.view.frame.size;
    }
    
    if (SYSTEM_VERSION_LESS_THAN(@"8.0"))
    {
        // iOS versions before 7.0 did not switch the width and height on device roration
        if (UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation))
        {
            CGSize ssz = sz;
            sz = CGSizeMake(ssz.height, ssz.width);
        }
    }
    
    if(!_usingNewWindow)
    {
        // Set new background frame
        CGRect newBackgroundFrame = self.backgroundView.frame;
        newBackgroundFrame.size   = sz;
        self.backgroundView.frame = newBackgroundFrame;
        
        // Set new main frame
        CGRect r;
        if (self.view.superview != nil)
        {
            // View is showing, position at center of screen
            r = CGRectMake((sz.width-_windowWidth)/2, (sz.height-_windowHeight)/2, _windowWidth, _windowHeight);
        }
        else
        {
            // View is not visible, position outside screen bounds
            r = CGRectMake((sz.width-_windowWidth)/2, -_windowHeight, _windowWidth, _windowHeight);
        }
        
        // Set frames
        self.view.frame = r;
        _contentView.frame = CGRectMake(0.0f, 0.0f, _windowWidth, _windowHeight);
        _titleLabel.frame = CGRectMake(12.0f, kTitleTop, _windowWidth - 24.0f, kTitleHeight);
    }
    else
    {
        CGFloat x = (sz.width - _windowWidth) / 2;
        CGFloat y = (sz.height - _windowHeight) / 2;
        _contentView.frame = CGRectMake(x, y, _windowWidth, _windowHeight);
        _titleLabel.frame  = CGRectMake(12.0f + self.contentView.frame.origin.x, kTitleTop + self.contentView.frame.origin.y, _windowWidth - 24.0f, kTitleHeight);
    }
    
    // 如果没有主标题
    if (_titleLabel.text == nil) {
        kSubTitleTop = 10.0f;
        _windowHeight += kSubTitleTop / 2;
    }
    CGFloat y = (_titleLabel.text == nil) ? (kTitleTop + kSubTitleTop) : kTitleTop + _titleLabel.frame.size.height;
    _textView.frame = CGRectMake(12.0f, y, _windowWidth - 24.0f, _subTitleHeight);
    
    if (!_titleLabel && !_textView) {
        y = 0.0f;
    }
    y += _subTitleHeight + 14.0f;
    
    // Custom views
    for (UIView *view in _customViews)
    {
        view.frame = CGRectMake(12.0f, y, view.frame.size.width, view.frame.size.height);
        y += view.frame.size.height + 10.0f;
    }
 
    // Buttons
    CGFloat x = 12.0f;
    for (SMAlertViewButton *btn in _buttons)
    {
        btn.frame = CGRectMake(x, y, btn.frame.size.width, btn.frame.size.height);
        
        // Add horizontal or vertical offset acording on _horizontalButtons parameter
        if (_horizontalButtons) {
            x += btn.frame.size.width + 10.0f;
        } else {
            y += btn.frame.size.height + 10.0f;
        }
    }
    
    // Adapt window height according to icon size
    _contentView.frame = CGRectMake(_contentView.frame.origin.x, _contentView.frame.origin.y, _windowWidth, _windowHeight);
    
    // Adjust corner radius, if a value has been passed
    _contentView.layer.cornerRadius = self.cornerRadius ? self.cornerRadius : 5.0f;
}

#pragma mark - UIViewController

- (BOOL)prefersStatusBarHidden
{
    return self.statusBarHidden;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return self.statusBarStyle;
}

#pragma mark - Handle gesture

- (void)handleTap:(UITapGestureRecognizer *)gesture
{
    if (_shouldDismissOnTapOutside)
    {
        BOOL hide = _shouldDismissOnTapOutside;

        if(hide)[self hideView];
    }
}

- (void)setShouldDismissOnTapOutside:(BOOL)shouldDismissOnTapOutside
{
    _shouldDismissOnTapOutside = shouldDismissOnTapOutside;
    
    if(_shouldDismissOnTapOutside)
    {
        self.gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
        [_usingNewWindow ? _SMAlertWindow : _backgroundView addGestureRecognizer:_gestureRecognizer];
    }
}

- (void)disableInteractivePopGesture
{
    UINavigationController *navigationController;
    
    if([_rootViewController isKindOfClass:[UINavigationController class]])
    {
        navigationController = ((UINavigationController*)_rootViewController);
    }
    else
    {
        navigationController = _rootViewController.navigationController;
    }
    
    // Disable iOS 7 back gesture
    if ([navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)])
    {
        _restoreInteractivePopGestureEnabled  = navigationController.interactivePopGestureRecognizer.enabled;
        _restoreInteractivePopGestureDelegate = navigationController.interactivePopGestureRecognizer.delegate;
        navigationController.interactivePopGestureRecognizer.enabled  = NO;
        navigationController.interactivePopGestureRecognizer.delegate = self;
    }
}

- (void)restoreInteractivePopGesture
{
    UINavigationController *navigationController;
    
    if([_rootViewController isKindOfClass:[UINavigationController class]])
    {
        navigationController = ((UINavigationController*)_rootViewController);
    }
    else
    {
        navigationController = _rootViewController.navigationController;
    }
    
    // Restore iOS 7 back gesture
    if ([navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)])
    {
        navigationController.interactivePopGestureRecognizer.enabled  = _restoreInteractivePopGestureEnabled;
        navigationController.interactivePopGestureRecognizer.delegate = _restoreInteractivePopGestureDelegate;
    }
}

#pragma mark - Custom Fonts

- (void)setTitleFontFamily:(NSString *)titleFontFamily withSize:(CGFloat)size
{
    self.titleFontFamily = titleFontFamily;
    self.titleFontSize = size;
    self.titleLabel.font = [UIFont fontWithName:_titleFontFamily size:_titleFontSize];
}

- (void)setBodyTextFontFamily:(NSString *)bodyTextFontFamily withSize:(CGFloat)size
{
    self.bodyTextFontFamily = bodyTextFontFamily;
    self.bodyFontSize = size;
    self.textView.font = [UIFont fontWithName:_bodyTextFontFamily size:_bodyFontSize];
}

- (void)setButtonsTextFontFamily:(NSString *)buttonsFontFamily withSize:(CGFloat)size
{
    self.buttonsFontFamily = buttonsFontFamily;
    self.buttonsFontSize = size;
}

#pragma mark - Background Color

- (void)setBackgroundViewColor:(UIColor *)backgroundViewColor
{
    _backgroundViewColor = backgroundViewColor;
    _contentView.backgroundColor = _backgroundViewColor;
    _textView.backgroundColor = _backgroundViewColor;
}

#pragma mark - UICustomView

- (UIView *)addCustomView:(UIView *)customView
{
    // Update view height
    self.windowHeight += customView.bounds.size.height + 10.0f;
    
    [_contentView addSubview:customView];
    [_customViews addObject:customView];
    
    return customView;
}

#pragma mark - Buttons

- (SMAlertViewButton *)addButton:(NSString *)title
{
    // Add button
    SMAlertViewButton *btn = [[SMAlertViewButton alloc] initWithWindowWidth:self.windowWidth];
    btn.layer.masksToBounds = YES;
    [btn setTitle:title forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont fontWithName:_buttonsFontFamily size:_buttonsFontSize];
    
    [_contentView addSubview:btn];
    [_buttons addObject:btn];
    
    if (_horizontalButtons) {
        // Update buttons width according to the number of buttons
        for (SMAlertViewButton *tempBtn in _buttons) {
            [tempBtn adjustWidthWithWindowWidth:self.windowWidth numberOfButtons:[_buttons count]];
        }
        
        // Update view height
        if (!([_buttons count] > 1)) {
            self.windowHeight += (btn.frame.size.height + ADD_BUTTON_PADDING);
        }
    } else {
        // Update view height
        self.windowHeight += (btn.frame.size.height + ADD_BUTTON_PADDING);
    }
    
    return btn;
}

- (SMAlertViewButton *)addDoneButtonWithTitle:(NSString *)title
{
    SMAlertViewButton *btn = [self addButton:title];
    
    if (_completeButtonFormatBlock != nil)
    {
        btn.completeButtonFormatBlock = _completeButtonFormatBlock;
    }
    
    [btn addTarget:self action:@selector(hideView) forControlEvents:UIControlEventTouchUpInside];
    
    return btn;
}

- (SMAlertViewButton *)addButton:(NSString *)title actionBlock:(SMActionBlock)action
{
    SMAlertViewButton *btn = [self addButton:title];
    
    if (_buttonFormatBlock != nil)
    {
        btn.buttonFormatBlock = _buttonFormatBlock;
    }
    
    btn.actionType = SMBlock;
    btn.actionBlock = action;
    [btn addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    return btn;
}

- (SMAlertViewButton *)addButton:(NSString *)title target:(id)target selector:(SEL)selector
{
    SMAlertViewButton *btn = [self addButton:title];
    btn.actionType = SMSelector;
    btn.target = target;
    btn.selector = selector;
    [btn addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    return btn;
}

- (void)buttonTapped:(SMAlertViewButton *)btn
{

    if (btn.actionType == SMBlock)
    {
        if (btn.actionBlock)
            btn.actionBlock();
    }
    else if (btn.actionType == SMSelector)
    {
        UIControl *ctrl = [[UIControl alloc] init];
        [ctrl sendAction:btn.selector to:btn.target forEvent:nil];
    }
    else
    {
        NSLog(@"Unknown action type for button");
    }
    
    if([self isVisible])
    {
        [self hideView];
    }
}


#pragma mark - Show Alert

- (void)showTitle:(UIViewController *)vc color:(UIColor *)color title:(NSString *)title subTitle:(NSString *)subTitle completeText:(NSString *)completeText
{
    if(_usingNewWindow)
    {
        // Save previous window
        self.previousWindow = [UIApplication sharedApplication].keyWindow;
        self.backgroundView.frame = _SMAlertWindow.bounds;
        
        // Add window subview
        [_SMAlertWindow addSubview:_backgroundView];
    }
    else
    {
        _rootViewController = vc;
        
        [self disableInteractivePopGesture];
        
        self.backgroundView.frame = vc.view.bounds;
        
        // Add view controller subviews
        [_rootViewController addChildViewController:self];
        [_rootViewController.view addSubview:_backgroundView];
        [_rootViewController.view addSubview:self.view];
    }
    
    self.view.alpha = 0.0f;
    [self setBackground];
    
    // Alert color
    UIColor *viewColor = color;
    
    // Custom Alert color
    if(_customViewColor)
    {
        viewColor = _customViewColor;
    }
    
    // Title
    if([title stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length > 0)
    {
        self.titleLabel.text = title;
    }
    else
    {
        // Title is nil, we can move the body message to center and remove it from superView
        self.windowHeight -= _titleLabel.frame.size.height;
        [_titleLabel removeFromSuperview];
        _titleLabel = nil;

        _subTitleY = -20;
    }
    
    // Subtitle
    if([subTitle stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length > 0)
    {
        // No custom text
        if (_attributedFormatBlock == nil)
        {
            _textView.text = subTitle;
        }
        else
        {
            self.textView.font = [UIFont fontWithName:_bodyTextFontFamily size:_bodyFontSize];
            _textView.attributedText = self.attributedFormatBlock(subTitle);
        }
        
        // Adjust text view size, if necessary
        CGSize sz = CGSizeMake(_windowWidth - 24.0f, CGFLOAT_MAX);
        
        CGSize size = [_textView sizeThatFits:sz];
        
        CGFloat ht = ceilf(size.height);
        if (ht < _subTitleHeight)
        {
            self.windowHeight -= (_subTitleHeight - ht);
            self.subTitleHeight = ht;
        }
        else
        {
            self.windowHeight += (ht - _subTitleHeight);
            self.subTitleHeight = ht;
        }
        _textView.frame = CGRectMake(12.0f, _subTitleY, _windowWidth - 24.0f, _subTitleHeight);
    }
    else
    {
        // Subtitle is nil, we can move the title to center and remove it from superView
        self.subTitleHeight = 0.0f;
        self.windowHeight -= _textView.frame.size.height;
        [_textView removeFromSuperview];
        _textView = nil;
        
        // Move up
        _titleLabel.frame = CGRectMake(12.0f, 37.0f, _windowWidth - 24.0f, kTitleHeight);
    }
    
    if (!_titleLabel && !_textView) {
        self.windowHeight -= kTitleTop;
    }
    
    // Add button, if necessary
    if(completeText != nil)
    {
        [self addDoneButtonWithTitle:completeText];
    }
    
    for (SMAlertViewButton *btn in _buttons)
    {
        if (!btn.defaultBackgroundColor) {
            btn.defaultBackgroundColor = viewColor;
        }
        
        if (btn.completeButtonFormatBlock != nil)
        {
            [btn parseConfig:btn.completeButtonFormatBlock()];
        }
        else if (btn.buttonFormatBlock != nil)
        {
            [btn parseConfig:btn.buttonFormatBlock()];
        }
    }
    
    if(_usingNewWindow)
    {
        [_SMAlertWindow makeKeyAndVisible];
    }
    
    // Show the alert view
    [self showView];
}


#pragma mark - Visibility

- (BOOL)isVisible
{
    return (self.view.alpha);
}

// 开始消失时触发
- (void)alertIsDismissed:(SMDismissBlock)dismissBlock
{
    self.dismissBlock = dismissBlock;
}

// 动画结束后触发
- (void)alertDismissAnimationIsCompleted:(SMDismissAnimationCompletionBlock)dismissAnimationCompletionBlock{
    self.dismissAnimationCompletionBlock = dismissAnimationCompletionBlock;
}

- (SMForceHideBlock)forceHideBlock:(SMForceHideBlock)forceHideBlock
{
    _forceHideBlock = forceHideBlock;
    
    if (_forceHideBlock)
    {
        [self hideView];
    }
    return _forceHideBlock;
}

- (CGRect)mainScreenFrame
{
    return [UIApplication sharedApplication].keyWindow.bounds;
}


#pragma mark - Background Effects

- (void)makeShadowBackground
{
    _backgroundView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    _backgroundView.backgroundColor = [UIColor blackColor];
    _backgroundView.alpha = 0.7f;
    _backgroundOpacity = 0.7f;
}

- (void)makeBlurBackground
{
    UIView *appView = (_usingNewWindow) ? [UIApplication sharedApplication].keyWindow.subviews.lastObject : _rootViewController.view;
    UIImage *image = [UIImage convertViewToImage:appView];
    UIImage *blurSnapshotImage = [image applyBlurWithRadius:5.0f
                                                  tintColor:[UIColor colorWithWhite:0.2f
                                                                              alpha:0.7f]
                                      saturationDeltaFactor:1.8f
                                                  maskImage:nil];
    
    _backgroundView.image = blurSnapshotImage;
    _backgroundView.alpha = 0.0f;
    _backgroundOpacity = 1.0f;
}

- (void)makeTransparentBackground
{
    _backgroundView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    _backgroundView.backgroundColor = [UIColor clearColor];
    _backgroundView.alpha = 0.0f;
    _backgroundOpacity = 1.0f;
}

- (void)setBackground
{
    switch (_backgroundType)
    {
        case SMAlertViewBackgroundShadow:
            [self makeShadowBackground];
            break;
            
        case SMAlertViewBackgroundBlur:
            [self makeBlurBackground];
            break;
            
        case SMAlertViewBackgroundTransparent:
            [self makeTransparentBackground];
            break;
    }
}


#pragma mark - Show Alert

- (void)showView
{
    switch (_showAnimationType)
    {
        case SMAlertViewShowAnimationFadeIn:
            [self fadeIn];
            break;
            
        case SMAlertViewShowAnimationSlideInFromBottom:
            [self slideInFromBottom];
            break;
            
        case SMAlertViewShowAnimationSlideInFromTop:
            [self slideInFromTop];
            break;
            
        case SMAlertViewShowAnimationSlideInFromLeft:
            [self slideInFromLeft];
            break;
            
        case SMAlertViewShowAnimationSlideInFromRight:
            [self slideInFromRight];
            break;
            
        case SMAlertViewShowAnimationSlideInFromCenter:
            [self slideInFromCenter];
            break;
            
        case SMAlertViewShowAnimationSlideInToCenter:
            [self slideInToCenter];
            break;
            
        case SMAlertViewShowAnimationSimplyAppear:
            [self simplyAppear];
            break;
    }
}

#pragma mark - Show Animations

- (void)fadeIn
{
    self.backgroundView.alpha = 0.0f;
    self.view.alpha = 0.0f;
    
    [UIView animateWithDuration:0.2f
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         self.backgroundView.alpha = _backgroundOpacity;
                         self.view.alpha = 1.0f;
                     }
                     completion:nil];
}

- (void)slideInFromTop
{
    if (SYSTEM_VERSION_LESS_THAN(@"7.0"))
    {
        //From Frame
        CGRect frame = self.backgroundView.frame;
        frame.origin.y = -self.backgroundView.frame.size.height;
        self.view.frame = frame;
        
        [UIView animateWithDuration:0.3f animations:^{
            self.backgroundView.alpha = _backgroundOpacity;
            
            //To Frame
            CGRect frame = self.backgroundView.frame;
            frame.origin.y = 0.0f;
            self.view.frame = frame;
            
            self.view.alpha = 1.0f;
        } completion:^(BOOL completed) {
            [UIView animateWithDuration:0.2f animations:^{
                self.view.center = _backgroundView.center;
            }];
        }];
    }
    else {
        //From Frame
        CGRect frame = self.backgroundView.frame;
        frame.origin.y = -self.backgroundView.frame.size.height;
        self.view.frame = frame;
        
        [UIView animateWithDuration:0.5f delay:0.0f usingSpringWithDamping:0.6f initialSpringVelocity:0.5f options:0 animations:^{
            self.backgroundView.alpha = _backgroundOpacity;
            
            //To Frame
            CGRect frame = self.backgroundView.frame;
            frame.origin.y = 0.0f;
            self.view.frame = frame;
            
            self.view.alpha = 1.0f;
        } completion:^(BOOL finished) {
            // nothing
        }];
    }
}

- (void)slideInFromBottom
{
    //From Frame
    CGRect frame = self.backgroundView.frame;
    frame.origin.y = self.backgroundView.frame.size.height;
    self.view.frame = frame;
    
    [UIView animateWithDuration:0.3f animations:^{
        self.backgroundView.alpha = _backgroundOpacity;
        
        //To Frame
        CGRect frame = self.backgroundView.frame;
        frame.origin.y = 0.0f;
        self.view.frame = frame;
        
        self.view.alpha = 1.0f;
    } completion:^(BOOL completed) {
        [UIView animateWithDuration:0.2f animations:^{
            self.view.center = _backgroundView.center;
        }];
    }];
}

- (void)slideInFromLeft
{
    //From Frame
    CGRect frame = self.backgroundView.frame;
    frame.origin.x = -self.backgroundView.frame.size.width;
    self.view.frame = frame;
    
    [UIView animateWithDuration:0.3f animations:^{
        self.backgroundView.alpha = _backgroundOpacity;
        
        //To Frame
        CGRect frame = self.backgroundView.frame;
        frame.origin.x = 0.0f;
        self.view.frame = frame;
        
        self.view.alpha = 1.0f;
    } completion:^(BOOL completed) {
        [UIView animateWithDuration:0.2f animations:^{
            self.view.center = _backgroundView.center;
        }];
    }];
}

- (void)slideInFromRight
{
    //From Frame
    CGRect frame = self.backgroundView.frame;
    frame.origin.x = self.backgroundView.frame.size.width;
    self.view.frame = frame;
    
    [UIView animateWithDuration:0.3f animations:^{
        self.backgroundView.alpha = _backgroundOpacity;
        
        //To Frame
        CGRect frame = self.backgroundView.frame;
        frame.origin.x = 0.0f;
        self.view.frame = frame;
        
        self.view.alpha = 1.0f;
    } completion:^(BOOL completed) {
        [UIView animateWithDuration:0.2f animations:^{
            self.view.center = _backgroundView.center;
        }];
    }];
}

- (void)slideInFromCenter
{
    //From Frame
    self.view.transform = CGAffineTransformConcat(CGAffineTransformIdentity,
                                                  CGAffineTransformMakeScale(3.0f, 3.0f));
    self.view.alpha = 0.0f;
    
    [UIView animateWithDuration:0.3f animations:^{
        self.backgroundView.alpha = _backgroundOpacity;
        
        //To Frame
        self.view.transform = CGAffineTransformConcat(CGAffineTransformIdentity,
                                                      CGAffineTransformMakeScale(1.0f, 1.0f));
        self.view.alpha = 1.0f;
    } completion:^(BOOL completed) {
        [UIView animateWithDuration:0.2f animations:^{
            self.view.center = _backgroundView.center;
        }];
    }];
}

- (void)slideInToCenter
{
    //From Frame
    self.view.transform = CGAffineTransformConcat(CGAffineTransformIdentity,
                                                  CGAffineTransformMakeScale(0.1f, 0.1f));
    self.view.alpha = 0.0f;
    
    [UIView animateWithDuration:0.3f animations:^{
        self.backgroundView.alpha = _backgroundOpacity;
        
        //To Frame
        self.view.transform = CGAffineTransformConcat(CGAffineTransformIdentity,
                                                      CGAffineTransformMakeScale(1.0f, 1.0f));
        self.view.alpha = 1.0f;
    } completion:^(BOOL completed) {
        [UIView animateWithDuration:0.2f animations:^{
            self.view.center = _backgroundView.center;
        }];
    }];
}

- (void)simplyAppear
{
    self.backgroundView.alpha = 0.0f;
    self.view.alpha = 0.0f;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.backgroundView.alpha = _backgroundOpacity;
        self.view.alpha = 1.0f;
    });
}


#pragma mark - Hide Alert

- (void)hideView
{
    switch (_hideAnimationType)
    {
        case SMAlertViewHideAnimationFadeOut:
            [self fadeOut];
            break;
            
        case SMAlertViewHideAnimationSlideOutToBottom:
            [self slideOutToBottom];
            break;
            
        case SMAlertViewHideAnimationSlideOutToTop:
            [self slideOutToTop];
            break;
            
        case SMAlertViewHideAnimationSlideOutToLeft:
            [self slideOutToLeft];
            break;
            
        case SMAlertViewHideAnimationSlideOutToRight:
            [self slideOutToRight];
            break;
            
        case SMAlertViewHideAnimationSlideOutToCenter:
            [self slideOutToCenter];
            break;
            
        case SMAlertViewHideAnimationSlideOutFromCenter:
            [self slideOutFromCenter];
            break;
            
        case SMAlertViewHideAnimationSimplyDisappear:
            [self simplyDisappear];
            break;
    }

    if (self.dismissBlock)
    {
        self.dismissBlock();
    }
    
    if (_usingNewWindow)
    {
        // Restore previous window
        [self.previousWindow makeKeyAndVisible];
        self.previousWindow = nil;
    }
    
    for (SMAlertViewButton *btn in _buttons)
    {
        btn.actionBlock = nil;
        btn.target = nil;
        btn.selector = nil;
    }
}

#pragma mark - Hide Animations

- (void)fadeOut
{
    [self fadeOutWithDuration:0.2f];
}

- (void)fadeOutWithDuration:(NSTimeInterval)duration
{
    [UIView animateWithDuration:duration animations:^{
        self.backgroundView.alpha = 0.0f;
        self.view.alpha = 0.0f;
    } completion:^(BOOL completed) {
        [self.backgroundView removeFromSuperview];
        if (_usingNewWindow)
        {
            // Remove current window
            [self.SMAlertWindow setHidden:YES];
            self.SMAlertWindow = nil;
        }
        else
        {
            [self.view removeFromSuperview];
            [self removeFromParentViewController];
        }
        if ( _dismissAnimationCompletionBlock ){
            self.dismissAnimationCompletionBlock();
        }
    }];
}

- (void)slideOutToBottom
{
    [UIView animateWithDuration:0.3f animations:^{
        CGRect frame = self.view.frame;
        frame.origin.y += self.backgroundView.frame.size.height;
        self.view.frame = frame;
    } completion:^(BOOL completed) {
        [self fadeOut];
    }];
}

- (void)slideOutToTop
{
    [UIView animateWithDuration:0.3f animations:^{
        CGRect frame = self.view.frame;
        frame.origin.y -= self.backgroundView.frame.size.height;
        self.view.frame = frame;
    } completion:^(BOOL completed) {
        [self fadeOut];
    }];
}

- (void)slideOutToLeft
{
    [UIView animateWithDuration:0.3f animations:^{
        CGRect frame = self.view.frame;
        frame.origin.x -= self.backgroundView.frame.size.width;
        self.view.frame = frame;
    } completion:^(BOOL completed) {
        [self fadeOut];
    }];
}

- (void)slideOutToRight
{
    [UIView animateWithDuration:0.3f animations:^{
        CGRect frame = self.view.frame;
        frame.origin.x += self.backgroundView.frame.size.width;
        self.view.frame = frame;
    } completion:^(BOOL completed) {
        [self fadeOut];
    }];
}

- (void)slideOutToCenter
{
    [UIView animateWithDuration:0.3f animations:^{
        self.view.transform =
        CGAffineTransformConcat(CGAffineTransformIdentity,
                                CGAffineTransformMakeScale(0.1f, 0.1f));
        self.view.alpha = 0.0f;
    } completion:^(BOOL completed) {
        [self fadeOut];
    }];
}

- (void)slideOutFromCenter
{
    [UIView animateWithDuration:0.3f animations:^{
        self.view.transform =
        CGAffineTransformConcat(CGAffineTransformIdentity,
                                CGAffineTransformMakeScale(3.0f, 3.0f));
        self.view.alpha = 0.0f;
    } completion:^(BOOL completed) {
        [self fadeOut];
    }];
}

- (void)simplyDisappear
{
    self.backgroundView.alpha = _backgroundOpacity;
    self.view.alpha = 1.0f;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self fadeOutWithDuration:0];
    });
}



@end
