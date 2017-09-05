/*!
 *  @header SGSScanUtil.h
 *
 *  @abstract 扫一扫工具类
 *
 *  @author Created by Lee on 16/10/14.
 *
 *  @copyright 2016年 SouthGIS. All rights reserved.
 */

@import UIKit;
@import AVFoundation;

NS_ASSUME_NONNULL_BEGIN

@protocol SGSScanUtilDelegate;

/*!
 *  @abstract 摄像头状态，在调用相机服务时，用以区分配置状况及权限状况等
 *
 *  @note 之后可能会将该枚举类型用于拍照、录制视频等
 */
typedef NS_ENUM(NSInteger, SGSCaptureSessionState) {
    SGSCaptureSessionStateConfigurationCompleted = 0, //! 摄像头配置完毕，可以进行拍照、扫一扫、人脸识别等
    SGSCaptureSessionStateNotAuthorized = 1,          //! 没有获得相机权限，需要引导用户设置相机服务
    SGSCaptureSessionStateConfigurationFailed = 2,    //! 摄像头配置失败，有可能是摄像头损坏或者获取不到摄像头信息
};


/*!
 *  @abstract 二维码容错级别
 *  @see https://en.wikipedia.org/wiki/QR_code#Error_correction
 */
typedef NS_ENUM(NSInteger, SGSQRCodeCorrectionLevel) {
    SGSQRCodeCorrectionLevelMedium = 0,  //! Level L, 15% 容错，默认
    SGSQRCodeCorrectionLevelLow,         //! Level L, 7% 容错
    SGSQRCodeCorrectionLevelQuartile,    //! Level L, 25% 容错
    SGSQRCodeCorrectionLevelHigh,        //! Level L, 30% 容错
};


/*!
 *  @abstract 扫一扫工具类
 */
@interface SGSScanUtil : NSObject <AVCaptureMetadataOutputObjectsDelegate>


/*!
 *  @abstract 摄像头设置状态
 */
@property (nonatomic, assign, readonly) SGSCaptureSessionState capturSessionState;

/*!
 *  @abstract 摄像头是否在运行
 */
@property (nonatomic, assign, readonly, getter=isSessionRunning) BOOL sessionRunning;

/*!
 *  @abstract 代理
 */
@property (nullable, nonatomic, weak) id<SGSScanUtilDelegate> scanDelegate;

/*!
 *  @abstract 扫一扫功能默认支持的识别类型（二维码/条形码）
 *
 *  @return @[AVMetadataObjectTypeCode39Code,
 *            AVMetadataObjectTypeCode39Mod43Code,
 *            AVMetadataObjectTypeEAN13Code,
 *            AVMetadataObjectTypeEAN8Code,
 *            AVMetadataObjectTypeCode93Code,
 *            AVMetadataObjectTypeCode128Code,
 *            AVMetadataObjectTypeQRCode];
 */
+ (NSArray<NSString *> *)defaultMetadataObjectTypes;


#pragma mark - 通过摄像头扫描
///-----------------------------------------------------------------------------
/// @name 通过摄像头扫描
///-----------------------------------------------------------------------------

/*!
 *  @abstract 实例化扫描工具，可通过配置识别类型实现扫描二维码、条形码、人脸识别等功能
 *
 *  @param previewView         将要预览的视图
 *  @param regionOfInterest    扫描有效区域
 *  @param metadataObjectTypes 扫描支持的识别类型
 *  @param handler             扫描结果，只有相机正常调用并且正式扫描之后才可能回调
 *
 *  @return 扫描工具实例
 */
- (instancetype)initWithPreviewView:(UIView *)previewView
                   regionOfInterest:(CGRect)regionOfInterest
                metadataObjectTypes:(nullable NSArray<NSString *> *)metadataObjectTypes
                       scanDelegate:(nullable id<SGSScanUtilDelegate>)delegate;

/*!
 *  @abstract 开始扫描
 */
- (void)startScan;

/*!
 *  @abstract 在相机服务被中断之后，可在适当的时机调用该方法恢复
 */
- (void)resumeScan;

/*!
 *  @abstract 停止扫描
 */
- (void)stopScan;


/*!
 *  @abstract 判断是否有闪光灯，只有返回 YES 时才能设置闪光灯模式
 */
- (BOOL)hasTorch;

/*!
 *  @abstract 打开闪光灯
 */
- (void)turnOnTorch;

/*!
 *  @abstract 关闭闪光灯
 */
- (void)turnOffTorch;

/*!
 *  @abstract 切换闪光灯状态
 */
- (void)switchTorchMode;

/*!
 *  @abstract 打开/关闭闪光灯
 *
 *  @param on `YES` 打开； `NO` 关闭
 */
- (void)setTorchModeToOn:(BOOL)on;


/*!
 *  @abstract 获取相机最大聚焦系数
 *
 *  @return 相机最大聚焦系数
 */
- (CGFloat)videoMaxZoomFactor;

/*!
 *  @abstract 修改相机聚焦系数
 *
 *  @param factor 相机聚焦系数
 */
- (void)setVideoZoomFactor:(CGFloat)factor;


/*!
 *  @abstract 重置扫描区域
 *
 *  @param scanRect 扫描有效区域
 */
- (void)resizeRectOfInterestForRect:(CGRect)scanRect;

/*!
 *  @abstract 修改扫描识别类型
 *
 *  @param metadataObjectTypes 扫描识别类型
 */
- (void)resetMetadataObjectTypes:(NSArray<NSString *> *)metadataObjectTypes;

/*!
 *  @abstract 重置相机画面分辨率，初始默认为：AVCaptureSessionPresetHigh
 *
 *  @param preset 相机画面分辨率
 */
- (void)resetCaptureSessionPreset:(NSString *)preset;

@end


FOUNDATION_EXPORT NSString * const SGSQRCode;     //! 二维码，值为 `CIQRCodeGenerator`
FOUNDATION_EXPORT NSString * const SGS128Barcode; //! 条形码，值为 `CICode128BarcodeGenerator`

/// 二维码与条形码生成与读取
@interface SGSScanUtil (Code)

#pragma mark - 从图片中读取二维码信息
///-----------------------------------------------------------------------------
/// @name 从图片中读取二维码信息
///-----------------------------------------------------------------------------

/*!
 *  @abstract 从图片中读取二维码信息
 *
 *  @param qrcodeImage 二维码图片
 *
 *  @return 二维码信息 or nil
 */
+ (nullable NSString *)readQRCodeFromImage:(UIImage *)qrcodeImage;


#pragma mark - 生成二维码/条形码
///-----------------------------------------------------------------------------
/// @name 生成二维码/条形码
///-----------------------------------------------------------------------------

/*!
 *  @abstract 生成二维码图片，容错级别默认为中（SGSQRCodeCorrectionLevelMedium）
 *
 *  @param message         二维码信息
 *  @param size            二维码大小
 *
 *  @return 二维码图片 or nil
 */
+ (nullable UIImage *)generateQRCode:(NSString *)message
                                size:(CGSize)size;

/*!
 *  @abstract 生成二维码图片
 *
 *  @param message         二维码信息
 *  @param correctionLevel 容错级别
 *  @param size            二维码大小
 *  @param color           二维码颜色，如果为空默认为黑色
 *  @param backgroundColor 背景颜色，如果为空默认为白色
 *
 *  @return 二维码图片 or nil
 */
+ (nullable UIImage *)generateQRCode:(NSString *)message
                     correctionLevel:(SGSQRCodeCorrectionLevel)correctionLevel
                                size:(CGSize)size
                               color:(nullable UIColor *)color
                     backgroundColor:(nullable UIColor *)backgroundColor;

/*!
 *  @abstract 生成中间有logo的二维码图片，容错级别默认为中（SGSQRCodeCorrectionLevelMedium）
 *
 *  @param message         二维码信息
 *  @param size            二维码大小
 *  @param logo            中间logo
 *
 *  @return 带logo的二维码图片 or nil
 */
+ (nullable UIImage *)generateQRCode:(NSString *)message
                                size:(CGSize)size
                           logoImage:(nullable UIImage *)logo;

/*!
 *  @abstract 生成中间有logo的二维码图片
 *
 *  @param message         二维码信息
 *  @param correctionLevel 容错级别
 *  @param size            二维码大小
 *  @param color           二维码颜色，如果为空默认为黑色
 *  @param backgroundColor 背景颜色，如果为空默认为白色
 *  @param logo            中间logo，容错级别设为Q（25%）
 *
 *  @return 带logo的二维码图片 or nil
 */
+ (nullable UIImage *)generateQRCode:(NSString *)message
                     correctionLevel:(SGSQRCodeCorrectionLevel)correctionLevel
                                size:(CGSize)size
                               color:(nullable UIColor *)color
                     backgroundColor:(nullable UIColor *)backgroundColor
                           logoImage:(nullable UIImage *)logo;


/*!
 *  @abstract 生成条形码
 *
 *  @param message         条形码
 *  @param size            条形码大小
 *  @param color           条形码颜色
 *  @param backgroundColor 背景颜色
 *
 *  @return 条形码图片
 */
+ (nullable UIImage *)generateBarcode:(NSString *)message
                                 size:(CGSize)size
                                color:(nullable UIColor *)color
                      backgroundColor:(nullable UIColor *)backgroundColor;

/*!
 *  @abstract 根据类型生成编码图片
 *
 *  @param type            编码类型，例如：SGSQRCode (CIQRCodeGenerator) 表示生成二维码图片
 *  @param message         编码信息
 *  @param correctionLevel 容错级别
 *  @param size            图片大小
 *  @param color           编码颜色，如果为空默认为黑色
 *  @param backgroundColor 背景颜色，如果为空默认为白色
 *
 *  @return 二维码图片 or nil
 */
+ (nullable UIImage *)generateCodeImageWithType:(NSString *)type
                                        message:(NSString *)message
                                correctionLevel:(SGSQRCodeCorrectionLevel)correctionLevel
                                           size:(CGSize)size
                                          color:(nullable UIColor *)color
                                backgroundColor:(nullable UIColor *)backgroundColor;
@end

NS_ASSUME_NONNULL_END
