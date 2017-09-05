/*!
 *  @header SGSScannerView.h
 *
 *  @abstract 扫一扫视图
 *
 *  @author Created by Lee on 16/10/24.
 *
 *  @copyright 2016年 SouthGIS. All rights reserved.
 */

#import "SGSScanPreviewView.h"

NS_ASSUME_NONNULL_BEGIN

@protocol SGSScannerViewDelegate;


/*!
 *  @abstract扫一扫视图
 */
@interface SGSScannerView : SGSScanPreviewView

@property (nullable, nonatomic, weak) id<SGSScannerViewDelegate> delegate;

/// 显示加载视图
- (void)showLoadingView;

/// 隐藏加载视图
- (void)hideLoadingView;

/// 显示提示信息，并控制是否可以点击提示信息触发代理方法回调
- (void)showTips:(nullable NSString *)tips enableClicked:(BOOL)enableClicked;

/// 隐藏提示信息
- (void)hideTipsWithAnimate:(BOOL)animate;

@end


@protocol SGSScannerViewDelegate <NSObject>
/// 点击提示信息按钮
- (void)scannerView:(SGSScannerView *)view tipsButtonClicked:(UIButton *)sender;
@end

NS_ASSUME_NONNULL_END
