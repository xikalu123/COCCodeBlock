//
//  ChenObjectRef.h
//  Fermi
//
//  Created by chenyuliang on 2022/6/6.
//  Copyright © 2022 didi. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ChenObjectRef : NSObject

/// For example, "NSString 0x1d4085d0" or "NSLayoutConstraint _object"
@property (nonatomic, readonly) NSString *reference;

/// For instances, this is the result of desc
/// For classes, there is no summary.
@property (nonatomic, readonly) NSString *summary;
@property (nonatomic, readonly, unsafe_unretained) id object;

+ (instancetype)referencing:(__unsafe_unretained id)object retained:(BOOL)retain;
+ (instancetype)referencing:(__unsafe_unretained id)object ivar:(NSString *)ivarName retained:(BOOL)retain;

@end

NS_ASSUME_NONNULL_END
