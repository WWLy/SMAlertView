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

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    // 创建一个显示在window上的alert
    SMAlertView *alert = [[SMAlertView alloc] initWithNewWindow];
    
    // 横向排列按钮
    [alert setHorizontalButtons:YES];
    
    // 通过SEL方式添加按钮
    SMAlertViewButton *button = [alert addButton:@"Firsrt Button" target:self selector:@selector(firstButtonClick)];
    
    // 设置按钮的样式
    button.buttonFormatBlock = ^NSDictionary* (void)
    {
        NSMutableDictionary *buttonConfig = [[NSMutableDictionary alloc] init];
        
        buttonConfig[@"backgroundColor"] = [UIColor whiteColor];
        buttonConfig[@"textColor"] = [UIColor blackColor];
        buttonConfig[@"borderWidth"] = @2.0f;
        buttonConfig[@"borderColor"] = [UIColor greenColor];
        
        return buttonConfig;
    };
    
    // 通过block方式添加按钮
    [alert addButton:@"Second Button" actionBlock:^(void) {
        NSLog(@"Second button tapped");
    }];
    
    // 设置完成按钮的样式
    alert.completeButtonFormatBlock = ^NSDictionary* (void)
    {
        NSMutableDictionary *buttonConfig = [[NSMutableDictionary alloc] init];
        
        buttonConfig[@"backgroundColor"] = [UIColor clearColor];
        buttonConfig[@"textColor"] = [UIColor blueColor];
        buttonConfig[@"borderWidth"] = @0.0f;
        buttonConfig[@"borderColor"] = [UIColor clearColor];
        
        return buttonConfig;
    };
    
    // 点击蒙版消失
    alert.shouldDismissOnTapOutside = YES; // Default: NO
    
    // 开始移除时触发
    [alert alertIsDismissed:^{
        NSLog(@"--");
    }];
    
    // 移除动画结束后触发
    [alert alertDismissAnimationIsCompleted:^{
        NSLog(@"----");
    }];
    
    // 显示动画类型
    alert.showAnimationType = SMAlertViewShowAnimationSlideInToCenter;
    // 移除动画类型
    alert.hideAnimationType = SMAlertViewHideAnimationFadeOut;
    
    // 关键方法, 显示alert
    [alert showTitle:nil color:[UIColor greenColor] title:nil subTitle:@"请确认输入项是否正确, 请检查网络连接" completeText:@"complete"];
}

- (void)firstButtonClick {
    NSLog(@"First button tapped");
}



@end
