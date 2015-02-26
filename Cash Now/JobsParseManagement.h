//
//  JobsParseManagement.h
//  Cash Now
//
//  Created by amaury soviche on 26/02/15.
//  Copyright (c) 2015 Amaury Soviche. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface JobsParseManagement : NSObject

+(void) applyForJobWithJobId:(NSString*)JobId;

@end
