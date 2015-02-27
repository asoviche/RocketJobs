//
//  MyPostedJobsViewController.m
//  Cash Now
//
//  Created by amaury soviche on 27/02/15.
//  Copyright (c) 2015 Amaury Soviche. All rights reserved.
//

#import "MyPostedJobsViewController.h"
#import "MemoryManagement.h"
#import "SWRevealViewController.h"
#import "ApplicantsForJobViewController.h"

@interface MyPostedJobsViewController ()
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property NSDictionary *myJobsDictionary;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *sidebarButton;
@end

@implementation MyPostedJobsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.sidebarButton.tintColor = [UIColor whiteColor];
    //    self.navigationController.navigationBar.barTintColor = UIColorFromRGB(0x225378);
    // Set the side bar button action. When it's tapped, it'll show up the sidebar.
    _sidebarButton.target = self.revealViewController;
    _sidebarButton.action = @selector(revealToggle:);
    
    [[self navigationController] setNavigationBarHidden:YES animated:YES];
    
    self.myJobsDictionary = [MemoryManagement getObjectFromMemoryInFolder:@"myJobsDictionary"];
    NSLog(@"myJobsDictionary : %@", [self.myJobsDictionary description]);
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
}

#pragma mark tableView delegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    UIStoryboard*  sb = [UIStoryboard storyboardWithName:@"Storyboard" bundle:nil];
    ApplicantsForJobViewController *vc1 = [sb instantiateViewControllerWithIdentifier:@"ApplicantsForJobViewController"];
    vc1.arrayApplicantsFromJob = [[self.myJobsDictionary objectForKey: [[self.myJobsDictionary allKeys] objectAtIndex:indexPath.row]] objectForKey:@"acceptedApplicants"];
    [self.navigationController pushViewController:vc1 animated:YES];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.myJobsDictionary count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    
    UITextView *textViewDescription = (UITextView*)[cell viewWithTag:100];
    UILabel *labelNbApplicants = (UILabel*)[cell viewWithTag:200];
    
    NSDictionary *job = [self.myJobsDictionary objectForKey:[[self.myJobsDictionary allKeys] objectAtIndex:indexPath.row]];
    
    textViewDescription.text = job[@"Description"];
    labelNbApplicants.text = [NSString stringWithFormat:@"%lu Applicants", (unsigned long)[job[@"acceptedApplicants"] count] ];
    
    
    
    
    return cell;
}

@end
