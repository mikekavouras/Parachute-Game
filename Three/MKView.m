#import "MKView.h"
#import "MKParachuteView.h"
#import "MKBarView.h"
#import <QuartzCore/QuartzCore.h>
@implementation MKView
{
  UILabel *scoreDisplay;
  UIButton *startButton;
}

@synthesize parachuteSpeed = _parachuteSpeed;
@synthesize score = _score;
@synthesize parachute = _parachute;
@synthesize bar = _bar;

- (id)initWithFrame:(CGRect)frame
{
  self = [super initWithFrame:frame];
  if (self) {
    
    self.backgroundColor = [UIColor whiteColor];
    
    CGRect screen = [UIScreen mainScreen].bounds;
    int width = screen.size.width;
    int height = screen.size.height;
    
    CGRect parachuteFrame = CGRectMake((width / 2) - 30.0, 20.0f, 18.0f, 100.0f);
    CGRect barFrame = CGRectMake((width / 2) - 60.0, height - 90,  60.0, 20.0);
    
    UIImage *bg = [UIImage imageNamed:@"bg.png"];
    UIImageView *bgView = [[UIImageView alloc] initWithImage:bg];
    
    if (self.bounds.size.height > 480.0f) {
      NSLog(@"iPhone5");
      bgView.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
    } else {
      NSLog(@"iPhone4");
      bgView.frame = CGRectMake(0, -20.0, self.bounds.size.width, self.bounds.size.height);
    }
    
    [self addSubview:bgView];
    
    _parachute = [[MKParachuteView alloc] initWithFrame:parachuteFrame];
    _parachute.layer.anchorPoint = CGPointMake(0.5, 0.05);
    _bar = [[MKBarView alloc] initWithFrame:barFrame];
    
    scoreDisplay = [[UILabel alloc] initWithFrame:CGRectMake(20, 20, 20, 20)];
    scoreDisplay.textColor = [UIColor blackColor];
    scoreDisplay.backgroundColor = [UIColor clearColor];
    
    [self addSubview:_parachute];
    [self addSubview:_bar];
    [self addSubview:scoreDisplay];
  }
  return self;
}

- (void)setScore:(int)score
{
  _score = score;
  scoreDisplay.text = [NSString stringWithFormat:@"%d", _score];
}


@end
