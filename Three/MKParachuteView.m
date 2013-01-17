#import "MKParachuteView.h"

@implementation MKParachuteView

- (id)initWithFrame:(CGRect)frame
{
  self = [super initWithFrame:frame];
  if (self) {
    
    [self setBackgroundColor:[UIColor clearColor]];
    
    UIImage *parachuteMan = [UIImage imageNamed:@"parachute_man.png"];
    UIImageView *parachuteManView = [[UIImageView alloc] initWithImage:parachuteMan];
    
    CGRect parachuteFrame = CGRectMake(-26.0, 0.0, 69.6f, 100.0f);
    parachuteManView.frame = parachuteFrame;
    
    [self addSubview:parachuteManView];
  }
  return self;
}

@end
