//
//  ChenTestOperation.h
//  Fermi
//
//  Created by chenyuliang on 2019/12/4.
//  Copyright © 2019 didi. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
 NSOperation使用： https://juejin.im/post/5a9e57af6fb9a028df222555
 要点：
 1.不加入队列的Operation在主线程执行.(如果额外操作比较多，在子线程执行)
 2.重写main或start定义自己的NSOperation对象，重写main简单，
 重写start需要管理状态属性 isExecuting,isFinished等
 */

NS_ASSUME_NONNULL_BEGIN

@interface ChenTestOperation : NSObject

+ (void)testOperation;

@end

NS_ASSUME_NONNULL_END
