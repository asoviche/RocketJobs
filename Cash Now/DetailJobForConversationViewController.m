//
//  DetailJobForConversationViewController.m
//  GPUImage
//
//  Created by amaury soviche on 10/06/14.
//  Copyright (c) 2014 Brad Larson. All rights reserved.
//

#import "DetailJobForConversationViewController.h"
#import "GGDraggableView.h"
#import <Parse/Parse.h>
#import "NSDate+Calculations.h"

@interface DetailJobForConversationViewController ()

@end

@implementation DetailJobForConversationViewController{
    
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
    
    self.navigationController.navigationBar.barTintColor = UIColorFromRGB(0x225378);

    //add all the details to the view
    NSError *error;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); //1
    NSString *documentsDirectory = [paths objectAtIndex:0]; //2
    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"JobsList.plist"]; //3
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if (![fileManager fileExistsAtPath: path]) //4
    {
        NSLog(@"file does not exist");
        NSString *bundle = [[NSBundle mainBundle] pathForResource:@"JobsList" ofType:@"plist"]; //5
        [fileManager copyItemAtPath:bundle toPath: path error:&error]; //6
    }
    
    //all the stuff in the plist file
    NSMutableDictionary *data = [[NSMutableDictionary alloc] initWithContentsOfFile: path];
    
    NSLog(@"data in the plist : %@", [data description]);
    
    
    
    
    
    GGDraggableView *JobView = [[GGDraggableView alloc]initWithFrame:CGRectMake((320-291)/2, 90, 291, 463)];
    [JobView setUserInteractionEnabled:NO];
    [self.view addSubview:JobView];
    
    NSDictionary *dicJob = [data objectForKey:self.JobId];
    NSLog(@"id : %@", self.JobId);
    NSLog(@"data in the dic : %@", [dicJob description]);
    
    JobView.LabelDescriptionJob.text =[dicJob objectForKey:@"description"];
    JobView.LabelPriceJob.text =[NSString stringWithFormat:@"%@/h", [dicJob objectForKey:@"price"]];
    JobView.LabelHourJob.text =[dicJob objectForKey:@"hour"];
    JobView.JobID = self.JobId;
    
    [JobView.activity startAnimating];
    
    PFQuery *query = [PFQuery queryWithClassName:@"Job"];
    [query getObjectInBackgroundWithId:self.JobId block:^(PFObject *Job, NSError *error) {
        if (!error) {
            
            //IMAGE
            if (Job[@"Picture"]) {
                
                PFFile *userImageFile = Job[@"Picture"];
                
                [userImageFile getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error) {
                    
                    [JobView.activity stopAnimating];
                    
                    if (!error) {
                        UIImage *image = [UIImage imageWithData:imageData];
                        if (image) {
                            //placer les photos dans les vues
                            [JobView loadImageAndStyle:[UIImage imageWithData:imageData]];
                            
                            //stop loading
                            
                        }
                        else{
                            //error : load rand image
                            [JobView loadImageAndStyle:[UIImage imageNamed:[@"rand_picture_" stringByAppendingString:[NSString stringWithFormat:@"%d", arc4random()%5]]]];
                        }
                    }
                }];
            }else{
                //no image : load rand image
                [JobView loadImageAndStyle:[UIImage imageNamed:[@"rand_picture_" stringByAppendingString:[NSString stringWithFormat:@"%d", arc4random()%5]]]];
            }
            
            //GEOPOINT
            [PFGeoPoint geoPointForCurrentLocationInBackground:^(PFGeoPoint *geoPoint, NSError *error) {
                float distanceToJob = [geoPoint distanceInKilometersTo:Job[@"Location"]];
                if (distanceToJob < 0.1) {
                    JobView.DistanceToUser.text = @"100 m";
                }else{
                    JobView.DistanceToUser.text = [NSString stringWithFormat:@"%0.1f km", distanceToJob];
                }
            }];
        }
    }];
    
    //DATE
    NSString *dateString;
    
    if ([dicJob objectForKey:@"date"]) {
        
        NSDate *todayDate = [NSDate date];
        
        NSDate *tomorrow = [[NSDate alloc] init];
        tomorrow = [[NSDate date] tomorrow];
        
        NSCalendar* calendar = [NSCalendar currentCalendar];
        
        NSDateComponents* TodayComponents = [calendar components:(NSEraCalendarUnit|NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit) fromDate:todayDate] ;
        [TodayComponents setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
        
        
        NSDateComponents* TomorrowComponents = [calendar components:(NSEraCalendarUnit|NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit) fromDate:tomorrow];
        [TomorrowComponents setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
        
        
        NSString *dateJobString = [[dicJob objectForKey:@"date"] description];
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

    
        JobView.LabelDateJob.text =dateString;
    
    
}

-(void) ShowLoading {
    
}

- (IBAction)back:(id)sender {
//    [self dismissViewControllerAnimated:YES completion:nil];
    [self.navigationController popViewControllerAnimated:YES];
}

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
