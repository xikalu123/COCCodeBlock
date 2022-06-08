//
//  SyncMutableDictionary.m
//  Fermi
//
//  Created by chenyuliang on 2019/12/2.
//  Copyright © 2019 didi. All rights reserved.
//

#import "SyncMutableDictionary.h"

@interface SyncMutableDictionary()

@property (nonatomic, strong) NSMutableDictionary *dictionary;
@property (nonatomic, strong) dispatch_queue_t dispatchQueue;

@end

@implementation SyncMutableDictionary

- (instancetype)init{
    if (self = [super init]) {
        _dictionary = [NSMutableDictionary new];
        _dispatchQueue = dispatch_queue_create("com.ChenSyncMutableDic.BarrierQueue", DISPATCH_QUEUE_CONCURRENT);
    }
    return self;
}

- (nullable id)objectForKey:(nonnull id)aKey{
    __block id returnObject = nil;
    if (!aKey) return returnObject;
    dispatch_sync(_dispatchQueue, ^{
        returnObject = [_dictionary objectForKey:aKey];
    });
    return returnObject;
}

- (nullable id)valueForKey:(NSString *)aKey{
    __block id returnValue = nil;
    if(!aKey) return returnValue;
    dispatch_sync(_dispatchQueue, ^{
        returnValue = [_dictionary valueForKey:aKey];
    });
    return returnValue;
}

- (nonnull NSArray *)allKeys{
    __block NSArray *returnArray = nil;
    dispatch_sync(_dispatchQueue, ^{
        returnArray = [_dictionary allKeys];
    });
    return returnArray;
}

- (void)setObject:(nullable id)anObject forKey:(nullable id <NSCopying>)aKey{
    if(!aKey) return;
    dispatch_barrier_async(_dispatchQueue, ^{
        [_dictionary setObject:anObject forKey:aKey];
    });
}

- (void)setValue:(nullable id)value forKey:(NSString *)aKey{
    if(!aKey) return
    dispatch_barrier_async(_dispatchQueue, ^{
        [_dictionary setValue:value forKey:aKey];
    });
}

- (void)removeObjectForKey:(nullable id)aKey{
    if(!aKey) return;
    dispatch_barrier_async(_dispatchQueue, ^{
        [_dictionary removeObjectForKey:aKey];
    });
}

- (void)removeAllObjects{
    dispatch_barrier_async(_dispatchQueue, ^{
        [_dictionary removeAllObjects];
    });
}

- (nonnull NSMutableDictionary *)getDictionary{
    __block NSMutableDictionary *returnDic = nil;
    dispatch_sync(_dispatchQueue, ^{
        returnDic = _dictionary;
    });
    return returnDic;
}



@end
