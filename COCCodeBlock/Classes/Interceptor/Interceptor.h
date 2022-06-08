//
//  Interceptor.h
//  Fermi
//
//  Created by chenyuliang on 2019/11/20.
//  Copyright © 2019 didi. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol RealInterceptorChainProtocol <NSObject>

- (NSDictionary*)input;

- (NSDictionary *)proceed:(NSDictionary *)input error:(NSError **)err;

@end

@protocol InterceptorProtocol <NSObject>

- (NSDictionary *)intercept:(id<RealInterceptorChainProtocol>)chain error:(NSError **)err;

@end

@interface RealInterceptorChain : NSObject <RealInterceptorChainProtocol>


- (id)initWithInterceptors:(NSArray<InterceptorProtocol>*)interceptors
                 originDic:(NSDictionary *)dic
                     index:(NSUInteger)index;

@end

NS_ASSUME_NONNULL_END
