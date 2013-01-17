#import "MKBarView.h"

@implementation MKBarView

- (id)initWithFrame:(CGRect)frame
{
  self = [super initWithFrame:frame];
  if (self) {
    [self setBackgroundColor:[UIColor clearColor]];
    
    UIImage *arm = [UIImage imageNamed:@"arm.png"];
    UIImageView *armView = [[UIImageView alloc] initWithImage:arm];
    armView.frame = CGRectMake(0.0, -40.0, 320.0, 100.0);
    [self addSubview:armView];
  }
  return self;
}

@end
