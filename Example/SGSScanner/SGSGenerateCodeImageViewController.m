//
//  SGSGenerateCodeImageViewController.m
//  SGSScanner
//
//  Created by Lee on 2017/1/13.
//  Copyright © 2017年 Lee. All rights reserved.
//

#import "SGSGenerateCodeImageViewController.h"
#import "UIViewController+SGSAlert.h"
#import "NSString+SGSRegex.h"
#import "SGSScanUtil.h"

@interface SGSGenerateCodeImageViewController ()
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UISegmentedControl *levelSegment;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@end

@implementation SGSGenerateCodeImageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"生成二维码/条形码";
}

// 生成条形码
- (IBAction)generateBarcode:(UIButton *)sender {
    NSString *msg = _textField.text;
    if (msg.length == 0) {
        [self showEmptyInputMessageAlert];
        return;
    }
    
    if (![msg isConsists7bitASCIICharacters]) {
        [self showAlertPanelWithTitle:@"您输入的字符串包含非法字符" message:@"生成条形码仅允许7-bit的ASCII码" handler:nil];
        return;
    }
    
    _imageView.image = [SGSScanUtil generateBarcode:msg size:_imageView.bounds.size color:nil backgroundColor:nil];
    [self.view endEditing:YES];
}

// 生成带logo的二维码
- (IBAction)generateCodeImageWithLogo:(UIButton *)sender {
    NSString *msg = _textField.text;
    if (msg.length == 0) {
        [self showEmptyInputMessageAlert];
        return;
    }
    
    
    
    UIImage *image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon" ofType:@"jpg"]];
    _imageView.image = [SGSScanUtil generateQRCode:msg correctionLevel:[self qrCodeCorrectionLevel] size:_imageView.bounds.size color:nil backgroundColor:nil logoImage:image];
    [self.view endEditing:YES];
}

// 生成没有logo的二维码
- (IBAction)generateCodeImage:(UIButton *)sender {
    NSString *msg = _textField.text;
    if (msg.length == 0) {
        [self showEmptyInputMessageAlert];
        return;
    }
    
    _imageView.image = [SGSScanUtil generateQRCode:msg correctionLevel:[self qrCodeCorrectionLevel] size:_imageView.bounds.size color:nil backgroundColor:nil];
    [self.view endEditing:YES];
}

- (IBAction)tappedBackgroundView:(UITapGestureRecognizer *)sender {
    [self.view endEditing:YES];
}

- (IBAction)longPressImageView:(UILongPressGestureRecognizer *)sender {
    UIImage *image = _imageView.image;
    if (image == nil) {
        return;
    }
    
    [self showConfirmPanelWithTitle:@"是否保存图片到相册中？" message:nil handler:^(BOOL confirm) {
        if (confirm) {
            UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
        }
    }];
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    if (error == nil) {
        [self showAlertPanelWithTitle:@"保存成功！" message:nil handler:nil];
    } else {
        [self showAlertPanelWithTitle:@"保存失败" message:error.localizedDescription handler:nil];
    }
}

- (SGSQRCodeCorrectionLevel)qrCodeCorrectionLevel {
    SGSQRCodeCorrectionLevel level = 0;
    switch (_levelSegment.selectedSegmentIndex) {
        case 0:
            level = SGSQRCodeCorrectionLevelLow;
            break;
        case 1:
            level = SGSQRCodeCorrectionLevelMedium;
            break;
        case 2:
            level = SGSQRCodeCorrectionLevelQuartile;
            break;
        case 3:
            level = SGSQRCodeCorrectionLevelHigh;
            break;
        default:
            break;
    }
    return level;
}

- (void)showEmptyInputMessageAlert {
    [self showAlertPanelWithTitle:@"输入信息不能为空" message:nil handler:nil];
}

@end
