#import <UIKit/UIKit.h>

@class MKParachuteView;
@class MKBarView;

@interface MKView : UIView

@property (nonatomic, assign) CGPoint parachuteSpeed;
@property (nonatomic, assign) int score;
@property (nonatomic, readonly) MKParachuteView *parachute;
@property (nonatomic, readonly) MKBarView *bar;

@end
