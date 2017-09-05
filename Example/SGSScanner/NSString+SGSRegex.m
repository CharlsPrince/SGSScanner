//
//  NSString+SGSRegex.m
//  SGSScanner
//
//  Created by Lee on 2017/1/16.
//  Copyright © 2017年 Lee. All rights reserved.
//

#import "NSString+SGSRegex.h"

@implementation NSString (SGSRegex)
- (BOOL)isConsists7bitASCIICharacters {
    NSString *regex = @"^[\\u0020-\\u007f]+$";
    NSPredicate *regular = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    return [regular evaluateWithObject:self];
}
@end
