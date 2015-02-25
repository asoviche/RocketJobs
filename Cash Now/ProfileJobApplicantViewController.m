//
//  ProfileJobApplicantViewController.m
//  Cash Now
//
//  Created by amaury soviche on 16.05.14.
//  Copyright (c) 2014 Amaury Soviche. All rights reserved.
//

#import "ProfileJobApplicantViewController.h"

@interface ProfileJobApplicantViewController ()
@property (strong, nonatomic) IBOutletCollection(UIImageView) NSArray *images;
@property (strong, nonatomic) IBOutletCollection(UIActivityIndicatorView) NSArray *activityIndicatorArray;

@property (strong, nonatomic) IBOutlet UIImageView *imageViewPP;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicatorPP;

@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UITextView *textViewDescription;

@end

@implementation ProfileJobApplicantViewController{
    int ActualImage;
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.view setBackgroundColor:[UIColor colorWithRed:0.89 green:0.89 blue:0.89 alpha:1]];

    self.textViewDescription.hidden=YES;

    [self.activityIndicatorPP startAnimating];
    
    self.navigationItem.title = @"Loading...";
    
    PFQuery *query2 = [PFUser query];
    [query2 getObjectInBackgroundWithId:self.UserJobProvider block:^(PFObject *user, NSError *error) {
        // Do something with the returned PFObject in the gameScore variable.
        
        if (error) {
            return ;
        }
        
        self.textViewDescription.text = user[@"About"];
        if (self.textViewDescription.text.length > 0 ) {
            self.textViewDescription.hidden = NO;
        }
        
        self.navigationItem.title = user[@"name"];
    
        
        //scrollView
        int compte=0;
        for (int i = 0; i<=5; i++) {
            if (user[[NSString stringWithFormat:@"Image%d", i]] != nil) compte ++;
        }
        
        self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width * compte, self.scrollView.frame.size.height);
        self.scrollView.pagingEnabled = YES;
        [self.scrollView setContentMode:UIViewContentModeScaleAspectFit];
        self.scrollView.delegate=self;
        
        for (UIImageView *image in self.images) {
            
            image.layer.masksToBounds = YES;
            image.layer.cornerRadius = 1;
            image.contentMode = UIViewContentModeScaleAspectFit;
        }
        
        
        //dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        
        PFFile *userImageFile = user[@"imagePP"];
        NSLog(@"image : %@",[userImageFile description]);
        [userImageFile getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error) {
            if (!error) {
                UIImage *imagePP = [UIImage imageWithData:imageData];
                self.imageViewPP.image = imagePP;

            }
            self.activityIndicatorPP.hidden = YES;
            [self.activityIndicatorPP stopAnimating];
        }];
        
        
    }];
}



- (void) viewWillAppear:(BOOL)animated
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    NSLog(@"user : %@", [self.UserJobProvider description]);
  
}
- (IBAction)back:(UIButton *)sender {
    NSLog(@"back ");
    [self.navigationController popViewControllerAnimated:YES];
}



@end
