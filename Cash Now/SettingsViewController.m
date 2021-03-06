//
//  SettingsViewController.m
//  Cash Now
//
//  Created by amaury soviche on 11.05.14.
//  Copyright (c) 2014 Amaury Soviche. All rights reserved.
//

#import "SettingsViewController.h"
#import "SWRevealViewController.h"
#import "GGDraggableView.h"
#import "LogInViewControllerCustom.h"
#import <Social/Social.h>
#import "SocialMedias.h"

@interface SettingsViewController ()
@property (strong, nonatomic) IBOutlet UISlider *SliderKm;
@property (strong, nonatomic) IBOutlet UILabel *labelDistance;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *sidebarButton;
@property (strong, nonatomic) IBOutlet UIButton *buttonSignOut;
@property (strong, nonatomic) IBOutlet UISegmentedControl *segmentCurrency;
@property (strong, nonatomic) IBOutlet UILabel *labelCurrency;
@end

@implementation SettingsViewController{
    
}

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]


-(void) viewWillAppear:(BOOL)animated{
    self.navigationController.navigationBar.barTintColor = UIColorFromRGB(0x225378);
    
    self.buttonSignOut.layer.cornerRadius = 4;
    
    NSDictionary *dic = [[NSDictionary alloc] initWithObjectsAndKeys: @0,@"$",  @1, @"€" ,@2  , @"£", @3, @"CHF" , nil];
    
    NSString *currency = [[NSUserDefaults standardUserDefaults]objectForKey:@"currency"];
    
    id a = [dic valueForKey:currency];
    
    NSLog(@"int : %@ and currency : %@", a , currency );
    
    self.segmentCurrency.selectedSegmentIndex = [a integerValue];
    
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.sidebarButton.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:0.14 green:0.8 blue:0.9 alpha:1];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    [self.view setBackgroundColor:[UIColor colorWithRed:0.89 green:0.89 blue:0.89 alpha:1]];
    [[self navigationController] setNavigationBarHidden:YES animated:YES];

    
    // Set the side bar button action. When it's tapped, it'll show up the sidebar.
    _sidebarButton.target = self.revealViewController;
    _sidebarButton.action = @selector(revealToggle:);
    
    
    //set the distance
    int distance = (int)[[[NSUserDefaults standardUserDefaults]stringForKey:@"distanceForSearch"] integerValue] ;
    self.SliderKm.value = distance;
    self.labelDistance.text = [NSString stringWithFormat:@"%d km",distance];
    
    // [self.labelCurrency setFont:[UIFont fontWithName:@"AvenirNextLTPro-UltLt" size:23.0]];
    
    
    // Set the gesture
    [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
}

- (IBAction)selectedSegmentedControl:(UISegmentedControl *)sender {
    [[NSUserDefaults standardUserDefaults] setObject:[sender titleForSegmentAtIndex:sender.selectedSegmentIndex] forKey:@"currency"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)sliderHour:(UISlider *)sender {
    NSString *distance = [NSString stringWithFormat:@"%d",(int)sender.value];
    [[NSUserDefaults standardUserDefaults] setObject:distance forKey:@"distanceForSearch"];
    self.labelDistance.text = [NSString stringWithFormat:@"%@ km",distance];
}
- (IBAction)logOut:(id)sender {
    NSLog(@"f");
    
    
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Log Out ?" message:@"All datas will be deleted" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Log Out" , nil];
    [alert show];

}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == 1) {
        
        
        //change installation to false
        PFInstallation *installation = [PFInstallation currentInstallation];
        [installation setObject:[NSNumber numberWithBool:NO] forKey:@"active"];
        [installation saveInBackground];
        
        [PFUser logOut];
        [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"name"];
        [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"About"];
        [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"phoneNumber"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        
        //display the login view
        UIStoryboard*  sb = [UIStoryboard storyboardWithName:@"Storyboard" bundle:nil];
        LogInViewControllerCustom* vc0 = [sb instantiateViewControllerWithIdentifier:@"FirstVC"];
        [self presentViewController:vc0 animated:YES completion:nil];
        
        
        
//        //DELETE PLIST FOR CONVERSATIONS
//        NSError *error;
//        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); //1
//        NSString *documentsDirectory = [paths objectAtIndex:0]; //2
//        NSString *path = [documentsDirectory stringByAppendingPathComponent:@"Conversations.plist"]; //3
//        
//        NSFileManager *fileManager = [NSFileManager defaultManager];
//        
//        if (![fileManager fileExistsAtPath: path]) //4
//        {
//            NSLog(@"file does not exist");
//            NSString *bundle = [[NSBundle mainBundle] pathForResource:@"Conversations" ofType:@"plist"]; //5
//            [fileManager copyItemAtPath:bundle toPath: path error:&error]; //6
//        }
//        [fileManager removeItemAtPath:path error:&error];
//        
//        //DELETE FILE FOR JOBS
//        NSError *error2;
//        NSArray *paths2 = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); //1
//        NSString *documentsDirectory2 = [paths2 objectAtIndex:0]; //2
//        NSString *path2 = [documentsDirectory2 stringByAppendingPathComponent:@"Conversations.plist"]; //3
//        
//        NSFileManager *fileManager2 = [NSFileManager defaultManager];
//        [fileManager2 removeItemAtPath:path2 error:&error2];
        
        


    }
    // else do your stuff for the rest of the buttons (firstOtherButtonIndex, secondOtherButtonIndex, etc)
}

#pragma mark send mail

- (IBAction)sendFeedBack:(id)sender {
    if([MFMailComposeViewController canSendMail]) {
        
        MFMailComposeViewController *mailCont = [[MFMailComposeViewController alloc] init];
        mailCont.mailComposeDelegate = self;
        mailCont.navigationBar.translucent = NO;
//        [mailCont.navigationBar setTintColor:[UIColor whiteColor]];
        
        //        mailCont.topViewController.navigationController

        
        [mailCont setSubject:@"Support - feedback"];
        [mailCont setToRecipients:@[@"amaury@payonesnap.com"]];
        
        [self presentViewController:mailCont animated:YES completion:nil];
    }
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)share:(id)sender {
    [self ShareFacebook];
}

- (void)ShareFacebook
{
    SLComposeViewController *fbController=[SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
    
    if([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook])
    {
        SLComposeViewControllerCompletionHandler __block completionHandler=^(SLComposeViewControllerResult result){
            
            [fbController dismissViewControllerAnimated:YES completion:nil];
            
            switch(result){
                case SLComposeViewControllerResultCancelled:
                default:
                {
                    NSLog(@"Cancelled.....");
                    // [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs://"]];
                    
                }
                    break;
                case SLComposeViewControllerResultDone:
                {
                    NSLog(@"Posted....");
                }
                    break;
            }};
        
        
        [fbController setInitialText:@"..."];
        
        
        [fbController setCompletionHandler:completionHandler];
        [self presentViewController:fbController animated:YES completion:nil];
    }
    else{
//        UIAlertView *alert = [[[UIAlertView alloc]initWithTitle:@"Sign in!" message:@"Please first Sign In!" delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil, nil]autorelease];
//        [alert show];
    }
}


- (IBAction)shareTwitter:(id)sender {
    [SocialMedias tweetWithMessage:@"Found a Job on RocketJobs !" image:nil url:nil viewController:self];

}

@end
