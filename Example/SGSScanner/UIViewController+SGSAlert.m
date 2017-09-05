//
//  UIViewController+SGSAlert.m
//  SGSScanner
//
//  Created by Lee on 2017/1/13.
//  Copyright © 2017年 Lee. All rights reserved.
//

#import "UIViewController+SGSAlert.h"

@implementation UIViewController (SGSAlert)
- (void)showAlertPanelWithTitle:(NSString *)title message:(NSString *)message handler:(void (^)())handler {
    [self showAlertWithTitle:title message:message buttonTitles:@[@"确定"] completion:^(NSUInteger idx) {
        if (handler != nil) {
            handler();
        }
    }];
}

- (void)showConfirmPanelWithTitle:(NSString *)title message:(NSString *)message handler:(void (^)(BOOL))handler {
    [self showAlertWithTitle:title message:message buttonTitles:@[@"取消", @"确定"] completion:^(NSUInteger idx) {
        if (handler != nil) {
            handler(idx==1);
        }
    }];
}

- (void)showAlertWithTitle:(NSString *)title message:(NSString *)message buttonTitles:(NSArray<NSString *> *)titles completion:(void(^)(NSUInteger idx))completion {
    if (self.view.window != nil) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
        [titles enumerateObjectsUsingBlock:^(NSString * _Nonnull title, NSUInteger idx, BOOL * _Nonnull stop) {
            UIAlertActionStyle style = (idx == 0) ? UIAlertActionStyleCancel : UIAlertActionStyleDefault;
            UIAlertAction *action = [UIAlertAction actionWithTitle:title style:style handler:^(UIAlertAction * _Nonnull action) {
                if (completion != nil) {
                    completion(idx);
                }
            }];
            [alert addAction:action];
        }];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

@end
