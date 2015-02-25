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
    
    self.ViewDeleted=NO;
    

    [self setBackgroundColor:[UIColor whiteColor]];
    
    self.Pictures = [[NSMutableArray alloc] init];
    
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
    
    self.LoadDetailView = YES;
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
    
    self.position = xDistance;
    
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
                [self Accept];
                
                [self deallocTheView];
                
            }else if (xDistance < -150){ //don't like

                [self deallocTheView];
            }
            else{//pas assez loin
                self.position=0;
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

-(void) Accept {
    //add the current user's objectID to the list of the applicants for the job
    
    
    //SEND THE PUSH NOTIFICATION ****************************
    
    //get the applicant
    PFQuery *query = [PFUser query];
    [query getObjectInBackgroundWithId:self.ApplicantID block:^(PFObject *Applicant, NSError *error) {
        
        //get the job
        PFQuery *queryJob = [PFQuery queryWithClassName:@"Job"];
        [queryJob getObjectInBackgroundWithId:self.JobsId block:^(PFObject *Job, NSError *error) {
            
            
            
            [Job[@"ApplicantsID"] removeObject:Applicant.objectId];
            [Job addObject:Applicant.objectId forKey:@"acceptedApplicants"];
            [Job saveEventually];
            
            
            // Create our Installation query
            PFQuery *pushQuery = [PFInstallation query];
            [pushQuery whereKey:@"user" equalTo:Applicant];
            [pushQuery whereKey:@"active" equalTo:[NSNumber numberWithBool:YES]];
            
            NSLog(@"query desc : %@", [pushQuery description]);
            
            NSDictionary *dataPush = [NSDictionary dictionaryWithObjectsAndKeys:
                                      @"You have been accepted for a job !", @"alert",
                                      @"Increment", @"badge",
                                      @"a",@"notifMessage",
                                      nil];
            
            
            // Send push notification to query
            PFPush *push = [[PFPush alloc] init];
            [push setQuery:pushQuery];
            [push setData:dataPush];
            [push sendPushInBackground];
            
            
            //save new message to DB *******************************
            
            PFObject *NewMessageForNewConversation = [PFObject objectWithClassName:@"Messages"];
            NewMessageForNewConversation[@"recipientIds"] = self.ApplicantID;
            NewMessageForNewConversation[@"senderIds"] = [PFUser currentUser].objectId;
            NewMessageForNewConversation[@"Content"] = [NSString stringWithFormat:@"new conversation between %@ and %@", self.ApplicantID , [PFUser currentUser].objectId];
            NewMessageForNewConversation[@"JobId"] = self.JobsId;
            NewMessageForNewConversation[@"seen"] = @"NO"; //set seen to FALSE
            
            [NewMessageForNewConversation saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                
                NSDictionary *FirstMessage = [[NSDictionary alloc] initWithObjectsAndKeys:@"First Message For conversation", @"Content" ,
                                              (NSDate *)[NSDate date], @"Date",
                                              @"YES", @"FromMe",
                                              NewMessageForNewConversation.objectId ,@"MessageID", nil];
                [self createConversation:[NSString stringWithFormat:@"%@ %@ %@ %@", self.JobsId, self.ApplicantID, @"MyJob:YES", Job[@"Description"]] andFirstMessage:FirstMessage];
                
                //store the image
                PFFile *ImageFile = Job[@"Picture"];
                [ImageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                    if (!error) {
                        
                        UIImage *image = [UIImage imageWithData:data];
                        NSData *compressedImage = UIImageJPEGRepresentation(image, 0.5);
                        
                        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                        NSString *documentsDirectory = [paths objectAtIndex:0];
                        NSString *imagePath =[documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png",Job.objectId]];
                        
                        if (![data writeToFile:imagePath atomically:NO])
                        {
                            NSLog((@"Failed to cache image data to disk"));
                            
                        }
                        else
                        {
                            NSLog(@"the cachedImagedPath is %@",compressedImage);
                            [[NSUserDefaults standardUserDefaults] setObject:compressedImage forKey: Job.objectId];
                            [[NSUserDefaults standardUserDefaults] synchronize];
                        }
                        
                    }
                }];
            }];
        }];
    }];
}


-(void) Accept_save {
    //add the current user's objectID to the list of the applicants for the job
    //    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    
    //SEND THE PUSH NOTIFICATION ****************************
    
    //get the applicant
    PFQuery *query = [PFUser query];

    PFUser *Applicant = (PFUser *)[query getObjectWithId:self.ApplicantID];
    //get the job
    PFQuery *queryJob = [PFQuery queryWithClassName:@"Job"];
    PFObject *Job = [queryJob getObjectWithId:self.JobsId];
    [Job[@"ApplicantsID"] removeObject:Applicant.objectId];
    [Job addObject:Applicant.objectId forKey:@"acceptedApplicants"];
    [Job saveEventually];
    
    
    // Create our Installation query
    PFQuery *pushQuery = [PFInstallation query];
    [pushQuery whereKey:@"user" equalTo:Applicant];
    [pushQuery whereKey:@"active" equalTo:[NSNumber numberWithBool:YES]];
    
    NSLog(@"query desc : %@", [pushQuery description]);
    
    NSDictionary *dataPush = [NSDictionary dictionaryWithObjectsAndKeys:
                              @"You have been accepted for a job !", @"alert",
                              @"Increment", @"badge",
                              @"a",@"notifMessage",
                              nil];
    
    
    // Send push notification to query
    PFPush *push = [[PFPush alloc] init];
    [push setQuery:pushQuery];
    [push setData:dataPush];
    [push sendPushInBackground];
    
    
    //save new message to DB *******************************
    
    PFObject *NewMessageForNewConversation = [PFObject objectWithClassName:@"Messages"];
    NewMessageForNewConversation[@"recipientIds"] = self.ApplicantID;
    NewMessageForNewConversation[@"senderIds"] = [PFUser currentUser].objectId;
    NewMessageForNewConversation[@"Content"] = [NSString stringWithFormat:@"new conversation between %@ and %@", self.ApplicantID , [PFUser currentUser].objectId];
    NewMessageForNewConversation[@"JobId"] = self.JobsId;
    NewMessageForNewConversation[@"seen"] = @"NO"; //set seen to FALSE
    
    [NewMessageForNewConversation saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        
        NSDictionary *FirstMessage = [[NSDictionary alloc] initWithObjectsAndKeys:@"First Message For conversation", @"Content" ,
                                      (NSDate *)[NSDate date], @"Date",
                                      @"YES", @"FromMe",
                                      NewMessageForNewConversation.objectId ,@"MessageID", nil];
        [self createConversation:[NSString stringWithFormat:@"%@ %@ %@ %@", self.JobsId, self.ApplicantID, @"MyJob:YES", Job[@"Description"]] andFirstMessage:FirstMessage];
        //      [self createConversation:[NSString stringWithFormat:@"%@ %@ %@", self.JobsId, self.ApplicantID,  Job[@"Description"]] andFirstMessage:FirstMessage]; // modified
        
        
        //store the image
        PFFile *ImageFile = Job[@"Picture"];
        [ImageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            if (!error) {
                
                NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                NSString *documentsDirectory = [paths objectAtIndex:0];
                NSString *imagePath =[documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png",Job.objectId]];
                
                if (![data writeToFile:imagePath atomically:NO])
                {
                    NSLog((@"Failed to cache image data to disk"));
                    
                }
                else
                {
                    NSLog(@"the cachedImagedPath is %@",data);
                    [[NSUserDefaults standardUserDefaults] setObject:imagePath forKey: Job.objectId];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                }
                
            }
        }];
    }];
    
    
    //    });
    
    
}


-(void) updateUI{
    self.LabelDescription.text = self.Description;
    self.LabelNameAge.text = self.NameAge;
    self.LabelJobDescription.text = self.JobDescription;
    
    NSLog(@"update ui : %@", self.LabelDescription.text);
}


-(void) createConversation : (NSString *) KeyForConversation andFirstMessage:(NSDictionary*)FirstMessageDescription{
    
    NSError *error;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); //1
    NSString *documentsDirectory = [paths objectAtIndex:0]; //2
    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"Conversations.plist"]; //3
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if (![fileManager fileExistsAtPath: path]) //4
    {
        NSLog(@"file does not exist");
        NSString *bundle = [[NSBundle mainBundle] pathForResource:@"Conversations" ofType:@"plist"]; //5
        [fileManager copyItemAtPath:bundle toPath: path error:&error]; //6
    }
    
    //all the stuff in the plist file
    NSMutableDictionary *data = [[NSMutableDictionary alloc] initWithContentsOfFile: path];
    NSLog(@"description plist before  : %@", [data description]);
    
    
    if ( ![data objectForKey:KeyForConversation]) { //no conversation yet : create one
        NSLog(@"create new conv");
        //initiate the conversation :

//        //create dictionary to order jobs ( last massage date + BOOL seen )  //careful for date *******************************************************
//        NSDictionary *JobState = [NSDictionary dictionaryWithObjectsAndKeys:[NSDate date], @"LastUpdate", @"NO", @"Seen" , nil]; //modif conv
//        NSArray *array = [[NSArray alloc] initWithObjects: FirstMessageDescription , nil];
//        
//        NSDictionary *StateAndMessagesDic =[NSDictionary dictionaryWithObjectsAndKeys:JobState, @"JobState",array, @"ArrayMessages" , nil];
//        
//        
//        //        [data setObject:array forKey:KeyForConversation];
//        [data setObject:StateAndMessagesDic forKey:KeyForConversation];
//        
//        
//        
//        if([data writeToFile:path atomically:YES])
//        {
//            NSLog(@"saved to plist");
//        }

        PFQuery *query = [PFUser query];
        NSString *otherUserName = [[[[KeyForConversation componentsSeparatedByString:@" "] objectAtIndex:1] componentsSeparatedByString:@" "]objectAtIndex:0];
        
        [query getObjectInBackgroundWithId:otherUserName block:^(PFObject *user, NSError *error) {
            
            //create dictionary to order jobs ( last massage date + BOOL seen )  //careful for date *******************************************************
            NSDictionary *JobState = [NSDictionary dictionaryWithObjectsAndKeys:[NSDate date], @"LastUpdate", @"NO", @"Seen" ,user[@"name"], @"otherUserName", nil]; //modif conv
            NSArray *array = [[NSArray alloc] initWithObjects: FirstMessageDescription , nil];
            
            NSDictionary *StateAndMessagesDic =[NSDictionary dictionaryWithObjectsAndKeys:JobState, @"JobState",array, @"ArrayMessages" , nil];
            
            
            //        [data setObject:array forKey:KeyForConversation];
            [data setObject:StateAndMessagesDic forKey:KeyForConversation];
            
            
            if([data writeToFile:path atomically:YES])
            {
                NSLog(@"saved to plist");
            }
            
            
        }];
    }
    
//    if ( ![data objectForKey:KeyForConversation]) { //no conversation yet : create one
//        NSLog(@"create new conv");
//        //initiate the conversation :
//        NSArray *array = [[NSArray alloc] initWithObjects: FirstMessageDescription ,nil];
//        [data setObject:array forKey:KeyForConversation];
//        if([data writeToFile:path atomically:YES])
//        {
//            NSLog(@"saved to plist");
//        }
//    }
    
    NSLog(@"description plist after : %@", [data description]);

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
    NSLog(@"numero de la vue deleted : %d",self.numeroView);
    
    self.ViewDeleted = YES; //CALL THE OBSERVER
    
    [self removeGestureRecognizer:self.panGestureRecognizer];
    
    
    
    //OBJECT REMOVED IN THE OBSERVER CALLBACK
}

@end
