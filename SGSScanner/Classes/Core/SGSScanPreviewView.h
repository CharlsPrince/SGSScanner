/*!
 *  @header SGSScanPreviewView.h
 *
 *  @abstract 扫一扫预览视图
 *
 *  @author Created by Lee on 16/10/24.
 *
 *  @copyright 2016年 SouthGIS. All rights reserved.
 */

#import <UIKit/UIKit.h>
#import "SGSScanPreviewStyle.h"

NS_ASSUME_NONNULL_BEGIN

@class AVCaptureVideoPreviewLayer;

/*!
 *  @abstract 扫一扫相机画面预览视图
 */
@interface SGSScanPreviewView : UIView

/*!
 *  @abstract 预览图层，由 `-setPreviewLayer:rectOfInterest:style:` 方法指定
 */
@property (nullable, nonatomic, weak, readonly) AVCaptureVideoPreviewLayer *previewLayer;

/*!
 *  @abstract 扫描识别区域
 *
 *  @discussion 通过 setter 方法可以重新设置四角控制标识和动画的位置，
 *      因此在屏幕旋转之后可以重新设置识别区域刷新布局
 */
@property (nonatomic, assign) CGRect rectOfInterest;

/*!
 *  @abstract 开启扫描动画
 */
- (void)startAnimating;

/*!
 *  @abstract 停止扫描动画
 */
- (void)stopAnimating;

/*!
 *  @abstract 设置预览图层、识别区域以及样式
 *
 *  @param previewLayer   预览图层
 *  @param rectOfInterest 扫描识别区域
 *  @param style          预览视图样式
 */
- (void)setPreviewLayer:(AVCaptureVideoPreviewLayer *)previewLayer rectOfInterest:(CGRect)rectOfInterest style:(SGSScanPreviewStyle *)style;

@end

NS_ASSUME_NONNULL_END
