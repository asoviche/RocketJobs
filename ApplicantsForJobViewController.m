//
//  ApplicantsForJobViewController.m
//  Cash Now
//
//  Created by amaury soviche on 27/02/15.
//  Copyright (c) 2015 Amaury Soviche. All rights reserved.
//

#import "ApplicantsForJobViewController.h"
#import "MemoryManagement.h"
#import "ImageManagement.h"
@interface ApplicantsForJobViewController ()

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *arrayApplicants;

@end

@implementation ApplicantsForJobViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSLog(@"applicants from job . %@", [self.arrayApplicantsFromJob description]);
    
    self.arrayApplicants = [NSMutableArray new];
    
    NSDictionary *dicAllApplicants = [MemoryManagement getObjectFromMemoryInFolder:@"applicantsDictionary"];
    
    NSLog(@"all appl : %@", [dicAllApplicants description]);
    
    for (NSString *applicantId in self.arrayApplicantsFromJob) {
        [self.arrayApplicants addObject:[dicAllApplicants objectForKey:applicantId]];
    }
    
    NSLog(@"applicants for job : %@", [self.arrayApplicants description]);
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
}

- (IBAction)back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark tableView delegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.arrayApplicants count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    
    UITextView *textViewDescription = (UITextView*)[cell viewWithTag:100];
    UILabel *labelPhoneNumber = (UILabel*)[cell viewWithTag:200];
    UILabel *labelName = (UILabel*)[cell viewWithTag:300];
    UIImageView *imageViewPP = (UIImageView*)[cell viewWithTag:400];
    
    NSDictionary *applicant = [self.arrayApplicants objectAtIndex:indexPath.row];
    NSLog(@"applicant for row : %@", [applicant description]);
    
    textViewDescription.text = applicant[@"About"];
    labelPhoneNumber.text = applicant[@"phoneNumber"];
    labelName.text = applicant[@"name"];
    imageViewPP.image = [ImageManagement getImageFromMemoryWithName:applicant[@"id"]];
    
 
    
    return cell;
}

@end
