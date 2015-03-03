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

+(NSDictionary*) getJobFromMemoryWithId:(NSString*)jobId{
    
    NSDictionary *jobsDictionary = [MemoryManagement getObjectFromMemoryInFolder:@"myJobsDictionary"];
    if (jobsDictionary == nil || [jobsDictionary objectForKey:jobId] == nil) {
        return nil;
    }else{
        return [jobsDictionary objectForKey:jobId];
    }
}

+(void) deleteJobWithId:(NSString*)jobId{
    NSMutableDictionary *jobsDictionary = [[MemoryManagement getObjectFromMemoryInFolder:@"myJobsDictionary"] mutableCopy];

    if (jobsDictionary != nil && [jobsDictionary objectForKey:jobId] != nil) {
        [jobsDictionary removeObjectForKey:jobId];
        [MemoryManagement saveObjectInMemory:jobsDictionary toFolder:@"myJobsDictionary"];
    }
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

+(void) newApplicantsArray:(NSArray*)applicantsArray forJobWithId:(NSString*)jobId{
    
    NSMutableDictionary *jobsDictionary = [[MemoryManagement getObjectFromMemoryInFolder:@"myJobsDictionary"] mutableCopy];

    NSMutableDictionary *job = [[jobsDictionary objectForKey:jobId] mutableCopy];
    
    if (job == nil) { //job not in memory
        return;
    }
    
    if (applicantsArray != nil ) {
        job[@"acceptedApplicants"] = applicantsArray;
    }else{
        NSLog(@"empty array  app :%@", [applicantsArray description]);
        [job removeObjectForKey:@"acceptedApplicants"];
    }
    
    
    NSLog(@"job id : %@", jobId);
    NSLog(@"array applicants :%@", [applicantsArray description]);
    
    [jobsDictionary setObject:job forKey:jobId];
    
    [MemoryManagement saveObjectInMemory:jobsDictionary toFolder:@"myJobsDictionary"];
    
    //check
    NSLog(@"new job dic new applicatn : %@", [MemoryManagement getObjectFromMemoryInFolder:@"myJobsDictionary"]);
}

+(void) updateApplicantsForJobsWithDictionary:(NSDictionary*)applicantsToMyJobsDictionary{
    
    NSMutableDictionary *jobsDictionary = [[MemoryManagement getObjectFromMemoryInFolder:@"myJobsDictionary"] mutableCopy];

    for (NSString *myJobId in [jobsDictionary allKeys]) {
        
        if ([applicantsToMyJobsDictionary objectForKey:myJobId]) {
            
            NSLog(@"job id to update : %@", myJobId);
            
            NSMutableDictionary *myJobToUpdate = [[jobsDictionary objectForKey:myJobId] mutableCopy];
            myJobToUpdate[@"acceptedApplicants"] = [applicantsToMyJobsDictionary objectForKey:myJobId];
            
            NSLog(@"myJobToUpdate[@'acceptedApplicants'] : %@",[myJobToUpdate[@"acceptedApplicants"] description] );
            
            
            [jobsDictionary setObject:myJobToUpdate forKey:myJobId];
        }
    }
    [MemoryManagement saveObjectInMemory:jobsDictionary toFolder:@"myJobsDictionary"];
    NSLog(@"jobsDictionary_updated : %@", [jobsDictionary description]);
}



@end