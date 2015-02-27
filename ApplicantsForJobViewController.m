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

@property (strong, nonatomic) MFMessageComposeViewController* controller;

@end

@implementation ApplicantsForJobViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.controller = [[MFMessageComposeViewController alloc] init] ;
    self.controller.delegate = self;
    
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

#pragma mrak action sheet delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    NSDictionary * applicant = [self.arrayApplicants objectAtIndex:actionSheet.tag];
    
    if (buttonIndex == 0){ //call
        
        NSString *phoneNumber = [@"telprompt://" stringByAppendingString:applicant[@"phoneNumber"]];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneNumber]];
        
    }else if(buttonIndex == 1){ //send message
        NSLog(@"send message !");
        
        if([MFMessageComposeViewController canSendText])
        {
            self.controller.body = @"SMS message here";
            self.controller.recipients = [NSArray arrayWithObjects:applicant[@"phoneNumber"], nil];
            self.controller.messageComposeDelegate = self;
            [self presentViewController:self.controller animated:YES completion:nil];
        }
    }
    
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    switch (result) {
        case MessageComposeResultCancelled:
            NSLog(@"Cancelled");
            break;
        case MessageComposeResultFailed:

            break;
        case MessageComposeResultSent:
            
            break;
        default:
            break;
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark tableView delegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:@"Choose" delegate:self cancelButtonTitle:@"cancel" destructiveButtonTitle:nil otherButtonTitles:@"Call", @"Message", nil];
    actionSheet.tag=indexPath.row;
    [actionSheet showInView:self.view];
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
