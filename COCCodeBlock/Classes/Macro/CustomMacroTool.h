//
//  CustomMacroTool.h
//  Fermi
//
//  Created by chenyuliang on 2019/12/4.
//  Copyright © 2019 didi. All rights reserved.
//

#ifndef CustomMacroTool_h
#define CustomMacroTool_h

#define dispatch_main_sync_safe(block)\
    if([NSThread isMainThread]){\
        block();\
    }else{\
         dispatch_sync(dispatch_get_main_queue(), block);\
    }

#define dispatch_main_async_safe(block)\
    if ([NSThread isMainThread]) {\
        block();\
    } else {\
        dispatch_async(dispatch_get_main_queue(), block);\
    }

#endif /* CustomMacroTool_h */
