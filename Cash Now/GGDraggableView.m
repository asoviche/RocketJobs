//
//  GGDraggableView.m
//  Cash Now
//
//  Created by amaury soviche on 09.05.14.
//  Copyright (c) 2014 Amaury Soviche. All rights reserved.
//

#import "GGDraggableView.h"
#import "GGOverlayView.h"
#import <Parse/Parse.h>

@interface GGDraggableView ()
@property (nonatomic, strong) UIPanGestureRecognizer *panGestureRecognizer;
@property (nonatomic, strong) UITapGestureRecognizer *tapGestureRecognizer;

@property(nonatomic, strong) GGOverlayView *overlayView;
@property(nonatomic) CGPoint originalPoint;



@property(nonatomic) CGFloat xOriginal;

@end

@implementation GGDraggableView{
    #define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (!self) return nil;
    
    //1. load xib file
    [[NSBundle mainBundle] loadNibNamed:@"ViewJob" owner:self options:nil];
    
    //2. adjust bounds
    self.bounds = self.viewJob.bounds;
    
    //3. add as a subview
    [self addSubview:self.viewJob];
    
    
    
    

    [self setBackgroundColor:[UIColor whiteColor]];
    
    self.panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(dragged:)];
    [self addGestureRecognizer:self.panGestureRecognizer];
    
    self.tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
    [self addGestureRecognizer:self.tapGestureRecognizer];
    
    //    [self loadImageAndStyle];
    
    self.overlayView = [[GGOverlayView alloc] initWithFrame:self.bounds];
    self.overlayView.alpha = 0;
    [self addSubview:self.overlayView];
    
    
    //    UIColor *colorRed2 = [UIColor colorWithRed:0.796 green:0.3019 blue:0.3607 alpha:1];
    self.layer.cornerRadius = 3.0f;
    self.layer.borderWidth = 1.0f;
    self.layer.borderColor = [UIColorFromRGB(0xD1D1D1) CGColor];
    
    //labels
//    self.LabelDescriptionJob = [[UITextView alloc]init];
//    [self addSubview:self.LabelDescriptionJob];
//    self.LabelDescriptionJob.editable=NO;
//    [self.LabelDescriptionJob setFont:[UIFont fontWithName:@"HelveticaNeue" size:16]];
//    self.LabelDescriptionJob.frame = CGRectMake(10, 255, 270,100);
//    self.LabelDescriptionJob.textColor = UIColorFromRGB(0x225378);
//
//    
//    self.LabelDateJob = [[UILabel alloc]init];
//    [self addSubview:self.LabelDateJob];
//    [self.LabelDateJob setFont:[UIFont fontWithName:@"HelveticaNeue" size:11]];
//    self.LabelDateJob.frame = CGRectMake(95, 430, 300,15);
//    self.LabelDateJob.textColor = UIColorFromRGB(0x225378);
//    
//    self.LabelPriceJob = [[UILabel alloc]init];
//    [self addSubview:self.LabelPriceJob];
//    [self.LabelPriceJob setFont:[UIFont fontWithName:@"HelveticaNeue" size:11]];
//    self.LabelPriceJob.frame = CGRectMake(227, 430, 290,15);
//    self.LabelPriceJob.textColor = UIColorFromRGB(0x225378);
//    
//    self.LabelHourJob = [[UILabel alloc]init];
//    [self addSubview:self.LabelHourJob];
//    [self.LabelHourJob setFont:[UIFont fontWithName:@"HelveticaNeue" size:11]];
//    self.LabelHourJob.frame = CGRectMake(160, 430, 300,15);
//    self.LabelHourJob.textColor = UIColorFromRGB(0x225378);
//    
//    self.DistanceToUser = [[UILabel alloc]init];
//    [self addSubview:self.DistanceToUser];
//    [self.DistanceToUser setFont:[UIFont fontWithName:@"HelveticaNeue" size:11]];
//    self.DistanceToUser.frame = CGRectMake(30, 430, 300,15);
//    self.DistanceToUser.textColor = UIColorFromRGB(0x225378);
    
    
    //ICONS
    
//    UIImageView *iconLoc = [[UIImageView alloc] initWithImage:[UIImage imageNamed: @"icon-location"]];
//    [self addSubview:iconLoc];
//    iconLoc.contentMode = UIViewContentModeScaleAspectFit;
//    iconLoc.frame = CGRectMake(30, 390, 30,35);
//    
//    UIImageView *iconCal = [[UIImageView alloc] initWithImage:[UIImage imageNamed: @"icon-calendar"]];
//    [self addSubview:iconCal];
//    iconCal.contentMode = UIViewContentModeScaleAspectFit;
//    iconCal.frame = CGRectMake(95, 390, 28,31);
//    
//    UIImageView *iconClock = [[UIImageView alloc] initWithImage:[UIImage imageNamed: @"icon-clock"]];
//    [self addSubview:iconClock];
//    iconClock.contentMode = UIViewContentModeScaleAspectFit;
//    iconClock.frame = CGRectMake(160, 390, 30,30);
//    
//    UIImageView *iconDollar = [[UIImageView alloc] initWithImage:[UIImage imageNamed: @"icon-dollar"]];
//    [self addSubview:iconDollar];
//    iconDollar.contentMode = UIViewContentModeScaleAspectFit;
//    iconDollar.frame = CGRectMake(225, 390, 30,30);
    
    
    //lines
//    UIImageView *line2 = [[UIImageView alloc] initWithImage:[UIImage imageNamed: @"line_grey"]];
//    [self addSubview:line2];
//    line2.contentMode = UIViewContentModeScaleAspectFit;
//    line2.frame = CGRectMake(80, 240, 130,5);
//    
//    UIImageView *line1 = [[UIImageView alloc] initWithImage:[UIImage imageNamed: @"line_grey"]];
//    [self addSubview:line1];
//    line1.contentMode = UIViewContentModeScaleAspectFit;
//    line1.frame = CGRectMake(80, 350, 130,30);
    
    //launch loading
    self.activity = [[UIActivityIndicatorView alloc]init];
    [self.activity setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
    [self.activity setCenter:CGPointMake( frame.size.width / 2 - self.activity.frame.size.width/2, 150)];
    [self addSubview:self.activity];
    self.activity.hidesWhenStopped = YES;
    
    return self;
}

-(void) tapped: (UITapGestureRecognizer *) tapGestureRecognizer {
    
    [self.delegate GGDraggableViewDelegate_LoadDetailView];
//    [self.delegate GGDraggableViewDelegate_LoadDetailView];
}

//- (void)loadImageAndStyle : (UIImage *) imageJob
//{
//    UIImageView *imageView = [[UIImageView alloc] initWithImage:imageJob];
//    imageView.clipsToBounds = YES;
//    [self addSubview:imageView];
//    imageView.frame = CGRectMake(0, 0, super.frame.size.width, 230);
//    imageView.contentMode = UIViewContentModeScaleAspectFit;
//    
//    imageView.clipsToBounds=YES;
//    imageView.layer.cornerRadius=3;
//    
// 
//}


- (void)dragged:(UIPanGestureRecognizer *)gestureRecognizer
{
    CGFloat xDistance = [gestureRecognizer translationInView:self].x;
    CGFloat yDistance = [gestureRecognizer translationInView:self].y;
    
    
    NSLog(@"position drag : %f",xDistance);
    
    switch (gestureRecognizer.state) {
        case UIGestureRecognizerStateBegan:{
            self.originalPoint = self.center;
            
            self.xOriginal = [gestureRecognizer locationInView:self].x;
            break;
        };
        case UIGestureRecognizerStateChanged:{
            
            [self.delegate GGDraggableViewDelegate_positionViewChanged:xDistance];
            
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
                
                [self.delegate GGDraggableViewDelegate_ApplyForJob];
                [self deallocTheView];
                
            }else if (xDistance < -150){ //don't like
                
                [self deallocTheView];
            }
            else{//pas assez loin
                
                [self.delegate GGDraggableViewDelegate_positionViewChanged:0];
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

-(void) Apply{
    //add the current user's objectID to the list of the applicants for the job

    PFQuery *query = [PFQuery queryWithClassName:@"Job"];
    [query whereKey:@"objectId" equalTo:self.JobID];
    [query getObjectInBackgroundWithId:self.JobID block:^(PFObject *JobToApply, NSError *error) {
        
        //check if the user has alreadey applied for the job !
        if (![JobToApply[@"ApplicantsID"] containsObject:[PFUser currentUser].objectId]) {
            
            NSLog(@"apply oui");
            [JobToApply addObject:[PFUser currentUser].objectId forKey:@"ApplicantsID"];
            [JobToApply setObject:[NSNumber numberWithBool:NO] forKey:@"isApplicantArrayEmpty"];
            [JobToApply saveEventually:^(BOOL succeeded, NSError *error) {
                
                if (succeeded) {
                    //SEND THE PUSH NOTIFICATION ****************************
                    
                    PFUser *JobProvider = JobToApply[@"Author"];
                    
                    // Create our Installation query
                    PFQuery *pushQuery = [PFInstallation query];
                    [pushQuery whereKey:@"user" equalTo:JobProvider];
                    [pushQuery whereKey:@"active" equalTo:[NSNumber numberWithBool:YES]];
                    
                    //add a badge for each notification
                    NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
                                          @"You have a new Applicant !", @"alert",
                                          @"Increment", @"badge",
                                          nil];
                    
                    // Send push notification to query
                    PFPush *push = [[PFPush alloc] init];
                    [push setQuery:pushQuery];
                    [push setData:data];
                    [push sendPushInBackground];
                }
                else{
                    [[[UIAlertView alloc] initWithTitle:@"Oops" message:@"It seems there was a connection problem..." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show] ;
                }
            }];
        }
    }];
}

- (void)deallocTheView
{
    NSLog(@"numero de la vue deleted : %d",self.numeroView);

    [self removeGestureRecognizer:self.panGestureRecognizer];
    [self.delegate GGDraggableViewDelegate_deleteView];
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

@end
