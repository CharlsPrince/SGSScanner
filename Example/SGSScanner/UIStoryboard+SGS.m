//
//  UIStoryboard+SGS.m
//  SGSScanner
//
//  Created by Lee on 2017/1/13.
//  Copyright © 2017年 Lee. All rights reserved.
//

#import "UIStoryboard+SGS.h"

@implementation UIStoryboard (SGS)
+ (UIViewController *)viewControllerInMainStoryboardWithIdentifier:(NSString *)identifier {
    return [[self storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:identifier];
}
@end
