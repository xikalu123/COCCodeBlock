//
//  NSString+ChenRuntime.m
//  COCCodeBlock
//
//  Created by chenyuliang on 2022/6/8.
//

#import "NSString+ChenRuntime.h"

@implementation NSString (ChenRuntime)

- (BOOL)chen_typeIsConst {
    if (!self.length) return NO;
    return [self characterAtIndex:0] == CHENTypeEncodingConst;
}

- (CHENTypeEncoding)chen_firstNonConstType {
    if (!self.length) return CHENTypeEncodingNull;
    return [self characterAtIndex:(self.chen_typeIsConst ? 1 : 0)];
}

- (BOOL)chen_typeIsObjectOrClass {
    CHENTypeEncoding type = self.chen_firstNonConstType;
    return type == CHENTypeEncodingObjcObject || type == CHENTypeEncodingObjcClass;
}

@end
