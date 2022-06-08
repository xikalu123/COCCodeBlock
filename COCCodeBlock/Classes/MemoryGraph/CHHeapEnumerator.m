//
//  CHHeapEnumerator.m
//  Fermi
//
//  Created by chenyuliang on 2022/6/6.
//  Copyright © 2022 didi. All rights reserved.
//

#import "CHHeapEnumerator.h"
#import <malloc/malloc.h>
#import <objc/runtime.h>
#include <objc/objc-api.h>
#include <mach/mach.h>

#import "ChenObjectRef.h"

static CFMutableSetRef registeredClasses;

typedef struct {
    Class isa;
} chen_maybe_object_t;


@implementation CHHeapEnumerator

static kern_return_t reader(__unused task_t remote_task, vm_address_t remote_address, __unused vm_size_t size, void **local_memory) {
    *local_memory = (void *)remote_address;
    return KERN_SUCCESS;
}

static void range_callback(task_t task, void *context, unsigned type, vm_range_t *ranges, unsigned rangeCount) {
    if (!context) {
        return;
    }
    
    for (unsigned int i = 0; i<rangeCount; i++) {
        vm_range_t range = ranges[i];
        chen_maybe_object_t *tryObject = ((chen_maybe_object_t *)range.address);
        
        Class tryClass = NULL;
        
#ifdef __arm64__
        // See http://www.sealiesoftware.com/blog/archive/2013/09/24/objc_explain_Non-pointer_isa.html
        extern uint64_t objc_debug_isa_class_mask WEAK_IMPORT_ATTRIBUTE;
        tryClass = (__bridge Class)((void *)((uint64_t)tryObject->isa & objc_debug_isa_class_mask));
#else
        tryClass = tryObject->isa;
#endif
        
        if (CFSetContainsValue(registeredClasses, (__bridge const void *)tryClass)) {
            (*(chen_object_enumeration_block_t __unsafe_unretained *)context)((__bridge id)tryObject,tryClass);
        }
        
    }
}

+ (void)enumerateLiveObjectsWithBlock:(chen_object_enumeration_block_t)block {
    
    [self updateRegisteredClasses];
    
    vm_address_t *zones = NULL;
    unsigned int zoneCount = 0;
    kern_return_t result= malloc_get_all_zones(TASK_NULL, reader, &zones, &zoneCount);
    
    if (result == KERN_SUCCESS) {
        for (unsigned int i = 0; i<zoneCount; i++) {
            malloc_zone_t *zone = (malloc_zone_t *)zones[i];
            malloc_introspection_t *introspection = zone->introspect;
            
            if (!introspection) {
                continue;
            }
            
            
            chen_object_enumeration_block_t callback = ^(__unsafe_unretained id object, __unsafe_unretained Class actualClass) {
                block(object,actualClass);
//               printf("0x%016x -- Class: %s\n",object, object_getClassName(actualClass));
            };
            
            
            introspection->enumerator(TASK_NULL, (void *)&callback, MALLOC_PTR_IN_USE_RANGE_TYPE, (vm_address_t)zone, reader, &range_callback);
        }
    }
}

+ (void)updateRegisteredClasses {
    if (!registeredClasses) {
        registeredClasses = CFSetCreateMutable(NULL, 0, NULL);
    }else{
        CFSetRemoveAllValues(registeredClasses);
    }
    
    unsigned int count = 0;
    Class *classes = objc_copyClassList(&count);
    for (unsigned int i = 0; i<count; i++) {
        CFSetAddValue(registeredClasses, (__bridge const void *)(classes[i]));
    }
    
    free(classes);
}

#pragma mark - Methods

+ (NSArray<ChenObjectRef *> *)objectsWithReferencesToObject:(id)object retained:(BOOL)retain {
    NSMutableArray<ChenObjectRef *> *instances = [NSMutableArray new];
    
    [CHHeapEnumerator enumerateLiveObjectsWithBlock:^(__unsafe_unretained id  _Nonnull object, __unsafe_unretained Class  _Nonnull actualClass) {
        
        // Skip known-invalid objects
        if (!FLEXPointerIsValidObjcObject((__bridge void *)object)) {
            return;
        }
    }];
    
    
    return instances.copy;
}
@end
