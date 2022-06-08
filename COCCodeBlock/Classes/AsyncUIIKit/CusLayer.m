//
//  CusLayer.m
//  Fermi
//
//  Created by chenyuliang on 2019/12/24.
//  Copyright © 2019 didi. All rights reserved.
//

#import "CusLayer.h"

@implementation CusLayer

//@dynamic time;
/*
 view 给 layer返回一个基本的动画，
 然后动画通过 addAnimation:forKey: 方法添加到 layer上面，就像显示添加动画那样
 */
- (void)addAnimation:(CAAnimation *)anim forKey:(NSString *)key{
    NSLog(@"adding animation: %@ ---  key %@",[anim description], key);
    [super addAnimation:anim forKey:key];
}

+ (BOOL)needsDisplayForKey:(NSString *)key{
    if ([key isEqualToString:@"time"]) {
        return YES;
    }
    return [super needsDisplayForKey:key];
}


- (void)display{
    NSLog(@"time == %f", self.time);
    
}

- (id<CAAction>)actionForKey:(NSString *)event{
    if ([event isEqualToString:@"time"]) {
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:event];
        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
        animation.fromValue = @(self.time);
        return animation;
    }
    return [super actionForKey:event];
}

- (void)drawInContext:(CGContextRef)ctx{
    [super drawInContext:ctx];
    NSLog(@"calayer is drawing.....%@",ctx);
}


+ (id)defaultValueForKey:(NSString *)key{
    if ([key isEqualToString:@"masksToBounds"]) {
        return [NSNumber numberWithBool:YES];
    }
    return [super defaultValueForKey:key];
}

@end
