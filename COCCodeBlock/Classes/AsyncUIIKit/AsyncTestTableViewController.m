//
//  AsyncTestTableViewController.m
//  Fermi
//
//  Created by chenyuliang on 2019/12/24.
//  Copyright © 2019 didi. All rights reserved.
//

#import "AsyncTestTableViewController.h"
#import "LayerView.h"
#import "ChenKeyFrameAnimation.h"
#import "ClockFace.h"

@interface AsyncTestTableViewController ()

@property (nonatomic, strong) CADisplayLink *displayLink;

@property (nonatomic, strong) UIButton *exitBtn;

/*
 如果一个layer的delegate 挂载了 view
 那么改变 属性时，则是隐示的动画，会从一帧直接跳到下一帧
 
 如果没有的话，则layer会去寻找一个CAAction，进行动画。默认时间大概是 0.25s
 */
@property (strong, nonatomic) UIView  *shapeView;
@property (strong, nonatomic) CAShapeLayer  *shapeLayer;
@property (strong, nonatomic) UIButton *testLayer;


@property (strong, nonatomic) LayerView *testViewlayer;

@property (strong, nonatomic) ChenKeyFrameAnimation *keyAnimation;

@property (strong, nonatomic) ClockFace *clockLayer;

 
@end

@implementation AsyncTestTableViewController

- (CADisplayLink *)displayLink{
    if (!_displayLink) {
        _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(hanldeDisplay)];
        [_displayLink addToRunLoop:[NSRunLoop currentRunLoop]  forMode:NSDefaultRunLoopMode];
    }
    return _displayLink;
}

- (ChenKeyFrameAnimation *)keyAnimation{
    if (!_keyAnimation) {
        _keyAnimation = [[ChenKeyFrameAnimation alloc] initWithFrame:CGRectMake(100, 100, 100, 20)];
        _keyAnimation.backgroundColor = [UIColor orangeColor];
    }
    return _keyAnimation;
}

- (ClockFace *)clockLayer{
    if (!_clockLayer) {
        _clockLayer = [ClockFace new];
    }
    return _clockLayer;
}

- (void)hanldeDisplay{
    NSLog(@"asdjlaksj==========%f",self.keyAnimation.layer.presentationLayer.frame.origin.x);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _exitBtn = [[UIButton alloc] initWithFrame:CGRectMake(20, 60, 30, 30)];
    _exitBtn.backgroundColor = [UIColor yellowColor];
    [_exitBtn addTarget:self action:@selector(exit) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_exitBtn];
    
//    [self.view.layer addSublayer:self.shapeLayer];
//    [self.view addSubview:self.shapeView];
//    [self.view addSubview:self.testLayer];
//
//    [self.view addSubview:self.testViewlayer];
//
//    [self.view addSubview:self.keyAnimation];
    
    self.clockLayer.frame = CGRectMake(100, 100, 200, 200);
    [self.view.layer addSublayer:self.clockLayer];
    self.clockLayer.time = [NSDate now];
    
    
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)exit{
//    [self displayLink];
    
//    [self.keyAnimation test];
//    [self.keyAnimation testPath];
//    [self.keyAnimation testTimeFunc];
//    [self.keyAnimation testAnimationGroup];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
#warning Incomplete implementation, return the number of sections
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
#warning Incomplete implementation, return the number of rows
    return 0;
}


- (UIButton *)testLayer{
    if (!_testLayer) {
        _testLayer = [UIButton buttonWithType:UIButtonTypeCustom];
        _testLayer.frame = CGRectMake(100, 100, 60, 50);
        _testLayer.layer.borderWidth = 1;
        [_testLayer setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_testLayer setTitle:@"测试Layer" forState:UIControlStateNormal];
        [_testLayer addTarget:self action:@selector(testLayerAnimation) forControlEvents:UIControlEventTouchUpInside];
    }
    return _testLayer;
}

static int c = 0;

- (void)testLayerAnimation{
    
    /*
     当layer的属性值改变时，会经过以下几个步骤来判断是否执行动画
     1.通过layer的delagate请求 actionForLayer:forKey: 消息，获取一个对应的动画 CAAction
     
     如果返回一个动作对象，则会执行这个动画 (在Animation block 中，则返回一个 actioon)
     如果返回一个nil，这样layer会到 其他的地方 继续查找 (单独1使用 layer，则使用默认的动画)
     如果返回一个 NSNull，则告诉layer不需要执行动画，则搜索停止 (所以如果layer的delegate是 view，并且不再 animate block中，则返回 NSNull)
     */
    NSLog(@"outside animation block: %@",[self.view actionForLayer:self.view.layer forKey:@"position"]);
      
      [UIView animateWithDuration:0.3 animations:^{
          NSLog(@"inside animation block: %@",
                [self.view actionForLayer:self.view.layer forKey:@"position"]);
      }];
    
    
        c++;
        if (c%2) {
//            [UIView animateWithDuration:0.25f animations:^{
//                 self.shapeView.center = CGPointMake(60, 60);
//            }];
//            self.shapeView.center = CGPointMake(60, 60);
//             self.shapeView.layer.position = CGPointMake(60, 60);
            self.shapeLayer.position = CGPointMake(60, 60);
        }else{
    //        [UIView animateWithDuration:0.25f animations:^{
    //             self.shapeView.center = CGPointMake(30, 30);
    //        }];
    //        self.shapeView.center = CGPointMake(30, 30);
    //        self.shapeView.layer.position = CGPointMake(30, 30);
            self.shapeLayer.position = CGPointMake(30, 30);
        }
}


- (UIView *)shapeView{
    if (!_shapeView) {
        _shapeView = [[UIView alloc] initWithFrame:CGRectMake(20, 100, 40, 40)];
        _shapeView.backgroundColor = [UIColor blackColor];
    }
    return _shapeView;
}

- (CAShapeLayer *)shapeLayer{
    if (!_shapeLayer) {
        _shapeLayer = [CAShapeLayer layer];
        _shapeLayer.frame = CGRectMake(20, 100, 40, 40);
        _shapeLayer.backgroundColor = [UIColor blackColor].CGColor;
    }
    return _shapeLayer;
}

- (LayerView *)testViewlayer{
    if (!_testViewlayer) {
        _testViewlayer = [[LayerView alloc] initWithFrame:CGRectMake(100, 200, 100, 100)];
        _testViewlayer.backgroundColor = [UIColor greenColor];
    }
    return  _testViewlayer;
}

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
