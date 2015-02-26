//
//  JobsParseManagement.m
//  Cash Now
//
//  Created by amaury soviche on 26/02/15.
//  Copyright (c) 2015 Amaury Soviche. All rights reserved.
//

#import "JobsParseManagement.h"

@implementation JobsParseManagement


+(void) applyForJobWithJobId:(NSString*)JobId{
    PFQuery *query = [PFQuery queryWithClassName:@"Job"];
    [query getObjectInBackgroundWithId:JobId block:^(PFObject *JobToApply, NSError *error) {
        
        NSLog(@"job : %@", [JobToApply description]);
        
        //check if the user has alreadey applied for the job !
        if (![JobToApply[@"ApplicantsID"] containsObject:[PFUser currentUser].objectId]) {
            
            NSLog(@"apply oui");
            [JobToApply addObject:[PFUser currentUser].objectId forKey:@"ApplicantsID"];
            [JobToApply setObject:[NSNumber numberWithBool:NO] forKey:@"isApplicantArrayEmpty"];
            [JobToApply saveEventually:^(BOOL succeeded, NSError *error) {
                
                if (succeeded) {
                    //SEND THE PUSH NOTIFICATION ****************************
                    
                    PFUser *JobProvider = JobToApply[@"Author"];
                    
                    // Create our Installation query
                    PFQuery *pushQuery = [PFInstallation query];
                    [pushQuery whereKey:@"user" equalTo:JobProvider];
                    [pushQuery whereKey:@"active" equalTo:[NSNumber numberWithBool:YES]];
                    
                    //add a badge for each notification
                    NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
                                          @"You have a new Applicant !", @"alert",
                                          @"Increment", @"badge",
                                          nil];
                    
                    // Send push notification to query
                    PFPush *push = [[PFPush alloc] init];
                    [push setQuery:pushQuery];
                    [push setData:data];
                    [push sendPushInBackground];
                }
                else{
                    [[[UIAlertView alloc] initWithTitle:@"Oops" message:@"It seems there was a connection problem..." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show] ;
                }
            }];
        }
    }];
}

@end
