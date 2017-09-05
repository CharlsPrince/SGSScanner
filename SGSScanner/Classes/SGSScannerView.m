/*!
 *  @header SGSScannerView.m
 *
 *  @author Created by Lee on 16/10/14.
 *
 *  @copyright 2016年 SouthGIS. All rights reserved.
 */

#import "SGSScannerView.h"

@interface SGSScannerView ()
@property (nonatomic, strong) UIView *maskView;
@property (nonatomic, strong) UIActivityIndicatorView *loadingIndicator;
@property (nonatomic, strong) UILabel *loadingLabel;
@property (nonatomic, strong) UIButton *tipsButton;
@property (nonatomic, strong) UILabel *hintLabel;
@end

@implementation SGSScannerView

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setupSubviews];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupSubviews];
    }
    return self;
}

#pragma mark - Setup

- (void)setupSubviews {
    _maskView = [[UIView alloc] initWithFrame:self.bounds];
    _maskView.backgroundColor = [UIColor blackColor];
    
    _loadingIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    _loadingIndicator.hidden = YES;
    
    _loadingLabel = [[UILabel alloc] init];
    _loadingLabel.text = @"正在加载...";
    _loadingLabel.textColor = [UIColor lightGrayColor];
    _loadingLabel.textAlignment = NSTextAlignmentCenter;
    _loadingLabel.hidden = YES;
    
    _tipsButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_tipsButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_tipsButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
    [_tipsButton addTarget:self action:@selector(tipsButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    _tipsButton.hidden = YES;
    
    [self addSubview:_maskView];
    [_maskView addSubview:_loadingIndicator];
    [_maskView addSubview:_loadingLabel];
    [_maskView addSubview:_tipsButton];
    
    [self setupMaskViewConstraints];
    [self setupLoadingIndicatorConstraints];
    [self setupLoadingLabelConstraints];
    [self setupTipsButtonConstraints];
}

- (void)setupMaskViewConstraints {
    if (_maskView && _maskView.superview) {
        _maskView.translatesAutoresizingMaskIntoConstraints = NO;
        NSDictionary *bindingViews = @{@"maskView": _maskView};
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[maskView]-0-|" options:kNilOptions metrics:nil views:bindingViews]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[maskView]-0-|" options:kNilOptions metrics:nil views:bindingViews]];
    }
}

- (void)setupLoadingIndicatorConstraints {
    if (_loadingIndicator && _loadingIndicator.superview) {
        [_loadingIndicator sizeToFit];
        _loadingIndicator.translatesAutoresizingMaskIntoConstraints = NO;
        UIView *superView = _loadingIndicator.superview;
        [superView addConstraint:[NSLayoutConstraint constraintWithItem:_loadingIndicator attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:superView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0]];
        [superView addConstraint:[NSLayoutConstraint constraintWithItem:_loadingIndicator attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:superView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0]];
    }
}

- (void)setupLoadingLabelConstraints {
    if (_loadingLabel && _loadingLabel.superview) {
        [_loadingLabel sizeToFit];
        _loadingLabel.translatesAutoresizingMaskIntoConstraints = NO;
        UIView *superView = _loadingLabel.superview;
        [superView addConstraint:[NSLayoutConstraint constraintWithItem:_loadingLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:superView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0]];
        [superView addConstraint:[NSLayoutConstraint constraintWithItem:_loadingLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_loadingIndicator   attribute:NSLayoutAttributeBottom multiplier:1.0 constant:15.0]];
    }
    
}

- (void)setupTipsButtonConstraints {
    if (_tipsButton && _tipsButton.superview) {
        _tipsButton.translatesAutoresizingMaskIntoConstraints = NO;
        UIView *superView = _tipsButton.superview;
        NSDictionary *bindingViews = @{@"tipsButton": _tipsButton};
        [superView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[tipsButton]-0-|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:bindingViews]];
        [superView addConstraint:[NSLayoutConstraint constraintWithItem:_tipsButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:0.0]];
        [superView addConstraint:[NSLayoutConstraint constraintWithItem:_tipsButton attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:superView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0]];
    }
}

#pragma mark - Override

- (void)setPreviewLayer:(AVCaptureVideoPreviewLayer *)previewLayer rectOfInterest:(CGRect)rectOfInterest style:(SGSScanPreviewStyle *)style {
    [super setPreviewLayer:previewLayer rectOfInterest:rectOfInterest style:style];
    
    UILabel *textLabel = [[UILabel alloc] init];
    textLabel.text = @"放入框内，自动扫描";
    textLabel.textColor = [UIColor lightTextColor];
    textLabel.textAlignment = NSTextAlignmentCenter;
    
    CGFloat positionX = CGRectGetMinX(rectOfInterest) + CGRectGetWidth(rectOfInterest) / 2;
    CGFloat positionY = CGRectGetMaxY(rectOfInterest) + 40;
    textLabel.center = CGPointMake(positionX, positionY);
    textLabel.bounds = CGRectMake(0, 0, self.bounds.size.width, 30);
    
    [self addSubview:textLabel];
    
    _maskView.alpha = 1.0;
    [self bringSubviewToFront:_maskView];
}

#pragma mark - Public

- (void)showLoadingView {
    _tipsButton.hidden = YES;
    [self bringSubviewToFront:_maskView];
    _maskView.alpha = 1.0;
    _maskView.hidden = NO;
    _loadingLabel.hidden = NO;
    [_loadingIndicator startAnimating];
}

- (void)hideLoadingView {
    _tipsButton.hidden = YES;
    _loadingLabel.hidden = YES;
    [_loadingIndicator stopAnimating];
    _maskView.hidden = YES;
}

- (void)showTips:(NSString *)tips enableClicked:(BOOL)enableClicked {
    _loadingLabel.hidden = YES;
    [_loadingIndicator stopAnimating];
    [self bringSubviewToFront:_maskView];
    _maskView.alpha = 1.0;
    _maskView.hidden = NO;
    _tipsButton.hidden = NO;
    _tipsButton.enabled = enableClicked;
    UIControlState state = enableClicked ? UIControlStateNormal : UIControlStateDisabled;
    [_tipsButton setTitle:tips forState:state];
}

- (void)hideTipsWithAnimate:(BOOL)animate {
    _loadingLabel.hidden = YES;
    [_loadingIndicator stopAnimating];
    
    if (!_maskView.isHidden) {
        if (animate) {
            [UIView animateWithDuration:0.25 animations:^{
                self.maskView.alpha = 0;
            } completion:^(BOOL finished) {
                self.tipsButton.hidden = YES;
                self.maskView.hidden = YES;
            }];
        } else {
            _tipsButton.hidden = YES;
            _maskView.hidden = YES;
        }
    }
}

#pragma mark - Actions
- (void)tipsButtonClicked:(UIButton *)sender {
    if ([_delegate respondsToSelector:@selector(scannerView:tipsButtonClicked:)]) {
        [_delegate scannerView:self tipsButtonClicked:sender];
    }
}

@end
