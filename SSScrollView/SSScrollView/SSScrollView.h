//
//  SSScrollView.h
//  Otryin
//
//  Created by Spence Shi on 16/5/31.
//  Copyright © 2016年 XCMedia. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SSScrollView : UIView

@property (nonatomic, strong) UIImageView *leftImgView;
@property (nonatomic, strong) UIImageView *middleImgView;
@property (nonatomic, strong) UIImageView *rightImgView;
@property (nonatomic, copy) void(^animationDidStopBlock)();
@property (nonatomic, copy) void(^animationWillStopBlock)();

- (instancetype)initWithPosition:(CGPoint)position bgViewWidth:(CGFloat)bgViewWidth opened:(BOOL)opened;

// 展开或闭合书卷动画，两个动画的组合,open or close
- (void)scrollAnimationWithDuration:(CFTimeInterval)duration open:(BOOL)open removedOnCompletion:(BOOL)removedOnCompletion;

// 暂停动画
- (void)pauseAnimation;

// 重启动画
- (void)resumeAnimation;

////纸张展开或合闭动画
//+ (void)openOrCloseScrollAnimationWithView:(UIView *)view duration:(CFTimeInterval)duration open:(BOOL)open;
////移动动画
//+ (void)positionAnimationOfLayer:(UIView *)view toLeft:(BOOL)toLeft duration:(CFTimeInterval)duration middleViewWith:(CGFloat)middleViewWith open:(BOOL)open;

@end
