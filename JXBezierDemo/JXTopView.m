//
//  JXTopView.m
//  JXBezierDemo
//
//  Created by pconline on 2018/1/30.
//  Copyright © 2018年 tianguo. All rights reserved.
//

#import "JXTopView.h"

#define ColorForTheme [UIColor colorWithRed:245.0/255.0 green:179.0/255.0 blue:185.0/255.0 alpha:1]
#define SCREEN_WIDTH ([[UIScreen mainScreen] bounds].size.width)
#define SCREEN_HEIGHT ([[UIScreen mainScreen] bounds].size.height)

static CGFloat minMoveDistance = 100;
static CGFloat minDisappearDistance = 150;

@interface JXTopView()<CAAnimationDelegate>

@property(nonatomic,strong) CAShapeLayer *topLineLayer;
@property(nonatomic,strong) UIPanGestureRecognizer *gesture;
@property(nonatomic,assign) CGFloat originY;
@end

@implementation JXTopView

- (id)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.originY = frame.origin.y;
        [self setUpLayer];
        [self addGesure];
    }
    return self;
}

- (void)setUpLayer{
    self.topLineLayer = [CAShapeLayer layer];
    self.topLineLayer.fillColor = ColorForTheme.CGColor;
    self.topLineLayer.strokeColor = ColorForTheme.CGColor;
    self.topLineLayer.path = [self getPathWithMoveDistance:0];
    [self.layer addSublayer:self.topLineLayer];
}

- (void)addGesure{
    if (self.gesture == nil) {
        self.gesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    }
    [self addGestureRecognizer:self.gesture];
}

//根据y值获取贝塞尔路径
- (CGPathRef)getPathWithMoveDistance:(CGFloat)distance{
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    CGPoint startPoint = CGPointMake(0, 0);
    CGPoint controlPoint = CGPointMake(self.bounds.size.width*0.5, 60+distance);
    CGPoint endPoint = CGPointMake(self.bounds.size.width, 0);
    
    [path moveToPoint:startPoint];
    [path addQuadCurveToPoint:endPoint controlPoint:controlPoint];
    
    [path addLineToPoint:CGPointMake(self.bounds.size.width, self.bounds.size.height)];
    [path addLineToPoint:CGPointMake(0, self.bounds.size.height)];
    
    return path.CGPath;
}

- (void)handlePan:(UIPanGestureRecognizer *)gesture{
    CGFloat distanceX = [gesture translationInView:self].x;
    CGFloat distanceY = [gesture translationInView:self].y;
    
    if (ABS(distanceX) > ABS(distanceY)) {
        return;
    }
    //拖动过程
    if (gesture.state == UIGestureRecognizerStateChanged) {
        NSLog(@"%f",distanceY);
        
        //移动少于minMoveDistance，贝赛尔曲线形变
        if (distanceY > 0 && distanceY <= minMoveDistance) {
            self.topLineLayer.path = [self getPathWithMoveDistance:distanceY];
        }
        //移动大于minMoveDistance，整个view下移
        else if (distanceY > minMoveDistance) {
            self.frame = CGRectMake(0, self.originY+distanceY-minMoveDistance, self.bounds.size.width, self.bounds.size.height);
        }
    }
    //手势结束
    if (gesture.state == UIGestureRecognizerStateEnded || gesture.state == UIGestureRecognizerStateCancelled || gesture.state == UIGestureRecognizerStateFailed) {
        [self removeGestureRecognizer:self.gesture];
        [self revertFormY:distanceY];
    }
}


//-(void)revertPositionToY:(CGFloat)y{
//    [UIView animateWithDuration:0.3 animations:^{
//        self.frame = CGRectMake(0, y, SCREEN_WIDTH, self.frame.size.height);
//    }];
//}

//手势结束后恢复或隐藏
-(void)revertFormY:(CGFloat)y{
    
    //y < 最小的隐藏位移距离，未发生位移，贝塞尔曲线恢复
    if (y < minDisappearDistance) {
        CAKeyframeAnimation *vibrate = [CAKeyframeAnimation animationWithKeyPath:@"path"];
        vibrate.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
        vibrate.values = @[
                           (id) [self getPathWithMoveDistance:y],
                           (id) [self getPathWithMoveDistance:-(y * 0.3)],
                           (id) [self getPathWithMoveDistance:(y * 0.2)],
                           (id) [self getPathWithMoveDistance:-(y * 0.15)],
                           (id) [self getPathWithMoveDistance:(y * 0.1)],
                           (id) [self getPathWithMoveDistance:-(y * 0.07)],
                           (id) [self getPathWithMoveDistance:(y * 0.05)],
                           (id) [self getPathWithMoveDistance:0.0]
                           ];
        vibrate.duration = 0.5;
        vibrate.removedOnCompletion = NO;
        vibrate.fillMode = kCAFillModeForwards;
        vibrate.delegate = self;
        [self.topLineLayer addAnimation:vibrate forKey:nil];
    }
    
    //y > 最小位移距离，发生了位移
    if(y > minMoveDistance){
        
        [UIView animateWithDuration:0.3 animations:^{
            CGFloat endY;
            //向上恢复view
            if (y < minDisappearDistance) {
                endY = self.originY;
            }
            //向下隐藏view
            else{
                endY = SCREEN_HEIGHT;
            }
            self.frame = CGRectMake(0, endY, SCREEN_WIDTH, self.frame.size.height);
        }];
    }
}

//恢复到初始位置
- (void)comeBack{
    if (self.frame.origin.y <= self.originY) {
        return;
    }
    
    [UIView animateWithDuration:0.3 animations:^{
        self.frame = CGRectMake(0, self.originY, SCREEN_WIDTH, self.frame.size.height);
    } completion:^(BOOL finished) {
        [self revertFormY:10];
    }];
}

#pragma mark - CAAnimationDelegate

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag{
    self.topLineLayer.path = [self getPathWithMoveDistance:0];
    [self.topLineLayer removeAllAnimations];
    [self addGesure];
}
@end

