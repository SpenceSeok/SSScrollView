//
//  SSScrollView.m
//  Otryin
//
//  Created by Spence Shi on 16/5/31.
//  Copyright © 2016年 XCMedia. All rights reserved.
//

#import "SSScrollView.h"

@interface SSScrollView()

@property(nonatomic, assign) BOOL opened;
@property(nonatomic, assign) BOOL removedOnCompletion;

@end

@implementation SSScrollView

- (instancetype)initWithPosition:(CGPoint)position bgViewWidth:(CGFloat)bgViewWidth opened:(BOOL)opened
{
    self = [super init];
    if (self) {
        self.opened = opened;
        [self scrollViewForAnimationInPosition:position bgViewWidth:bgViewWidth];
    }
    return self;
}

// 添加卷轴视图
- (UIView *)scrollViewForAnimationInPosition:(CGPoint)position bgViewWidth:(CGFloat)bgViewWidth {
    //注意：部分图片中间有空隙
    CGFloat bgViewTmpWidth = 39+262.5+36-9-2;
    CGFloat scale = bgViewWidth / bgViewTmpWidth;
    
    _middleImgView = [[UIImageView alloc] initWithFrame:CGRectMake((39-9)*scale,((173-132.5)/2+1)*scale,262.5*scale,132.5*scale)];
    _middleImgView.image = [UIImage imageNamed:@"抽奖背面——圣旨纸"];
    _middleImgView.hidden = !_opened;
    
    CGFloat offset = CGRectGetWidth(_middleImgView.frame)/2;
    
    _leftImgView = [[UIImageView alloc] initWithFrame:CGRectMake(_opened?0:offset,0,39*scale,173*scale)];
    _leftImgView.image = [UIImage imageNamed:@"抽奖背面——左卷轴"];
    
    CGFloat righViewX = (39+262.5-9-2)*scale;
    _rightImgView = [[UIImageView alloc] initWithFrame:CGRectMake(_opened?righViewX:righViewX-offset,0,36*scale,173*scale)];
    _rightImgView.image = [UIImage imageNamed:@"抽奖背面——右卷轴"];
    
    self.frame = CGRectMake(position.x,position.y,bgViewTmpWidth * scale, 173*scale);
    
    [self addSubview:_leftImgView];
    [self addSubview:_rightImgView];
    [self addSubview:_middleImgView];
    
    return self;
}

- (void)scrollAnimationWithDuration:(CFTimeInterval)duration open:(BOOL)open removedOnCompletion:(BOOL)removedOnCompletion {
    [NSTimer scheduledTimerWithTimeInterval:(duration - .1) target:self selector:@selector(animationWillStop) userInfo:nil repeats:NO];
    self.removedOnCompletion = removedOnCompletion;
    if (!_opened) {
        CGFloat offset = CGRectGetWidth(_middleImgView.frame)/2;
        [_leftImgView setCenter:CGPointMake(_leftImgView.center.x - offset, _leftImgView.center.y)];
        [_rightImgView setCenter:CGPointMake(_rightImgView.center.x + offset, _rightImgView.center.y)];
        _opened = YES;
        _middleImgView.hidden = NO;
    }
    
    CGFloat middleViewWith = CGRectGetWidth(_middleImgView.frame);
    [self positionAnimationOfLayer:_leftImgView toLeft:YES duration:duration middleViewWidth:middleViewWith open:open];
    [self positionAnimationOfLayer:_rightImgView toLeft:NO duration:duration middleViewWidth:middleViewWith open:open];
    [self openOrCloseScrollAnimationWithView:_middleImgView duration:duration open:open];
}

//纸张展开或合闭动画
- (void)openOrCloseScrollAnimationWithView:(UIView *)view duration:(CFTimeInterval)duration open:(BOOL)open {
    CGFloat viewWidth = CGRectGetWidth(view.frame);
    CGFloat viewHeight = CGRectGetHeight(view.frame);
    
    CGRect leftRect = CGRectMake(viewWidth/2.0, 0, 1, viewHeight); //宽度加1是为解决浮点精度丢失引起的总宽度稍小的问题
    UIBezierPath *leftPath = [UIBezierPath bezierPathWithRect:leftRect];
    
    CGRect leftEndRect = CGRectMake(0, 0, viewWidth/2.0+1, viewHeight);
    UIBezierPath *leftEndPath = [UIBezierPath bezierPathWithRect:leftEndRect];
    
    CABasicAnimation *pathAnimation = [CABasicAnimation animationWithKeyPath:@"path"];
    pathAnimation.fromValue = open ? (__bridge id)(leftPath.CGPath) : (__bridge id)((leftEndPath.CGPath));
    pathAnimation.toValue = open ? (__bridge id)((leftEndPath.CGPath)) : (__bridge id)(leftPath.CGPath);
    pathAnimation.duration = duration;
    pathAnimation.removedOnCompletion = self.removedOnCompletion;
    pathAnimation.fillMode = kCAFillModeForwards;
    
    CAShapeLayer *leftLayer = [CAShapeLayer layer];
    leftLayer.path = leftEndPath.CGPath;
    [leftLayer addAnimation:pathAnimation forKey:nil];
    
    CGRect rightRect = CGRectMake(viewWidth/2.0, 0, 0, viewHeight);
    UIBezierPath *rightPath = [UIBezierPath bezierPathWithRect:rightRect];
    
    CGRect rightEndRect = CGRectMake(viewWidth/2.0, 0, viewWidth/2.0, viewHeight);
    UIBezierPath *rightEndPath = [UIBezierPath bezierPathWithRect:rightEndRect];
    
    CABasicAnimation *pathAnimationR = [CABasicAnimation animationWithKeyPath:@"path"];
    pathAnimationR.delegate = self; //只设置其中一个动画的代理，方便判断一次动画完成
    pathAnimationR.fromValue = open ? (__bridge id)(rightPath.CGPath) : (__bridge id)((rightEndPath.CGPath));
    pathAnimationR.toValue = open ? (__bridge id)((rightEndPath.CGPath)) : (__bridge id)(rightPath.CGPath);
    pathAnimationR.duration = duration;
    pathAnimationR.removedOnCompletion = self.removedOnCompletion;
    pathAnimationR.fillMode = kCAFillModeForwards;
    
    CAShapeLayer *rightLayer = [CAShapeLayer layer];
    rightLayer.path = rightEndPath.CGPath;
    [rightLayer addAnimation:pathAnimationR forKey:nil];
    
    CALayer *mask = [CALayer layer];
    mask.frame = view.bounds;
    [mask addSublayer:leftLayer];
    [mask addSublayer:rightLayer];
    
    view.layer.mask = mask;
}

//移动动画
- (void)positionAnimationOfLayer:(UIView *)view toLeft:(BOOL)toLeft duration:(CFTimeInterval)duration middleViewWidth:(CGFloat)middleViewWidth open:(BOOL)open {
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.translation.x"];
    
    // 动画选项的设定
    animation.duration = duration; // 持续时间
    
    // 起始帧和终了帧的设定
    CGFloat offset = middleViewWidth/2;
    NSNumber *endNum = [NSNumber numberWithFloat:toLeft ? offset : -offset]; //向左还是向右
    animation.fromValue = open ? endNum : [NSNumber numberWithFloat:0];
    animation.toValue = open ? [NSNumber numberWithFloat:0] : endNum;
    //  结束动画后不复位
    animation.removedOnCompletion = self.removedOnCompletion;
    animation.fillMode=kCAFillModeForwards;
    
    // 添加动画
    [view.layer addAnimation:animation forKey:@"move-layer"];
}

- (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)flag {
    if (self.animationDidStopBlock != nil) {
        self.animationDidStopBlock();
    }
}

- (void)animationWillStop {
    if (self.animationWillStopBlock != nil) {
        self.animationWillStopBlock();
    }
}

- (void)pauseAnimation {
    [self pauseLayer:_leftImgView.layer];
    [self pauseLayer:_middleImgView.layer];
    [self pauseLayer:_rightImgView.layer];
}

- (void)resumeAnimation {
    [self resumeLayer:_leftImgView.layer];
    [self resumeLayer:_middleImgView.layer];
    [self resumeLayer:_rightImgView.layer];
}

#pragma mark 暂停CALayer的动画
-(void)pauseLayer:(CALayer*)layer
{
    CFTimeInterval pausedTime = [layer convertTime:CACurrentMediaTime() fromLayer:nil];
    
    // 让CALayer的时间停止走动
    layer.speed = 0.0;
    // 让CALayer的时间停留在pausedTime这个时刻
    layer.timeOffset = pausedTime;
}

#pragma mark 恢复CALayer的动画
-(void)resumeLayer:(CALayer*)layer
{
    CFTimeInterval pausedTime = layer.timeOffset;
    // 1. 让CALayer的时间继续行走
    layer.speed = 1.0;
    // 2. 取消上次记录的停留时刻
    layer.timeOffset = 0.0;
    // 3. 取消上次设置的时间
    layer.beginTime = 0.0;
    // 4. 计算暂停的时间(这里也可以用CACurrentMediaTime()-pausedTime)
    CFTimeInterval timeSincePause = [layer convertTime:CACurrentMediaTime() fromLayer:nil] - pausedTime;
    // 5. 设置相对于父坐标系的开始时间(往后退timeSincePause)
    layer.beginTime = timeSincePause;
}

@end
