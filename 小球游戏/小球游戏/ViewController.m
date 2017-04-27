#import "ViewController.h"

//运动管理框架
#import <CoreMotion/CoreMotion.h>

@interface ViewController ()

//运动管理器
@property(nonatomic,strong)CMMotionManager *motionManager;

//小球
@property (weak, nonatomic) IBOutlet UIImageView *ballImageView;


//小球位移量
@property(nonatomic,assign)CGPoint movePoint;

@end

@implementation ViewController

/**
 * 1.添加加速器；使用push模式（需要不断获取数据）
 * 2.处理加速器数据
 2.1 数值叠加
 2.2 边界检测
 2.3 碰撞回弹处理
 */

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //1. 创建运动管理器
    self.motionManager = [CMMotionManager new];
    
    //2. 判断加速计是否可用
    if (!self.motionManager.isAccelerometerAvailable) {
        return;
    }
    //3. 设置采样间隔 (更新间隔设置要短，保证小球运动平滑)
    self.motionManager.accelerometerUpdateInterval = 0.1;
    
    //4. 开始采样
    [self.motionManager startAccelerometerUpdatesToQueue:[NSOperationQueue mainQueue] withHandler:^(CMAccelerometerData * _Nullable accelerometerData, NSError * _Nullable error) {
        
        //5. 处理数据
        [self ballMoveWithAcceleration:accelerometerData.acceleration];
        
    }];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidAppear:(BOOL)animated
{
    
}
#pragma mark - 小球移动

- (void)ballMoveWithAcceleration:(CMAcceleration)acceleration
{
    NSLog(@"acceleration : x: %f, y: %f, z: %f", acceleration.x, acceleration.y, acceleration.z);
    
    //1.获取加速计的偏移值
    //结构体不能直接修改里面的成员变量:不能使用self.point
    //我们需要在原来的偏移量上叠加偏移量，所以是+=，而不是-=
    _movePoint.x += acceleration.x;
    _movePoint.y += acceleration.y;
    
    //2.改变小球的位置
    //先获取小球当前的位置
    CGRect currentRect = self.ballImageView.frame;
    //使用偏移矩形CGRectOffset设置小球的新位置：  第一个参数：原始矩形  第二个参数：x轴偏移量  第三个参数：y轴偏移量
    //加速器是笛卡尔坐标系，y轴向上为正，向下为负。而iPhone屏幕的y轴正方向是向下，所以这里y轴的偏移量应该与加速器的偏移量相反
    CGRect rect = CGRectOffset(currentRect, _movePoint.x, -_movePoint.y);
    
    //3.x轴边界检测
    if (rect.origin.x <= 0) {
        
        rect.origin.x = 0;
        //一旦超出边界，设置回弹（把偏移量的设为原来的反方向即可）
        //在实际游戏开发中，回弹量的大小与小球材料有关（高中物理知识），这里我们就暂时设为一半0.5
        _movePoint.x *= -0.5;
    }
    else if (rect.origin.x > self.view.bounds.size.width-rect.size.width)
    {
        rect.origin.x = self.view.bounds.size.width-rect.size.width;
        _movePoint.x *= -0.5;
    }
    
    //3.1 y轴边界检测
    if (rect.origin.y <= 0) {
        
        rect.origin.y = 0;
        _movePoint.y *= -0.5;
    }
    else if (rect.origin.y > self.view.bounds.size.height-rect.size.height)
    {
        rect.origin.y = self.view.bounds.size.height-rect.size.height;
        _movePoint.y *= -0.5;
    }
    
    //4.修改小球的位置
    self.ballImageView.frame = rect;
    
    NSLog(@"x方向：%f====y方向:%f",rect.origin.x,rect.origin.y);
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
