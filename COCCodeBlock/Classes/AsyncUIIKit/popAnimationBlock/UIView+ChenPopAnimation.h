//
//  UIView+ChenPopAnimation.h
//  Fermi
//
//  Created by chenyuliang on 2019/12/25.
//  Copyright © 2019 didi. All rights reserved.
//



#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIView (ChenPopAnimation)

+ (void)CH_popAnimationWithDuration:(NSTimeInterval)duration
                         animations:(void (^)(void))animations;

@end

NS_ASSUME_NONNULL_END
