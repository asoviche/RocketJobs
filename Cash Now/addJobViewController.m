//
//  addJobViewController.m
//  Cash Now
//
//  Created by amaury soviche on 06.05.14.
//  Copyright (c) 2014 Amaury Soviche. All rights reserved.
//

#import "addJobViewController.h"
#import <Parse/Parse.h>

#import "SWRevealViewController.h"

#import "ASProgressPopUpView.h"

#import "AMSmoothAlertView.h"
#import "MyAnnotation.h"
#import "NSDate+Calculations.h"

#import "MyJobsViewController.h"
#import "MyPostedJobsViewController.h"

@interface addJobViewController ()
@property (strong, nonatomic) IBOutlet UIButton *buttonCamera;
@property (strong, nonatomic) IBOutlet UITextView *JobDesription;
@property (strong, nonatomic) IBOutlet UISegmentedControl *JobDate;
@property (strong, nonatomic) IBOutlet UISlider *jobPriceSlider;
@property (strong, nonatomic) IBOutlet UILabel *jobPriceLabel;
@property (strong, nonatomic) IBOutlet UILabel *jobTimeLabel;
@property (strong, nonatomic) IBOutlet UISlider *JobTimeSlider;
@property (strong, nonatomic) IBOutlet UIButton *jobLocationButton;
@property (strong, nonatomic) IBOutlet UILabel *labelInfoSnap;

@property (strong, nonatomic) IBOutlet UITextField *jobTitle;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *sidebarButton;

@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@property (strong, nonatomic) IBOutlet UIImageView *ImageViewJob;

@property (strong, nonatomic) IBOutlet ASProgressPopUpView *progressView;

@property (strong, nonatomic) IBOutlet UIImageView *imageViewJobPicture;


@property (strong, nonatomic) IBOutlet UIBarButtonItem *buttonPost;


//****
@property (strong, nonatomic) MapView* mapViewCustom;
//

@property (strong, nonatomic) IBOutlet UIButton *buttonOtherLocation;
@property (strong, nonatomic) IBOutlet UIButton *buttonCurrentLocation;


@property (strong, nonatomic) IBOutlet UILabel *labelCountDescription;


@end

@implementation addJobViewController{
    NSString *date;
    NSString *price;
    NSString *hour;
    UIImage *picture_camera;
    UIImage *picture_camera_small;
    
    int sliderHour;
    int sliderMinute;
    
    MyAnnotation *annotationForMap;
    
    NSString *currency;
    
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

-(void) viewWillAppear:(BOOL)animated{
    self.navigationController.navigationBar.barTintColor = UIColorFromRGB(0x225378);
    
    self.JobDesription.textColor =  UIColorFromRGB(0x225378);
    
    self.imageViewJobPicture.layer.cornerRadius = 3;
    self.imageViewJobPicture.clipsToBounds = YES;
    
    self.buttonCamera.layer.cornerRadius = 3;
    self.buttonCamera.clipsToBounds = YES;
    
    
    //fonts
    self.buttonOtherLocation.titleLabel.font = [UIFont fontWithName:@"OpenSans-Light" size:14];
    self.buttonCurrentLocation.titleLabel.font = [UIFont fontWithName:@"OpenSans-Light" size:14];
    
    [[UISegmentedControl appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:@"OpenSans-Light" size:14.0], UITextAttributeFont, nil] forState:UIControlStateNormal];
    
    self.jobTimeLabel.font = [UIFont fontWithName:@"OpenSans-Light" size:16];
    self.jobPriceLabel.font = [UIFont fontWithName:@"OpenSans-Light" size:16];
    
    self.JobDesription.font = [UIFont fontWithName:@"OpenSans-Light" size:16];
    self.labelInfoSnap.font = [UIFont fontWithName:@"OpenSans-Light" size:16];
}

- (void)viewDidLoad
{
    self.progressView.font = [UIFont fontWithName:@"Futura-CondensedExtraBold" size:26];
    self.progressView.popUpViewAnimatedColors = @[[UIColor redColor], [UIColor orangeColor], [UIColor greenColor]];
    self.progressView.popUpViewCornerRadius = 16.0;
    //self.progressView.delegate=self;
    
    self.jobTitle.enabled=NO;
    
    self.activityIndicator.hidden=YES;
    self.activityIndicator.hidesWhenStopped = YES;
    
    self.JobDesription.delegate=self;
    
    self.progressView.hidden = YES;
    
    self.JobDesription.layer.cornerRadius = 5.0f;
    self.JobDesription.layer.borderWidth = 1.0f;
    self.JobDesription.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    
    self.imageViewJobPicture.layer.masksToBounds = YES;
    self.imageViewJobPicture.layer.cornerRadius = 2;
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.sidebarButton.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:0.14 green:0.8 blue:0.9 alpha:1];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    [self.view setBackgroundColor:[UIColor colorWithRed:0.89 green:0.89 blue:0.89 alpha:1]];
    
    
    // Set the side bar button action. When it's tapped, it'll show up the sidebar.
    _sidebarButton.target = self.revealViewController;
    _sidebarButton.action = @selector(revealToggle:);
    
    
    // Set the gesture
    [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    
    self.JobDesription.delegate=self;
    
    self.buttonCurrentLocation.selected=YES;
    
    //mapView ***********************************
    self.mapViewCustom = [[MapView alloc]init];
    self.mapViewCustom.center = self.view.center;
    self.mapViewCustom.alpha = 0;
    self.mapViewCustom.delegate=self;
    [self.view addSubview:self.mapViewCustom];
    //*******************************************
    
    
    //initialisation
    date = [self.JobDate titleForSegmentAtIndex:self.JobDate.selectedSegmentIndex];
    
    currency = [[NSUserDefaults standardUserDefaults] objectForKey:@"currency"];
    NSLog(@"pref currency : %@", currency);
    price = [NSString stringWithFormat:@"%d",(int)self.jobPriceSlider.value];
    self.jobPriceLabel.text = [NSString stringWithFormat:@"Hourly rate : %@ %@/h", price ,currency ];
    
    int hourSlider = self.JobTimeSlider.value/4;
    int remainder = (int)self.JobTimeSlider.value%4;
    int quarter = remainder*15;
    self.jobTimeLabel.text = [NSString stringWithFormat:@"Job starts at : %02d : %02d",hourSlider, quarter];
    
    sliderHour = (int)hourSlider;
    sliderMinute = (int)quarter;
    
}

#pragma mark - MapViewCustom Delegate

-(void) MapViewDelegate_clickedOkWithLocation:(MyAnnotation*)annotation{
    
    annotationForMap = annotation;
    self.buttonPost.enabled=YES;
    
    [UIView animateWithDuration:0.2 animations:^{
        self.mapViewCustom.alpha=0;
    } completion:^(BOOL finished) {
        
    }];
}

-(void) MapViewDelegate_clickedCancel{
    
    self.buttonPost.enabled=YES;
    
    if (!annotationForMap) {
        self.buttonCurrentLocation.selected=YES;
        self.buttonOtherLocation.selected=NO;
    }
    
    [UIView animateWithDuration:0.2 animations:^{
        self.mapViewCustom.alpha=0;
    } completion:^(BOOL finished) {
        
    }];
}

#pragma mark -


#pragma mark - TextView delegate

-(void) textViewDidChange:(UITextView *)textView{
    self.labelCountDescription.text = [NSString stringWithFormat:@"%lu/140", (unsigned long)textView.text.length];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    
    
    
    self.JobDesription.textColor =  UIColorFromRGB(0x225378);
    
    if([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    
    return textView.text.length + (text.length - range.length) <= 140;
}

- (void)textViewDidBeginEditing:(UITextView *)textView{
    if ([textView.text isEqualToString:@"Job Description"]) {
        textView.text = @"";
        textView.textColor = [UIColor blackColor]; //optional
    }
    [textView becomeFirstResponder];
}

- (IBAction)tap:(id)sender {
    [self.JobDesription resignFirstResponder];
}

-(BOOL) textFieldShouldReturn:(UITextField *)textField{
    
    [textField resignFirstResponder];
    return YES;
}

#pragma mark -


- (IBAction) btnAction:(UIButton*)button{
    self.buttonCurrentLocation.selected=NO;
    self.buttonOtherLocation.selected=NO;
    button.selected = YES;

    if (button == self.buttonCurrentLocation) {
        annotationForMap = nil;
    }
}

- (IBAction)LocateSomewhereElse:(id)sender {
    
    self.buttonPost.enabled = NO;
    
    self.title = @"Pin your job location";
    
    [self.JobDesription resignFirstResponder];
    
    [self.mapViewCustom showMapView];
    
    [UIView animateWithDuration:0.2 animations:^{
        self.mapViewCustom.alpha=1;
    } completion:^(BOOL finished) {
    }];
}

- (IBAction)SegmentControlDateJob:(UISegmentedControl *)sender {
    [self.JobDesription resignFirstResponder];
}

- (IBAction)SliderPrice:(UISlider *)sender {
    
    self.jobPriceLabel.text = [NSString stringWithFormat:@"Hourly rate : %d %@/h", (int)sender.value, currency ];
    price = [NSString stringWithFormat:@"%d",(int)sender.value];
}

- (IBAction)sliderHour:(UISlider *)sender {
    int hourInteger = sender.value/4;
    int remainder = (int)sender.value%4;
    int quarter = remainder*15;
    
    self.jobTimeLabel.text = [NSString stringWithFormat:@"Job starts at : %02d : %02d", hourInteger, quarter];
    
    sliderHour = hourInteger;
    sliderMinute = quarter;
    
}

-(IBAction)POST:(id)sender {
    
    self.activityIndicator.hidden = NO;
    [self.activityIndicator startAnimating];
    
    if ([self.JobDesription.text isEqualToString:@"Job Description"] || self.JobDesription.text.length == 0 ) {
        [[[UIAlertView alloc]initWithTitle:@"Bad Description" message:@"Please fill in the job description" delegate:self cancelButtonTitle:@"Thanks" otherButtonTitles: nil] show];
        self.activityIndicator.hidden = YES;
        return;
    }
    
    if (self.JobDesription.text.length) { //faire la localisation aussi
        
        [self.JobDesription resignFirstResponder];
        self.buttonPost.enabled=NO;
        
        //date (today ou tomorrow)
        date = [self.JobDate titleForSegmentAtIndex:self.JobDate.selectedSegmentIndex];
        NSLog(@"%@",date);
        
        PFObject *Job = [PFObject objectWithClassName:@"Job"];
        Job[@"Description"] = self.JobDesription.text;
        Job[@"Price"] = [NSString stringWithFormat:@"%@ %@",price, currency];
        Job[@"Date"] = date;
        Job[@"Hour"] = [NSString stringWithFormat:@"%02d : %02d", sliderHour, sliderMinute];
        [Job setObject:[PFUser currentUser] forKey:@"Author"];
        
        
        // HANDLE DATE OF THE JOB ***************************************
        NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear | NSCalendarUnitHour | NSCalendarUnitMinute fromDate:[NSDate date]];
        
        
        if (self.JobDate.selectedSegmentIndex == 0) {   //today selected
            
            
            //check if the date of the job is in the past **********************
            NSDate* now = [NSDate date] ;
            NSCalendar* calendar = [NSCalendar currentCalendar] ;
            NSDateComponents* Components2 = [calendar components:(NSEraCalendarUnit|NSYearCalendarUnit|NSMonthCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit) fromDate:now] ;
            [Components2 setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
            
            int CurrentHour = (int)[Components2 hour];
            int CurrentMinute = (int)[Components2 minute];
            
            NSLog(@"hour : %d", CurrentHour);
            NSLog(@"minute : %d", CurrentMinute);
            
            if (sliderHour < CurrentHour || (sliderHour == CurrentHour && sliderMinute < CurrentMinute)) {
                
                NSLog(@"job in the past");
                
                [[[UIAlertView alloc]initWithTitle:@"Wrong Date" message:@"Please provide a valide date" delegate:self cancelButtonTitle:@"ok" otherButtonTitles: nil] show];
                self.buttonPost.enabled=YES;
                self.activityIndicator.hidden = YES;
                return;
            }
            
            //*******************************************************************
            
            
            
            //progress view
            //            self.progressView.hidden = NO;
            //            self.progressView.progress = 0.0;
            
            
            
            
            NSLog(@"hour before sending : %d", sliderHour);
            NSDate *dateJob = [NSDate dateWithYear:(int)[components year] month:(int)[components month] day:(int)[components day] hour:sliderHour minute:sliderMinute second:0];
            
            NSLog(@"date to save : %@", dateJob);
            
            Job[@"DateJob"] = dateJob;
            
            
        }
        else {  //tomorrow selected
            NSDate* now = [NSDate date] ;
            
            NSDateComponents* tomorrowComponents = [NSDateComponents new] ;
            
            tomorrowComponents.day = 1 ;
            NSCalendar* calendar = [NSCalendar currentCalendar] ;
            NSDate* tomorrow = [calendar dateByAddingComponents:tomorrowComponents toDate:now options:0] ;
            
            NSDateComponents* tomorrowComponents2 = [calendar components:(NSEraCalendarUnit|NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit) fromDate:tomorrow] ;
            [tomorrowComponents2 setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
            
            tomorrowComponents2.hour = sliderHour ;
            tomorrowComponents2.minute = sliderMinute;
            NSDate* dateJobTomorrow = [calendar dateFromComponents:tomorrowComponents2] ;
            
            NSLog(@"date tomorrow : %@", dateJobTomorrow);
            
            Job[@"DateJob"] = dateJobTomorrow;
            
            
        }
        //*****************************************************************
        
        if (self.buttonOtherLocation.selected==YES && annotationForMap != nil ) { //the user changed location
            
            PFGeoPoint *newLocation = [PFGeoPoint geoPointWithLatitude:annotationForMap.coordinate.latitude longitude:annotationForMap.coordinate.longitude];
            Job[@"Location"] = newLocation;
            [self saveJobParse:Job];
        }
        else if (self.buttonOtherLocation.selected==NO) {
            
            [PFGeoPoint geoPointForCurrentLocationInBackground:^(PFGeoPoint *geoPoint, NSError *error) {
                if (!error) {
                    // do something with the new geoPoint
                    Job[@"Location"] = geoPoint;
                    [self saveJobParse:Job];
                }else{
                    NSLog(@"error finding current location");
                }
            }];
            
        }
        
    }
}

-(void) saveJobParse:(PFObject*) Job{
    
    [Job saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        

        
        NSDictionary *job = [NSDictionary dictionaryWithObjectsAndKeys: Job[@"Description"], @"Description",
                             Job[@"Price"], @"Price",
                             Job[@"Hour"], @"Hour",
                             Job[@"DateJob"], @"DateJob",
                             Job[@"Location"], @"Location",
                             Job.objectId, @"id", nil];
        
        NSLog(@"annotation for map : %@", [annotationForMap description]);
        NSLog(@"job : %@", Job[@"Location"]);
        
        [JobMemoryManagement saveJobInMemory:job];
        [self goToAnotherViewController];
        
//        [[[UIAlertView alloc]initWithTitle:@"Thanks" message:@"Your job has been posted !" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil]show];
        
        
        
        //                self.activityIndicator.hidden = YES;
        //                self.progressView.hidden  = YES;
        //                self.JobDesription.text = @"Job Description";
        //                AMSmoothAlertView *alert = [[AMSmoothAlertView alloc] initDropAlertWithTitle:@"Thanks" andText:@"Your job has been posted !" andCancelButton:NO forAlertType:AlertSuccess];
        
    }];
}

-(void) goToAnotherViewController {
    SWRevealViewController *revealController = self.revealViewController;
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Storyboard" bundle:nil];
    
    MyPostedJobsViewController *vc = [sb instantiateViewControllerWithIdentifier:@"MyPostedJobsViewController"];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:vc];
    [revealController setFrontViewController:navigationController animated:YES];
}

- (NSString *)progressView:(ASProgressPopUpView *)progressView stringForProgress:(float)progress{
    NSString *s;
    if (progress < 0.2) {
        s = @"Just starting";
    } else if (progress > 0.4 && progress < 0.6) {
        s = @"About halfway";
    } else if (progress > 0.75 && progress < 1.0) {
        s = @"Nearly there";
    } else if (progress >= 1.0) {
        s = @"Complete";
    }
    return s;
}

#pragma mark - Job picture

- (IBAction)takePicture:(id)sender {
    if ([UIImagePickerController isSourceTypeAvailable:
         UIImagePickerControllerSourceTypeCamera])
    {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.allowsEditing = YES;
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        
        [self presentViewController:picker animated:YES completion:NULL];
    }
    NSLog(@"1");
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES completion:nil];
    NSLog(@"2");
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    picture_camera = [info objectForKey:UIImagePickerControllerEditedImage];
    
    picture_camera_small = [self imageScaled:picture_camera toMaxSideSize: 300];
    
    // You have the image. You can use this to present the image in the next view like you require in `#3`.
    
    //[self.buttonCamera setBackgroundImage:picture_camera_small forState:UIControlStateNormal];
    self.ImageViewJob.image = picture_camera;
    
    self.imageViewJobPicture.image = picture_camera;
    
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (UIImage*)imageScaled:(UIImage *) image toMaxSideSize:(int) maxSize{
    float scaleFactor = 0;
    
    if(image.size.width > image.size.height) scaleFactor = maxSize / image.size.width;
    else scaleFactor = maxSize / image.size.height;
    
    CGSize newSize = CGSizeMake(image.size.width * scaleFactor, image.size.height * scaleFactor);
    
    UIGraphicsBeginImageContext(newSize);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage* updatedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return updatedImage;
}


@end
