//
//  ChenKeyFrameAnimation.m
//  Fermi
//
//  Created by 陈宇亮 on 2020/1/12.
//  Copyright © 2020 didi. All rights reserved.
//

#import "ChenKeyFrameAnimation.h"


@implementation ChenKeyFrameAnimation

- (void)test{
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animation];
    animation.keyPath = @"position.x";
    animation.values = @[ @0, @10, @-10, @10, @0 ];
    animation.keyTimes = @[ @0, @(1 / 6.0), @(3 / 6.0), @(5 / 6.0), @1 ];
    animation.duration = 2.4;
    
    animation.additive = NO;
    
    [self.layer addAnimation:animation forKey:@"shake"];
    
}

- (void)testPath{
    CGRect boundingRect = CGRectMake(-50, -50, 300, 300);
    
    CAKeyframeAnimation *orbit = [CAKeyframeAnimation animation];
    orbit.keyPath = @"position";
    orbit.path = CFAutorelease(CGPathCreateWithEllipseInRect(boundingRect, NULL));
    orbit.duration = 4;
    orbit.additive = YES;
    orbit.repeatCount = HUGE_VALF;
    orbit.calculationMode = kCAAnimationPaced;
//    orbit.rotationMode = kCAAnimationRotateAuto;
    orbit.rotationMode = nil;
    
    [self.layer addAnimation:orbit forKey:@"orbit"];
}

- (void)testTimeFunc{
    CABasicAnimation *animation = [CABasicAnimation animation];
    animation.keyPath = @"position.x";
    animation.fromValue = @50;
    animation.toValue = @150;
    animation.duration = 1;
    
//    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    
//    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
//    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
//    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
//    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault];
    
    //自定义时间函数 范围是 0 - 1.
    animation.timingFunction = [CAMediaTimingFunction functionWithControlPoints:0.5 :0 :0.9 :0.7];
    
    
    [self.layer addAnimation:animation forKey:@"basic"];
    
    //最后设置属性
//    self.layer.position = CGPointMake(150, 200);
}

- (void)testAnimationGroup{
    
    //z轴的动画
    CABasicAnimation *zPostion = [CABasicAnimation animation];
    zPostion.keyPath = @"zPosition";
    zPostion.fromValue = @-1;
    zPostion.toValue = @1;
    zPostion.duration = 1.2;
    
    //旋转动画
    CAKeyframeAnimation *rotation = [CAKeyframeAnimation animation];
    rotation.keyPath = @"transform.rotation";
    rotation.values = @[@0,@0.14,@0];
    rotation.duration = 1.2;
    rotation.timingFunctions = @[
        [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut],
        [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]
    ];
    
    //位置动画
    CAKeyframeAnimation *position = [CAKeyframeAnimation animation];
    position.keyPath = @"position";
    position.values = @[
        [NSValue valueWithCGPoint:CGPointZero],
        [NSValue valueWithCGPoint:CGPointMake(110, -20)],
        [NSValue valueWithCGPoint:CGPointZero]
    ];
    
    position.timingFunctions = @[
        [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut],
        [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]
    ];
    position.additive = YES;
    position.duration= 1.2;
    
    CAAnimationGroup *group  = [CAAnimationGroup new];
    group.animations = @[zPostion,rotation,position];
    group.duration = 1.2;
    group.beginTime = 0.5;
    
    [self.layer addAnimation:group forKey:@"shuffle"];
    
    
}


@end
