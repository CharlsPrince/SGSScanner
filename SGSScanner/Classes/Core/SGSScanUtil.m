/*!
 *  @header SGSScanUtil.m
 *
 *  @author Created by Lee on 16/10/14.
 *
 *  @copyright 2016年 SouthGIS. All rights reserved.
 */

#import "SGSScanUtil.h"
#import "SGSScanUtilDelegate.h"

@interface SGSScanUtil ()

@property (nonatomic, strong) AVCaptureSession *session;       //! 摄像头会话
@property (nonatomic, strong) NSOperationQueue *sessionQueue;  //! 摄像头设置安全串行队列
@property (nonatomic, assign) SGSCaptureSessionState sessionState;
@property (nonatomic, assign) BOOL running;
@property (nonatomic, assign) BOOL isSessionObserve;

@property (nonatomic, strong) AVCaptureDeviceInput *deviceInput;       //! 设备输入
@property (nonatomic, strong) AVCaptureMetadataOutput *metadataOutput; //! 数据输出
@property (nonatomic, weak) UIView *previewView;      //! 拍摄画面预览图层
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;

@property (nonatomic, assign) CGRect regionOfInterest;
@property (nonatomic, strong) NSArray<NSString *> *metadataObjectTypes;

@end


@implementation SGSScanUtil

+ (NSArray<NSString *> *)defaultMetadataObjectTypes {
    return  @[AVMetadataObjectTypeCode39Code,
              AVMetadataObjectTypeCode39Mod43Code,
              AVMetadataObjectTypeEAN13Code,
              AVMetadataObjectTypeEAN8Code,
              AVMetadataObjectTypeCode93Code,
              AVMetadataObjectTypeCode128Code,
              AVMetadataObjectTypeQRCode];
}

- (instancetype)initWithPreviewView:(UIView *)previewView
                   regionOfInterest:(CGRect)regionOfInterest
                metadataObjectTypes:(NSArray<NSString *> *)metadataObjectTypes
                       scanDelegate:(id<SGSScanUtilDelegate>)delegate
{
    NSAssert(previewView != nil, @"预览视图为空");
    self = [super init];
    if (self) {
        _previewView = previewView;
        _regionOfInterest = regionOfInterest;
        _metadataObjectTypes = metadataObjectTypes.copy;
        _scanDelegate = delegate;
        [self setup];
    }
    return self;
}

- (void)dealloc {
    [self removeObservers];
}


#pragma mark - Public

// 开始扫描
- (void)startScan {
    __weak typeof(self) weakSelf = self;
    [_sessionQueue addOperationWithBlock:^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf.sessionState == SGSCaptureSessionStateConfigurationCompleted) {
            if (!strongSelf.isSessionObserve) {
                [strongSelf addObservers];
            }
            [strongSelf.session startRunning];
        }
    }];
}

// 继续扫描
- (void)resumeScan {
    __weak typeof(self) weakSelf = self;
    [_sessionQueue addOperationWithBlock:^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf.sessionState == SGSCaptureSessionStateConfigurationCompleted) {
            [strongSelf.session startRunning];
        }
    }];
}

// 停止扫描
- (void)stopScan {
    __weak typeof(self) weakSelf = self;
    [_sessionQueue addOperationWithBlock:^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf.sessionState == SGSCaptureSessionStateConfigurationCompleted) {
            [strongSelf.session stopRunning];
            [strongSelf removeObservers];
        }
    }];
}

// 是否有闪光灯
- (BOOL)hasTorch {
    return _deviceInput.device.hasTorch;
}


// 打开闪光灯
- (void)turnOnTorch {
    AVCaptureDevice *device = _deviceInput.device;
    if ((device != nil) &&
        [device isTorchModeSupported:AVCaptureTorchModeOn])
    {
        [device lockForConfiguration:NULL];
        device.torchMode = AVCaptureTorchModeOn;
        [device unlockForConfiguration];
    }
}

// 关闭闪光灯
- (void)turnOffTorch {
    AVCaptureDevice *device = _deviceInput.device;
    if ((device != nil) &&
        [device isTorchModeSupported:AVCaptureTorchModeOff])
    {
        [device lockForConfiguration:NULL];
        device.torchMode = AVCaptureTorchModeOff;
        [device unlockForConfiguration];
    }
}

// 切换闪光灯状态
- (void)switchTorchMode {
    AVCaptureDevice *device = _deviceInput.device;
    switch (device.torchMode) {
        case AVCaptureTorchModeOn:
            [self turnOffTorch];
            break;
            
        case AVCaptureTorchModeOff:
            [self turnOnTorch];
            break;
            
        default:
            break;
    }
}

// 打开/关闭闪光灯
- (void)setTorchModeToOn:(BOOL)on {
    AVCaptureTorchMode mode = on ? AVCaptureTorchModeOn : AVCaptureTorchModeOff;
    AVCaptureDevice *device = _deviceInput.device;
    if ((device != nil) &&
        [device isTorchModeSupported:mode])
    {
        [device lockForConfiguration:NULL];
        device.torchMode = mode;
        [device unlockForConfiguration];
    }
}

// 获取最大聚焦系数
- (CGFloat)videoMaxZoomFactor {
    CGFloat result = 0.0;
    AVCaptureDevice *device = _deviceInput.device;
    if (device != nil) {
        [device lockForConfiguration:NULL];
        result = device.activeFormat.videoMaxZoomFactor;
        [device unlockForConfiguration];
    }
    return result;
}

// 改变聚焦系数
- (void)setVideoZoomFactor:(CGFloat)factor {
    AVCaptureDevice *device = _deviceInput.device;
    if (device != nil) {
        [device lockForConfiguration:NULL];
        CGFloat zoom = factor / device.videoZoomFactor;
        device.videoZoomFactor = factor;
        [device unlockForConfiguration];
        
        if (_previewView != nil) {
            CGAffineTransform transform = _previewView.transform;
            _previewView.transform = CGAffineTransformScale(transform, zoom, zoom);
        }
    }
}

// 重置扫描区域
- (void)resizeRectOfInterestForRect:(CGRect)scanRect {
    __weak typeof(self) weakSelf = self;
    [_sessionQueue addOperationWithBlock:^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf.metadataOutput != nil) {
            strongSelf.metadataOutput.rectOfInterest = [strongSelf.previewLayer metadataOutputRectOfInterestForRect:scanRect];
        }
    }];
}

// 重置识别类型
- (void)resetMetadataObjectTypes:(NSArray<NSString *> *)metadataObjectTypes {
    __weak typeof(self) weakSelf = self;
    [_sessionQueue addOperationWithBlock:^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf.metadataOutput != nil) {
            strongSelf.metadataOutput.metadataObjectTypes = metadataObjectTypes;
        }
    }];
}

// 重置相机预览画面分辨率
- (void)resetCaptureSessionPreset:(NSString *)preset {
    __weak typeof(self) weakSelf = self;
    [_sessionQueue addOperationWithBlock:^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if ([strongSelf.session canSetSessionPreset:preset]) {
            strongSelf.session.sessionPreset = preset;
        }
    }];
}

#pragma mark - Configration

// 设置属性
- (void)setup {
    _session = [[AVCaptureSession alloc] init];
    _sessionQueue = [[NSOperationQueue alloc] init];
    _sessionQueue.maxConcurrentOperationCount = 1;
    _sessionState = SGSCaptureSessionStateConfigurationCompleted;
    _running = NO;
    _isSessionObserve = NO;
    _metadataOutput = [[AVCaptureMetadataOutput alloc] init];
    
    __weak typeof(self) weakSelf = self;
    
    // 检查授权状态
    switch ([AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo]) {
        case AVAuthorizationStatusAuthorized:  // 用户已授权
            break;
            
        case AVAuthorizationStatusNotDetermined: {  // 用户未授权，该状态下自动显示授权对话框
            // 挂起队列
            _sessionQueue.suspended = YES;
            
            // 访问权限完毕后再执行队列内容，回调block在子线程中执行
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                __strong typeof(weakSelf) strongSelf = weakSelf;
                if (!granted) {
                    strongSelf.sessionState = SGSCaptureSessionStateNotAuthorized;
                }
                strongSelf.sessionQueue.suspended = NO;
            }];
        } break;
            
        default: // 用户之前拒绝了授权
            _sessionState = SGSCaptureSessionStateNotAuthorized;
            break;
    }
    
    // 设置摄像头
    [_sessionQueue addOperationWithBlock:^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf configureSession];
    }];
}

// 设置摄像头
- (void)configureSession {
    if (_sessionState != SGSCaptureSessionStateConfigurationCompleted) {
        return;
    }
    
    // 获取相机设备
    AVCaptureDevice *captureDevice = nil;
//    BOOL iOS10OrLater = ([[UIDevice currentDevice].systemVersion compare:@"10" options:NSNumericSearch] == NSOrderedAscending);
    BOOL iOS10OrLater = [[[UIDevice currentDevice] systemVersion] floatValue] >= 10.0 ? YES : NO;
    if (iOS10OrLater) {
        // 优先选择后置双摄像头（例如 iPhone 7 Plus）
        captureDevice = [AVCaptureDevice defaultDeviceWithDeviceType:AVCaptureDeviceTypeBuiltInDuoCamera
                                                           mediaType:AVMediaTypeVideo
                                                            position:AVCaptureDevicePositionBack];
        // 如果后置双摄像头不可用，那么使用后置广角摄像头
        if (captureDevice == nil) {
            captureDevice = [AVCaptureDevice defaultDeviceWithDeviceType:AVCaptureDeviceTypeBuiltInWideAngleCamera
                                                               mediaType:AVMediaTypeVideo
                                                                position:AVCaptureDevicePositionBack];
        }
        
        // 如果后置广角摄像头不可用，那么使用前置广角摄像头
        if (captureDevice == nil) {
            captureDevice = [AVCaptureDevice defaultDeviceWithDeviceType:AVCaptureDeviceTypeBuiltInWideAngleCamera
                                                               mediaType:AVMediaTypeVideo
                                                                position:AVCaptureDevicePositionFront];
        }
    } else {
        captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    }
    
    if (captureDevice == nil) {
        _sessionState = SGSCaptureSessionStateConfigurationFailed;
        [self performCaptureSessionConfigurationFailedDelegateMethodOnMainThread];
        return;
    }
    
    [_session beginConfiguration];
    
    // 输入
    AVCaptureDeviceInput *input = [[AVCaptureDeviceInput alloc] initWithDevice:captureDevice error:NULL];
    if ((input == nil) || ![_session canAddInput:input]) {
        _sessionState = SGSCaptureSessionStateConfigurationFailed;
        [_session commitConfiguration];
        [self performCaptureSessionConfigurationFailedDelegateMethodOnMainThread];
        return;
    }
    
    [_session addInput:input];
    _deviceInput = input;
    
    // 输出
    if (![_session canAddOutput:_metadataOutput]) {
        _sessionState = SGSCaptureSessionStateConfigurationFailed;
        [_session commitConfiguration];
        [self performCaptureSessionConfigurationFailedDelegateMethodOnMainThread];
        return;
    }
    
    [_session addOutput:_metadataOutput];
    [_metadataOutput setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    
    // 指定输出的元数据类型，必须在设置会话的输出后执行
    if (_metadataObjectTypes != nil) {
        _metadataOutput.metadataObjectTypes = _metadataObjectTypes;
    } else {
        _metadataOutput.metadataObjectTypes = [SGSScanUtil defaultMetadataObjectTypes];
    }
    
    // 设置有效识别区域
    CGRect bounds = _previewView.bounds;
    if (!CGRectEqualToRect(_regionOfInterest, CGRectZero) &&
        (bounds.size.height > 0) &&
        (bounds.size.width > 0))
    {
        CGFloat xOfInterest = _regionOfInterest.origin.y / bounds.size.height;
        CGFloat yOfInterest = ((bounds.size.width - _regionOfInterest.size.width) / 2.0) / bounds.size.width;
        CGFloat widthOfInterest = _regionOfInterest.size.height / bounds.size.height;
        CGFloat heightOfInterest = _regionOfInterest.size.width / bounds.size.width;
        _metadataOutput.rectOfInterest = CGRectMake(xOfInterest, yOfInterest, widthOfInterest, heightOfInterest);
    }
    
    // 设置预览层
    _previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:_session];
    _previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    _previewLayer.frame = bounds;
    
    // 设置自动对焦
    if (captureDevice.isFocusPointOfInterestSupported &&
        [captureDevice isFocusModeSupported:AVCaptureFocusModeAutoFocus])
    {
        [captureDevice lockForConfiguration:NULL];
        captureDevice.focusMode = AVCaptureFocusModeContinuousAutoFocus;
        [captureDevice unlockForConfiguration];
    }
    
    _session.sessionPreset = AVCaptureSessionPresetHigh;
    
    [_session commitConfiguration];
    
    [self performCaptureSessionConfigurationCompletedDelegateMethodOnMainThread];
}

#pragma mark - Delegate Method

- (void)performCaptureSessionConfigurationCompletedDelegateMethodOnMainThread {
    __weak typeof(self) weakSelf = self;
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if ([strongSelf.scanDelegate respondsToSelector:@selector(scanUtil:captureSessionConfigurationCompleted:previewLayer:)]) {
            [strongSelf.scanDelegate scanUtil:strongSelf captureSessionConfigurationCompleted:strongSelf.session previewLayer:strongSelf.previewLayer];
        }
    }];
}

- (void)performCaptureSessionConfigurationFailedDelegateMethodOnMainThread {
    __weak typeof(self) weakSelf = self;
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if ([strongSelf.scanDelegate respondsToSelector:@selector(scanUtil:captureSessionConfigurationFailed:)]) {
            [strongSelf.scanDelegate scanUtil:strongSelf captureSessionConfigurationFailed:strongSelf.session];
        }
    }];
}

#pragma mark - KVO and Notifications

- (void)addObservers {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sessionDidStartRunning:) name:AVCaptureSessionDidStartRunningNotification object:_session];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sessionDidStopRunning:) name:AVCaptureSessionDidStopRunningNotification object:_session];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sessionRuntimeError:) name:AVCaptureSessionRuntimeErrorNotification object:_session];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sessionWasInterrupted:) name:AVCaptureSessionWasInterruptedNotification object:_session];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sessionInterruptionEnded:) name:AVCaptureSessionInterruptionEndedNotification object:_session];
    _isSessionObserve = YES;
}

- (void)removeObservers {
    _isSessionObserve = NO;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


// 相机开始扫描
- (void)sessionDidStartRunning:(NSNotification *)notification {
    __weak typeof(self) weakSelf = self;
    [_sessionQueue addOperationWithBlock:^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        strongSelf.running = YES;
    }];
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if ([strongSelf.scanDelegate respondsToSelector:@selector(scanUtil:captureSessionDidStartRunning:)]) {
            [strongSelf.scanDelegate scanUtil:strongSelf captureSessionDidStartRunning:strongSelf.session];
        }
    }];
}

// 相机停止扫描
- (void)sessionDidStopRunning:(NSNotification *)notification {
    __weak typeof(self) weakSelf = self;
    [_sessionQueue addOperationWithBlock:^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        strongSelf.running = NO;
    }];
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if ([strongSelf.scanDelegate respondsToSelector:@selector(scanUtil:captureSessionDidStopRunning:)]) {
            [strongSelf.scanDelegate scanUtil:strongSelf captureSessionDidStopRunning:strongSelf.session];
        }
    }];
}

// 相机运行时错误
- (void)sessionRuntimeError:(NSNotification *)notification {
    __weak typeof(self) weakSelf = self;
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if ([strongSelf.scanDelegate respondsToSelector:@selector(scanUtil:captureSession:runtimeError:)]) {
            [strongSelf.scanDelegate scanUtil:strongSelf captureSession:strongSelf.session runtimeError:notification.userInfo[AVCaptureSessionErrorKey]];
        }
    }];
}

// 相机中断
- (void)sessionWasInterrupted:(NSNotification *)notification {
    __weak typeof(self) weakSelf = self;
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if ([strongSelf.scanDelegate respondsToSelector:@selector(scanUtil:captureSession:wasInterrupted:)]) {
            [strongSelf.scanDelegate scanUtil:strongSelf captureSession:strongSelf.session wasInterrupted:[notification.userInfo[AVCaptureSessionInterruptionReasonKey] integerValue]];
        }
    }];
}

// 相机可恢复
- (void)sessionInterruptionEnded:(NSNotification *)notification {
    __weak typeof(self) weakSelf = self;
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if ([strongSelf.scanDelegate respondsToSelector:@selector(scanUtil:captureSessionInterruptionEnded:)]) {
            [strongSelf.scanDelegate scanUtil:strongSelf captureSessionInterruptionEnded:strongSelf.session];
        }
    }];
}

#pragma mark - AVCaptureMetadataOutputObjectsDelegate

- (void)captureOutput:(AVCaptureOutput *)captureOutput
didOutputMetadataObjects:(NSArray *)metadataObjects
       fromConnection:(AVCaptureConnection *)connection
{
    if ([_scanDelegate respondsToSelector:@selector(scanUtil:didFinishScan:)]) {
        [_scanDelegate scanUtil:self didFinishScan:metadataObjects];
    }
}

#pragma mark - Accessors

- (SGSCaptureSessionState)capturSessionState {
    [_sessionQueue waitUntilAllOperationsAreFinished];
    return _sessionState;
}

- (BOOL)isSessionRunning {
    [_sessionQueue waitUntilAllOperationsAreFinished];
    return _running;
}

@end


NSString * const SGSQRCode = @"CIQRCodeGenerator";
NSString * const SGS128Barcode = @"CICode128BarcodeGenerator";

@implementation SGSScanUtil (Code)

#pragma mark - 从图片读取二维码

// 从图片中读取二维码
+ (NSString *)readQRCodeFromImage:(UIImage *)qrcodeImage {
    CIContext *qrcodeContext             = nil;
    CIDetector *qrcodeDetector           = nil;
    NSArray<CIFeature *> *qrcodeFeatures = nil;
    NSString *result                     = nil;
    
    // 获取上下文
    qrcodeContext = [CIContext contextWithOptions:nil];
    
    // 设置检测精度为高
    qrcodeDetector = [CIDetector detectorOfType:CIDetectorTypeQRCode
                                        context:qrcodeContext
                                        options:@{CIDetectorAccuracy: CIDetectorAccuracyHigh}];
    // 读取二维码
    qrcodeFeatures = [qrcodeDetector featuresInImage:[CIImage imageWithCGImage:qrcodeImage.CGImage]];
    
    for (CIFeature *feature in qrcodeFeatures) {
        if ([feature isKindOfClass:[CIQRCodeFeature class]]) {
            result = [(CIQRCodeFeature *)feature messageString];
            break;
        }
    }
    
    return result;
}


#pragma mark - 生成二维码或条形码

// 生成二维码
+ (UIImage *)generateQRCode:(NSString *)message size:(CGSize)size
{
    return [self generateQRCode:message correctionLevel:SGSQRCodeCorrectionLevelMedium size:size color:nil backgroundColor:nil];
}

+ (UIImage *)generateQRCode:(NSString *)message correctionLevel:(SGSQRCodeCorrectionLevel)correctionLevel size:(CGSize)size color:(UIColor *)color backgroundColor:(UIColor *)backgroundColor
{
    return [self generateCodeImageWithType:SGSQRCode message:message correctionLevel:correctionLevel size:size color:color backgroundColor:backgroundColor];
}

// 生成带logo的二维码
+ (UIImage *)generateQRCode:(NSString *)message size:(CGSize)size logoImage:(UIImage *)logo
{
    return [self generateQRCode:message correctionLevel:SGSQRCodeCorrectionLevelMedium size:size color:nil backgroundColor:nil logoImage:logo];
}

+ (UIImage *)generateQRCode:(NSString *)message correctionLevel:(SGSQRCodeCorrectionLevel)correctionLevel size:(CGSize)size color:(UIColor *)color backgroundColor:(UIColor *)backgroundColor logoImage:(UIImage *)logo
{
    UIImage *qrCodeImage = [self generateQRCode:message correctionLevel:correctionLevel size:size color:color backgroundColor:backgroundColor];
    if (qrCodeImage == nil) return nil;
    
    if (logo == nil) return qrCodeImage;
    if ((logo.size.width <= 0) || (logo.size.height <= 0)) return qrCodeImage;
    
    // 将logo绘制到生成的二维码图片中
    UIGraphicsBeginImageContextWithOptions(size, NO, [UIScreen mainScreen].scale);
    
    [qrCodeImage drawInRect:CGRectMake(0, 0, size.width, size.height)];
    
    CGFloat scale = 0.15;
    switch (correctionLevel) {
        case SGSQRCodeCorrectionLevelLow: scale = 0.07; break;
        case SGSQRCodeCorrectionLevelMedium: scale = 0.15; break;
        case SGSQRCodeCorrectionLevelQuartile: scale = 0.25; break;
        case SGSQRCodeCorrectionLevelHigh: scale = 0.30; break;
    }
    
    CGFloat logoWidthLimit = size.width * scale;
    CGFloat logoHeightLimit = size.height * scale;
    
    CGFloat logoWidth = logo.size.width;
    if (logoWidth >= logoWidthLimit) {
        logoWidth = logoWidthLimit;
    }
    
    CGFloat logoHeight = logo.size.height;
    if (logoHeight >= logoHeightLimit) {
        logoHeight = logoHeightLimit;
    }
    
    [logo drawInRect:CGRectMake((size.width - logoWidth) / 2.0,
                                (size.height - logoHeight) / 2,
                                logoWidth,
                                logoHeight)];
    
    UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return result;
}

// 生成条形码
+ (UIImage *)generateBarcode:(NSString *)message size:(CGSize)size color:(UIColor *)color backgroundColor:(UIColor *)backgroundColor
{
    return [self generateCodeImageWithType:SGS128Barcode message:message correctionLevel:0 size:size color:color backgroundColor:backgroundColor];
}

// 生成二维码或条形码图片
+ (UIImage *)generateCodeImageWithType:(NSString *)type
                               message:(NSString *)message
                       correctionLevel:(SGSQRCodeCorrectionLevel)correctionLevel
                                  size:(CGSize)size color:(UIColor *)color
                       backgroundColor:(UIColor *)backgroundColor
{
    if (message.length == 0) return nil;
    
    NSData *messageData = [message dataUsingEncoding:NSUTF8StringEncoding];
    if (messageData == nil) return nil;
    
    NSDictionary *params = nil;
    CIFilter *filter     = nil;
    CIImage *image       = nil;
    
    // 生成图片
    filter = [CIFilter filterWithName:type];
    [filter setValue:messageData forKey:@"inputMessage"];
    if ([type isEqualToString:SGSQRCode]) {
        NSString *level = @"M";
        // 容错级别
        // L　: 7%
        // M　: 15%
        // Q　: 25%
        // H　: 30%
        switch (correctionLevel) {
            case SGSQRCodeCorrectionLevelLow:      level = @"L"; break;
            case SGSQRCodeCorrectionLevelMedium:   level = @"M"; break;
            case SGSQRCodeCorrectionLevelQuartile: level = @"Q"; break;
            case SGSQRCodeCorrectionLevelHigh:     level = @"H"; break;
        }
        
        [filter setValue:level forKey:@"inputCorrectionLevel"];
    }
    image = filter.outputImage;
    if (image == nil) return nil;
    
    // 上色
    color = (color != nil) ? color : [UIColor blackColor];
    backgroundColor = (backgroundColor != nil) ? backgroundColor : [UIColor whiteColor];
    params = @{@"inputImage": image,
               @"inputColor0": [CIColor colorWithCGColor:color.CGColor],
               @"inputColor1": [CIColor colorWithCGColor:backgroundColor.CGColor]};
    filter = [CIFilter filterWithName:@"CIFalseColor" withInputParameters:params];
    image = filter.outputImage;
    if (image == nil) return nil;
    
    CGImageRef cgImage = [[CIContext contextWithOptions:nil] createCGImage:image fromRect:image.extent];
    UIGraphicsBeginImageContext(size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetInterpolationQuality(context, kCGInterpolationNone);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextDrawImage(context, CGContextGetClipBoundingBox(context), cgImage);
    UIImage *codeImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    CGImageRelease(cgImage);
    
    return codeImage;
}

@end
