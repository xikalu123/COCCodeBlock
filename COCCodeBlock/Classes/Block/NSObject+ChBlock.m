//
//  NSObject+ChBlock.m
//  Fermi
//
//  Created by 陈宇亮 on 2020/2/8.
//  Copyright © 2020 didi. All rights reserved.
//

#import "NSObject+ChBlock.h"
#import <objc/runtime.h>

@implementation NSObject (ChBlock)

+ (void)load{
    Class blockCls = NSClassFromString(@"NSBlock");
    //Encode 编码
    BOOL bok = class_addMethod(blockCls, @selector(description), block_description, "@@:");
}

NSString *block_description(id obj, SEL _cmd){
    showBlockExtendedLayout(obj);
    return @"";
}

void showBlockExtendedLayout(id block){
    static int32_t BLOCK_HAS_COPY_DISPOSE = (1<<25);//compiler
    static int32_t BLOCK_HAS_EXTENDED_LAYOUT = (1<<31);//compiler
    
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
        
        NSLog(@"kkkkk==========++%d",x);
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
                    
                    NSLog(@"The refObjc is : %@  type is : %d",refObjc,P);
                }
                
                refObjOffset += sizeof(void *);
            }
        }
    }
}

@end
