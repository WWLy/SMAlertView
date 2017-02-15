//
//  ViewController.m
//  SMAlertView
//
//  Created by WWLy on 13/02/2017.
//  Copyright © 2017 WWLy. All rights reserved.
//

#import "ViewController.h"
#import "SMAlertView.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    SMAlertView *alert = [[SMAlertView alloc] initWithNewWindow];
    
    [alert setHorizontalButtons:YES];
    
    SMAlertViewButton *button = [alert addButton:@"Firsrt Button" target:self selector:@selector(firstButton)];
    button.buttonFormatBlock = ^NSDictionary* (void)
    {
        NSMutableDictionary *buttonConfig = [[NSMutableDictionary alloc] init];
        
        buttonConfig[@"backgroundColor"] = [UIColor whiteColor];
        buttonConfig[@"textColor"] = [UIColor blackColor];
        buttonConfig[@"borderWidth"] = @2.0f;
        buttonConfig[@"borderColor"] = [UIColor greenColor];
        
        return buttonConfig;
    };
    
    [alert addButton:@"Second Button" actionBlock:^(void) {
        NSLog(@"Second button tapped");
    }];
    
    
    [alert alertIsDismissed:^{
        NSLog(@"--");
    }];
    
    // 动画结束后触发
    [alert alertDismissAnimationIsCompleted:^{
        NSLog(@"----");
    }];
    
    alert.showAnimationType = SMAlertViewShowAnimationSlideInToCenter;
    alert.hideAnimationType = SMAlertViewHideAnimationFadeOut;
    
    [alert showTitle:nil color:[UIColor greenColor] title:nil subTitle:@"请确认输入项是否正确, 请检查网络连接" completeText:@"complete"];
}

- (void)firstButton {
    NSLog(@"First button tapped");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
