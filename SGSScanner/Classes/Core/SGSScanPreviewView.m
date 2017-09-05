/*!
 *  @header SGSScanPreviewView.m
 *
 *  @author Created by Lee on 16/10/24.
 *
 *  @copyright 2016年 SouthGIS. All rights reserved.
 */

#import "SGSScanPreviewView.h"
#import <AVFoundation/AVCaptureVideoPreviewLayer.h>


@interface SGSScanPreviewView ()

@property (nonatomic, weak, readwrite) AVCaptureVideoPreviewLayer *previewLayer;
@property (nonatomic, strong) SGSScanPreviewStyle *style;

@property (nonatomic, strong) UIView *animationRegionView;
@property (nonatomic, strong) UIImageView *animationImageView;
@property (nonatomic, assign) BOOL animating;
@property (nonatomic, strong) CADisplayLink *link;

@property (nonatomic, strong) CAShapeLayer *maskLayer;
@property (nonatomic, strong) CAShapeLayer *regionOfInterestOutline;
@property (nonatomic, strong) CAShapeLayer *topLeftControl;
@property (nonatomic, strong) CAShapeLayer *topRightControl;
@property (nonatomic, strong) CAShapeLayer *bottomRightControl;
@property (nonatomic, strong) CAShapeLayer *bottomLeftControl;

@end


@implementation SGSScanPreviewView

- (void)dealloc {
    [self stopAnimating];
}

#pragma mark - Animation

/// 开启扫描动画
- (void)startAnimating {
    if (_animationImageView != nil) {
        switch (_style.animationStyle) {
            case SGSScanAnimationStyleLineMove:
                [self startLineMoveAnimation];
                break;
                
            case SGSScanAnimationStyleGrid:
                [self startGridAnimation];
                break;
                
            case SGSScanAnimationStyleLineStill:
                [self startLineStillAnimation];
                break;
                
            default:
                [self stopAnimating];
                break;
        }
    }
}

/// 起开线条静止在中央的动画
- (void)startLineStillAnimation {
    _animationRegionView.hidden = NO;
    if (_link != nil) {
        [_link invalidate];
        _link = nil;
    }
    _animating = YES;
}

/// 起开线条滚动的动画
- (void)startLineMoveAnimation {
    _animationRegionView.hidden = NO;
    if (_link != nil) {
        [_link invalidate];
    }
    _link = [CADisplayLink displayLinkWithTarget:self selector:@selector(lineMoveAnimation)];
    [_link addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    _animating = YES;
}

/// 起开网格扫描的动画
- (void)startGridAnimation {
    _animationRegionView.hidden = NO;
    if (_link != nil) {
        [_link invalidate];
    }
    _link = [CADisplayLink displayLinkWithTarget:self selector:@selector(gridAnimation)];
    [_link addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    _animating = YES;
}

// 线条滚动动画
- (void)lineMoveAnimation {
    [self animationWithStarting:-CGRectGetHeight(_animationImageView.frame) end:CGRectGetHeight(_animationRegionView.frame) afterDelayWhenCompleted:-1 isGrid:NO];
}

// 网格扫描动画
- (void)gridAnimation {
    [self animationWithStarting:-CGRectGetHeight(_animationRegionView.frame) end:0 afterDelayWhenCompleted:0.5 isGrid:YES];
}

// 动画执行
- (void)animationWithStarting:(CGFloat)start end:(CGFloat)end afterDelayWhenCompleted:(NSTimeInterval)delay isGrid:(BOOL)isGrid {
    CGFloat x      = _animationImageView.frame.origin.x;
    CGFloat y      = _animationImageView.frame.origin.y;
    CGFloat width  = _animationImageView.frame.size.width;
    CGFloat height = _animationImageView.frame.size.height;
    
    y += 2;
    if (y >= end) {
        // 到达底部是否延迟循环
        if (delay > 0) {
            [self pausedAnimating];
            __weak typeof(&*self) weakSelf = self;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                if (weakSelf) {
                    weakSelf.animationImageView.frame = CGRectMake(x, start, width, height);
                    [weakSelf resumeAnimating];
                }
            });
            
            if (isGrid) {
                [UIView animateWithDuration:delay + 0.1 animations:^{
                    weakSelf.animationImageView.alpha = 0.0;
                } completion:^(BOOL finished) {
                    weakSelf.animationImageView.alpha = 1.0;
                }];
            }
        } else {
            y = start;
        }
    }
    
    _animationImageView.frame = CGRectMake(x, y, width, height);
}

/// 停止扫描动画
- (void)stopAnimating {
    _animationRegionView.hidden = YES;
    _animating = NO;
    [_link invalidate];
    _link = nil;
}

/// 暂停动画
- (void)pausedAnimating {
    if ((_link != nil) && !_link.isPaused) {
        _link.paused = YES;
    }
}

/// 继续启动动画
- (void)resumeAnimating {
    if ((_link != nil) && _link.isPaused) {
        _link.paused = NO;
    }
}

#pragma mark - Preview Layer

- (void)setPreviewLayer:(AVCaptureVideoPreviewLayer *)previewLayer rectOfInterest:(CGRect)rectOfInterest style:(SGSScanPreviewStyle *)style {
    
    [self pausedAnimating];
    
    if (_previewLayer != nil) {
        [_previewLayer removeFromSuperlayer];
    }
    
    _previewLayer = previewLayer;
    _rectOfInterest = rectOfInterest;
    _style = style;
    
    [self setupAnimationView];
    [self setupPreviewLayer];
    [self setNeedsLayout];
    
    [self resumeAnimating];
}

- (void)setupAnimationView {
    if (_style.animationStyle == SGSScanAnimationStyleNone) {
        _animationRegionView.hidden = YES;
    } else {
        // 触发懒加载
        UIView *animationRegionView = self.animationRegionView;
        UIImageView *animationImageView = self.animationImageView;
        
        animationImageView.image = _style.animationImage;
        
        animationRegionView.hidden = (animationImageView.image == nil);
    }
}

- (void)setupPreviewLayer {
    if (_previewLayer == nil) return;
    
    _previewLayer.frame = self.bounds;
    [self.layer insertSublayer:_previewLayer atIndex:0];
    
    CAShapeLayer *maskLayer               = self.maskLayer;
    CAShapeLayer *regionOfInterestOutline = self.regionOfInterestOutline;
    CAShapeLayer *topLeftControl          = self.topLeftControl;
    CAShapeLayer *topRightControl         = self.topRightControl;
    CAShapeLayer *bottomRightControl      = self.bottomRightControl;
    CAShapeLayer *bottomLeftControl       = self.bottomLeftControl;
    
    // 掩膜
    maskLayer.fillColor = _style.maskColor.CGColor;
    maskLayer.opacity = _style.maskOpacity;
    [self.layer addSublayer:maskLayer];
    
    // 识别区域边框
    regionOfInterestOutline.path = CGPathCreateWithRect(_rectOfInterest, NULL);
    regionOfInterestOutline.lineWidth = _style.regionOfInterestOutlineWidth;
    regionOfInterestOutline.strokeColor = _style.regionOfInterestOutlineColor.CGColor;
    [self.layer addSublayer:regionOfInterestOutline];
    
    CGFloat controlCornerWidth = fabs(_style.controlCornerWidth);
    CGFloat controlCornerHeight = fabs(_style.controlCornerHeight);
    CGFloat controlCornerLineWidth = fabs(_style.controlCornerLineWidth);
    
    // 左上角
    UIBezierPath *topLeftPath = [[UIBezierPath alloc] init];
    [topLeftPath moveToPoint:CGPointMake(0, controlCornerHeight)];
    [topLeftPath addLineToPoint:CGPointMake(0, 0)];
    [topLeftPath addLineToPoint:CGPointMake(controlCornerWidth, 0)];
    topLeftControl.path        = topLeftPath.CGPath;
    topLeftControl.lineWidth   = controlCornerLineWidth;
    topLeftControl.strokeColor = _style.controlCornerColor.CGColor;
    [self.layer addSublayer:topLeftControl];
    
    // 右上角
    UIBezierPath *topRightPath = [[UIBezierPath alloc] init];
    [topRightPath moveToPoint:CGPointMake(-controlCornerWidth, 0)];
    [topRightPath addLineToPoint:CGPointMake(0, 0)];
    [topRightPath addLineToPoint:CGPointMake(0, controlCornerHeight)];
    topRightControl.path        = topRightPath.CGPath;
    topRightControl.lineWidth   = controlCornerLineWidth;
    topRightControl.strokeColor = _style.controlCornerColor.CGColor;
    [self.layer addSublayer:topRightControl];
    
    // 右下角
    UIBezierPath *bottomRightPath = [[UIBezierPath alloc] init];
    [bottomRightPath moveToPoint:CGPointMake(0, -controlCornerHeight)];
    [bottomRightPath addLineToPoint:CGPointMake(0, 0)];
    [bottomRightPath addLineToPoint:CGPointMake(-controlCornerWidth, 0)];
    bottomRightControl.path        = bottomRightPath.CGPath;
    bottomRightControl.lineWidth   = controlCornerLineWidth;
    bottomRightControl.strokeColor = _style.controlCornerColor.CGColor;
    [self.layer addSublayer:bottomRightControl];
    
    // 左下角
    UIBezierPath *bottomLeftPath = [[UIBezierPath alloc] init];
    [bottomLeftPath moveToPoint:CGPointMake(controlCornerWidth, 0)];
    [bottomLeftPath addLineToPoint:CGPointMake(0, 0)];
    [bottomLeftPath addLineToPoint:CGPointMake(0, -controlCornerHeight)];
    bottomLeftControl.path        = bottomLeftPath.CGPath;
    bottomLeftControl.lineWidth   = controlCornerLineWidth;
    bottomLeftControl.strokeColor = _style.controlCornerColor.CGColor;
    [self.layer addSublayer:bottomLeftControl];
}


#pragma mark - Layout

// 因为屏幕旋转适配问题，所以在这里设置预览图层要素的位置
- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self pausedAnimating];
    
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    
    if (_previewLayer != nil) {
        _previewLayer.frame = self.bounds;
    }
    
    // 掩膜
    if (_maskLayer != nil) {
        UIBezierPath *path = [UIBezierPath bezierPathWithRect:self.bounds];
        [path appendPath:[UIBezierPath bezierPathWithRect:_rectOfInterest]];
        path.usesEvenOddFillRule = YES;
        _maskLayer.path = path.CGPath;
    }
    
    // 识别区域边框
    if (_regionOfInterestOutline != nil) {
        _regionOfInterestOutline.path = CGPathCreateWithRect(_rectOfInterest, NULL);
    }
    
    // 四角控制标识
    if ((_topLeftControl != nil) &&
        (_topRightControl != nil) &&
        (_bottomRightControl != nil) &&
        (_bottomLeftControl != nil)) {
        
        // 偏移量，由 SGSScanControlCornerStyle 决定
        CGFloat offset = 0.0;
        switch (_style.controlCornerStyle) {
            case SGSScanControlCornerStyleOuter: // 控制标识在扫码矩形框外围
                offset = fabs(_style.controlCornerLineWidth);
                break;
            case SGSScanControlCornerStyleInner: // 控制标识内嵌在扫码区域内
                offset = -fabs(_style.controlCornerLineWidth)/2;
                break;
            default:
                break;
        }
        
        CGFloat xMinOfInterest = CGRectGetMinX(_rectOfInterest);
        CGFloat yMinOfInterest = CGRectGetMinY(_rectOfInterest);
        CGFloat xMaxOfInterest = CGRectGetMaxX(_rectOfInterest);
        CGFloat yMaxOfInterest = CGRectGetMaxY(_rectOfInterest);
        
        _topLeftControl.position     = CGPointMake(xMinOfInterest-offset, yMinOfInterest-offset);
        _topRightControl.position    = CGPointMake(xMaxOfInterest+offset, yMinOfInterest-offset);
        _bottomRightControl.position = CGPointMake(xMaxOfInterest+offset, yMaxOfInterest+offset);
        _bottomLeftControl.position  = CGPointMake(xMinOfInterest-offset, yMaxOfInterest+offset);
    }
    
    if (_style.animationStyle != SGSScanAnimationStyleNone) {
        if (_animationRegionView != nil) {
            _animationRegionView.frame = _rectOfInterest;
        }
        
        // 有可能动画样式为 SGSScanPreviewAnimationNone，此时不需要动画图片
        // 因此不需要用懒加载触发 animationImageView 的实例化
        if (_animationImageView != nil) {
            CGFloat animationX       = 0;
            CGFloat animationY       = 0;
            CGFloat animationWidth   = CGRectGetWidth(_rectOfInterest);
            CGFloat animationHeight  = _style.animationImageHeight;
            CGFloat heightOfInterest = CGRectGetHeight(_rectOfInterest);
            
            if (_style.animationStyle == SGSScanAnimationStyleGrid) {
                animationHeight = heightOfInterest;
                animationY = -heightOfInterest;
            } else {
                if (animationHeight < 0) {
                    animationHeight = _animationImageView.image.size.height;
                    if (animationHeight > heightOfInterest) {
                        animationHeight = heightOfInterest;
                    }
                }
            }
            
            if (_style.animationStyle == SGSScanAnimationStyleLineStill) {
                animationX += 5;
                animationY = heightOfInterest / 2;
                animationWidth -= 10;
            } else if (_style.animationStyle == SGSScanAnimationStyleLineMove) {
                animationX += 5;
                animationY = -animationHeight;
                animationWidth -= 10;
            }
            
            _animationImageView.frame = CGRectMake(animationX, animationY, animationWidth, animationHeight);
        }
    }
    
    [CATransaction commit];
    
    [self resumeAnimating];
}


#pragma mark - Accessors

- (void)setRectOfInterest:(CGRect)rectOfInterest {
    _rectOfInterest = rectOfInterest;
    [self setNeedsLayout];
}

- (UIView *)animationRegionView {
    if (_animationRegionView == nil) {
        _animationRegionView = [[UIView alloc] init];
        _animationRegionView.clipsToBounds = YES;
        [self addSubview:_animationRegionView];
    }
    return _animationRegionView;
}

- (UIImageView *)animationImageView {
    if (_animationImageView == nil) {
        _animationImageView = [[UIImageView alloc] init];
        [self.animationRegionView addSubview:_animationImageView];
    }
    return _animationImageView;
}

- (CAShapeLayer *)maskLayer {
    if (_maskLayer == nil) {
        _maskLayer = [[CAShapeLayer alloc] init];
        _maskLayer.fillRule = kCAFillRuleEvenOdd;
    }
    return _maskLayer;
}

- (CAShapeLayer *)regionOfInterestOutline {
    if (_regionOfInterestOutline == nil) {
        _regionOfInterestOutline = [[CAShapeLayer alloc] init];
        _regionOfInterestOutline.fillColor = [UIColor clearColor].CGColor;
    }
    return _regionOfInterestOutline;
}

- (CAShapeLayer *)topLeftControl {
    if (_topLeftControl == nil) {
        _topLeftControl = [[CAShapeLayer alloc] init];
        _topLeftControl.fillColor = [UIColor clearColor].CGColor;
        _topLeftControl.anchorPoint = CGPointMake(0, 0);
    }
    return _topLeftControl;
}

- (CAShapeLayer *)topRightControl {
    if (_topRightControl == nil) {
        _topRightControl = [[CAShapeLayer alloc] init];
        _topRightControl.fillColor = [UIColor clearColor].CGColor;
        _topRightControl.anchorPoint = CGPointMake(1, 0);
    }
    return _topRightControl;
}

- (CAShapeLayer *)bottomRightControl {
    if (_bottomRightControl == nil) {
        _bottomRightControl = [[CAShapeLayer alloc] init];
        _bottomRightControl.fillColor = [UIColor clearColor].CGColor;
        _bottomRightControl.anchorPoint = CGPointMake(1, 1);
    }
    return _bottomRightControl;
}

- (CAShapeLayer *)bottomLeftControl {
    if (_bottomLeftControl == nil) {
        _bottomLeftControl = [[CAShapeLayer alloc] init];
        _bottomLeftControl.fillColor = [UIColor clearColor].CGColor;
        _bottomLeftControl.anchorPoint = CGPointMake(0, 1);
    }
    return _bottomLeftControl;
}

@end
