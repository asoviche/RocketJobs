//
//  GGDraggableView.h
//  Cash Now
//
//  Created by amaury soviche on 09.05.14.
//  Copyright (c) 2014 Amaury Soviche. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol GGDraggableViewDelegate <NSObject>


-(void) GGDraggableViewDelegate_LoadDetailView;
-(void) GGDraggableViewDelegate_positionViewChanged:(int)positionView;
-(void) GGDraggableViewDelegate_deleteView;

-(void) GGDraggableViewDelegate_ApplyForJob;

@end


@interface GGDraggableView : UIView

@property (nonatomic, assign) id<GGDraggableViewDelegate> delegate;


@property (nonatomic) int numeroView;

@property (strong, nonatomic) IBOutlet UIImageView *imageJob;
@property (strong, nonatomic) IBOutlet UITextView *LabelDescriptionJob;
@property (strong, nonatomic) IBOutlet UILabel *LabelDateJob;
@property (strong, nonatomic) IBOutlet UILabel *LabelPriceJob;
@property (strong, nonatomic) IBOutlet UILabel *LabelHourJob;
@property (strong, nonatomic) IBOutlet UIView *ViewSingleJob;
@property (strong, nonatomic) IBOutlet UILabel *DistanceToUser;

@property(nonatomic) NSString *JobID;

- (void)loadImageAndStyle : (UIImage *) imageJob;

@property (nonatomic, strong) UIActivityIndicatorView *activity;

//.xib
@property (strong, nonatomic) IBOutlet UIView *viewJob;

//iboutlets
@property (strong, nonatomic) IBOutlet UITextView *textViewJobDesription;

@property (strong, nonatomic) IBOutlet UILabel *labelJobLocation;
@property (strong, nonatomic) IBOutlet UILabel *labelJobDate;
@property (strong, nonatomic) IBOutlet UILabel *labelJobHour;
@property (strong, nonatomic) IBOutlet UILabel *labelJobPrice;

@property (strong, nonatomic) IBOutlet UIImageView *imageViewPosterImagePP;
@property (strong, nonatomic) IBOutlet UILabel *labelPosterName;
@property (strong, nonatomic) IBOutlet UITextView *textViewPosterDescription;



@end
