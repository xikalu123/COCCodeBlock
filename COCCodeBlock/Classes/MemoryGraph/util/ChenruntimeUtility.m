//
//  ChenruntimeUtility.m
//  Fermi
//
//  Created by chenyuliang on 2022/6/7.
//  Copyright © 2022 didi. All rights reserved.
//

#import "ChenruntimeUtility.h"
#import <objc/runtime.h>

@implementation ChenruntimeUtility

+ (NSString *)summaryForObject:(id)value {
    NSString *description = nil;

    // Special case BOOL for better readability.
    if ([self safeObject:value isKindOfClass:[NSValue class]]) {
        const char *type = [value objCType];
        if (strcmp(type, @encode(BOOL)) == 0) {
            BOOL boolValue = NO;
            [value getValue:&boolValue];
            return boolValue ? @"YES" : @"NO";
        } else if (strcmp(type, @encode(SEL)) == 0) {
            SEL selector = NULL;
            [value getValue:&selector];
            return NSStringFromSelector(selector);
        }
    }
    
    @try {
        // Single line display - replace newlines and tabs with spaces.
        description = [[self safeDescriptionForObject:value] stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
        description = [description stringByReplacingOccurrencesOfString:@"\t" withString:@" "];
    } @catch (NSException *e) {
        description = [@"Thrown: " stringByAppendingString:e.reason ?: @"(nil exception reason)"];
    }

    if (!description) {
        description = @"nil";
    }

    return description;
}

+ (NSString *)safeClassNameForObject:(id)object {
    // Don't assume that we have an NSObject subclass
    if ([self safeObject:object respondsToSelector:@selector(class)]) {
        return NSStringFromClass([object class]);
    }

    return NSStringFromClass(object_getClass(object));
}

+ (BOOL)safeObject:(id)object isKindOfClass:(Class)cls {
    static BOOL (*isKindOfClass)(id, SEL, Class) = nil;
    static BOOL (*isKindOfClass_meta)(id, SEL, Class) = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        isKindOfClass = (BOOL(*)(id, SEL, Class))[NSObject instanceMethodForSelector:@selector(isKindOfClass:)];
        isKindOfClass_meta = (BOOL(*)(id, SEL, Class))[NSObject methodForSelector:@selector(isKindOfClass:)];
    });
    
    BOOL isClass = object_isClass(object);
    return (isClass ? isKindOfClass_meta : isKindOfClass)(object, @selector(isKindOfClass:), cls);
}


+ (NSString *)safeDescriptionForObject:(id)object {
    // Don't assume that we have an NSObject subclass; not all objects respond to -description
    if ([self safeObject:object respondsToSelector:@selector(description)]) {
        @try {
            return [object description];
        } @catch (NSException *exception) {
            return @"";
        }
    }

    return @"";
}

+ (BOOL)safeObject:(id)object respondsToSelector:(SEL)sel {
    // If we're given a class, we want to know if classes respond to this selector.
    // Similarly, if we're given an instance, we want to know if instances respond.
    BOOL isClass = object_isClass(object);
    Class cls = isClass ? object : object_getClass(object);
    // BOOL isMetaclass = class_isMetaClass(cls);
    
    if (isClass) {
        // In theory, this should also work for metaclasses...
        return class_getClassMethod(cls, sel) != nil;
    } else {
        return class_getInstanceMethod(cls, sel) != nil;
    }
}

@end
