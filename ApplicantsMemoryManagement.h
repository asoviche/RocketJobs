//
//  ApplicantsMemoryManagement.h
//  Cash Now
//
//  Created by amaury soviche on 26/02/15.
//  Copyright (c) 2015 Amaury Soviche. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ApplicantsMemoryManagement : NSObject

+ (void) saveApplicant:(NSDictionary*) applicant withImagePP:(UIImage*) imagePP;
+ (void) deleteApplicantWithId:(NSString*)applicantId;

@end
