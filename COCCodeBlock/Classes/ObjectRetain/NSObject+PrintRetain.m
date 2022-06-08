//
//  NSObject+PrintRetain.m
//  Fermi
//
//  Created by 陈宇亮 on 2020/4/6.
//  Copyright © 2020 didi. All rights reserved.
//

#import "NSObject+PrintRetain.h"
#import <objc/runtime.h>

typedef NS_ENUM(NSUInteger, CHType) {
    CHObjectType,
    CHBlockType,
    CHStructType,
    CHUnknownType,
};

@interface CHIvarReference : NSObject

@property (nonatomic, readonly) NSString *name;
@property (nonatomic, readonly) CHType type;
@property (nonatomic, readonly) ptrdiff_t offset;
@property (nonatomic, readonly) NSUInteger index;
@property (nonatomic, readonly) Ivar ivar;

- (instancetype)initWithIvar:(Ivar)ivar;

- (NSUInteger)indexForInvarLayout;

- (id)objectReferenceFromObject:(id)object;


@end

@implementation CHIvarReference

- (instancetype)initWithIvar:(Ivar)ivar{
    if (self = [super init]) {
        _name = @(ivar_getName(ivar));
        _type = [self convertEncodingToType:ivar_getTypeEncoding(ivar)];
        _offset = ivar_getOffset(ivar);
        _index = _offset / sizeof(void *);
        _ivar = ivar;
    }
    return self;
}

- (CHType)convertEncodingToType:(const char *)typeEncoding{
    if (typeEncoding == NULL) {
        return CHUnknownType;
    }
    
    if (typeEncoding[0] == '{') {
        return CHStructType;
    }
    
    if (typeEncoding[0] == '@') {
        //是 object 或者是 block
        
        if (strncmp(typeEncoding, "@?", 2) == 0) {
            return CHBlockType;
        }
        
        return CHObjectType;
    }
    
    
    return CHUnknownType;
}

- (NSString *)description{
    return [NSString stringWithFormat:@"[%@, index : %lu]",_name,(unsigned long)_index];
}


@end



@implementation NSObject (PrintRetain)


static NSUInteger CHGetMinIvarIndex(Class acls){
    NSUInteger minIndex = 1;
    
    unsigned int count;
    Ivar *ivars = class_copyIvarList(acls, &count);
    
    if (count>1) {
        Ivar firstIvar = ivars[0];
        ptrdiff_t startAddress =  ivar_getOffset(firstIvar);
        minIndex = startAddress / sizeof(void *);
    }
    free(ivars);
    
    return minIndex;
}

static NSIndexSet * CHGetIvarsIndexsForDes(NSUInteger minIndex, const uint8_t * fulllayout){
    NSMutableIndexSet *ivarsIndexs = [NSMutableIndexSet new];
    NSUInteger currentIndex = minIndex;
    
    while (*fulllayout != '\x00') {
        int upper = (*fulllayout & 0xf0) >>4;
        int lower = (*fulllayout & 0x0f);
        
        currentIndex += upper;
        
        [ivarsIndexs addIndexesInRange:NSMakeRange(currentIndex, lower)];
        currentIndex += lower;
        
        fulllayout++;
    }
    
    return ivarsIndexs;
}


- (NSArray *)GetClassReferencesForClass:(Class)acls{
    NSMutableArray *result = [NSMutableArray new];
    
    unsigned int count ;
    Ivar *ivars = class_copyIvarList(acls, &count);
    
    for (unsigned int i = 0; i<count; i++) {
        Ivar ivar = ivars[i];
        CHIvarReference *warpper = [[CHIvarReference alloc] initWithIvar:ivar];
        
        if (warpper.type == CHObjectType) {
            [result addObject:warpper];
        }
    }
    
    free(ivars);
    
    return result.copy;
}


- (NSArray *)GetStrongReferencesForClass:(Class)acls{
    NSArray<CHIvarReference *> *ivars = [[self GetClassReferencesForClass:acls] filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id  _Nullable evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
        if ([evaluatedObject isKindOfClass:CHIvarReference.class]) {
            CHIvarReference *wrapper = evaluatedObject;
            return wrapper.type != CHUnknownType;
        }
        
        return YES;
    }]];
    
    
    const uint8_t *fulllayout =  class_getIvarLayout(acls);
    
    if (!fulllayout) {
        return @[];
    }
    
    //获得下标的单位是 指针单位, 以每个指针为单位
    NSUInteger minIndex = CHGetMinIvarIndex(acls);
    NSIndexSet *ivarIndexs = CHGetIvarsIndexsForDes(minIndex, fulllayout);
   
    NSArray<CHIvarReference *> *filteredIvars = [ivars filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(CHIvarReference * evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
        return [ivarIndexs containsIndex:evaluatedObject.index];
    }]];
    
    return filteredIvars;
}

- (NSArray *)GetObjectStrongReferences:(id)obj{
    NSMutableArray<CHIvarReference *> *strongReferences = [NSMutableArray new];
    NSMutableArray *result = [NSMutableArray new];
    
    
    return result.copy;
}


- (NSString *)strongReference_des{
    
    return  @"";
}

@end
