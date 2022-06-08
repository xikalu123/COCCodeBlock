//
//  CHHeapEnumerator.h
//  Fermi
//
//  Created by chenyuliang on 2022/6/6.
//  Copyright © 2022 didi. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@class ChenObjectRef;

typedef void (^chen_object_enumeration_block_t)(__unsafe_unretained id object, __unsafe_unretained Class actualClass);

@interface CHHeapEnumerator : NSObject

+ (NSArray<ChenObjectRef *> *)objectsWithReferencesToObject:(id)object retained:(BOOL)retain;

@end

NS_ASSUME_NONNULL_END
