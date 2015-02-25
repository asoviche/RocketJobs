//
//  ViewController.m
//  Cash Now
//
//  Created by amaury soviche on 06.05.14.
//  Copyright (c) 2014 Amaury Soviche. All rights reserved.
//

#import "ViewController.h"
#import <ParseFacebookUtils/PFFacebookUtils.h>
#import "UserDetailsViewController.h"

#import "SWRevealViewController.h"
#import "ProfileJobsProviderViewController.h"
#import "ProfileJobApplicantViewController.h"
#import "GGDraggableView.h"
#import "FriendsViewController.h"
#import "NSDate+Calculations.h"


@interface ViewController ()


@property (nonatomic, strong) UIPanGestureRecognizer *panGestureRecognizer;

@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) IBOutlet UILabel *textUI;

@property (strong, nonatomic) IBOutlet UIButton *buttonNext;
@property (strong, nonatomic) IBOutlet UIButton *buttonConversation;
@property (strong, nonatomic) IBOutlet UIButton *buttonReloadJobs;

@property(strong, nonatomic) IBOutlet UIImageView *ImageViewAccept;
@property(strong, nonatomic) IBOutlet UIImageView *ImageViewDeny;
@property (strong, nonatomic) IBOutlet UILabel *labelNoJobs;

@property (strong, nonatomic) IBOutlet UIBarButtonItem *barButtonConversation;

@property (strong, nonatomic) FirstTimePhoneNumberView *firstTimePhoneNumberView;

@end


@implementation ViewController{
    PFLogInViewController *logInViewController;

    NSArray *MyJobs;
    NSMutableArray *arraysOfApplicantsIDForTheJobs;
    NSMutableArray *arraysOfApplicantsForTheJob;
    
    NSMutableArray *ViewsArray;
    
    int numberOfTheCurrentView;
    
    int countApplicants;
    
    UIImageView *animationImageView ;
    
    NSArray *JobsArray;
    __block int countAllJobs;
    NSMutableArray *JobsPicturesArray;
    
    NSString *dateString;
    NSString *Description;
    NSString *Hour;
    NSString *Price;
    NSString *JobID;

    
    #define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
}



- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSLog(@"viewDidLoad");
    
    self.activityIndicator.hidden=YES;
    [self.activityIndicator startAnimating];
    self.activityIndicator.color = UIColorFromRGB(0x225378);
    
    self.buttonNext.hidden=YES;
    self.buttonConversation.hidden=YES;
    self.labelNoJobs.hidden=YES;
    self.buttonReloadJobs.hidden = YES;
    
    self.ImageViewAccept.hidden=YES;
    self.ImageViewDeny.hidden=YES;
    
    //save the model of the device
    NSString *device=[UIDevice currentDevice].model;
    [[NSUserDefaults standardUserDefaults] setObject:device forKey:@"device"];
    
    self.labelNoJobs.font = [UIFont fontWithName:@"OpenSans-Light" size:16];
    
    self.textUI.font = [UIFont fontWithName:@"OpenSans-Light" size:16];

    [self showTheGameHAHA];
    
}



-(void)viewWillAppear:(BOOL)animated{
    
    NSLog(@"viewWillAppear");
    
    // Do any additional setup after loading the view, typically from a nib.
    [self.navigationController setNavigationBarHidden:NO];
    

    
    self.sidebarButton.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.barTintColor = UIColorFromRGB(0x225378);
    // self.navigationController.navigationBar.translucent=NO;
    
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    [self.view setBackgroundColor:[UIColor colorWithRed:0.89 green:0.89 blue:0.89 alpha:1]];


    // Set the side bar button action. When it's tapped, it'll show up the sidebar.
    _sidebarButton.target = self.revealViewController;
    _sidebarButton.action = @selector(revealToggle:);
    
    // Set the gesture
    [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    

    //OBSERVE WHEN THE VIEW IS DELETED : CALLBACK BELLOW
    for (GGDraggableView *dragView in ViewsArray) {
        
        if ([dragView isDescendantOfView:self.view]) {
            
            [dragView addObserver:self forKeyPath:@"ViewDeleted" options:NSKeyValueObservingOptionNew context:nil];
            [dragView addObserver:self forKeyPath:@"LoadDetailView" options:NSKeyValueObservingOptionNew context:nil];
            [dragView addObserver:self forKeyPath:@"position" options:NSKeyValueObservingOptionNew context:nil];
        }
    }
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults addObserver:self
               forKeyPath:@"ListConversationsHaveToBeUpdated"
                  options:NSKeyValueObservingOptionNew
                  context:NULL];
    
    self.firstTimePhoneNumberView = [[FirstTimePhoneNumberView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    self.firstTimePhoneNumberView.delegate = self;
    [self.view addSubview:self.firstTimePhoneNumberView];
    self.firstTimePhoneNumberView.center = self.view.center;
    CGRect framePhoneView = self.firstTimePhoneNumberView.frame;
    framePhoneView.origin.y = -self.firstTimePhoneNumberView.frame.size.height;
    self.firstTimePhoneNumberView.frame = framePhoneView;
}

#pragma mark - firstTimePhoneNumberView delegate

-(void) FirstTimePhoneNumberDelegate_canceled{
    CGRect frame = self.firstTimePhoneNumberView.frame;
    frame.origin.y = -self.firstTimePhoneNumberView.frame.size.height;
    [UIView animateWithDuration:0.2 animations:^{
        self.firstTimePhoneNumberView.frame = frame;
    }];
}

-(void) FirstTimePhoneNumberDelegate_saved{
    CGRect frame = self.firstTimePhoneNumberView.frame;
    frame.origin.y = -self.firstTimePhoneNumberView.frame.size.height;
    [UIView animateWithDuration:0.2 animations:^{
        self.firstTimePhoneNumberView.frame = frame;
    } completion:^(BOOL finished) {
        
    }];
    
    //save phone number in parse
    [PFUser currentUser][@"phoneNumber"] = [[NSUserDefaults standardUserDefaults] objectForKey:@"phoneNumber"];
    [[PFUser currentUser] saveEventually];
}

#pragma mark -

-(void) viewWillDisappear:(BOOL)animated{
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObserver:self forKeyPath:@"ListConversationsHaveToBeUpdated"];
    
    for (GGDraggableView *dragView in ViewsArray) {
        
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


#pragma mark to be ordered

-(BOOL) areJobsSeen{

    NSError *error;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); //1
    NSString *documentsDirectory = [paths objectAtIndex:0]; //2
    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"Conversations.plist"]; //3
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if (![fileManager fileExistsAtPath: path]) //4
    {
        NSString *bundle = [[NSBundle mainBundle] pathForResource:@"Conversations" ofType:@"plist"]; //5
        [fileManager copyItemAtPath:bundle toPath: path error:&error]; //6
    }
    
    NSMutableDictionary *savedStock = [[NSMutableDictionary alloc] initWithContentsOfFile: path];
    NSLog(@"STATE BASE : %@", [[savedStock allKeys] description]);
    
    for (NSString *key in [savedStock allKeys]) {
        
        NSDictionary * dicJob = [savedStock objectForKey:key];
        if ([[[dicJob objectForKey:@"JobState"] objectForKey:@"Seen" ] isEqualToString:@"NO"]) {
            
            return NO;
        }
    }
    
    return YES;
}

-(void) showTheGameHAHA{
    
    numberOfTheCurrentView = 0;

    countAllJobs=0;
    JobsPicturesArray = [[NSMutableArray alloc]init];
    ViewsArray = [[NSMutableArray alloc]init];
    
    self.buttonReloadJobs.hidden = YES;
    self.activityIndicator.hidden=NO;
    
    NSLog(@"salut");
    // User's location
    [PFGeoPoint geoPointForCurrentLocationInBackground:^(PFGeoPoint *userGeoPoint, NSError *error) {
        if (!error) {
            
            PFQuery *query = [PFQuery queryWithClassName:@"Job"];
        
            NSLog(@"il y a tant de jobs %d",countAllJobs);
            
            //search for the prefered distance for the job area
            int distance = (int)[[[NSUserDefaults standardUserDefaults]stringForKey:@"distanceForSearch"] integerValue] ;
            NSLog(@"date today : %@", [NSDate date]);
            
            [query whereKey:@"Location" nearGeoPoint:userGeoPoint withinKilometers:distance];
            [query whereKey:@"Author" notEqualTo:[PFUser currentUser]]; // remove own jobs

            NSDateComponents* components = [[NSCalendar currentCalendar] components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit
                                                         fromDate:[NSDate date]];
            
            NSDate *currentDate = [NSDate dateWithYear:(int)[components year] month:(int)[components month] day:(int)[components day] hour:(int)[components hour] minute:(int)[components minute] second:0];
            
            NSLog(@"date now now now : %@", currentDate);
            
            [query whereKey:@"DateJob" greaterThan:currentDate];
            NSLog(@"description query : %@",[query description]);
            [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                if (!error) {
                    if ([objects count] != 0) {
                        
                        //ON A TOUS LES OBJETS
                        JobsArray = objects;
                        NSLog(@"desc distance des jobs : %@",[JobsArray description]);
                        
                        
                        //sort the array by date !
//                        NSSortDescriptor *sortByDate = [NSSortDescriptor sortDescriptorWithKey:@"DateJob"
//                                                                                     ascending:NO];
//                        NSArray *sortDescriptors = [NSArray arrayWithObject:sortByDate];
//                        NSLog(@"desc du sort : %@", [sortByDate description]);
//                        
//                        JobsArray = [JobsArray sortedArrayUsingDescriptors:sortDescriptors];
                        
                        
                        //CREATION DES DRAG VIEW POUR LES JOBS
                        [self createViewsForJobs];
                        
                    }else{                              //NO JOBS
                        NSLog(@"no jobs");
                        [self.activityIndicator stopAnimating];
                        self.activityIndicator.hidden=YES;
                        self.textUI.hidden=YES;
                        self.labelNoJobs.hidden=NO;
                        self.buttonReloadJobs.hidden = NO;
                        return;
                    }
                }
            }];
            
        }else {
            
            NSLog(@"erreur geolocalisation ");
            [self.activityIndicator stopAnimating];
            self.activityIndicator.hidden=YES;
            self.textUI.text=@"erreur geolocalisation";
            self.buttonReloadJobs.hidden = NO;
        }
    }];
    
}


- (IBAction)ReloadJobs:(UIButton *)sender {
    
    self.buttonReloadJobs.hidden = YES;
    
    [self.activityIndicator startAnimating];
    self.activityIndicator.hidden=NO;
    self.labelNoJobs.hidden=YES;
    self.textUI.hidden=NO;
    
    [self showTheGameHAHA];
}



//**************** MAKE ALL THE JOBS APPEAR ************************************

-(void)createViewsForJobs{
    //handle all the views for the jobs
    
    int numberOfTheJob = 0 ;
    
    for (int i = 0; i < [JobsArray count]  ; i++) {
        
        //fill the view information
        PFObject *JobOnTop = [JobsArray objectAtIndex:i];
        NSArray *applicantsArray = JobOnTop[@"ApplicantsID"];
        NSArray *acceptedApplicants = JobOnTop[@"acceptedApplicants"];
        
        NSLog(@"a");
        
        //check if the user has already applied or is accepted for the job
        if ( !([applicantsArray containsObject:[PFUser currentUser].objectId] ||
               [acceptedApplicants containsObject:[PFUser currentUser].objectId] )) {
            
            
            Description = JobOnTop[@"Description"];
            Hour = JobOnTop[@"Hour"];
            Price = JobOnTop[@"Price"];
            JobID = [JobOnTop objectId];
            
            
            //we add a view for each job
            GGDraggableView *dragView= [[GGDraggableView alloc] initWithFrame:CGRectMake((320-280)/2, 90, 280, 463)];
            
            if (numberOfTheJob == 0) {
                dragView.frame = CGRectMake((320-280)/2, 80, 280, 463);
            }
            
            if( numberOfTheJob < 2 ) {
                
                [self.view addSubview:dragView]; //print only 2 jobs
                
            }
            [ViewsArray addObject:dragView];
            
            dragView.numeroView = numberOfTheJob;
            
            
            
            
            if (JobOnTop[@"DateJob"]) {
                
                
                NSDate *todayDate = [NSDate date];
                
                NSDate *tomorrow = [[NSDate alloc] init];
                tomorrow = [[NSDate date] tomorrow];
                
                NSCalendar* calendar = [NSCalendar currentCalendar];
                
                NSDateComponents* TodayComponents = [calendar components:(NSEraCalendarUnit|NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit) fromDate:todayDate] ;
                [TodayComponents setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
                
                
                NSDateComponents* TomorrowComponents = [calendar components:(NSEraCalendarUnit|NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit) fromDate:tomorrow];
                [TomorrowComponents setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
                
                
                NSString *dateJobString = [JobOnTop[@"DateJob"] description];
                NSString *firstPart = [[dateJobString componentsSeparatedByString:@"-"] objectAtIndex:2];
                NSString *dayString = [[firstPart componentsSeparatedByString:@" "] objectAtIndex:0];
                
                
                int dayToday = (int) [TodayComponents day];
                NSInteger dayJob = [dayString intValue];
                int dayTomorrow =(int) [TomorrowComponents day] ;
                
                
                if (dayJob == dayToday) {
                    NSLog(@"today 1234");
                    dateString = @"Today";
                    
                }else if (dayJob == dayTomorrow){
                    NSLog(@"tomorrow 1234");
                    dateString = @"Tomorrow";
                }else{
                    dateString = @"past";
                }
                
            }
            else{
                dateString = @"no date";
            }
            
            
            
            //distance to the user
            if (JobOnTop[@"Location"]) {
                
                [PFGeoPoint geoPointForCurrentLocationInBackground:^(PFGeoPoint *geoPoint, NSError *error) {
                    float distanceToJob = [geoPoint distanceInKilometersTo:JobOnTop[@"Location"]];
                    if (distanceToJob < 0.1) {
                        dragView.DistanceToUser.text = @"100 m";
                    }else{
                        dragView.DistanceToUser.text = [NSString stringWithFormat:@"%0.1f km", distanceToJob];
                    }
                }];
            }
            
            //gestion des images des jobs
            if (JobOnTop[@"Picture"]) {
                
                [dragView.activity startAnimating];
                
                PFFile *userImageFile = JobOnTop[@"Picture"];
                
                [userImageFile getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error) {
                    if (!error) {
                        UIImage *image = [UIImage imageWithData:imageData];
                        [dragView.activity stopAnimating];
                        if (image) {
                            
                            [JobsPicturesArray addObject:image];
                            //placer les photos dans les vues
                            [dragView loadImageAndStyle:[UIImage imageWithData:imageData]];
                        }
                        else{
                            //error : load rand image
                            [dragView loadImageAndStyle:[UIImage imageNamed:[@"rand_picture_" stringByAppendingString:[NSString stringWithFormat:@"%d", arc4random()%5]]]];
                        }
                    }
                }];
            }else{
                //no image : load rand image
                [dragView loadImageAndStyle:[UIImage imageNamed:[@"rand_picture_" stringByAppendingString:[NSString stringWithFormat:@"%d", arc4random()%5]]]];
            }
            
            
            
            //OBSERVE WHEN THE VIEW IS DELETED : CALLBACK BELLOW
            [dragView addObserver:self forKeyPath:@"ViewDeleted" options:NSKeyValueObservingOptionNew context:nil];
            [dragView addObserver:self forKeyPath:@"LoadDetailView" options:NSKeyValueObservingOptionNew context:nil];
            [dragView addObserver:self forKeyPath:@"position" options:NSKeyValueObservingOptionNew context:nil];
            
            dragView.LabelDescriptionJob.text =Description;
            dragView.LabelDateJob.text =dateString;
            dragView.LabelPriceJob.text =[NSString stringWithFormat:@"%@/h", Price];
            dragView.LabelHourJob.text =Hour;
            dragView.JobID = JobID;
            
            numberOfTheJob++;
            countAllJobs++;
            
        }
        
        
    }
    if ([ViewsArray count]) { // there are jobs
        GGDraggableView *dragCurrentView2 = [ViewsArray objectAtIndex: 0];
        [self.view bringSubviewToFront:dragCurrentView2];
    }else{ //no jobs
        self.buttonReloadJobs.hidden=NO;
        self.labelNoJobs.hidden=NO;
    }
    
    [self.activityIndicator stopAnimating];
    self.activityIndicator.hidden=YES;
    self.textUI.hidden=YES;
    
}

-(void)createViewsForJobs_save{
    //handle all the views for the jobs
    for (int i = 0; i < [JobsArray count]  ; i++) {
        
        //we add a view for each job
        GGDraggableView *dragView= [[GGDraggableView alloc] init];
        dragView.frame = CGRectMake((320-291)/2, 90, 291, 463);
        
        if (i==0) {
            dragView.frame = CGRectMake((320-291)/2, 80, 291, 463);
        }
        
        if( i < 2 ) {
            
            [self.view addSubview:dragView]; //print only 2 jobs
            
        }
        [ViewsArray addObject:dragView];
        
        dragView.numeroView = i;
        
        //fill the view information
        PFObject *JobOnTop = [JobsArray objectAtIndex:i];
        Description = JobOnTop[@"Description"];
        Hour = JobOnTop[@"Hour"];
        Price = JobOnTop[@"Price"];
        JobID = [JobOnTop objectId];
        
        
        if (JobOnTop[@"DateJob"]) {
            
            
            NSDate *todayDate = [NSDate date];
            
            NSDate *tomorrow = [[NSDate alloc] init];
            tomorrow = [[NSDate date] tomorrow];
            
            NSCalendar* calendar = [NSCalendar currentCalendar];
            
            NSDateComponents* TodayComponents = [calendar components:(NSEraCalendarUnit|NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit) fromDate:todayDate] ;
            [TodayComponents setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
            
            
            NSDateComponents* TomorrowComponents = [calendar components:(NSEraCalendarUnit|NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit) fromDate:tomorrow];
            [TomorrowComponents setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
            
            
            NSString *dateJobString = [JobOnTop[@"DateJob"] description];
            NSString *firstPart = [[dateJobString componentsSeparatedByString:@"-"] objectAtIndex:2];
            NSString *dayString = [[firstPart componentsSeparatedByString:@" "] objectAtIndex:0];
            
            
            int dayToday = (int) [TodayComponents day];
            NSInteger dayJob = [dayString intValue];
            int dayTomorrow =(int) [TomorrowComponents day] ;
            
            
            if (dayJob == dayToday) {
                NSLog(@"today 1234");
                dateString = @"Today";
                
            }else if (dayJob == dayTomorrow){
                NSLog(@"tomorrow 1234");
                dateString = @"Tomorrow";
            }else{
                dateString = @"past";
            }
            
        }
        else{
            dateString = @"no date";
        }
        
        
        //distance to the user
        if (JobOnTop[@"Location"]) {
            
            [PFGeoPoint geoPointForCurrentLocationInBackground:^(PFGeoPoint *geoPoint, NSError *error) {
                float distanceToJob = [geoPoint distanceInKilometersTo:JobOnTop[@"Location"]];
                dragView.DistanceToUser.text = [NSString stringWithFormat:@"%0.3f km", distanceToJob];
            }];
        }
        
        //gestion des images des jobs
        if (JobOnTop[@"Picture"]) {
            
            PFFile *userImageFile = JobOnTop[@"Picture"];
            
            [userImageFile getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error) {
                if (!error) {
                    UIImage *image = [UIImage imageWithData:imageData];
                    if (image) {
                        
                        [JobsPicturesArray addObject:image];
                        //placer les photos dans les vues
                        [dragView loadImageAndStyle:[UIImage imageWithData:imageData]];
                    }
                    else{
                        //error : load rand image
                        [dragView loadImageAndStyle:[UIImage imageNamed:[@"rand_picture_" stringByAppendingString:[NSString stringWithFormat:@"%d", arc4random()%5]]]];
                    }
                }
            }];
        }else{
            //no image : load rand image
            [dragView loadImageAndStyle:[UIImage imageNamed:[@"rand_picture_" stringByAppendingString:[NSString stringWithFormat:@"%d", arc4random()%5]]]];
        }
        

        
            //OBSERVE WHEN THE VIEW IS DELETED : CALLBACK BELLOW
            [dragView addObserver:self forKeyPath:@"ViewDeleted" options:NSKeyValueObservingOptionNew context:nil];
            [dragView addObserver:self forKeyPath:@"LoadDetailView" options:NSKeyValueObservingOptionNew context:nil];
            [dragView addObserver:self forKeyPath:@"position" options:NSKeyValueObservingOptionNew context:nil];
            
            dragView.LabelDescriptionJob.text =Description;
            dragView.LabelDateJob.text =dateString;
            dragView.LabelPriceJob.text =[NSString stringWithFormat:@"%@/h", Price];
            dragView.LabelHourJob.text =Hour;
            dragView.JobID = JobID;
            
        
    }
    GGDraggableView *dragCurrentView2 = [ViewsArray objectAtIndex: 0];
    [self.view bringSubviewToFront:dragCurrentView2];
    
    [self.activityIndicator stopAnimating];
    self.activityIndicator.hidden=YES;
    self.textUI.hidden=YES;
}

#pragma mark KVO

//observe when the view is deleted
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    NSLog(@"value changed");
    
    
    if ([keyPath isEqualToString:@"LoadDetailView"]) {
        
        PFObject *job = JobsArray[numberOfTheCurrentView];
        PFUser *user = job[@"Author"];
        
        //load the detail view of the profile

        [self performSegueWithIdentifier:@"next" sender:user];
        
    }
    else if ([keyPath isEqualToString:@"position"])
    {
        
        GGDraggableView *o = object;
        int pos = o.position;
        
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
    }else if ([keyPath isEqualToString:@"positionView"]){
        NSLog(@"position view changed for : %d",self.revealViewController.positionView);
        
        if (self.revealViewController.positionView == 3) { //revealview active
            for (GGDraggableView *dragView in ViewsArray) {
                [dragView setUserInteractionEnabled:NO];
            }
        }else if (self.revealViewController.positionView == 4){
            for (GGDraggableView *dragView in ViewsArray) {//revealview inactive
                [dragView setUserInteractionEnabled:YES];
            }
        }
    }
    else if ([keyPath isEqualToString:@"ListConversationsHaveToBeUpdated"]) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            if ([self areJobsSeen] == NO) {
                NSLog(@"place image for non seen jobs");
                dispatch_async(dispatch_get_main_queue(), ^{
//                  self.barButtonConversation.image = [UIImage imageNamed:@""];
                });
            }else{
                NSLog(@"place image for seen jobs");
                dispatch_async(dispatch_get_main_queue(), ^{
//                  self.barButtonConversation.image = [UIImage imageNamed:@""];
                });
            }
        });
    }
    else{
        //add a view
        NSLog(@"numero current view : %d", numberOfTheCurrentView);
        
        GGDraggableView *dragCurrentView = [ViewsArray objectAtIndex: numberOfTheCurrentView ];
        NSLog(@"description of the array : %@", [ViewsArray description]);
        [dragCurrentView removeObserver:self forKeyPath:@"ViewDeleted"];
        [dragCurrentView removeObserver:self forKeyPath:@"LoadDetailView"];
        [dragCurrentView removeObserver:self forKeyPath:@"position"];
        [dragCurrentView removeFromSuperview];
        dragCurrentView=nil;
        
        if (numberOfTheCurrentView + 1 == countAllJobs) {
            self.buttonReloadJobs.hidden = NO;
            self.buttonReloadJobs.hidden=NO;
        }
        
        numberOfTheCurrentView++;
        
        if (numberOfTheCurrentView + 1 < countAllJobs ) { //countalljobs - 1 : array begins at 0 !
            NSLog(@"nb all jobs : %d", countAllJobs);
            
            GGDraggableView *dragView = [ViewsArray objectAtIndex: (numberOfTheCurrentView + 1)];
            [self.view addSubview:dragView];
            
            GGDraggableView *dragCurrentView2 = [ViewsArray objectAtIndex: numberOfTheCurrentView ];
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

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(PFUser*)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    UIViewController* controllerSegue = [segue destinationViewController] ;
    //ProfileJobsProviderViewController* controller = [segue destinationViewController] ;
    
    if ([controllerSegue isKindOfClass:[ProfileJobApplicantViewController class]])
    {
        ProfileJobApplicantViewController* controller = [segue destinationViewController] ;
        controller.UserJobProvider = sender.objectId;

    }else {
        NSLog(@"conv");
        
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

@end
