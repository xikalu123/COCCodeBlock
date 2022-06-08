//
//  NSObject+ChBlock.h
//  Fermi
//
//  Created by 陈宇亮 on 2020/2/8.
//  Copyright © 2020 didi. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// 查看block引用了哪些对象

/*
 1. block的内存布局.
 struct Block_layout{
    void *isa;   //block 对象的类型
    volatile int32_t flags;  //block 对象的一些特性和标志
    int32_t reserved; //保留未用
    BlockInvokeFunction invoke; //block的实现函数地址
    struct Block_descriptor_1 *descriptor;  //block的描述信息
    // imported variables。 所引用的外部对象或者变量
 }
 
 根据 flags 和 descriptor 可以知道捕获对象的所有扩展成员.
 
 
 2. 引用了外部对象的标志位 BLOCK_BYREF_LAYOUT_EXTENDED.
 3. Block持有对象的具体类型.
 4. 打印一个block持有的对象.
 */

//block的内部实现: https://opensource.apple.com/source/libclosure/libclosure-73/Block_private.h.auto.html

@interface NSObject (ChBlock)

void showBlockExtendedLayout(id block);

@end

NS_ASSUME_NONNULL_END
