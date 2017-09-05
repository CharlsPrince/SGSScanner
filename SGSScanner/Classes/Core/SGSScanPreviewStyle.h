/*!
 *  @header SGSScanPreviewStyle.h
 *
 *  @abstract 扫一扫预览视图样式
 *
 *  @author Created by Lee on 16/10/24.
 *
 *  @copyright 2016年 SouthGIS. All rights reserved.
 */

@import CoreGraphics;
@import Foundation;
@import UIKit.UIImage;
@import UIKit.UIColor;

NS_ASSUME_NONNULL_BEGIN

/*!
 *  @abstract 预览图层的扫码动画
 */
typedef NS_ENUM(NSInteger, SGSScanAnimationStyle) {
    SGSScanAnimationStyleNone      = 0, //! 无动画
    SGSScanAnimationStyleLineStill = 1, //! 在扫描区域中央的静止线条
    SGSScanAnimationStyleLineMove  = 2, //! 线条滚动
    SGSScanAnimationStyleGrid      = 3, //! 网格
};

/*!
 *  @abstract 四角控制标识样式
 */
typedef NS_ENUM(NSInteger, SGSScanControlCornerStyle) {
    SGSScanControlCornerStyleOuter = 0, //! 四角控制标识在扫码矩形框外围
    SGSScanControlCornerStyleInner = 1, //! 四角控制标识内嵌在扫码区域内
    SGSScanControlCornerStyleOn    = 2, //! 四角控制标识覆盖在扫码矩形框的四角位置上
};


/*!
 *  @abstract 扫一扫预览视图样式，不单独使用
 */
@interface SGSScanPreviewStyle : NSObject

/*! 扫码动画，默认为无动画样式 SGSScanPreviewAnimationNone */
@property (nonatomic, assign) SGSScanAnimationStyle animationStyle;

/*! 扫码动画效果图片，默认为空 */
@property (nullable, nonatomic, strong) UIImage *animationImage;

/*! 动画图片高度，如果小于0则使用 animationImage.size.height，默认为 -1 */
@property (nonatomic, assign) CGFloat animationImageHeight;


/*! 四角控制标识符样式，默认为外围样式 SGSScanControlCornerStyleOuter */
@property (nonatomic, assign) SGSScanControlCornerStyle controlCornerStyle;

/*! 四角控制标识符颜色，默认为 [UIColor orangeColor] */
@property (nonatomic, strong) UIColor *controlCornerColor;

/*! 四角控制标识符的宽度，默认 20 */
@property (nonatomic, assign) CGFloat controlCornerWidth;

/*! 四角控制标识符的高度，默认 20  */
@property (nonatomic, assign) CGFloat controlCornerHeight;

/*! 四角控制标识符线宽，默认为 5 */
@property (nonatomic, assign) CGFloat controlCornerLineWidth;


/*! 扫码区域边框颜色，默认为 [UIColor whiteColor] */
@property (nonatomic, strong) UIColor *regionOfInterestOutlineColor;

/*! 扫描区域边框线宽，默认为 2 */
@property (nonatomic, assign) CGFloat regionOfInterestOutlineWidth;

/*! 识别区域外部的颜色，默认为 [UIColor blackColor] */
@property (nonatomic, strong) UIColor *maskColor;

/*! 识别区域外部的不透明度，取值范围：0~1，默认为0.6 */
@property (nonatomic, assign) CGFloat maskOpacity;

@end

NS_ASSUME_NONNULL_END
