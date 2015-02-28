//
//  LaunchImageViewController.m
//  Cash Now
//
//  Created by amaury soviche on 28/02/15.
//  Copyright (c) 2015 Amaury Soviche. All rights reserved.
//

#import "LaunchImageViewController.h"
#import "LogInViewControllerCustom.h"
#import "ViewController.h"

#import <ParseFacebookUtils/PFFacebookUtils.h>

@interface LaunchImageViewController ()

@end

@implementation LaunchImageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIStoryboard*  sb = [UIStoryboard storyboardWithName:@"Storyboard" bundle:nil];
    
    // Check if user is cached and linked to Facebook, if so, bypass login
    if ([PFUser currentUser] && [PFFacebookUtils isLinkedWithUser:[PFUser currentUser]]) {
        
        ViewController *vc1 = [sb instantiateViewControllerWithIdentifier:@"jobVC"];
        [self.navigationController pushViewController:vc1 animated:NO];
    }else{
        
        LogInViewControllerCustom *vc1 = [sb instantiateViewControllerWithIdentifier:@"LogInVc"];
        [self.navigationController pushViewController:vc1 animated:NO];
    }

}


@end
