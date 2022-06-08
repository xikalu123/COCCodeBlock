//
//  ChenObjectRef.m
//  Fermi
//
//  Created by chenyuliang on 2022/6/6.
//  Copyright © 2022 didi. All rights reserved.
//

#import "ChenObjectRef.h"
#import "ChenruntimeUtility.h"

@interface ChenObjectRef() {
    id _retainer;
}
@property (nonatomic, readonly) BOOL wantsSummary;

@end

@implementation ChenObjectRef

+ (instancetype)referencing:(__unsafe_unretained id)object retained:(BOOL)retain {
    return [self referencing:object ivar:@"" retained:retain];
}

+ (instancetype)referencing:(__unsafe_unretained id)object ivar:(NSString *)ivarName retained:(BOOL)retain {
    return [[self alloc] initWithObject:object ivarName:ivarName showSummary:YES retained:retain];
}

- (instancetype)initWithObject:(__unsafe_unretained id)object
                      ivarName:(NSString *)ivar
                   showSummary:(BOOL)showSummary
                      retained:(BOOL)retain {
    self = [super init];
    if (self) {
        _object = object;
        _wantsSummary = showSummary;
        
        if (retain) {
            _retainer = object;
        }
        
        NSString *class = [ChenruntimeUtility safeClassNameForObject:object];
        if (ivar) {
            _reference = [NSString stringWithFormat:@"%@ --- %@",class,ivar];
        }else if (showSummary){
            _reference = [NSString stringWithFormat:@"%@ --- %@",class,object];
        }else {
            _reference = class;
        }
    }
    
    return self;
}

@end
