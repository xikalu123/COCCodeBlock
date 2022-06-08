//
//  UIView+ChenPopAnimation.m
//  Fermi
//
//  Created by chenyuliang on 2019/12/25.
//  Copyright © 2019 didi. All rights reserved.
//

#import "UIView+ChenPopAnimation.h"
#import <objc/runtime.h>


@interface CHSavedPopAnimationState : NSObject

@property (strong,nonatomic) CALayer *layer;
@property (copy, nonatomic) NSString *keyPath;
@property (strong, nonatomic) id oldValue;

+ (instancetype)savedStateWithLayer:(CALayer *)layer
                            keyPath:(NSString *)keyPath;

@end

@implementation CHSavedPopAnimationState

+ (instancetype)savedStateWithLayer:(CALayer *)layer keyPath:(NSString *)keyPath{
    CHSavedPopAnimationState *state = [CHSavedPopAnimationState new];
    state.layer = layer;
    state.keyPath = keyPath;
    state.oldValue = [layer valueForKey:keyPath];
    return state;
}


@end


static void *CH_currentAnimationContext = NULL;
static void *CH_popAnimationContext     = &CH_popAnimationContext;

@implementation UIView (ChenPopAnimation)

static NSMutableArray *savedStateArray;

+ (NSMutableArray *)ch_savedPopStateArray{
    if (!savedStateArray) {
        savedStateArray= [NSMutableArray new];
    }
    return savedStateArray;
}



+ (void)load{
    SEL originalSel = @selector(actionForLayer:forKey:);
    SEL replaceSel = @selector(ch_actionForLayer:forKey:);
    
    Method originalMethod = class_getInstanceMethod(self, originalSel);
    Method replaceMethod = class_getInstanceMethod(self, replaceSel);
    
    if (class_addMethod(self, originalSel, method_getImplementation(replaceMethod), method_getTypeEncoding(replaceMethod))) {
        class_replaceMethod(self, replaceSel, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
    }else{
        method_exchangeImplementations(originalMethod, replaceMethod);
    }
}


+ (void)CH_popAnimationWithDuration:(NSTimeInterval)duration animations:(void (^)(void))animations{
    CH_currentAnimationContext = CH_popAnimationContext;
    animations();
    
    [[self ch_savedPopStateArray] enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        CHSavedPopAnimationState *savedState = (CHSavedPopAnimationState *)obj;
        CALayer *layer = savedState.layer;
        NSString *keyPath = savedState.keyPath;
        id oldValue = savedState.oldValue;
        id newValue = [layer valueForKey:keyPath];
        
        if (!oldValue || !newValue)  return;
        
        /*
         CAKeyframeAnimation 类的使用
         */
        CAKeyframeAnimation *anim = [CAKeyframeAnimation animationWithKeyPath:keyPath];
        
        CGFloat easing = 0.2;
        CAMediaTimingFunction *easeIn  = [CAMediaTimingFunction functionWithControlPoints:1.0 :0.0 :(1.0-easing) :1.0];
        CAMediaTimingFunction *easeOut = [CAMediaTimingFunction functionWithControlPoints:easing :0.0 :0.0 :1.0];
        
        anim.duration = duration;
        anim.keyTimes = @[@0, @(0.35), @1];
        anim.values = @[oldValue, newValue, oldValue];
        anim.timingFunctions = @[easeIn, easeOut];
        
        // 不带动画地返回原来的值
        [CATransaction begin];
        [CATransaction setDisableActions:YES];
        [layer setValue:oldValue forKeyPath:keyPath];
        [CATransaction commit];
        
        [layer addAnimation:anim forKey:keyPath];
    }];
    
    [[self ch_savedPopStateArray] removeAllObjects];
    
    
    CH_currentAnimationContext = nil;
}


- (id<CAAction>)ch_actionForLayer:(CALayer *)layer forKey:(NSString *)event{
    if (CH_currentAnimationContext == CH_popAnimationContext) {
        [[UIView ch_savedPopStateArray] addObject:[CHSavedPopAnimationState savedStateWithLayer:layer keyPath:event]];
        
        return (id<CAAction>)[NSNull null];
    }
    
    return  [self ch_actionForLayer:layer forKey:event];
}

@end
