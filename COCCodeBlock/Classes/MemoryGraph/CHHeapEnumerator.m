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

#import "ChenObjcUtility.h"
#import "NSString+ChenRuntime.h"
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
    
    [CHHeapEnumerator enumerateLiveObjectsWithBlock:^(__unsafe_unretained id  _Nonnull tryObject, __unsafe_unretained Class  _Nonnull actualClass) {
        
        // Skip known-invalid objects
        if (!ChenPointerIsValidObjcObject((__bridge void *)object)) {
            return;
        }
        
        //处理object的引用
        [self findObjectReferenceToObject:object tryObject:tryObject actualClass:actualClass instances:instances retained:retain];
        
        //处理block的引用
        [self findBlockReferenceToObject:object tryObject:tryObject actualClass:actualClass instances:instances retained:retain];
        
    }];
    
    
    return instances.copy;
}


+ (void)findObjectReferenceToObject:(__unsafe_unretained id  _Nonnull)object
                          tryObject:(__unsafe_unretained id  _Nonnull)tryObject
                        actualClass:(__unsafe_unretained Class)actualClass
                          instances:(NSMutableArray<ChenObjectRef *> *)instances
                           retained:(BOOL)retain {
    Class tryClass = actualClass;
    while (tryClass) {
        unsigned int ivarCount = 0;
        Ivar *ivars = class_copyIvarList(tryClass, &ivarCount);

        for (unsigned int ivarIndex = 0; ivarIndex < ivarCount; ivarIndex++) {
            Ivar ivar = ivars[ivarIndex];
            NSString *typeEncoding = @(ivar_getTypeEncoding(ivar) ?: "");

            if (typeEncoding.chen_typeIsObjectOrClass) {
                ptrdiff_t offset = ivar_getOffset(ivar);
                uintptr_t *fieldPointer = (__bridge void *)tryObject + offset;

                if (*fieldPointer == (uintptr_t)(__bridge void *)object) {
                    NSString *ivarName = @(ivar_getName(ivar) ?: "???");
                    id ref = [ChenObjectRef referencing:tryObject ivar:ivarName retained:retain];
                    [instances addObject:ref];
                    return;
                }
            }
        }

        free(ivars);
        tryClass = class_getSuperclass(tryClass);
    }
}

+ (void)findBlockReferenceToObject:(__unsafe_unretained id  _Nonnull)object
                         tryObject:(__unsafe_unretained id  _Nonnull)tryObject
                       actualClass:(Class)actualClass
                         instances:(NSMutableArray<ChenObjectRef *> *)instances
                          retained:(BOOL)retain {
    __unsafe_unretained id block = tryObject;
    //只关注分配在堆上的block
    if (strcmp("__NSMallocBlock__", object_getClassName(block)) != 0)  {
        return;
    }
    
    static int32_t BLOCK_HAS_COPY_DISPOSE = (1<<25);//compiler
    static int32_t BLOCK_HAS_EXTENDED_LAYOUT = (1<<31);//compiler
    static int32_t BLOCK_DEALLOCATING =   (0x0001) ; //runtime  标志当前block是否正在销毁中。这个值会在运行时被修改
    static int32_t BLOCK_USE_STRET =      (1 << 29); // compiler: undefined if !BLOCK_HAS_SIGNATURE
    static int32_t BLOCK_HAS_CTOR =          (1 << 26); // compiler block中有C++的代码
    
    struct Block_descriptor_1 {
        //normal Block
        uintptr_t reserved;
        uintptr_t size;
    };

    struct Block_descriptor_2 {
        // requires BLOCK_HAS_COPY_DISPOSE
        void *copy;
        void *dispose;
    };

    struct Block_descriptor_3 {
        // requires BLOCK_HAS_SIGNATURE
        const char *signature;
        const char *layout;     // contents depend on BLOCK_HAS_EXTENDED_LAYOUT
    };

    struct Block_layout {
        void *isa;
        volatile int32_t flags; // contains ref count
        int32_t reserved;
        void *invoke;
        struct Block_descriptor_1 *descriptor;
        // imported variables
    };
    
    //将一个block对象转化为 blocklayout 结构体指针
    struct Block_layout *blockLayout = (__bridge struct Block_layout *)(block);
    
    //正在被销毁
    if (blockLayout->flags & BLOCK_DEALLOCATING) {
        return;
    }

    //未定义
    if (blockLayout->flags & BLOCK_USE_STRET) {
        return;
    }

    //含有C++代码
    if (blockLayout->flags & BLOCK_HAS_CTOR) {
        return;
    }
    
    //如果没有引用外部对象,也就是没有扩展布局标志,则直接返回
    if (! (blockLayout->flags & BLOCK_HAS_EXTENDED_LAYOUT)) return ;
    
    //得到描述信息
    //如果有 BLOCK_HAS_COPY_DISPOSE 则表示描述信息中有 Block_descriptor_2 中的内容
    //因此需要加上这部分信息的偏移.这里有 BLOCK_HAS_COPY_DISPOSE的原因是因为 block 持有了外部对象
    //所以需要负责对外部对象的e声明周期管理, 也就是对block进行赋值拷贝以及销毁时需要将引用的外部对象的引用计数进行 添加  或者 减少.
    uint8_t *desc = (uint8_t *)blockLayout->descriptor;
    desc += sizeof(struct Block_descriptor_1);
    if (blockLayout->flags & BLOCK_HAS_COPY_DISPOSE) {
        desc += sizeof(struct Block_descriptor_2);
    }
    
    //增加了两个 Block_descriptor 最终转化为 Block_descriptor_3 中结构体指针.
    //当布局值为0的s时候,表示没有引用外部对象
    struct Block_descriptor_3 *desc3 = (struct Block_descriptor_3 *)desc;
    if (desc3->layout == 0) {
        return ;
    }
    
    //block 捕获的外部对象类型
    static unsigned char BLOCK_LAYOUT_STRONG           = 3;    // N words strong pointers
    static unsigned char BLOCK_LAYOUT_BYREF            = 4;    // N words byref pointers
    static unsigned char BLOCK_LAYOUT_WEAK             = 5;    // N words weak pointers
    static unsigned char BLOCK_LAYOUT_UNRETAINED       = 6;    // N words unretained pointers
    
    const char *extlayoutstr = desc3->layout;
    
    //处理压缩布局的描述情况
    if (extlayoutstr < (const char *) 0x1000) {
        
        //当布局值小于 0x1000 时时压缩布局描述,这里分别取出 xyz 部分内容,进行重新编码
        // x 是 strong 指针数量
        // y 是 __block 指针数量
        // z 是 weak 指针数量
        
        char compactEncoding[4] = {0};
        unsigned short xyz = (unsigned short)(extlayoutstr);
        unsigned char x = (xyz>>8) & 0xF;
        unsigned char y = (xyz>>4) & 0xF;
        unsigned char z = (xyz>>0) & 0xF;
        
        int idx = 0;
        if (x!=0) {
            //重新编码 高4位 是3 表示 strong 指针, 低4位是 指针的个数.
            compactEncoding[idx++] = (BLOCK_LAYOUT_STRONG<<4) | x;
        }
        
        if (y!=0) {
            //重新编码 高4位 是3 表示 __block 指针, 低4位是 指针的个数.
            compactEncoding[idx++] = (BLOCK_LAYOUT_BYREF<<4) | y;
        }
        
        if (z!=0) {
            //重新编码 高4位 是3 表示 weak 指针, 低4位是 指针的个数.
            compactEncoding[idx++] = (BLOCK_LAYOUT_WEAK<<4) | z;
        }
        
        compactEncoding[idx++] = 0;
        extlayoutstr = compactEncoding;
    }
    
    unsigned char * blockmemoryAddr = (__bridge void *)(block);
    int refObjOffset  = sizeof(struct Block_layout);

    for (int i  = 0 ; i < strlen(extlayoutstr); i++) {
        
        unsigned char PN = extlayoutstr[i];
        int P = (PN>>4) & 0xF;
        int N = PN & 0xF;
        
        //这里只对类型3,4,5,6z四种类型处理
        if (P>= BLOCK_LAYOUT_STRONG && P<= BLOCK_LAYOUT_UNRETAINED) {
            
            for(int j = 0; j < N; j++){
                
                //因为引用外部__block类型不是一个OC对象,这里跳过BLOCK_LAYOUT_BYREF
                if (P != BLOCK_LAYOUT_BYREF) {
                    //根据便宜得到外部对象的地址,并转化为OC对象.
                    //这点 最好区分 指针 * 的用法
                    void *refObjcAddr = *(void **)(blockmemoryAddr + refObjOffset);
                    id refObjc = (__bridge id) refObjcAddr;
                    
                    if (P == BLOCK_LAYOUT_STRONG) {
                        if (refObjc == object) {
                            id ref = [ChenObjectRef referencing:tryObject retained:retain];
                            [instances addObject:ref];
                        }
                    }
                }
                
                refObjOffset += sizeof(void *);
            }
        }
    }
    
}

@end
