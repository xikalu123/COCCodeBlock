//
//  ChenruntimeUtility.h
//  Fermi
//
//  Created by chenyuliang on 2022/6/7.
//  Copyright © 2022 didi. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ChenruntimeUtility : NSObject

+ (NSString *)summaryForObject:(id)value;

+ (NSString *)safeClassNameForObject:(id)object;
+ (NSString *)safeDescriptionForObject:(id)object;
+ (BOOL)safeObject:(id)object respondsToSelector:(SEL)sel;

@end

NS_ASSUME_NONNULL_END
