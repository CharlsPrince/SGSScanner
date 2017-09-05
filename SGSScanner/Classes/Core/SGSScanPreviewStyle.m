/*!
 *  @header SGSScanPreviewStyle.m
 *
 *  @author Created by Lee on 16/10/24.
 *
 *  @copyright 2016年 SouthGIS. All rights reserved.
 */

#import "SGSScanPreviewStyle.h"

@implementation SGSScanPreviewStyle

- (instancetype)init {
    self = [super init];
    if (self) {
        _animationStyle = SGSScanAnimationStyleNone;
        
        _controlCornerStyle      = SGSScanControlCornerStyleOuter;
        _controlCornerColor      = [UIColor orangeColor];
        _controlCornerWidth      = 20.0;
        _controlCornerHeight     = 20.0;
        _controlCornerLineWidth  = 5.0;
        
        _animationImageHeight = -1;
        
        _regionOfInterestOutlineColor = [UIColor whiteColor];
        _regionOfInterestOutlineWidth = 2.0;
        
        _maskColor   = [UIColor blackColor];
        _maskOpacity = 0.6;
    }
    return self;
}

@end
