//
//  TestMacro.m
//  Fermi
//
//  Created by chenyuliang on 2019/12/4.
//  Copyright © 2019 didi. All rights reserved.
//

#import "TestMacro.h"
#import "CustomMacroTool.h"

@implementation TestMacro

+ (void)testMacro{
    dispatch_main_sync_safe(^{
        NSLog(@"sasdasd");
    });
}

@end
