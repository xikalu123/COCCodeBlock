//
//  LayerView.m
//  Fermi
//
//  Created by chenyuliang on 2019/12/24.
//  Copyright © 2019 didi. All rights reserved.
//

#import "LayerView.h"
#import "CusLayer.h"
#import "UIView+ChenPopAnimation.h"

@implementation LayerView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.test];
    }
    return self;
}

- (UIButton *)test{
    if (!_test) {
        _test = [UIButton buttonWithType:UIButtonTypeCustom];
        _test.frame = CGRectMake(0, 0, 10, 10);
        _test.backgroundColor = [UIColor redColor];
        [_test addTarget:self action:@selector(testAnimation) forControlEvents:UIControlEventTouchUpInside];
    }
    return _test;
}

/*
 如果layer的属性发生变化，会触发layer的代理方法 actionForLayer:forKey:
 这个方法的触发是在 属性变化之前，所以通过 [layer valueForKey:event] 获取的属性值是变化之前的属性值
 */

//- (id<CAAction>)actionForLayer:(CALayer *)layer forKey:(NSString *)event{
//    NSLog(@"ssssss===================%@",[layer valueForKey:event]);
//    return [super actionForLayer:layer forKey:event];
//}

static int k = 0;
- (void)testAnimation{
    
//    if ([self.layer isKindOfClass:[CusLayer class]]) {
//        ((CusLayer *)self.layer).time = 1.4;
//    }
    
    NSLog(@"sss======%@",[self.layer valueForKey:@"masksToBounds"]);
    
    
//    CABasicAnimation *animation = [CABasicAnimation animation];
//    animation.keyPath = @"position.x";
//    animation.fromValue = @77;
//    animation.toValue = @455;
//    animation.duration = 1;
//
//    [self.layer addAnimation:animation forKey:@"basic"];
//    self.frame = CGRectMake(455, self.frame.origin.y, self.frame.size.width, self.frame.size.height);
    
//    k++;
//    if(k%2){
//
//        /*
//         如果没有效果
//         是因为 view 重写了 drawRect方法。
//         因为生成iamge设置到 layer.contents 上面 不能重写。
//         */
//        [UIView CH_popAnimationWithDuration:1.7
//        animations:^{
//            self.backgroundColor = [UIColor redColor];
//            self.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.3, 1.3);
//            self.transform = CGAffineTransformMakeRotation(M_PI_2);
//           }];
//
////       self.center = CGPointMake(200, 200);
//    }else{
////       self.center = CGPointMake(100, 100);
//    }
//
//    NSLog(@"jjjssss===========%@",[self.layer valueForKey:@"position"]); // layer属性改变后的新值
    
    
    
//    [UIView animateWithDuration:1.0f animations:^{
//        NSLog(@"inside animation block: %@",
    
//        [self actionForLayer:self.layer forKey:@"position"]);
//        self.center = CGPointMake(200, 200);
//    }];
}

//- (id<CAAction>)actionForLayer:(CALayer *)layer forKey:(NSString *)event{
//    NSLog(@"ssss================%@",layer);
//    return [super actionForLayer:layer forKey:event];
//}

/*
 layer显示 与 view绘制的整个流程
 CALayer 收到需要更新的信号  layout_and_display_if_needed
 1.CAlayer display
 2.CAlayer drawInContext
 3.UIView drawLayer:inContext:
 4.Uiview drawRect
 5.最后绘制的Image 加在 layer.contents 上面
 */


//- (void)drawRect:(CGRect)rect{
//    NSLog(@"UIview is drawing 。。。。。。");
//}
//
//- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx{
//    [super drawLayer:layer inContext:ctx];
//    NSLog(@"UIview is drawing  layer === %@",layer);
//}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

+ (Class)layerClass{
    return  [CusLayer class];
}

@end
