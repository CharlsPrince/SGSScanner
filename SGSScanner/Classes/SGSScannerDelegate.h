/*!
 *  @header SGSScannerDelegate.h
 *
 *  @abstract 扫一扫协议
 *
 *  @author Created by Lee on 16/10/24.
 *
 *  @copyright 2016年 SouthGIS. All rights reserved.
 */

#import <Foundation/Foundation.h>
#import "SGSScannerView.h"
#import "SGSScanUtil.h"

NS_ASSUME_NONNULL_BEGIN

/// 扫描代理
@protocol SGSScannerDelegate <NSObject>
@required

/*!
 *  @abstract 扫描完毕
 *
 *  @param viewController 扫一扫视图控制器
 *  @param message 扫描结果
 */
- (void)scannerViewController:(__kindof UIViewController *)viewController didFinishScanWithResultMessage:(nullable NSString *)message;


@optional

/*!
 *  @abstract 预览视图提示按钮点击事件
 *
 *  @param viewController 扫一扫视图控制器
 *  @param view           扫一扫视图
 *  @param sender         提示按钮
 */
- (void)scannerViewController:(__kindof UIViewController *)viewController scannerView:(SGSScannerView *)view tipsButtonClicked:(UIButton *)sender;


/*!
 *  @abstract 扫描完毕回调
 *
 *  @param viewController  扫一扫视图控制器
 *  @param scanUtil        扫一扫工具类
 *  @param metadataObjects 扫描结果元数据
 *
 *  @discussion 如果实现了该方法，那么将不会自动调用 scannerViewController:didFinishScanWithResultMessage:
 */
- (void)scannerViewController:(__kindof UIViewController *)viewController scanUtil:(SGSScanUtil *)scanUtil didFinishScan:(NSArray<__kindof AVMetadataObject *> *)metadataObjects;

/*!
 *  @abstract 摄像头开启
 *
 *  @param viewController 扫一扫视图控制器
 *  @param scanUtil       扫一扫工具类
 *  @param session        摄像头设备
 */
- (void)scannerViewController:(__kindof UIViewController *)viewController scanUtil:(SGSScanUtil *)scanUtil captureSessionDidStartRunning:(AVCaptureSession *)session;

/*!
 *  @abstract 摄像头关闭
 *
 *  @param viewController 扫一扫视图控制器
 *  @param scanUtil       扫一扫工具类
 *  @param session        摄像头设备
 */
- (void)scannerViewController:(__kindof UIViewController *)viewController scanUtil:(SGSScanUtil *)scanUtil captureSessionDidStopRunning:(AVCaptureSession *)session;

/*!
 *  @abstract 摄像头设置完毕
 *
 *  @param viewController 扫一扫视图控制器
 *  @param scanUtil       扫一扫工具类
 *  @param session        摄像头设备
 *  @param previewLayer   扫描预览视图
 */
- (void)scannerViewController:(__kindof UIViewController *)viewController scanUtil:(SGSScanUtil *)scanUtil captureSessionConfigurationCompleted:(AVCaptureSession *)session previewLayer:(AVCaptureVideoPreviewLayer *)previewLayer;

/*!
 *  @abstract 摄像头设置失败
 *
 *  @param viewController 扫一扫视图控制器
 *  @param scanUtil       扫一扫工具类
 *  @param session        摄像头设备
 */
- (void)scannerViewController:(__kindof UIViewController *)viewController scanUtil:(SGSScanUtil *)scanUtil captureSessionConfigurationFailed:(AVCaptureSession *)session;

/*!
 *  @abstract 摄像头运行时出错
 *
 *  @param viewController 扫一扫视图控制器
 *  @param scanUtil       扫一扫工具类
 *  @param session        摄像头设备
 *  @param error          错误
 */
- (void)scannerViewController:(__kindof UIViewController *)viewController scanUtil:(SGSScanUtil *)scanUtil captureSession:(AVCaptureSession *)session runtimeError:(NSError *)error;

/*!
 *  @abstract 摄像头扫描中断，例如扫描过程中有通话
 *
 *  @param viewController     扫一扫视图控制器
 *  @param scanUti            扫一扫工具类
 *  @param session            摄像头设备
 *  @param interruptionReason 中断原因
 */
- (void)scannerViewController:(__kindof UIViewController *)viewController scanUti:(SGSScanUtil *)scanUti captureSession:(AVCaptureSession *)session wasInterrupted:(AVCaptureSessionInterruptionReason)interruptionReason;

/*!
 *  @abstract 摄像头从中断状态恢复，例如从通话中恢复
 *
 *  @param viewController 扫一扫视图控制器
 *  @param scanUti        扫一扫工具类
 *  @param session        摄像头设备
 */
- (void)scannerViewController:(__kindof UIViewController *)viewController scanUti:(SGSScanUtil *)scanUti captureSessionInterruptionEnded:(AVCaptureSession *)session;

@end

NS_ASSUME_NONNULL_END
