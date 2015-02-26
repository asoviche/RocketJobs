//
//  GGDraggableViewApplicants.m
//  Cash Now
//
//  Created by amaury soviche on 10.05.14.
//  Copyright (c) 2014 Amaury Soviche. All rights reserved.
//

#import "GGDraggableViewApplicants.h"
#import "GGOverlayView.h"





@interface GGDraggableViewApplicants ()

@property (nonatomic, strong) UIPanGestureRecognizer *panGestureRecognizer;
@property (nonatomic, strong) UITapGestureRecognizer *tapGestureRecognizer;
@property(nonatomic, strong) GGOverlayView *overlayView;
@property(nonatomic) CGPoint originalPoint;

@end

@implementation GGDraggableViewApplicants{

}

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (!self) return nil;
    
    [self setBackgroundColor:[UIColor whiteColor]];
    
    self.panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(dragged:)];
    [self addGestureRecognizer:self.panGestureRecognizer];
    
    self.tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
    [self addGestureRecognizer:self.tapGestureRecognizer];
    
    self.overlayView = [[GGOverlayView alloc] initWithFrame:self.bounds];
    self.overlayView.alpha = 0;
    [self addSubview:self.overlayView];
    
    
//    UIColor *colorRed2 = [UIColor colorWithRed:0.796 green:0.3019 blue:0.3607 alpha:1];
    self.layer.cornerRadius = 3.0f;
    self.layer.borderWidth = 1.0f;
    self.layer.borderColor = [UIColorFromRGB(0xD1D1D1) CGColor];

    
    
    
    //lines
    UIImageView *line2 = [[UIImageView alloc] initWithImage:[UIImage imageNamed: @"line_grey"]];
    [self addSubview:line2];
    line2.contentMode = UIViewContentModeScaleAspectFit;
    line2.frame = CGRectMake(80, 310, 130,5);
    
    //labels
    self.LabelJobDescription = [[UITextView alloc]init];
    [self addSubview:self.LabelJobDescription];
    self.LabelJobDescription.editable = NO;
    [self.LabelJobDescription setFont:[UIFont fontWithName:@"HelveticaNeue" size:14]];
    self.LabelJobDescription.textColor = UIColorFromRGB(0xea2e49);
    self.LabelJobDescription.frame = CGRectMake(10, 315, 270,100);
    
    //line
    UIImageView *line1 = [[UIImageView alloc] initWithImage:[UIImage imageNamed: @"line_grey"]];
    [self addSubview:line1];
    line1.contentMode = UIViewContentModeScaleAspectFit;
    line1.frame = CGRectMake(80, 385, 130,30);
    
    
    self.LabelNameAge = [[UILabel alloc]init];
    [self addSubview:self.LabelNameAge];
    self.LabelNameAge.textColor = UIColorFromRGB(0x225378);
    [self.LabelNameAge setFont:[UIFont fontWithName:@"HelveticaNeue" size:16]];
    self.LabelNameAge.frame = CGRectMake(10, 410, 300,20);
    
    
    self.LabelDescription = [[UILabel alloc]init];
    [self addSubview:self.LabelDescription];
    self.LabelDescription.textColor = UIColorFromRGB(0x225378);
    [self.LabelDescription setFont:[UIFont fontWithName:@"HelveticaNeue" size:14]];
    self.LabelDescription.frame = CGRectMake(10, 430, 300,18);
    
    //launch loading
    self.activity = [[UIActivityIndicatorView alloc]init];
    [self.activity setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
    [self.activity setCenter:CGPointMake( frame.size.width / 2 - self.activity.frame.size.width/2, 150)];
    [self addSubview:self.activity];
    self.activity.hidesWhenStopped = YES;
    
    return self;
}

-(void) tapped: (UITapGestureRecognizer *) tapGestureRecognizer {
    
}

- (void)loadImageAndStyle : (UIImage *) imageJob
{
    UIImageView *imageView = [[UIImageView alloc] initWithImage:imageJob];
    imageView.frame = CGRectMake(0, 0, 291,300);
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self addSubview:imageView];

    
    [self bringSubviewToFront:self.overlayView];
}

- (void)dragged:(UIPanGestureRecognizer *)gestureRecognizer
{
    CGFloat xDistance = [gestureRecognizer translationInView:self].x;
    CGFloat yDistance = [gestureRecognizer translationInView:self].y;
    
    [self.delegate GGDraggableViewApplicantDelegate_positionViewChanged:xDistance];
    
    switch (gestureRecognizer.state) {
        case UIGestureRecognizerStateBegan:{
            self.originalPoint = self.center;
            break;
        };
        case UIGestureRecognizerStateChanged:{
            CGFloat rotationStrength = MIN(xDistance / 320, 1);
            CGFloat rotationAngel = (CGFloat) (2*M_PI/16 * rotationStrength);
            CGFloat scaleStrength = 1 - fabsf(rotationStrength) / 4;
            CGFloat scale = MAX(scaleStrength, 0.93);
            CGAffineTransform transform = CGAffineTransformMakeRotation(rotationAngel);
            CGAffineTransform scaleTransform = CGAffineTransformScale(transform, scale, scale);
            self.transform = scaleTransform;
            self.center = CGPointMake(self.originalPoint.x + xDistance, self.originalPoint.y + yDistance);
            
            break;
        };
        case UIGestureRecognizerStateEnded: {
            if (xDistance > 150   ) { //like
                
                NSLog(@"test");
//                [self Accept];
                [self.delegate GGDraggableViewApplicantDelegate_AcceptApplicant];
                [self deallocTheView];
                
            }else if (xDistance < -150){ //don't like

                [self deallocTheView];
            }
            else{//pas assez loin
                
                [self.delegate GGDraggableViewApplicantDelegate_positionViewChanged:0];
                [self resetViewPositionAndTransformations];
            }
            NSLog(@"distance : %f and %f", xDistance , yDistance);
            break;
        };
        case UIGestureRecognizerStatePossible:break;
        case UIGestureRecognizerStateCancelled:break;
        case UIGestureRecognizerStateFailed:break;
    }
}

- (void)updateOverlay:(CGFloat)distance
{
    if (distance > 0) {
        self.overlayView.mode = GGOverlayViewModeRight;
    } else if (distance <= 0) {
        self.overlayView.mode = GGOverlayViewModeLeft;
    }
    CGFloat overlayStrength = MIN(fabsf(distance) / 100, 0.4);
    self.overlayView.alpha = overlayStrength;
}

-(void) updateUI{
    self.LabelDescription.text = self.Description;
    self.LabelNameAge.text = self.NameAge;
    self.LabelJobDescription.text = self.JobDescription;
    
    NSLog(@"update ui : %@", self.LabelDescription.text);
}

-(void) deny {
    
    // deny the guy
}

- (void)resetViewPositionAndTransformations
{
    [UIView animateWithDuration:0.2
                     animations:^{
                         self.center = self.originalPoint;
                         self.transform = CGAffineTransformMakeRotation(0);
                         self.overlayView.alpha = 0;
                     }];
}

- (void)deallocTheView
{
    
    [self removeGestureRecognizer:self.panGestureRecognizer];
    [self.delegate GGDraggableViewApplicantDelegate_deleteView];
}

@end
