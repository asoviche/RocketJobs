//
//  ApplicantsForJobViewController.h
//  Cash Now
//
//  Created by amaury soviche on 27/02/15.
//  Copyright (c) 2015 Amaury Soviche. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>

#import <MessageUI/MFMessageComposeViewController.h>

@interface ApplicantsForJobViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate, MFMessageComposeViewControllerDelegate>

@property NSArray *arrayApplicantsFromJob;

@end
