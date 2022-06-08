//
//  ClockFace.h
//  Fermi
//
//  Created by 陈宇亮 on 2020/1/13.
//  Copyright © 2020 didi. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ClockFace : CAShapeLayer

@property (nonatomic, strong) NSDate *time;

@end

NS_ASSUME_NONNULL_END
