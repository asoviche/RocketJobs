//
//  LogInViewControllerCustom.h
//  Cash Now
//
//  Created by amaury soviche on 13.05.14.
//  Copyright (c) 2014 Amaury Soviche. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LogInViewControllerCustom : UIViewController

@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *activityIndicator;

- (IBAction)loginButtonTouchHandler:(id)sender;

@end
