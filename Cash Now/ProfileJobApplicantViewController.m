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

@property (strong, nonatomic) IBOutlet UILabel *AboutName;


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
    
    // Get the user from a non-authenticated method
//    PFQuery *query = [PFUser query];
//    PFUser *user = (PFUser *)[query getObjectWithId:self.UserJobProvider];
    
    self.AboutName.hidden = YES;
    self.textViewDescription.hidden=YES;
    
    self.navigationItem.title = @"Loading...";
    
    PFQuery *query2 = [PFUser query];
    [query2 getObjectInBackgroundWithId:self.UserJobProvider block:^(PFObject *user, NSError *error) {
        // Do something with the returned PFObject in the gameScore variable.
        
        if (error) {
            return ;
        }
        
//        self.AboutName.text =  [NSString stringWithFormat:@"%@",user[@"name"]];
//        self.AboutName.hidden = NO;
        
        self.textViewDescription.text = user[@"About"];
        if (self.textViewDescription.text.length > 0 ) {
            self.textViewDescription.hidden = NO;
        }
        
        self.navigationItem.title = user[@"name"];
        
        for (UIActivityIndicatorView *activityIndicator in self.activityIndicatorArray) {
            [activityIndicator startAnimating];
            activityIndicator.hidden=NO;
        }
        
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
        
        
        PFFile *userImageFile = user[@"Image5"];
        if (userImageFile==nil) {
            [self.activityIndicatorArray[5] stopAnimating];
            UIActivityIndicatorView *a = self.activityIndicatorArray[5];
            a.hidden=YES;
        }
        NSLog(@"image : %@",[userImageFile description]);
        [userImageFile getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error) {
            if (!error) {
                
                [self addPicture:5 Data:imageData];
            }
        }];
        
        PFFile *userImageFile4 = user[@"Image4"];
        if (userImageFile4==nil) {
            [self.activityIndicatorArray[4] stopAnimating];
            UIActivityIndicatorView *a = self.activityIndicatorArray[4];
            a.hidden=YES;
        }
        [userImageFile4 getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error) {
            if (!error) {
                [self addPicture:4 Data:imageData];
            }
        }];
        
        PFFile *userImageFile3 = user[@"Image3"];
        if (userImageFile3==nil) {
            [self.activityIndicatorArray[3] stopAnimating];
            UIActivityIndicatorView *a = self.activityIndicatorArray[3];
            a.hidden=YES;
        }
        [userImageFile3 getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error) {
            if (!error) {
                [self addPicture:3 Data:imageData];
            }
        }];
        
        PFFile *userImageFile2 = user[@"Image2"];
        if (userImageFile2==nil) {
            [self.activityIndicatorArray[2] stopAnimating];
            UIActivityIndicatorView *a = self.activityIndicatorArray[2];
            a.hidden=YES;
        }
        [userImageFile2 getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error) {
            if (!error) {
                [self addPicture:2 Data:imageData];
            }
        }];
        
        PFFile *userImageFile1 = user[@"Image1"];
        if (userImageFile1==nil) {
            [self.activityIndicatorArray[1] stopAnimating];
            UIActivityIndicatorView *a = self.activityIndicatorArray[1];
            a.hidden=YES;
        }
        [userImageFile1 getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error) {
            if (!error) {
                [self addPicture:1 Data:imageData];
            }
        }];
        
        PFFile *userImageFile0 = user[@"Image0"];
        if (userImageFile0==nil) {
            [self.activityIndicatorArray[0] stopAnimating];
            UIActivityIndicatorView *a = self.activityIndicatorArray[0];
            a.hidden=YES;
        }
        [userImageFile0 getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error) {
            if (!error) {
                [self addPicture:0 Data:imageData];
            }
        }];
        
        
    }];
}


-(void) addPicture : (int) nb Data : (NSData *) imageData {
    NSLog(@"image5");
    UIImage *imageProfile = [UIImage imageWithData:imageData];
    
    UIImageView *imageView = self.images[nb];
    imageView.image = imageProfile;
    
    [self.activityIndicatorArray[nb] stopAnimating];
    UIActivityIndicatorView *a = self.activityIndicatorArray[nb];
    a.hidden=YES;
    
    //scrollView
    ActualImage ++;
    
    imageView.frame = self.scrollView.frame;
    
    imageView.frame = CGRectMake(0, 0, self.scrollView.frame.size.width, self.scrollView.frame.size.height);
    CGRect frameScroll = imageView.frame;
    frameScroll.origin.x = (ActualImage-1) * self.scrollView.frame.size.width;
    imageView.frame = frameScroll;
    
    
    [self.scrollView addSubview:imageView];
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


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
