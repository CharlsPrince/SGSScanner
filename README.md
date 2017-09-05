# SGSScanner

[![CI Status](http://img.shields.io/travis/Lee/SGSScanner.svg?style=flat)](https://travis-ci.org/Lee/SGSScanner)
[![Version](https://img.shields.io/cocoapods/v/SGSScanner.svg?style=flat)](http://cocoapods.org/pods/SGSScanner)
[![License](https://img.shields.io/cocoapods/l/SGSScanner.svg?style=flat)](http://cocoapods.org/pods/SGSScanner)
[![Platform](https://img.shields.io/cocoapods/p/SGSScanner.svg?style=flat)](http://cocoapods.org/pods/SGSScanner)

------

**SGSScanner**（OC版本）是移动支撑平台 iOS Objective-C 组件之一，该组件包含了二维码、条形码的生成与扫描识别功能

## 安装
------
**SGSScanner** 可以通过 **Cocoapods** 进行安装，可以复制下面的文字到 Podfile 中：

```ruby
target '项目名称' do
pod 'SGSScanner', '~> 0.1.0'
end
```

## 功能
------
**SGSScanner** 提供二维码与条形码的扫描识别与生成功能，并且已集成默认的二维码扫描界面，通过代理的方式处理扫描过程与扫描结果，支持 iPhone 7 plus 的双摄像头。

核心类是 `SGSScanUtil`，包含了二维码与条形码的识别与生成，开启摄像头扫描预览，开启或关闭闪关灯等功能。

如果需要自定义二维码扫描的界面，可以通过继承 `SGSScanPreviewView` 实现自定义扫描视图，`SGSScanPreviewView` 通过 `SGSScanPreviewStyle` 配置简易的预览效果。

`SGSScanPreviewStyle` 将提供一个中间为亮色的识别区域和四周暗淡的预览区域效果，通过属性可以控制识别区域的动画样式、四角控制标识符的颜色与粗细、识别区域边缘的颜色和线宽等


## 使用方法
------

### 生成条形码

```
UIImage *barcodeImage = [SGSScanUtil generateBarcode:msg size:_imageView.bounds.size color:nil backgroundColor:nil];
```

### 生成二维码

```
// 不带logo，默认颜色，默认容错级别（M）的二维码生成
UIImage *qrCodeImage1 = [SGSScanUtil generateQRCode:msg size:_imageView.bounds.size];

// 不带logo，蓝色背景，红色喷墨，容错级别为 'Q' 的二维码生成
UIImage *qrCodeImage2 = [SGSScanUtil generateQRCode:msg 
                                    correctionLevel:SGSQRCodeCorrectionLevelQuartile 
                                               size:_imageView.bounds.size
                                              color:[UIColor blueColor]
                                    backgroundColor:[UIColor redColor]];

// 带logo，默认颜色，默认容错级别（M）的二维码生成
UIImage *qrCodeImage3 = [SGSScanUtil generateQRCode:msg size:_imageView.bounds.size logoImage:logo];

// 带logo，绿色背景，红色喷墨，容错级别为 'H' 的二维码生成
UIImage *qrCodeImage3 = [SGSScanUtil generateQRCode:msg 
                                    correctionLevel:SGSQRCodeCorrectionLevelHigh 
                                               size:_imageView.bounds.size
                                              color:[UIColor blueColor]
                                    backgroundColor:[UIColor redColor]
                                          logoImage:logo];
```

### 直接从图片中读取二维码信息

```
NSString *message = [SGSScanUtil readQRCodeFromImage:qrCodeImage];
if (message == nil) {
    NSLog(@"读取二维码信息失败");
} else {
    NSLog(@"二维码内容: %@", message);
}
```

### 扫码识别

扫码识别同时支持条形码和二维码

创建一个扫描代理类，并且继承 `SGSScannerDelegate` 协议，实现 `-scannerViewController:didFinishScanWithResultMessage:` 代理方法
```
@interface SGSScannerHelper : NSObject <SGSScannerDelegate>
@end

@implementation SGSScannerHelper
- (void)scannerViewController:(__kindof UIViewController *)viewController didFinishScanWithResultMessage:(NSString *)message {
    NSLog(@"扫描结果: %@", message);
}
@end
```

### SGSScannerDelegate

`SGSScannerDelegate` 除了获取扫描结果外，还可以对扫描过程进行控制器，其余可选的接口如下：

```
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
```

### 自定义扫描界面

如果需要自定义扫描的界面，可以通过继承 `SGSScanPreviewView` 或者完全自定义，可以参照 `SGSScannerView` 类和 `SGSScannerViewController` 类

## 结尾
------
**移动支撑平台** 是研发中心移动团队打造的一套移动端开发便捷技术框架。这套框架立旨于满足公司各部门不同的移动业务研发需求，实现App快速定制的研发目标，降低研发成本，缩短开发周期，达到代码的易扩展、易维护、可复用的目的，从而让开发人员更专注于产品或项目的优化与功能扩展

整体框架采用组件化方式封装，以面向服务的架构形式供开发人员使用。同时兼容 Android 和 iOS 两大移动平台，涵盖 **网络通信**, **数据持久化存储**, **数据安全**, **移动ArcGIS** 等功能模块（近期推出混合开发组件，只需采用前端的开发模式即可同时在 Android 和 iOS 两个平台运行），各模块间相互独立，开发人员可根据项目需求使用相应的组件模块

更多组件请参考：
> * [HTTP 请求模块组件](http://112.94.224.243:8081/kun.li/sgshttpmodule/tree/master)
> * [ArcGIS绘图组件](https://github.com/crash-wu/SGSketchLayer-OC)
> * [数据安全组件](http://112.94.224.243:8081/kun.li/sgscrypto/tree/master)
> * [数据持久化存储组件](http://112.94.224.243:8081/kun.li/sgsdatabase/tree/master)
> * [常用类别组件](http://112.94.224.243:8081/kun.li/sgscategories/tree/master)
> * [常用工具组件](http://112.94.224.243:8081/kun.li/sgsutilities/tree/master)
> * [集合页面视图](http://112.94.224.243:8081/kun.li/sgscollectionpageview/tree/master)

如果您对移动支撑平台有更多的意见和建议，欢迎联系我们！

研发中心移动团队

2016 年 08月 29日   

## Author
------
Lee, kun.li@southgis.com

## License
------
SGSScanner is available under the MIT license. See the LICENSE file for more info.
