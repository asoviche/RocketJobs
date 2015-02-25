//
//  ProfileJobsProviderViewController.m
//  GPUImage
//
//  Created by amaury soviche on 16.05.14.
//  Copyright (c) 2014 Brad Larson. All rights reserved.
//

#import "ProfileJobsProviderViewController.h"


@interface ProfileJobsProviderViewController ()

@property (strong, nonatomic) IBOutletCollection(UIImageView) NSArray *images;

@property (strong, nonatomic) IBOutletCollection(UIActivityIndicatorView) NSArray *activityIndicatorArray;

@property (strong, nonatomic) IBOutlet UILabel *AboutName;
@property (strong, nonatomic) IBOutlet UILabel *LabelAbout;



@property (strong, nonatomic) IBOutlet UIPageControl *pageControl;



@end

@implementation ProfileJobsProviderViewController{
    int ActualImage;
}
@synthesize scrollView;

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
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    ActualImage = 0;
    
    
    NSLog(@"user : %@", [self.UserJobProvider description]);
    
    NSString *userID = self.UserJobProvider.objectId;
    
    // Get the user from a non-authenticated method
    PFQuery *query = [PFUser query];
    PFUser *user = (PFUser *)[query getObjectWithId:userID];
    
    self.AboutName.text =  [NSString stringWithFormat:@"%@",user[@"name"]];
    self.LabelAbout.text = user[@"About"];
    
    self.navigationItem.title = user[@"name"];
    
    for (UIActivityIndicatorView *activityIndicator in self.activityIndicatorArray) {
        [activityIndicator startAnimating];
        activityIndicator.hidden=NO;
    }
    
    for (UIImageView *image in self.images) {
        image.contentMode = UIViewContentModeScaleAspectFit;
        
        image.layer.masksToBounds = YES;
        image.layer.cornerRadius = 1;
        
        //place the uiactivity indicator in the middle of the images
        UIActivityIndicatorView *a = self.activityIndicatorArray[[self.images indexOfObject:image]];
        [image addSubview:a];
        a.frame = CGRectMake(a.superview.frame.size.width/2, a.superview.frame.size.height/2, a.frame.size.width, a.frame.size.height);
        
//        image.layer.shadowOffset = CGSizeMake(0.5, 0.5);
//        image.layer.shadowRadius = 4;
//        image.layer.shadowOpacity = 0.2;
    }
    
    
    //scrollView
    int compte=0;
    for (int i = 0; i<=5; i++) {
        if (user[[NSString stringWithFormat:@"Image%d", i]] != nil) {
            compte ++;
            self.pageControl.numberOfPages = compte;
        }
        NSLog(@"compte : %d", compte);
    }
    
    
    self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width * compte, self.scrollView.frame.size.height);
    self.scrollView.pagingEnabled = YES;
    //self.scrollView.delegate=self;
    

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
    
    CGRect frameScroll = self.scrollView.frame;
    frameScroll.origin.x = (ActualImage-1) * self.scrollView.frame.size.width;  //change
    imageView.frame = frameScroll;
    
    [self.scrollView addSubview:imageView];
    //[self.scrollView addSubview:self.pageControl];
}


- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    self.pageControl.currentPage = floorf(self.scrollView.contentOffset.x/self.scrollView.frame.size.width);
    NSLog(@"a");
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    NSLog(@"b");
}

- (IBAction)back:(UIButton *)sender {
//    [self dismissViewControllerAnimated:YES completion:nil];
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
