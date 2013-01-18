#import <QuartzCore/QuartzCore.h>
#import "MKViewController.h"
#import "MKView.h"
#import "MKParachuteView.h"
#import "MKBarView.h"
#import <CoreMotion/CoreMotion.h>

#define RAND_SPEED(y) ((arc4random () % 1) + 3 + y)

@interface MKViewController ()

@end

@implementation MKViewController
{
  CMMotionManager *motion_;
  MKView *_mainView;
  UIButton *_startButton;
  UIView *_overlay;
  CADisplayLink *_timer;
  BOOL touching_;
  float accelX_;
}

- (id)init
{
  self = [super init];
  if (self) {
    motion_ = [[CMMotionManager alloc] init];
    [motion_ startAccelerometerUpdates];
    accelX_ = 0;
  }
  return self;
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  
  CGRect screen = [[UIScreen mainScreen] bounds];
  int width = screen.size.width;
  int height = screen.size.height;
  
  _mainView = [[MKView alloc] initWithFrame:[UIScreen mainScreen].bounds];
  
  _startButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
  _startButton.frame = CGRectMake(width / 2 - 100 / 2, height / 2 - 50 / 2, 100.0, 50.0);
  [_startButton setTitle:@"Play!" forState:UIControlStateNormal];
  [_startButton addTarget:self
                   action:@selector(startGame:)
         forControlEvents:UIControlEventTouchUpInside];

  _overlay = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
  _overlay.backgroundColor = [UIColor whiteColor];
  _overlay.alpha = 0.6f;
  
  [self.view addSubview:_mainView];
  [self.view addSubview:_overlay];
  [self.view addSubview:_startButton];
}

- (void)startGame:(id)sender
{
  NSDate *now = [NSDate date];
  NSCalendar *cal = [NSCalendar currentCalendar];
  NSDateComponents *dc = [cal components:NSSecondCalendarUnit fromDate:now];
  int sec = [dc second];
  
  float startYSpeed = 1.0;
  float startXSpeed = RAND_SPEED(startYSpeed);
  startXSpeed = (sec % 2 == 0) ? startXSpeed : -(startXSpeed);
  
   _mainView.parachuteSpeed = CGPointMake(startXSpeed, startYSpeed);
  
  _timer = [CADisplayLink displayLinkWithTarget:self selector:@selector(gameLoop)];
  [_timer addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
  
  _startButton.hidden = YES;
  _overlay.hidden = YES;
  
  _mainView.score = 0;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
  touching_ = YES;
  MKBarView *bar = _mainView.bar;
  
  UITouch *touch = [touches anyObject];
  CGPoint location = [touch locationInView:_mainView];
  
  float y = bar.frame.origin.y;
  float x = location.x;
  
  bar.center = location.x > 30 ? CGPointMake(x, y + 10) : CGPointMake(30.0, y + 10);
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
  MKBarView *bar = _mainView.bar;
  
  UITouch *touch = [touches anyObject];
  CGPoint location = [touch locationInView:_mainView];
  
  float y = bar.frame.origin.y;
  float x = location.x;
  
  bar.center = location.x > 30 ? CGPointMake(x, y + 10) : CGPointMake(30.0, y + 10);
}

- (void)accelerometerMoved:(CMAccelerometerData *)accelData {
  MKBarView *bar = _mainView.bar;
  float y = bar.frame.origin.y;
  float x = bar.center.x + (accelX_ * 20);
  x = fminf(x, (self.view.bounds.size.width + (bar.frame.size.width/2) - 30));
  bar.center = x > 30 ? CGPointMake(x, y + 10) : CGPointMake(30.0, y + 10);
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
  touching_ = NO;
}

- (float)filterAccelXData:(CMAccelerometerData *)accelData {
  accelX_ = (accelData.acceleration.x * 0.1) + (accelX_ * (1.0 - 0.1));
  return accelX_;
}

- (void)gameLoop
{
  
  MKParachuteView *parachute = _mainView.parachute;
  CGPoint speed = _mainView.parachuteSpeed;
  MKBarView *bar = _mainView.bar;
  
  float rotation = [self filterAccelXData:motion_.accelerometerData] * -(M_PI / 6);
  if (!touching_)
  {
    [self accelerometerMoved:motion_.accelerometerData];
  }
  parachute.center = CGPointMake(parachute.center.x + speed.x, parachute.center.y + speed.y);
  
  BOOL parachuteDidHitSide = parachute.center.x + parachute.frame.size.width / 2 >= _mainView.bounds.size.width || parachute.center.x - parachute.frame.size.width / 2 < 0;
  
  if (parachuteDidHitSide) {
    _mainView.parachuteSpeed = CGPointMake(-speed.x, speed.y);
  } else {
    CGAffineTransform xform = CGAffineTransformMakeRotation(rotation);
    parachute.transform = xform;
  }
  
  BOOL parachuteDidHitBar = CGRectIntersectsRect(parachute.frame, bar.frame) && parachute.frame.origin.y + parachute.frame.size.height <= _mainView.bar.frame.origin.y + 10;
  
  if (parachuteDidHitBar) {
    [self parachuteDidHitBar];
    
    parachute.center = CGPointMake(parachute.center.x, 60.0);
  }
  
  if (parachute.center.y + parachute.frame.size.height / 2 >= _mainView.bounds.size.height) {
    [self parachuteDidBlowUp];
  }
}

- (void)parachuteDidBlowUp
{
  [_timer removeFromRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
  [_timer invalidate];
  _timer = nil;
  
  CGPoint resetCenter = CGPointMake([[UIScreen mainScreen] bounds].size.width / 2 - 20, 60.0);
  _mainView.parachute.center = resetCenter;
  _mainView.parachuteSpeed = CGPointMake(2.0, 2.0);
  
  _startButton.hidden = NO;
  _overlay.hidden = NO;
}

- (void)parachuteDidHitBar
{
  CGPoint speed = _mainView.parachuteSpeed;
  float y = speed.y + 0.2;
  float random = RAND_SPEED(y);
  float x = (speed.x < 0) ? -random : random;
  
  _mainView.parachuteSpeed = CGPointMake(x, y);
  
  _mainView.score++;
}

- (NSUInteger)supportedInterfaceOrientations
{
  return UIInterfaceOrientationMaskPortrait;
}

- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
}

@end