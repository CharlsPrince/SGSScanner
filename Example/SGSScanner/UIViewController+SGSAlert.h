//
//  UIViewController+SGSAlert.h
//  SGSScanner
//
//  Created by Lee on 2017/1/13.
//  Copyright © 2017年 Lee. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (SGSAlert)
- (void)showAlertPanelWithTitle:(NSString *)title message:(NSString *)message handler:(void(^)())handler;
- (void)showConfirmPanelWithTitle:(NSString *)title message:(NSString *)message handler:(void(^)(BOOL confirm))handler;
@end
