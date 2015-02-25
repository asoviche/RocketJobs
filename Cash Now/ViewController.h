//
//  ViewController.h
//  Cash Now
//
//  Created by amaury soviche on 06.05.14.
//  Copyright (c) 2014 Amaury Soviche. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "GGDraggableView.h"
#import "FirstTimePhoneNumberView.h"

@interface ViewController : UIViewController<PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate, FirstTimePhoneNumberDelegate, GGDraggableViewDelegate>

@property (weak, nonatomic) IBOutlet UIBarButtonItem *sidebarButton;

@end
