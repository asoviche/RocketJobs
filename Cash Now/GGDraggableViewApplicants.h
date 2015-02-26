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

//@property (nonatomic) BOOL ViewDeleted;
//@property (nonatomic) BOOL LoadDetailView;
//@property (nonatomic) int position;


@property (nonatomic) int numeroView;



@property (nonatomic) NSString *Name;

@property (nonatomic) NSString *Age;
@property (nonatomic) NSString *About;
@property (nonatomic) UIImage *imagePP;
@property (nonatomic) NSString *ApplicantID;

@property (nonatomic) NSString *JobsId;



@property (nonatomic) NSMutableArray *dragViewArray;

@property (strong, nonatomic) GGDraggableViewApplicants *NextDragView;


@property (strong, nonatomic) IBOutlet UIImageView *FirstImage;
@property (strong, nonatomic) IBOutlet UILabel *LabelNameAge;
@property (strong, nonatomic) IBOutlet UILabel *LabelDescription;
@property (strong, nonatomic) IBOutlet UITextView *LabelJobDescription;

@property (nonatomic) NSString *Description;
@property (nonatomic) NSString *NameAge;
@property (nonatomic) NSString *JobDescription;

@property (nonatomic, strong) UIActivityIndicatorView *activity;

- (void)loadImageAndStyle : (UIImage *) imageJob;



-(void) updateUI;
@end
