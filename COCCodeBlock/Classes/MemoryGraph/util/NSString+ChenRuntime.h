//
//  NSString+ChenRuntime.h
//  COCCodeBlock
//
//  Created by chenyuliang on 2022/6/8.
//

#import <Foundation/Foundation.h>
#import "ChenRuntimeConstants.h"

NS_ASSUME_NONNULL_BEGIN

@interface NSString (ChenRuntime)

/// @return the first char in the type encoding that is not the const specifier
@property (nonatomic, readonly) CHENTypeEncoding chen_firstNonConstType;
/// @return whether this type is an objc object of any kind, even if it's const
@property (nonatomic, readonly) BOOL chen_typeIsObjectOrClass;

@end

NS_ASSUME_NONNULL_END
