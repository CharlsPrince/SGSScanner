/*!
 *  @header NSBundle+SGSScanner.h
 *
 *  @abstract 资源类别
 *
 *  @author Created by Lee on 16/10/14.
 *
 *  @copyright 2016年 SouthGIS. All rights reserved.
 */

@import Foundation;
@import UIKit.UIImage;

NS_ASSUME_NONNULL_BEGIN

@interface NSBundle (SGSScanner)

/*! 资源 */
+ (instancetype)sgsScannerBundle;

/*! 蓝色扫描线 */
+ (nullable UIImage *)sgsScannerBlueLineImage;

/*! 绿色扫描线 */
+ (nullable UIImage *)sgsScannerGreenLineImage;

/*! 网格图片 */
+ (nullable UIImage *)sgsScannerGridImage;

/*! 导航栏返回按钮 */
+ (nullable UIImage *)sgsScannerNavBackNormalImage;

/*! 导航栏按压状态返回按钮 */
+ (nullable UIImage *)sgsScannerNavBackPressedImage;

@end

NS_ASSUME_NONNULL_END
