/*!
 *  @header NSBundle+SGSScanner.m
 *
 *  @author Created by Lee on 16/10/14.
 *
 *  @copyright 2016年 SouthGIS. All rights reserved.
 */

#import "NSBundle+SGSScanner.h"
#import "SGSScanUtil.h"

@implementation NSBundle (SGSScanner)

+ (instancetype)sgsScannerBundle {
    static NSBundle *sgsScannerResources = nil;
    if (sgsScannerResources == nil) {
        sgsScannerResources = [self bundleWithURL:[self p_sgsScannerBundleURL]];
    }
    return sgsScannerResources;
}

+ (UIImage *)sgsScannerBlueLineImage {
    static UIImage *blueLineImage = nil;
    if (blueLineImage == nil) {
        blueLineImage = [UIImage imageWithContentsOfFile:[[self sgsScannerBundle] pathForResource:@"scanner_blue_line" ofType:@"png"]];
    }
    return blueLineImage;
}

+ (UIImage *)sgsScannerGreenLineImage {
    static UIImage *greenLineImage = nil;
    if (greenLineImage == nil) {
        greenLineImage = [UIImage imageWithContentsOfFile:[[self sgsScannerBundle] pathForResource:@"scanner_green_line" ofType:@"png"]];
    }
    return greenLineImage;
}

+ (UIImage *)sgsScannerGridImage {
    static UIImage *gridImage = nil;
    if (gridImage == nil) {
        gridImage = [UIImage imageWithContentsOfFile:[[self sgsScannerBundle] pathForResource:@"scanner_grid" ofType:@"png"]];
    }
    return gridImage;
}

+ (UIImage *)sgsScannerNavBackNormalImage {
    static UIImage *navBackNormalImage = nil;
    if (navBackNormalImage == nil) {
        navBackNormalImage = [UIImage imageWithContentsOfFile:[[self sgsScannerBundle] pathForResource:@"scanner_nav_back_normal" ofType:@"png"]];
    }
    return navBackNormalImage;
}

+ (UIImage *)sgsScannerNavBackPressedImage {
    static UIImage *navBackPressedImage = nil;
    if (navBackPressedImage == nil) {
        navBackPressedImage = [UIImage imageWithContentsOfFile:[[self sgsScannerBundle] pathForResource:@"scanner_nav_back_pressed" ofType:@"png"]];
    }
    return navBackPressedImage;
}

+ (NSURL *)p_sgsScannerBundleURL {
    NSBundle *bundle = [NSBundle bundleForClass:[SGSScanUtil class]];
    return [bundle URLForResource:@"SGSScanner" withExtension:@"bundle"];
}

@end
