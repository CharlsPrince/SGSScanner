//
//  UIStoryboard+SGS.h
//  SGSScanner
//
//  Created by Lee on 2017/1/13.
//  Copyright © 2017年 Lee. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIStoryboard (SGS)
+ (__kindof UIViewController *)viewControllerInMainStoryboardWithIdentifier:(NSString *)identifier;
@end
