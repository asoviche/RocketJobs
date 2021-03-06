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
#import <Parse/Parse.h>
#import "JobMemoryManagement.h"
#import "ApplicantsMemoryManagement.h"
#import "ImageManagement.h"

@interface MyPostedJobsViewController ()
@property (strong, nonatomic) IBOutlet UITableView *tableView;

@property NSDictionary *myJobsDictionary;
@property NSMutableDictionary *applicantsToMyJobsDictionary;


@property (weak, nonatomic) IBOutlet UIBarButtonItem *sidebarButton;
@property (strong, nonatomic) UIRefreshControl *refreshControl;

@end

@implementation MyPostedJobsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    NSLog(@"MyPostedJobsViewController ");
    
    self.sidebarButton.tintColor = [UIColor whiteColor];
    //    self.navigationController.navigationBar.barTintColor = UIColorFromRGB(0x225378);
    // Set the side bar button action. When it's tapped, it'll show up the sidebar.
    _sidebarButton.target = self.revealViewController;
    _sidebarButton.action = @selector(revealToggle:);
    
    [[self navigationController] setNavigationBarHidden:YES animated:YES];
    
    self.applicantsToMyJobsDictionary = [NSMutableDictionary new];
    
    
    NSLog(@"myJobsDictionary : %@", [self.myJobsDictionary description]);
    
    self.refreshControl = [[UIRefreshControl alloc]init];
    [self.tableView addSubview:self.refreshControl];
    [self.refreshControl addTarget:self action:@selector(refreshTable) forControlEvents:UIControlEventValueChanged];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [self downloadPostedJobs];
}

-(void) viewDidAppear:(BOOL)animated{
    self.myJobsDictionary =  [MemoryManagement getObjectFromMemoryInFolder:@"myJobsDictionary"];
    [self.tableView reloadData];
}

-(void)refreshTable{
   
    [self downloadPostedJobs];
    [self.refreshControl endRefreshing];
}

-(void) downloadPostedJobs{
    
    NSMutableArray *arrayAllApplicantsId = [NSMutableArray new];
    
    //DOWNLOAD JOBS
    PFQuery *query = [PFQuery queryWithClassName:@"Job"];
    [query whereKey:@"Author" equalTo:[PFUser currentUser]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *myJobsArray, NSError *error) {
        
        if (error) {
            NSLog(@"error description : %@", [error description]);
            return;
        }
        
        NSLog(@"count posted jobs : %lu", (unsigned long)[myJobsArray count]);
        
        for (PFObject *myJob in myJobsArray) {
            
            if ( [myJob[@"ApplicantsID"] count] > 0 ) {
                
                NSLog(@"my job : %@", [myJob description]);
                NSLog(@"ApplicantsID : %@", myJob[@"ApplicantsID"]);
                
                NSSet *applicantsSet = [NSSet setWithArray:myJob[@"ApplicantsID"]];
                [self.applicantsToMyJobsDictionary setObject:[applicantsSet allObjects] forKey:myJob.objectId];
                
                [arrayAllApplicantsId addObjectsFromArray:[applicantsSet allObjects]];
                
            }else{ //no applicants
                
                NSLog(@"empty array : %@", myJob.objectId);
                
                [self.applicantsToMyJobsDictionary setObject:[NSArray array] forKey:myJob.objectId];
            }
        }
        
        [JobMemoryManagement updateApplicantsForJobsWithDictionary:self.applicantsToMyJobsDictionary];
        
        self.myJobsDictionary = [MemoryManagement getObjectFromMemoryInFolder:@"myJobsDictionary"]; //update jobs from memory
        [self.tableView reloadData];
        
        [self downloadApplicantsProfilesWithIds:arrayAllApplicantsId];
        
    }];
}

-(void) downloadApplicantsProfilesWithIds:(NSArray*) applicantsArrayIds{
    
    PFQuery *queryApplicants = [PFUser query];
    [queryApplicants whereKey:@"objectId" containedIn:applicantsArrayIds];
    [queryApplicants findObjectsInBackgroundWithBlock:^(NSArray *arrayApplicantsParse, NSError *error) {
        
        if (error) {
            NSLog(@"error : %@", [error description]);
            return;
        }
        
        for (PFUser *applicant in arrayApplicantsParse) {
            
            NSMutableDictionary *dicApplicant = [NSMutableDictionary dictionaryWithObjectsAndKeys:applicant.objectId, @"id", nil];
            if (applicant[@"name"]) {
                [dicApplicant setObject:applicant[@"name"] forKey:@"name"];
            }
            if (applicant[@"phoneNumber"]) {
                [dicApplicant setObject:applicant[@"phoneNumber"] forKey:@"phoneNumber"];
            }
            if (applicant[@"About"]) {
                [dicApplicant setObject:applicant[@"About"] forKey:@"About"];
            }
            
            NSLog(@"dic applicant to save : %@", [dicApplicant description]);
            
            [ApplicantsMemoryManagement saveApplicant:dicApplicant withImagePP:nil];
            
            //DOWLOAD IMAGE PP
            PFFile *userImageFile = applicant[@"imagePP"];
            [userImageFile getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error) {
                if (!error) {
                    [ImageManagement saveImageWithData:imageData forName:applicant.objectId];
                }
            }];
        }
        
    }];
}


#pragma mark tableView delegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UIStoryboard*  sb = [UIStoryboard storyboardWithName:@"Storyboard" bundle:nil];
    ApplicantsForJobViewController *vc1 = [sb instantiateViewControllerWithIdentifier:@"ApplicantsForJobViewController"];
    
    NSSet *applicantsSet = [NSSet setWithArray:[[self.myJobsDictionary objectForKey: [[self.myJobsDictionary allKeys] objectAtIndex:indexPath.row]] objectForKey:@"acceptedApplicants"]];
    vc1.arrayApplicantsFromJob = [applicantsSet allObjects];
    vc1.jobId = [[self.myJobsDictionary allKeys] objectAtIndex:indexPath.row];
    [self.navigationController pushViewController:vc1 animated:YES];
    
    
//    NSDictionary *job = [self.myJobsDictionary objectForKey:[[self.myJobsDictionary allKeys] objectAtIndex:indexPath.row]];
//    if ([self.applicantsToMyJobsDictionary objectForKey:job[@"id"]] && [[self.applicantsToMyJobsDictionary objectForKey:job[@"id"]] count] > 0) {
//        vc1.arrayApplicantsFromJob = [self.applicantsToMyJobsDictionary objectForKey:job[@"id"]];
//        [self.navigationController pushViewController:vc1 animated:YES];
//    }
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
    
    NSLog(@"desc : %@", textViewDescription.text);
    
//    if ([self.applicantsToMyJobsDictionary objectForKey:job[@"id"]]) {
//        labelNbApplicants.text = [NSString stringWithFormat:@"%lu Applicants", (unsigned long)[[self.applicantsToMyJobsDictionary objectForKey:job[@"id"]] count] ];
//    }
    
    
    
    return cell;
}



@end
