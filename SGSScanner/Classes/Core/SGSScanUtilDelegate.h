/*!
 *  @header SGSScanUtilDelegate.h
 *
 *  @abstract 扫一扫工具代理协议
 *
 *  @author Created by Lee on 16/10/14.
 *
 *  @copyright 2016年 SouthGIS. All rights reserved.
 */

#import <Foundation/Foundation.h>
#import "SGSScanUtil.h"

NS_ASSUME_NONNULL_BEGIN

/*!
 *  @abstract 扫一扫工具代理协议
 */
@protocol SGSScanUtilDelegate <NSObject>
@optional

/*!
 *  @abstract 扫描完毕
 *
 *  @param scanUtil        扫一扫工具类
 *  @param metadataObjects 扫描结果
 */
- (void)scanUtil:(SGSScanUtil *)scanUtil didFinishScan:(NSArray<__kindof AVMetadataObject *> *)metadataObjects;

/*!
 *  @abstract 相机设置完毕
 *
 *  @param scanUtil     扫一扫工具类
 *  @param session      摄像头会话
 *  @param previewLayer 相机画面预览图层
 */
- (void)scanUtil:(SGSScanUtil *)scanUtil captureSessionConfigurationCompleted:(AVCaptureSession *)session previewLayer:(AVCaptureVideoPreviewLayer *)previewLayer;

/*!
 *  @abstract 相机设置错误
 *
 *  @param scanUtil 扫一扫工具类
 *  @param session  摄像头会话
 */
- (void)scanUtil:(SGSScanUtil *)scanUtil captureSessionConfigurationFailed:(AVCaptureSession *)session;

/*!
 *  @abstract 相机开始扫描
 *
 *  @param scanUtil 扫一扫工具类
 *  @param session  摄像头会话
 */
- (void)scanUtil:(SGSScanUtil *)scanUtil captureSessionDidStartRunning:(AVCaptureSession *)session;

/*!
 *  @abstract 相机停止扫描
 *
 *  @param scanUtil 扫一扫工具类
 *  @param session  摄像头会话
 */
- (void)scanUtil:(SGSScanUtil *)scanUtil captureSessionDidStopRunning:(AVCaptureSession *)session;

/*!
 *  @abstract 相机运行时错误
 *
 *  @param scanUtil 扫一扫工具类
 *  @param session  摄像头会话
 *  @param error    相机运行时错误
 */
- (void)scanUtil:(SGSScanUtil *)scanUtil captureSession:(AVCaptureSession *)session runtimeError:(nullable NSError *)error;

/*!
 *  @abstract 相机扫描中断，例如，被来电呼叫或警报或者控制所需硬件资源的另一程序所中断
 *
 *  @param scanUtil           扫一扫工具类
 *  @param session            摄像头会话
 *  @param interruptionReason 终端原因枚举值
 */
- (void)scanUtil:(SGSScanUtil *)scanUtil captureSession:(AVCaptureSession *)session wasInterrupted:(AVCaptureSessionInterruptionReason)interruptionReason;

/*!
 *  @abstract 可以通过该方法得知相机何时可以从中断状态恢复
 *
 *  @discussion 例如，当电话呼叫结束，并且运行会话所需的硬件资源再次可用时，可在适当时机恢复相机扫描状态
 *
 *  @param scanUtil 扫一扫工具类
 *  @param session  摄像头会话
 */
- (void)scanUtil:(SGSScanUtil *)scanUtil captureSessionInterruptionEnded:(AVCaptureSession *)session;

@end

NS_ASSUME_NONNULL_END
