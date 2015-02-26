//
//  JobMemoryManagement.m
//  Cash Now
//
//  Created by amaury soviche on 26/02/15.
//  Copyright (c) 2015 Amaury Soviche. All rights reserved.
//

#import "JobMemoryManagement.h"
#import "MemoryManagement.h"

@implementation JobMemoryManagement

+(void) saveJobInMemory:(NSDictionary*)job{

    //get the list of jobs
    NSMutableDictionary *jobsDictionary;
    if ([MemoryManagement getObjectFromMemoryInFolder:@"myJobsDictionary"] == nil) {
        jobsDictionary = [NSMutableDictionary new];
    }else{
        jobsDictionary = [[MemoryManagement getObjectFromMemoryInFolder:@"myJobsDictionary"] mutableCopy];
    }
    
    //set the new applicant
    [jobsDictionary setObject:job forKey:job[@"id"]];
    
    NSLog(@"applicant dic : %@", [jobsDictionary description]);
    
    //store updated dic applicants
    [MemoryManagement saveObjectInMemory:jobsDictionary toFolder:@"myJobsDictionary"];

    
    //check
    NSLog(@"new job dic : %@", [MemoryManagement getObjectFromMemoryInFolder:@"myJobsDictionary"]);
    
}


+(void) newApplicantWithId:(NSString*)applicantId forJobWithId:(NSString*)jobId{
    
    NSLog(@"newApplicantWithId");

    NSMutableDictionary *jobsDictionary = [[MemoryManagement getObjectFromMemoryInFolder:@"myJobsDictionary"] mutableCopy];
    
    NSMutableDictionary *job = [[jobsDictionary objectForKey:jobId] mutableCopy];
    if (job[@"acceptedApplicants"]) {
        job[@"acceptedApplicants"] = [[job[@"acceptedApplicants"] mutableCopy] arrayByAddingObject:applicantId];
    }else{
        NSArray *arrayAcceptedApplicants = [NSArray arrayWithObject:applicantId];
        job[@"acceptedApplicants"] = arrayAcceptedApplicants;
    }

    [jobsDictionary setObject:job forKey:job[@"id"]];
    
    [MemoryManagement saveObjectInMemory:jobsDictionary toFolder:@"myJobsDictionary"];
    
    //check
    NSLog(@"new job dic new applicatn : %@", [MemoryManagement getObjectFromMemoryInFolder:@"myJobsDictionary"]);
}

@end
