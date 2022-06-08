//
//  SyncMutableDictionary.h
//  Fermi
//
//  Created by chenyuliang on 2019/12/2.
//  Copyright © 2019 didi. All rights reserved.
//


/*
 线程安全的字典类(数组写法相同)
 参考的知识点：Effect-OC 41条 多用派发队列，少用同步锁
 */

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SyncMutableDictionary : NSObject

- (nullable id)objectForKey:(nonnull id)aKey;

- (nullable id)valueForKey:(NSString *)aKey;

- (nonnull NSArray *)allKeys;

- (void)setObject:(nullable id)anObject forKey:(nullable id <NSCopying>)aKey;

- (void)setValue:(nullable id)value forKey:(NSString *)aKey;

- (void)removeObjectForKey:(nullable id)aKey;

- (void)removeAllObjects;

- (nonnull NSMutableDictionary *)getDictionary;

@end

NS_ASSUME_NONNULL_END
