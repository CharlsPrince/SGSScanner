/*!
 *  @header SGSScannerViewController.h
 *
 *  @abstract 扫一扫视图控制器
 *
 *  @author Created by Lee on 16/10/24.
 *
 *  @copyright 2016年 SouthGIS. All rights reserved.
 */

#import <UIKit/UIKit.h>
#import "SGSScanUtilDelegate.h"
#import "SGSScannerDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@class SGSScanPreviewStyle, SGSScanUtil, SGSScannerView;

@interface SGSScannerViewController : UIViewController <SGSScanUtilDelegate>

@property (nonatomic, strong, readonly) SGSScanUtil *scanner;
@property (nonatomic, strong, readonly) SGSScannerView *previewView;
@property (nullable, nonatomic, strong) id<SGSScannerDelegate> delegate;


/*!
 *  根据代理初始化，style使用默认的样式
 *
 *  @param delegate 扫描代理
 *  @return SGSScannerViewController
 */
- (instancetype)initWithDelegate:(id<SGSScannerDelegate>)delegate;


/*!
 *  根据样式和代理初始化
 *
 *  @param style 扫描预览样式
 *  @param delegate 扫描代理
 *  @return SGSScannerViewController
 */
- (instancetype)initWithStyle:(nullable SGSScanPreviewStyle *)style delegate:(id<SGSScannerDelegate>)delegate;

@end

NS_ASSUME_NONNULL_END
