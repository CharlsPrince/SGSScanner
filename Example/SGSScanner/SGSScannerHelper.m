//
//  SGSScannerHelper.m
//  SGSScanner
//
//  Created by Lee on 2017/1/13.
//  Copyright © 2017年 Lee. All rights reserved.
//

#import "SGSScannerHelper.h"
#import "SGSScanResultViewController.h"
#import "UIViewController+SGSAlert.h"
#import "UIStoryboard+SGS.h"

@implementation SGSScannerHelper

- (void)dealloc {
    NSLog(@"扫描代理销毁");
}

- (void)scannerViewController:(__kindof UIViewController *)viewController didFinishScanWithResultMessage:(NSString *)message {
    NSLog(@"扫描结果: %@", message);
    if (message == nil) {
        [self gotoScanResultViewControllerWithMessage:message from:viewController];
        return;
    }
    
    if (![message hasPrefix:@"http"]) {
        [self gotoScanResultViewControllerWithMessage:message from:viewController];
        return;
    }
    
    NSURL *url = [NSURL URLWithString:message];
    if (url == nil) {
        [self gotoScanResultViewControllerWithMessage:message from:viewController];
        return;
    }
    
    [viewController showConfirmPanelWithTitle:@"是否要在网页中打开？" message:nil handler:^(BOOL confirm) {
        if (confirm) {
            [self openSafariWithURL:url];
        } else {
            [self gotoScanResultViewControllerWithMessage:message from:viewController];
        }
    }];
}

- (void)openSafariWithURL:(NSURL *)url {
    UIApplication *app = [UIApplication sharedApplication];
    
    if ([app respondsToSelector:@selector(openURL:options:completionHandler:)]) {
        [app openURL:url options:@{} completionHandler:nil];
    } else {
        [app openURL:url];
    }
}

- (void)gotoScanResultViewControllerWithMessage:(NSString *)message from:(UIViewController *)viewController {
    SGSScanResultViewController *vc = [UIStoryboard viewControllerInMainStoryboardWithIdentifier:@"SGSScanResultViewController"];
    if ([vc isKindOfClass:[SGSScanResultViewController class]]) {
        vc.scanResult = message;
    }
    
    if (vc) {
        [viewController.navigationController pushViewController:vc animated:YES];
    }
}

@end
