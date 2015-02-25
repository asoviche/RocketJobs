//
//  ProfileJobsProviderViewController.h
//  GPUImage
//
//  Created by amaury soviche on 16.05.14.
//  Copyright (c) 2014 Brad Larson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface ProfileJobsProviderViewController : UIViewController<UIScrollViewDelegate>

@property (strong,nonatomic) PFUser *UserJobProvider;

@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;

@end
