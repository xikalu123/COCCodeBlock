//
//  handleInterceptorTwo.m
//  Fermi
//
//  Created by chenyuliang on 2019/11/20.
//  Copyright © 2019 didi. All rights reserved.
//

#import "handleInterceptorTwo.h"

@implementation handleInterceptorTwo

- (NSDictionary *)intercept:(id<RealInterceptorChainProtocol>)chain error:(NSError * _Nullable __autoreleasing *)err{
    
    NSLog(@"执行two 之前");
    NSDictionary *output = [chain proceed:[chain input] error:err];
    NSLog(@"执行two 之后");
    return output;
}

@end
