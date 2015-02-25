//
//  MyJobsViewController.m
//  Cash Now
//
//  Created by amaury soviche on 10.05.14.
//  Copyright (c) 2014 Amaury Soviche. All rights reserved.
//

#import "MyJobsViewController.h"
#import "GGDraggableViewApplicants.h"
#import <Parse/Parse.h>
#import "ProfileJobApplicantViewController.h"
#import "SWRevealViewController.h"
#import "FriendsViewController.h"

@interface MyJobsViewController ()

@property (weak, nonatomic) IBOutlet UIBarButtonItem *sidebarButton;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) IBOutlet UILabel *textUI;

@property (strong, nonatomic) IBOutlet UIButton *buttonNext;
@property (strong, nonatomic) IBOutlet UIButton *buttonConversation;

@property (strong, nonatomic) IBOutlet UIButton *buttonReloadJobs;

@property(strong, nonatomic) IBOutlet UIImageView *ImageViewAccept;
@property(strong, nonatomic) IBOutlet UIImageView *ImageViewDeny;
@property (strong, nonatomic) IBOutlet UILabel *labelNoApplicant;

@end


#define STATE_LOADING 0
#define STATE_NO_APPLICANTS 1
#define STATE_RELOAD_LIST 2
#define STATE_HIDE 3

@implementation MyJobsViewController{
    NSArray *MyJobs;
    NSMutableArray *arraysOfApplicantsIDForTheJobs;
    NSMutableArray *arraysOfApplicantsForTheJob;
    
    NSMutableArray *ViewsArray;
    
    int numberApplicant;
    int numberOfTheCurrentView;
    int countApplicants;
    
    UIImageView *animationImageView ;
    
        #define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // Set the gesture
    [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    
    
    //set imagesviews for accept or deny************************************************************
    
    self.ImageViewAccept.hidden=YES;
    self.ImageViewDeny.hidden=YES;

    [self showTheGame];
}

//**************** MAKE ALL THE JOBS APPEAR ************************************

-(void)viewWillAppear:(BOOL)animated{
    
    NSLog(@"will appear");

    self.buttonNext.hidden=YES;
    self.buttonConversation.hidden=YES;
    
    self.navigationController.title = @"My posted Jobs";
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    
    
    
    self.sidebarButton.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.barTintColor = UIColorFromRGB(0x225378);
    // Set the side bar button action. When it's tapped, it'll show up the sidebar.
    _sidebarButton.target = self.revealViewController;
    _sidebarButton.action = @selector(revealToggle:);
    
    
    self.activityIndicator.color = UIColorFromRGB(0x225378);
    [self.activityIndicator startAnimating];
    
    self.labelNoApplicant.hidden = YES;
    
    if ([ViewsArray count]) {
        //OBSERVE WHEN THE VIEW IS DELETED : CALLBACK BELLOW
        for (GGDraggableViewApplicants *dragView in ViewsArray) {
            
            if ([dragView isDescendantOfView:self.view]) {
                [dragView addObserver:self forKeyPath:@"ViewDeleted" options:NSKeyValueObservingOptionNew context:nil];
                [dragView addObserver:self forKeyPath:@"LoadDetailView" options:NSKeyValueObservingOptionNew context:nil];
                [dragView addObserver:self forKeyPath:@"position" options:NSKeyValueObservingOptionNew context:nil];
            }
        }
    }
}


- (IBAction)ReloadJobs:(UIButton *)sender {
    self.buttonReloadJobs.hidden = YES;
    [self showTheGame];
}



-(void) showTheGame{
    
    arraysOfApplicantsIDForTheJobs = [[NSMutableArray alloc]init];
    ViewsArray = [[NSMutableArray alloc]init];
    
    numberApplicant = 0;
    numberOfTheCurrentView = 0;
    
    [self.activityIndicator startAnimating];
    self.activityIndicator.hidden=NO;
    self.buttonReloadJobs.hidden=YES;
    self.labelNoApplicant.hidden = YES;
    
    //takes jobs created by the user
    PFQuery *query = [PFQuery queryWithClassName:@"Job"];
    [query whereKey:@"Author" equalTo:[PFUser currentUser]];
    [query whereKey:@"isApplicantArrayEmpty" equalTo:[NSNumber numberWithBool:NO]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *MyJobsArray, NSError *error) {
        if (!error) {
            
            MyJobs = [[NSArray alloc]initWithArray:MyJobsArray];
            NSLog(@"there are %d jobs found", (int)[MyJobsArray count]);
            //count the number of applicants for total jobs
            for (PFObject *Job in MyJobs){
                countApplicants += [[[NSSet setWithArray: Job[@"ApplicantsID"]] allObjects] count]; //delete duplicates
            }
            
            if (countApplicants > 0) {
                
                //LOOP : pick up the applicants
                for (PFObject *Job in MyJobs) {
                    
                    if ( [Job[@"ApplicantsID"] count] > 0 ){
                        
                        NSArray *applicantsID = Job[@"ApplicantsID"];
                        [arraysOfApplicantsIDForTheJobs addObject:applicantsID];
                        NSArray *noDuplicatesArray = [[NSSet setWithArray: applicantsID] allObjects]; //delete duplicates
                        
                        if ([noDuplicatesArray count] == [applicantsID count]) {
                            [Job setObject:noDuplicatesArray forKey:@"ApplicantsID"];
                            [Job saveInBackground];
                        }
                        applicantsID = noDuplicatesArray;
                
                        
                        //aller chercher les user chez parse
                        for (NSString *UserId in applicantsID) {
                            
                            PFQuery *queryUser = [PFUser query];
                            [queryUser getObjectInBackgroundWithId:UserId block:^(PFObject *object, NSError *error) {
                                [self createViewsForApplicants:(PFUser*)object andJob:Job];
                                
                                if ([applicantsID indexOfObject:UserId] == [applicantsID count]-1) { //last element downloaded
                                    [self LoadingState:STATE_HIDE];
                                }
                                
                            }];
                        }
        
                    }
                }
            }
            else{
                [self LoadingState:STATE_NO_APPLICANTS];
            }
        }
    }];
}

-(void)LoadingState : (int) state{
    switch (state) {
        case STATE_LOADING:
            
            break;
        case STATE_NO_APPLICANTS:
            
            NSLog(@"no applicant for the job");
            //no jobs provided by the user = no applicants
            self.labelNoApplicant.hidden=NO;
            [self.activityIndicator stopAnimating];
            self.activityIndicator.hidden=YES;
            self.buttonReloadJobs.hidden=NO;
            self.textUI.hidden=YES;
            break;
        case STATE_RELOAD_LIST:
            
            break;
            
        case STATE_HIDE:
            [self.activityIndicator stopAnimating];
            self.activityIndicator.hidden=YES;
            self.textUI.hidden=YES;
            self.buttonReloadJobs.hidden=YES;
            self.labelNoApplicant.hidden=YES;
            break;
            
        default:
            break;
    }
}

-(void) showTheGame_save{
    
    arraysOfApplicantsIDForTheJobs = [[NSMutableArray alloc]init];
    ViewsArray = [[NSMutableArray alloc]init];
    
    numberApplicant = 0;
    numberOfTheCurrentView = 0;
    

    
    [self.activityIndicator startAnimating];
    self.activityIndicator.hidden=NO;
    self.buttonReloadJobs.hidden=YES;
    self.labelNoApplicant.hidden = YES;
    
    //takes jobs created by the user
    PFQuery *query = [PFQuery queryWithClassName:@"Job"];
    [query whereKey:@"Author" equalTo:[PFUser currentUser]];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *MyJobsArray, NSError *error) {
        if (!error) {
            if ([MyJobsArray count] > 0) {
                
                MyJobs = [[NSArray alloc]initWithArray:MyJobsArray];
                
                //count the number of applicants for total jobs
                for (PFObject *Job in MyJobs) {
                    countApplicants += [Job[@"ApplicantsID"] count];
                }
                
                numberOfTheCurrentView = 0;
                __block NSInteger compte = 0; //counts for the first jobs
                
                //LOOP : pick up the applicants
                for (PFObject *Job in MyJobs) {
                    
                    if ( [Job[@"ApplicantsID"] count] > 0 ){
                        
                        NSLog(@"a");
                        
                        NSArray *applicantsID = Job[@"ApplicantsID"];
                        [arraysOfApplicantsIDForTheJobs addObject:applicantsID];
                        
                        //aller chercher les user chez parse
                        for (NSString *UserId in applicantsID) {
                            
                            
                            //for the two first one
                            if (compte == 0) {
                    
                                PFQuery *query = [PFUser query];
                                [query getObjectInBackgroundWithId:UserId block:^(PFObject *object, NSError *error) {
                                    [self createViewsForApplicants:(PFUser*)object andJob:Job];
                                }];
                            }
                            else if (compte == 1) {
                                PFQuery *query = [PFUser query];
                                [query getObjectInBackgroundWithId:UserId block:^(PFObject *object, NSError *error) {
                                    [self createViewsForApplicants:(PFUser*)object andJob:Job];
                                }];
                                
                            }
                            else {
                                PFQuery *query = [PFUser query];
                                [query getObjectInBackgroundWithId:UserId block:^(PFObject *object, NSError *error) {
                                    [self createViewsForApplicants:(PFUser*)object andJob:Job];
                                }];
                            }
                            compte++;
                        }
                    }else{
                        NSLog(@"b");
                        //no applicants for the jobs
                        self.labelNoApplicant.hidden=NO;
                        [self.activityIndicator stopAnimating];
                        self.activityIndicator.hidden=YES;
                        self.buttonReloadJobs.hidden=NO;
                        self.textUI.hidden=YES;
                    }
                } //end of the loop ->all the views are created
                if ([ViewsArray count] > 0) {
                    
                    NSLog(@"c");
                    [self.activityIndicator stopAnimating];
                    self.activityIndicator.hidden=YES;
                    self.textUI.hidden=YES;
                    self.buttonReloadJobs.hidden=YES;
                    self.labelNoApplicant.hidden=YES;
                }
                
            }else{
                //no jobs provided by the user = no applicants
                self.labelNoApplicant.hidden=NO;
                [self.activityIndicator stopAnimating];
                self.activityIndicator.hidden=YES;
                self.buttonReloadJobs.hidden=NO;
                self.textUI.hidden=YES;
            }
        }
    }];
}

-(void)createViewsForApplicants : (PFUser *) applicant andJob : (PFObject*) Job {
    
    //we add a view for each job
    GGDraggableViewApplicants *dragView= [[GGDraggableViewApplicants alloc] initWithFrame:CGRectMake((320-280)/2, 90, 280, 463)];
    
    
    if (numberApplicant < 2) [self.view addSubview:dragView]; //LOAD ONLY THE 2 FIRST VIEWS
    
    [ViewsArray addObject:dragView];
    
    
    //OBSERVE WHEN THE VIEW IS DELETED : CALLBACK BELLOW
    [dragView addObserver:self forKeyPath:@"ViewDeleted" options:NSKeyValueObservingOptionNew context:nil];
    [dragView addObserver:self forKeyPath:@"LoadDetailView" options:NSKeyValueObservingOptionNew context:nil];
    [dragView addObserver:self forKeyPath:@"position" options:NSKeyValueObservingOptionNew context:nil];
    
    NSLog(@"le nombre de vue dans le array : %lu", (unsigned long)[ViewsArray count]);
    
    NSLog(@"NUMERO VIEW : %d", numberApplicant);
    dragView.numeroView = numberApplicant;
    
    if ( dragView.numeroView == 1 ){
        GGDraggableViewApplicants *dragCurrentView2 = [ViewsArray objectAtIndex: 0];
        [self.view bringSubviewToFront:dragCurrentView2];
        dragCurrentView2.frame = dragView.frame;
    }
    
    //REMPLIR LES INFOS DE LA VUE POUR CHAQUE USER
    
    if ( [applicant[@"About"] length] > 40) {
        dragView.Description = [[applicant[@"About"] substringToIndex:40] stringByAppendingString:@"..."];
    }else dragView.Description = applicant[@"About"] ;
    
    
    dragView.NameAge = [NSString stringWithFormat:@"%@ ", applicant[@"name"]];
    dragView.ApplicantID = applicant.objectId;
    dragView.JobsId = Job.objectId;
    dragView.JobDescription = [NSString stringWithFormat:@"%@", Job[@"Description"]];
    [dragView updateUI];
    
    //gestion des images des applicants
    if (applicant[@"Image5"]){
        
        [dragView.activity startAnimating];
        
        PFFile *userImageFile = applicant[@"Image5"];
        [userImageFile getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error) {
            if (!error) {
                
                UIImage *image = [UIImage imageWithData:imageData];
                if (image) {
                    
                    [dragView.activity stopAnimating];
                    
                    [dragView.Pictures addObject:image];
                    //placer les photos dans les vues
                    [dragView loadImageAndStyle:[UIImage imageWithData:imageData]];
                }
                else NSLog(@"erreur");
            }
        }];
    }else{
        NSLog(@"pas de photo");
        dragView.activity.hidden = YES;
    }
    
    numberApplicant++;
}

-(void) viewWillDisappear:(BOOL)animated{
    for (GGDraggableViewApplicants *dragView in ViewsArray) {
        
        @try {
            [dragView removeObserver:self forKeyPath:@"ViewDeleted"];
        }
        @catch (NSException *exception) {
            
        }
        @finally {
            
        }
        
        @try {
            [dragView removeObserver:self forKeyPath:@"LoadDetailView"];
        }
        @catch (NSException *exception) {
            
        }
        @finally {
            
        }
        
        @try {
            [dragView removeObserver:self forKeyPath:@"position"];
        }
        @catch (NSException *exception) {
            
        }
        @finally {
            
        }
    }
}
//observe when the view is deleted
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    NSLog(@"value changed");
    
    if ([keyPath isEqualToString:@"LoadDetailView"]) {
        
        NSLog(@"load view");
        GGDraggableViewApplicants *dragCurrentView = [ViewsArray objectAtIndex: numberOfTheCurrentView ];
        
        NSLog(@"numero current view : %@", dragCurrentView.ApplicantID);
        
        [self performSegueWithIdentifier:@"next" sender:dragCurrentView.ApplicantID];
        
    }else if ([keyPath isEqualToString:@"position"])
    {
        GGDraggableViewApplicants *o = object;
        int pos = o.position;
        NSLog(@"position : %d ", pos);
        
        static int factor = 2;
        
        //position < 0 : deny view
        if (pos <= 0) {
            
            self.ImageViewDeny.hidden=NO;
            [self.view bringSubviewToFront:self.ImageViewDeny];
            
            if (pos <= -150/factor) {
                self.ImageViewDeny.frame = CGRectMake(-10, _ImageViewDeny.frame.origin.y, _ImageViewDeny.frame.size.width, _ImageViewDeny.frame.size.height);
            }else{
                self.ImageViewDeny.frame = CGRectMake(-90 + factor*(-pos/150.0)*80, _ImageViewDeny.frame.origin.y, _ImageViewDeny.frame.size.width, _ImageViewDeny.frame.size.height);
            }
            
            self.ImageViewAccept.frame = CGRectMake(320, _ImageViewAccept.frame.origin.y, _ImageViewAccept.frame.size.width, _ImageViewAccept.frame.size.height);
        }
        //position >0  : accept view
       if (pos >= 0){

            self.ImageViewAccept.hidden=NO;
            [self.view bringSubviewToFront:self.ImageViewAccept];
            
            if (pos >= 150/factor) {
                self.ImageViewAccept.frame = CGRectMake(240, _ImageViewAccept.frame.origin.y, _ImageViewAccept.frame.size.width, _ImageViewAccept.frame.size.height);
            }else{
                NSLog(@"change");
                self.ImageViewAccept.frame = CGRectMake(240 + 80 - factor*(pos/150.0)*80, _ImageViewAccept.frame.origin.y, _ImageViewAccept.frame.size.width, _ImageViewAccept.frame.size.height);
            }
           
           self.ImageViewDeny.frame = CGRectMake(-80, _ImageViewDeny.frame.origin.y, _ImageViewDeny.frame.size.width, _ImageViewDeny.frame.size.height);
        }
    }
    else{
        
        //add a view
        NSLog(@"numero current view : %d", numberOfTheCurrentView);
        
        GGDraggableViewApplicants *dragCurrentView = [ViewsArray objectAtIndex: numberOfTheCurrentView ];
        [dragCurrentView removeObserver:self forKeyPath:@"ViewDeleted"];
        [dragCurrentView removeObserver:self forKeyPath:@"LoadDetailView"];
        [dragCurrentView removeObserver:self forKeyPath:@"position"];
        [dragCurrentView removeFromSuperview];
        dragCurrentView = nil;
        
        if (numberOfTheCurrentView + 1 == numberApplicant) {
            self.buttonReloadJobs.hidden=NO;
        }
        
        numberOfTheCurrentView++;
        
        if (numberOfTheCurrentView + 1 < numberApplicant) {
            
            GGDraggableViewApplicants *dragView = [ViewsArray objectAtIndex: (numberOfTheCurrentView + 1)];
            [dragView updateUI];
            [self.view addSubview:dragView];
            
            GGDraggableViewApplicants *dragCurrentView2 = [ViewsArray objectAtIndex: numberOfTheCurrentView ];
            // + load the UI
            [dragCurrentView2 updateUI];
            [self.view bringSubviewToFront:dragCurrentView2];
            
            [UIView animateWithDuration:0.1 animations:^{
                dragCurrentView2.frame = CGRectMake((320-291)/2, 80, 291, 463);
            }];
            
        }
        
        //handle the view on the side : green/red
        
        self.ImageViewDeny.frame = CGRectMake(-80, _ImageViewDeny.frame.origin.y, _ImageViewDeny.frame.size.width, _ImageViewDeny.frame.size.height);
        self.ImageViewAccept.frame = CGRectMake(320, _ImageViewAccept.frame.origin.y, _ImageViewAccept.frame.size.width, _ImageViewAccept.frame.size.height);
    }
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    NSLog(@"a");
    
    ProfileJobApplicantViewController* controller = [segue destinationViewController];
    if ([controller isKindOfClass:[ProfileJobApplicantViewController class]])
    {
        NSLog(@"b");
        controller.UserJobProvider = sender;
    }else{
        FriendsViewController *vc = [segue destinationViewController];
        vc.activateBackButton = @"YES";
    }
}

- (IBAction)goToConversation:(UIButton *)sender {
    [self performSegueWithIdentifier:@"conversationSegue" sender:self];
}


//****************************************************

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
