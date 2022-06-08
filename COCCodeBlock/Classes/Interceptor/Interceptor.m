//
//  Interceptor.m
//  Fermi
//
//  Created by chenyuliang on 2019/11/20.
//  Copyright © 2019 didi. All rights reserved.
//

#import "Interceptor.h"

@interface RealInterceptorChain()

@property (nonatomic, copy) NSDictionary *input;
@property (nonatomic, copy) NSArray<InterceptorProtocol> *interceptors;
@property (nonatomic, assign) NSUInteger index;

@end


@implementation RealInterceptorChain

- (NSDictionary *)input{
    return _input;
}

-(id)initWithInterceptors:(NSArray<InterceptorProtocol> *)interceptors originDic:(NSDictionary *)dic index:(NSUInteger)index{
    self = [super init];
    if (self) {
        _interceptors = interceptors;
        _input = dic;
        _index = index;
    }
    return self;
}

- (NSDictionary *)proceed:(NSDictionary *)input error:(NSError * _Nullable __autoreleasing *)err
{
    if (self.index >= self.interceptors.count) {
        return nil;
    }
    
    RealInterceptorChain *next = [[RealInterceptorChain alloc] initWithInterceptors:self.interceptors originDic:input index:self.index+1];
    
    id<InterceptorProtocol> interceptor = [self.interceptors objectAtIndex:self.index];
    
    NSDictionary *output = [interceptor intercept:next error:err];
    
    return output;
    
}

@end
