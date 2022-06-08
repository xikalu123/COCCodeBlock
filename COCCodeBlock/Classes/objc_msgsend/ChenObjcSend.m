//
//  ChenObjcSend.m
//  Fermi
//
//  Created by 陈宇亮 on 2020/2/18.
//  Copyright © 2020 didi. All rights reserved.
//

#import "ChenObjcSend.h"

@implementation ChenObjcSend
/*
  原始的objc_msgSend 只做了以下几件事
 1.获得一个对象的类传入.
 2.获得类的方法cache表
 3.通过传入的selector,在cache表中查找
 4.如果不在表中,则调用c语言代码,走复杂的消息转发.
 5.如果在表中,则直接调用方法的地址IMP.
 */

/*
 汇编需要处理的逻辑
 1.对象指针是nil,tagger指针.
 2.哈希表的冲突.
 
 ARM64有31个寄存器, 每个寄存器的宽是 64位.
 X0~X30 代表这31个寄存器.
 W0~W30 代表这31个寄存器的 低 32位.
 
 对于函数调用来说,使用X0~X7 这8个寄存器来传递参数.
 X0 来接收 self 参数
 X1 来接收 __cmd 参数 (selector)
 */



/* ARM64 汇编指令
 b.le 结果小于等于的时候执行跳转, 常和CMP做if判断
 
 ldr x13,[x0] 将x0寄存器的地址所在内存读取出来,存储到x13寄存器中.
 
 ldp x10,x11,[x16,#0x10] 将x16寄存器保存地址偏移 16个字节,然后读取内容到 x10,x11两个寄存器
 
 */


 /*
static void origin_objc_msgSend(){
  
    //比较X0寄存器和 零(#0x0)的值, 如果self<=0,则跳转到 0x6c 的代码处(处理nil,tagger指针)
  
    0x0000 cmp x0, #0x0
  
     1. self<=0的话,跳转到小于等于0的逻辑处理
     2. self == 0 表示 self是nil
     3. self < 0, 表示最高位是1,是一个Tagged Pointers.

    0x0004 b.le 0x6c
  
    此时,x13存储的是isa指针内容
    0x0008 ldr x13,[x0]
    
    x13寄存器内容和#0xffffffff8,赋值给x16寄存器
    指针对象都是8字节,所以内存分配最小单位是8.
    由于存在着指针对象的对齐,所以内存地址的后三位一定是0. 所以与过之后才能得到Class对象的指针
    0x000c and x16,x13,#0xffffffff8
   
    这里便宜16个字节,指向cache_t结构体 (isa占8字节,superclass占8字节)
    然后读取两个指针变量值,分别是 bucket_t * 和 _mask, _occupied
    0x0010 ldp x10,x11,[x16,#0x10]
    
    其中x10存储 bucket_t * 指向的是方法缓存表
    x11的高32位存储_occupied,低32位存储_mask.
    _occupied 代表着哈希表有多少个方法的数量
    _mask表示哈希表的容量减1,主要用来缓存查找时的算法.
    w12 = __cmd & _mask ,表示从w12处开始查找
    0x0014 and    w12, w1, w11
    
}
*/
static void hook_objc_msgSend(){
    
}

@end
