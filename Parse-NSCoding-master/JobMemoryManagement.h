//
//  JobMemoryManagement.h
//  Cash Now
//
//  Created by amaury soviche on 26/02/15.
//  Copyright (c) 2015 Amaury Soviche. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JobMemoryManagement : NSObject

+(void) saveJobInMemory:(NSDictionary*)job;
+(void) newApplicantWithId:(NSString*)applicantId forJobWithId:(NSString*)jobId;
+(void) newApplicantsArray:(NSArray*)applicantsArray forJobWithId:(NSString*)jobId;
+(void) updateApplicantsForJobsWithDictionary:(NSDictionary*)applicantsToMyJobsDictionary;
+(NSDictionary*) getJobFromMemoryWithId:(NSString*)jobId;
+(void) deleteJobWithId:(NSString*)jobId;
@end
