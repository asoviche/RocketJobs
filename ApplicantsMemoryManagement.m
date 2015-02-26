//
//  ApplicantsMemoryManagement.m
//  Cash Now
//
//  Created by amaury soviche on 26/02/15.
//  Copyright (c) 2015 Amaury Soviche. All rights reserved.
//

#import "ApplicantsMemoryManagement.h"
#import "MemoryManagement.h"
#import "ImageManagement.h"

@implementation ApplicantsMemoryManagement

+ (void) saveApplicant:(NSDictionary*) applicant withImagePP:(UIImage*) imagePP{
    
    
    NSLog(@"save1234 : %@", [imagePP description]);
    
    //get the list of applicants
    NSMutableDictionary *applicantDictionary ;
    if ([MemoryManagement getObjectFromMemoryInFolder:@"applicantsDictionary"] == nil) {
        applicantDictionary = [NSMutableDictionary new];
        
    }else{
        applicantDictionary = [[MemoryManagement getObjectFromMemoryInFolder:@"applicantsDictionary"] mutableCopy];
    }

    //set the new applicant
    applicantDictionary[applicant[@"id"]] = applicant;


    NSLog(@"applicant dic : %@", [applicantDictionary description]);
    
    //store updated dic applicants
    [MemoryManagement saveObjectInMemory:applicantDictionary toFolder:@"applicantsDictionary"];
    
    //store the image
    [ImageManagement saveImageWithData:UIImagePNGRepresentation(imagePP) forName:applicant[@"id"]];
    
    //check
    NSLog(@"image : %@", [ImageManagement getImageFromMemoryWithName:applicant[@"id"]]);
    NSLog(@"new applicant dic : %@", [MemoryManagement getObjectFromMemoryInFolder:@"applicantsDictionary"]);
}

+ (void) deleteApplicantWithId:(NSString*)applicantId{
    
}

@end