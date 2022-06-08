//
//  handleInterceptorThree.m
//  Fermi
//
//  Created by chenyuliang on 2019/11/20.
//  Copyright © 2019 didi. All rights reserved.
//

#import "handleInterceptorThree.h"

@implementation handleInterceptorThree

- (NSDictionary *)intercept:(id<RealInterceptorChainProtocol>)chain error:(NSError * _Nullable __autoreleasing *)err{
    
    NSLog(@"执行Three 之前");
    
    NSMutableDictionary *output = [[NSMutableDictionary alloc] initWithDictionary:[chain input]];
    
    [output setObject:@"123" forKey:@"aaa"];
    
    NSLog(@"执行Three 之后");
    return output;
    
}

@end
