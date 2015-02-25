//
//  ProfileMVPViewController.h
//  Cash Now
//
//  Created by amaury soviche on 25/02/15.
//  Copyright (c) 2015 Amaury Soviche. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AddDescriptionView.h"
#import "AddPhoneNumber.h"

@interface ProfileMVPViewController : UIViewController <UIActionSheetDelegate, UIGestureRecognizerDelegate, AddDescriptionDelegate, AddPhoneNumberDelegate>

@end
