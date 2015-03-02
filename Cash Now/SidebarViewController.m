//
//  SidebarViewController.m
//  SidebarDemo
//
//  Created by Simon on 29/6/13.
//  Copyright (c) 2013 Appcoda. All rights reserved.
//

#import "SidebarViewController.h"
#import "SWRevealViewController.h"
#import "addJobViewController.h"
#import "ImageManagement.h"
#import "ProfileMVPViewController.h"

@interface SidebarViewController ()

@property (strong, nonatomic) IBOutlet UIButton *buttonConversations;

@end

@implementation SidebarViewController{
    BOOL areJobsSeen;
}

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated{
    self.view.backgroundColor=  UIColorFromRGB(0x225378);
    
//    [[NSUserDefaults standardUserDefaults] objectForKey:@"areAllJobsSeen"]
//    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:[self areJobsSeen]] forKey:@"areAllJobsSeen"];
//    [[NSUserDefaults standardUserDefaults] synchronize];
//    [self.tableView reloadData];
    
    NSLog(@"viewWillAppear");
    [self.tableView reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
//    self.view.backgroundColor = [UIColor colorWithWhite:0.2f alpha:1.0f];
//    self.tableView.backgroundColor = [UIColor colorWithWhite:0.2f alpha:1.0f];
//    self.tableView.separatorColor = [UIColor colorWithWhite:0.15f alpha:0.2f];
    
//    areJobsSeen = [[[NSUserDefaults standardUserDefaults]objectForKey:@"areAllJobsSeen"] boolValue];
//     dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//         areJobsSeen = [self areJobsSeen];
//         
//     });
    

    
    _menuItems = @[@"ProfileInfo", @"Blank2", @"SearchJobs", @"PostAJob", @"MyJobs",@"blank", @"Settings"];
}

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




#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.menuItems count];;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = [self.menuItems objectAtIndex:indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    NSLog(@"refresh");
    
    if ([[self.menuItems objectAtIndex:indexPath.row] isEqualToString:@"ProfileInfo"]) {
        
        UIImageView *imageView = (UIImageView*)[cell viewWithTag:100];
        UILabel *labelName = (UILabel*)[cell viewWithTag:200];
        UILabel *labelPhone = (UILabel*)[cell viewWithTag:300];
        
        labelPhone.textColor = [UIColor whiteColor];
        labelName.textColor = [UIColor whiteColor];
        labelName.font = [UIFont fontWithName:@"OpenSans-Light" size:16];
        labelPhone.font = [UIFont fontWithName:@"OpenSans-Light" size:16];
        
        labelName.text = [[NSUserDefaults standardUserDefaults]stringForKey:@"name"];
        imageView.image = [ImageManagement getImageFromMemoryWithName:@"imagePP"];
        
        imageView.layer.cornerRadius = imageView.frame.size.width/2;
        imageView.clipsToBounds = YES;
        
        if([[NSUserDefaults standardUserDefaults]stringForKey:@"phoneNumber"]){
            labelPhone.text = [[NSUserDefaults standardUserDefaults]stringForKey:@"phoneNumber"];
        }else{
            labelPhone.text = @"Enter your phone number";
        }
        
    }else{
        
        UIButton *button = (UIButton*)[cell viewWithTag:100];
        if (button != nil) {
            button.titleLabel.font = [UIFont fontWithName:@"OpenSans-Light" size:16];
        }
        
        if( indexPath.row == 1) {
            if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"areAllJobsSeen"] boolValue] == NO ){
                cell.backgroundColor = [UIColor whiteColor];
                button.titleLabel.textColor =  UIColorFromRGB(0x225378);
            }
            else{
                cell.backgroundColor = UIColorFromRGB(0x225378);
                button.titleLabel.textColor = [UIColor whiteColor];
            }
        }
    }

    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if ([[self.menuItems objectAtIndex:indexPath.row] isEqualToString:@"ProfileInfo"]) {
        
        return 120;
    }else{
        return 60;
    }
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    if ([[self.menuItems objectAtIndex:indexPath.row] isEqualToString:@"ProfileInfo"]) {
      
        UIStoryboard*  sb = [UIStoryboard storyboardWithName:@"Storyboard" bundle:nil];
        ProfileMVPViewController *vc1 = [sb instantiateViewControllerWithIdentifier:@"ProfileMVPViewController"];
//        [self presentViewController:vc1 animated:YES completion:nil];
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ProfileInfo" forIndexPath:indexPath];
        UIButton *button = (UIButton*)[cell viewWithTag:500];
        [button sendActionsForControlEvents:UIControlEventTouchUpInside];
    }
}

- (void) prepareForSegue: (UIStoryboardSegue *) segue sender: (id) sender
{

    if ( [segue isKindOfClass: [SWRevealViewControllerSegue class]] ) {
        NSLog(@"good part 1");
        SWRevealViewControllerSegue *swSegue = (SWRevealViewControllerSegue*) segue;
        
        swSegue.performBlock = ^(SWRevealViewControllerSegue* rvc_segue, UIViewController* svc, UIViewController* dvc) {
            
            UINavigationController* navController = (UINavigationController*)self.revealViewController.frontViewController;
            [navController setViewControllers: @[dvc] animated: NO ];
            [self.revealViewController setFrontViewPosition:FrontViewPositionLeft animated: YES];
        };
        
    }
    
}

@end
