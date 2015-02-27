//
//  GGDraggableViewApplicants.h
//  Cash Now
//
//  Created by amaury soviche on 10.05.14.
//  Copyright (c) 2014 Amaury Soviche. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "ApplicantsMemoryManagement.h"
#import "JobMemoryManagement.h"

@protocol GGDraggableViewApplicantDelegate <NSObject>


-(void) GGDraggableViewApplicantDelegate_LoadDetailView;
-(void) GGDraggableViewApplicantDelegate_positionViewChanged:(int)positionView;
-(void) GGDraggableViewApplicantDelegate_deleteView;

-(void) GGDraggableViewApplicantDelegate_AcceptApplicant;

@end

@interface GGDraggableViewApplicants : UIView



@property (nonatomic, assign) id<GGDraggableViewApplicantDelegate> delegate;


@property (nonatomic) int numeroView;


@property (nonatomic) NSString *ApplicantID;
@property (nonatomic) NSString *JobsId;

@property (nonatomic, strong) UIActivityIndicatorView *activity;

@property (strong, nonatomic) IBOutlet UIView *viewApplicant;

//iboutlets for xib
@property (strong, nonatomic) IBOutlet UIImageView *imageViewPP;
@property (strong, nonatomic) IBOutlet UILabel *labelName;
@property (strong, nonatomic) IBOutlet UITextView *textViewApplicantDescription;
@property (strong, nonatomic) IBOutlet UITextView *textViewJobDescription;



@end
