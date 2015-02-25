#import "GGOverlayView.h"

@interface GGOverlayView ()
@property (nonatomic, strong) UIImageView *imageView;
@end

@implementation GGOverlayView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (!self) return nil;

    self.backgroundColor = [UIColor whiteColor];
    self.imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Unknown.png"]];
    [self addSubview:self.imageView];

    return self;
}

- (void)setMode:(GGOverlayViewMode)mode
{
    if (_mode == mode) return;

    _mode = mode;
    self.imageView.contentMode = UIViewContentModeScaleAspectFit; //added
    if (mode == GGOverlayViewModeLeft) {
        self.imageView.image = [UIImage imageNamed:@"Deny_button"];//added
    } else {
        self.imageView.image = [UIImage imageNamed:@"Apply_button"];//added
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.imageView.frame = CGRectMake(50, 50, 100, 100);
}

@end