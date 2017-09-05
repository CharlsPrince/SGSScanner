/*!
 *  @header SGSScannerViewController.m
 *
 *  @author Created by Lee on 16/10/14.
 *
 *  @copyright 2016年 SouthGIS. All rights reserved.
 */

#import "SGSScannerViewController.h"
#import "SGSScanUtil.h"
#import "SGSScannerView.h"
#import "NSBundle+SGSScanner.h"

@interface SGSScannerViewController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate>
@property (nonatomic, strong, readwrite) SGSScanUtil *scanner;
@property (nonatomic, strong, readwrite) SGSScannerView *previewView;
@property (nonatomic, strong) SGSScanPreviewStyle *style;
@property (nonatomic, strong) UIView *customNavBar;
@property (nonatomic, strong) UIButton *backButton;
@property (nonatomic, strong) UIButton *torchButton;
@property (nonatomic, strong) UIButton *photoPickerButton;
@property (nonatomic, assign) CGRect rectOfInterest;
@property (nonatomic, assign) BOOL isSelectImage;
@property (nonatomic, assign) BOOL didParseScanResult;
@end

@implementation SGSScannerViewController

- (instancetype)initWithDelegate:(id<SGSScannerDelegate>)delegate {
    return [self initWithStyle:nil delegate:delegate];
}

- (instancetype)initWithStyle:(SGSScanPreviewStyle *)style delegate:(id<SGSScannerDelegate>)delegate {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        if (style == nil) {
            style = [[SGSScanPreviewStyle alloc] init];
        }
        _style = style;
        _delegate = delegate;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:self.previewView];
    [self.view addSubview:self.customNavBar];
    
    CGFloat screenWidth      = [UIScreen mainScreen].bounds.size.width;
    CGFloat widthOfInterest  = screenWidth * 0.7;
    CGFloat heightOfInterest = widthOfInterest;
    CGFloat xOfInterest      = (screenWidth - widthOfInterest) / 2;
    CGFloat yOfInterest      = xOfInterest * 2.5;
    _rectOfInterest = CGRectMake(xOfInterest, yOfInterest, widthOfInterest, heightOfInterest);
    
    _scanner = [[SGSScanUtil alloc] initWithPreviewView:self.previewView
                                       regionOfInterest:_rectOfInterest
                                    metadataObjectTypes:nil
                                           scanDelegate:self];
    
    _didParseScanResult = NO;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    _didParseScanResult = NO;
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    
    switch (_scanner.capturSessionState) {
        case SGSCaptureSessionStateConfigurationCompleted: { // 摄像头设置完毕
            [_previewView showLoadingView];
            [_scanner startScan];
        } break;
            
        case SGSCaptureSessionStateNotAuthorized: { // 没有获取摄像头权限
            [self showSettingCaptureAuthorizedAlert];
        } break;
            
        case SGSCaptureSessionStateConfigurationFailed: { // 摄像头打开失败
            [self.previewView showTips:@"无法获取摄像头服务" enableClicked:NO];
        } break;
    }
}

- (void)showSettingCaptureAuthorizedAlert {
    __weak typeof(&*self) weakSelf = self;
    [self showAlertWithTitle:@"相机服务未开启" message:@"请在系统设置中开启相机服务" buttonTitles:@[@"暂不", @"设置"] completion:^(NSUInteger idx) {
        if (idx == 1) {
            [weakSelf gotoAppSettingWithCompletionHandler:^(BOOL success) {
                [weakSelf.previewView showTips:@"点击前往系统设置开启相机服务" enableClicked:YES];
            }];
        }
    }];
}

- (void)gotoAppSettingWithCompletionHandler:(void (^)(BOOL))completion {
    UIApplication *app = [UIApplication sharedApplication];
    NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
    
    if ([app respondsToSelector:@selector(openURL:options:completionHandler:)]) {
        [app openURL:url options:@{} completionHandler:completion];
    } else {
        BOOL result = [app openURL:url];
        if (completion != nil) {
            completion(result);
        }
    }
}


- (void)viewWillDisappear:(BOOL)animated {
    [_scanner stopScan];
    
    if (!_isSelectImage) {
        [self.navigationController setNavigationBarHidden:NO animated:YES];
    }
    
    [super viewWillDisappear:animated];
}

#pragma mark - StatusBar

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

#pragma mark - Auto Rotation

- (BOOL)shouldAutorotate {
    return YES;
}

// 只允许竖屏
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

#pragma mark - Actions

// 点击返回按钮
- (void)backButtonClicked:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

// 点击闪光灯按钮
- (void)torchButtonClicked:(UIButton *)sender {
    if ([_scanner hasTorch]) {
        sender.selected = !sender.selected;
        [_scanner setTorchModeToOn:sender.selected];
    } else {
        [self showAlertWithTitle:@"您的设备不支持闪光灯" message:nil buttonTitles:@[@"明白了"] completion:nil];
    }
}

// 从相册中选择二维码
- (void)photoPickerButtonClicked:(UIButton *)sender {
    _isSelectImage = YES;
    [_scanner stopScan];
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:imagePicker animated:YES completion:nil];
}


#pragma mark - SGSScannerViewDelegate

- (void)scannerView:(SGSScannerView *)view tipsButtonClicked:(UIButton *)sender {
    if ([_delegate respondsToSelector:@selector(scannerViewController:scannerView:tipsButtonClicked:)]) {
        [_delegate scannerViewController:self scannerView:view tipsButtonClicked:sender];
    } else {
        if (_scanner.capturSessionState == SGSCaptureSessionStateNotAuthorized) {
            [self gotoAppSettingWithCompletionHandler:nil];
        }
    }
}

#pragma mark - Scan Result

// 处理扫描结果
- (void)handleScanResult:(NSString *)result {
    if (_didParseScanResult) return;
    
    _didParseScanResult = YES;
    
    if ([_delegate respondsToSelector:@selector(scannerViewController:didFinishScanWithResultMessage:)]) {
        [_delegate scannerViewController:self didFinishScanWithResultMessage:result];
    }
}


#pragma mark - SGSScanUtilDelegate

// 二维码扫描完毕
- (void)scanUtil:(SGSScanUtil *)scanUtil didFinishScan:(NSArray<__kindof AVMetadataObject *> *)metadataObjects {
    if ([_delegate respondsToSelector:@selector(scannerViewController:scanUtil:didFinishScan:)]) {
        [_delegate scannerViewController:self scanUtil:scanUtil didFinishScan:metadataObjects];
    } else {
        [scanUtil stopScan];
        if (metadataObjects.count > 0) {
            AVMetadataMachineReadableCodeObject *obj = metadataObjects[0];
            [self handleScanResult:obj.stringValue];
        } else {
            [self handleScanResult:nil];
        }
    }
}

// 摄像头开启
- (void)scanUtil:(SGSScanUtil *)scanUtil captureSessionDidStartRunning:(AVCaptureSession *)session {
    if ([_delegate respondsToSelector:@selector(scannerViewController:scanUtil:captureSessionDidStartRunning:)]) {
        [_delegate scannerViewController:self scanUtil:scanUtil captureSessionDidStartRunning:session];
    } else {
        [_previewView hideLoadingView];
        [scanUtil setTorchModeToOn:_torchButton.selected];
        [_previewView startAnimating];
    }
}

// 摄像头关闭
- (void)scanUtil:(SGSScanUtil *)scanUtil captureSessionDidStopRunning:(AVCaptureSession *)session {
    if ([_delegate respondsToSelector:@selector(scannerViewController:scanUtil:captureSessionDidStopRunning:)]) {
        [_delegate scannerViewController:self scanUtil:scanUtil captureSessionDidStopRunning:session];
    } else {
        [scanUtil turnOffTorch];
        [_previewView stopAnimating];
    }
}

// 摄像头设置完毕
- (void)scanUtil:(SGSScanUtil *)scanUtil captureSessionConfigurationCompleted:(AVCaptureSession *)session previewLayer:(AVCaptureVideoPreviewLayer *)previewLayer {
    if ([_delegate respondsToSelector:@selector(scannerViewController:scanUtil:captureSessionConfigurationCompleted:previewLayer:)]) {
        [_delegate scannerViewController:self scanUtil:scanUtil captureSessionConfigurationCompleted:session previewLayer:previewLayer];
    } else {
        [_previewView setPreviewLayer:previewLayer rectOfInterest:_rectOfInterest style:_style];
        [scanUtil resizeRectOfInterestForRect:_rectOfInterest];
    }
}

// 摄像头设置失败
- (void)scanUtil:(SGSScanUtil *)scanUtil captureSessionConfigurationFailed:(AVCaptureSession *)session {
    if ([_delegate respondsToSelector:@selector(scannerViewController:scanUtil:captureSessionConfigurationFailed:)]) {
        [_delegate scannerViewController:self scanUtil:scanUtil captureSessionConfigurationFailed:session];
    } else {
        [_previewView showTips:@"无法获取摄像头服务" enableClicked:NO];
    }
}

// 摄像头运行时出错
- (void)scanUtil:(SGSScanUtil *)scanUtil captureSession:(AVCaptureSession *)session runtimeError:(NSError *)error {
    if ([_delegate respondsToSelector:@selector(scannerViewController:scanUtil:captureSession:runtimeError:)]) {
        [_delegate scannerViewController:self scanUtil:scanUtil captureSession:session runtimeError:error];
    } else {
        if (error.code == AVErrorMediaServicesWereReset) {
            if (scanUtil.isSessionRunning) {
                [scanUtil startScan];
            }
        } else {
            [_previewView showTips:@"摄像头打开失败" enableClicked:NO];
        }
    }
}

// 摄像头扫描中断
- (void)scanUtil:(SGSScanUtil *)scanUtil captureSession:(AVCaptureSession *)session wasInterrupted:(AVCaptureSessionInterruptionReason)interruptionReason {
    if ([_delegate respondsToSelector:@selector(scannerViewController:scanUti:captureSession:wasInterrupted:)]) {
        [_delegate scannerViewController:self scanUti:scanUtil captureSession:session wasInterrupted:interruptionReason];
    } else {
        if (interruptionReason == AVCaptureSessionInterruptionReasonVideoDeviceNotAvailableWithMultipleForegroundApps) {
            [_previewView showTips:@"扫描中断" enableClicked:NO];
        }
    }
}


// 摄像头从中断状态恢复
- (void)scanUtil:(SGSScanUtil *)scanUtil captureSessionInterruptionEnded:(AVCaptureSession *)session {
    if ([_delegate respondsToSelector:@selector(scannerViewController:scanUti:captureSessionInterruptionEnded:)]) {
        [_delegate scannerViewController:self scanUti:scanUtil captureSessionInterruptionEnded:session];
    } else {
        [_previewView hideTipsWithAnimate:YES];
    }
}


#pragma mark - UIImagePickerControllerDelegate

// 从相册选择二维码图片
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    _isSelectImage = NO;
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    NSString *message = [SGSScanUtil readQRCodeFromImage:image];
    [self handleScanResult:message];
}

// 取消选择二维码图片
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    _isSelectImage = NO;
    [picker dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - Alert

- (void)showAlertWithTitle:(NSString *)title message:(NSString *)message buttonTitles:(NSArray<NSString *> *)titles completion:(void(^)(NSUInteger))completion {
    if (self.view.window != nil) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
        [titles enumerateObjectsUsingBlock:^(NSString * _Nonnull title, NSUInteger idx, BOOL * _Nonnull stop) {
            UIAlertActionStyle style = (idx == 0) ? UIAlertActionStyleCancel : UIAlertActionStyleDefault;
            UIAlertAction *action = [UIAlertAction actionWithTitle:title style:style handler:^(UIAlertAction * _Nonnull action) {
                if (completion != nil) {
                    completion(idx);
                }
            }];
            [alert addAction:action];
        }];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

#pragma mark - Accessors

- (SGSScannerView *)previewView {
    if (_previewView == nil) {
        _previewView = [[SGSScannerView alloc] initWithFrame:self.view.bounds];
        _previewView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }
    return _previewView;
}

- (UIView *)customNavBar {
    if (_customNavBar == nil) {
        _customNavBar = [[UIView alloc] initWithFrame:CGRectMake(0, 20, self.view.bounds.size.width, 44)];
        _customNavBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [_customNavBar addSubview:self.backButton];
        [_customNavBar addSubview:self.torchButton];
        [_customNavBar addSubview:self.photoPickerButton];
        
        NSDictionary *bindingViews = @{@"backButton": self.backButton, @"torchButton": self.torchButton, @"photoPickerButton": self.photoPickerButton};
        
        // 返回按钮的布局
        [_customNavBar addConstraint:[NSLayoutConstraint constraintWithItem:self.backButton attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:_customNavBar attribute:NSLayoutAttributeLeft multiplier:1.0 constant:8]];
        [_customNavBar addConstraint:[NSLayoutConstraint constraintWithItem:self.backButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.backButton attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0.0]];
        [_customNavBar addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-6-[backButton]-8-|" options:kNilOptions metrics:nil views:bindingViews]];
        
        // 闪光灯按钮和相册按钮
        [_customNavBar addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[torchButton(>=0)]-8-[photoPickerButton(>=0)]-8-|" options:NSLayoutFormatAlignAllTop | NSLayoutFormatAlignAllBottom metrics:nil views:bindingViews]];
        [_customNavBar addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-6-[photoPickerButton]-8-|" options:kNilOptions metrics:nil views:bindingViews]];
    }
    return _customNavBar;
}

- (UIButton *)backButton {
    if (_backButton == nil) {
        _backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _backButton.translatesAutoresizingMaskIntoConstraints = NO;
        _backButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
        [_backButton setImage:[NSBundle sgsScannerNavBackNormalImage] forState:UIControlStateNormal];
        [_backButton setImage:[NSBundle sgsScannerNavBackPressedImage] forState:UIControlStateHighlighted];
        [_backButton addTarget:self action:@selector(backButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _backButton;
}

- (UIButton *)torchButton {
    if (_torchButton == nil) {
        _torchButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _torchButton.translatesAutoresizingMaskIntoConstraints = NO;
        _torchButton.contentEdgeInsets = UIEdgeInsetsMake(0, 8, 0, 8);
        [_torchButton setTitle:@"开灯" forState:UIControlStateNormal];
        [_torchButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_torchButton setTitle:@"关灯" forState:UIControlStateSelected];
        [_torchButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        [_torchButton addTarget:self action:@selector(torchButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _torchButton;
}

- (UIButton *)photoPickerButton {
    if (_photoPickerButton == nil) {
        _photoPickerButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _photoPickerButton.translatesAutoresizingMaskIntoConstraints = NO;
        _photoPickerButton.contentEdgeInsets = UIEdgeInsetsMake(0, 8, 0, 8);
        [_photoPickerButton setTitle:@"相册" forState:UIControlStateNormal];
        [_photoPickerButton addTarget:self action:@selector(photoPickerButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _photoPickerButton;
}

@end
