//
//  ProfileMVPViewController.m
//  Cash Now
//
//  Created by amaury soviche on 25/02/15.
//  Copyright (c) 2015 Amaury Soviche. All rights reserved.
//

#import "ProfileMVPViewController.h"
#import <ParseFacebookUtils/PFFacebookUtils.h>
#import <Parse/Parse.h>
#import "SWRevealViewController.h"
#import "ImageManagement.h"


@interface ProfileMVPViewController ()
@property (strong, nonatomic) IBOutlet UIImageView *imageViewPP;

@property (strong, nonatomic) IBOutlet UIButton *buttonAddDescription;
@property (strong, nonatomic) IBOutlet UIButton *buttonAddPhoneNumber;

@property (strong, nonatomic) IBOutlet UILabel *labelDescription;
@property (strong, nonatomic) IBOutlet UILabel *labelPhoneNumber;

@property (strong, nonatomic) IBOutlet UINavigationBar *navBar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *sidebarButton;

@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicatorImagePP;

@property(strong, nonatomic) AddDescriptionView *addDescriptionView;
@property(strong, nonatomic) AddPhoneNumber *addPhoneNumberView;
@end

@implementation ProfileMVPViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.sidebarButton.tintColor = [UIColor whiteColor];
//    self.navigationController.navigationBar.barTintColor = UIColorFromRGB(0x225378);
    // Set the side bar button action. When it's tapped, it'll show up the sidebar.
    _sidebarButton.target = self.revealViewController;
    _sidebarButton.action = @selector(revealToggle:);
    
    [[self navigationController] setNavigationBarHidden:YES animated:YES];

    //set title
    self.navBar.topItem.title = [[NSUserDefaults standardUserDefaults]stringForKey:@"name"];

    self.activityIndicatorImagePP.hidden = YES;
    
    //set image PP
    self.imageViewPP.layer.cornerRadius = 3;
    self.imageViewPP.clipsToBounds=YES;
    UIImage *imagePP = [ImageManagement getImageFromMemoryWithName:@"imagePP"];
    if (imagePP == nil) {
        imagePP = [UIImage imageNamed:@"iTunesArtwork.png"];
    }
    self.imageViewPP.image = imagePP;
    
    [self checkStates];
    
    self.addDescriptionView = [[AddDescriptionView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    self.addDescriptionView.delegate = self;
    [self.view addSubview:self.addDescriptionView];
    self.addDescriptionView.center = self.view.center;
    CGRect frameDescView = self.addDescriptionView.frame;
    frameDescView.origin.y = -self.addDescriptionView.frame.size.height;
    self.addDescriptionView.frame = frameDescView;
    
    self.addPhoneNumberView = [[AddPhoneNumber alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    self.addPhoneNumberView.delegate = self;
    [self.view addSubview:self.addPhoneNumberView];
    self.addPhoneNumberView.center = self.view.center;
    CGRect framePhoneView = self.addPhoneNumberView.frame;
    framePhoneView.origin.y = -self.addPhoneNumberView.frame.size.height;
    self.addPhoneNumberView.frame = framePhoneView;
    
}

-(void) checkStates{
    
    //set description
    self.labelDescription.text = [[NSUserDefaults standardUserDefaults]stringForKey:@"About"];
    if (self.labelDescription.text.length == 0) {
        self.labelDescription.hidden = YES;
        self.buttonAddDescription.hidden = NO;
    }else{
        self.buttonAddDescription.hidden = YES;
        self.labelDescription.hidden = NO;
    }
    
    
    //Set phone number
    self.labelPhoneNumber.text = [[NSUserDefaults standardUserDefaults]stringForKey:@"phoneNumber"];
    NSLog(@"label phone : %@", [[NSUserDefaults standardUserDefaults]stringForKey:@"phoneNumber"]);
    if (self.labelPhoneNumber.text.length == 0) {
        self.labelPhoneNumber.hidden = YES;
        self.buttonAddPhoneNumber.hidden = NO;

    }else{
        self.buttonAddPhoneNumber.hidden = YES;
        self.labelPhoneNumber.hidden = NO;
    }
}

#pragma mark AddDescriptionView delegate

-(void)AddDescriptionDelegate_saved{
    [self userInteractionEnabled:YES];
    [self checkStates];
    
    CGRect frame = self.addDescriptionView.frame;
    frame.origin.y = -self.addDescriptionView.frame.size.height;
    [UIView animateWithDuration:0.2 animations:^{
        self.addDescriptionView.frame = frame;
    } completion:^(BOOL finished) {
        self.labelDescription.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"About"];
    }];
    
    //save description in parse
    [PFUser currentUser][@"About"] = self.labelDescription.text;
    [[PFUser currentUser] saveEventually];
    
}

-(void) AddDescriptionDelegate_canceled{
    [self userInteractionEnabled:YES];

    CGRect frame = self.addDescriptionView.frame;
    frame.origin.y = -self.addDescriptionView.frame.size.height;
    [UIView animateWithDuration:0.2 animations:^{
        self.addDescriptionView.frame = frame;
    }];
}

#pragma mark AddPhoneNumberView delegate

-(void)AddPhoneNumberDelegate_saved{
    [self userInteractionEnabled:YES];
    [self checkStates];
    
    CGRect frame = self.addPhoneNumberView.frame;
    frame.origin.y = -self.addPhoneNumberView.frame.size.height;
    [UIView animateWithDuration:0.2 animations:^{
        self.addPhoneNumberView.frame = frame;
    } completion:^(BOOL finished) {
        self.labelPhoneNumber.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"phoneNumber"];
    }];
    
    //save phone number in parse
    [PFUser currentUser][@"phoneNumber"] = [[NSUserDefaults standardUserDefaults] objectForKey:@"phoneNumber"];
    [[PFUser currentUser] saveEventually];
}

-(void) AddPhoneNumberDelegate_canceled{
    [self userInteractionEnabled:YES];

    CGRect frame = self.addPhoneNumberView.frame;
    frame.origin.y = -self.addPhoneNumberView.frame.size.height;
    [UIView animateWithDuration:0.2 animations:^{
        self.addPhoneNumberView.frame = frame;
    }];
}

#pragma mark animations

-(void) animation_showAddDescriptionView{
    
    [UIView animateWithDuration:0.2 animations:^{
        self.addDescriptionView.center = self.view.center;
    }completion:^(BOOL finished) {
        [self.addDescriptionView showKeyboard];
    }];
        
}

-(void) animation_showAddPhoneNumberView{
    
    [UIView animateWithDuration:0.2 animations:^{
        self.addPhoneNumberView.center = self.view.center;
    }completion:^(BOOL finished) {
        [self.addPhoneNumberView showKeyboard];
    }];
    
}

-(void) userInteractionEnabled:(BOOL)enable{
    self.labelDescription.userInteractionEnabled = enable;
    self.labelPhoneNumber.userInteractionEnabled = enable;
    self.buttonAddPhoneNumber.userInteractionEnabled = enable;
    self.buttonAddDescription.userInteractionEnabled = enable;
    self.imageViewPP.userInteractionEnabled = enable;
}


#pragma mark IBActions

- (IBAction)addDescription:(id)sender {
    [self userInteractionEnabled:NO];
    [self animation_showAddDescriptionView];
}

- (IBAction)addPhoneNumber:(id)sender {
    [self userInteractionEnabled:NO];
    [self animation_showAddPhoneNumberView];
}

#pragma mark Gesture Recognizers

- (IBAction)touchedImageViewPP:(UITapGestureRecognizer*)sender {
    
    NSLog(@"touched");
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:@"Change profile picture from :" delegate:self cancelButtonTitle:@"cancel" destructiveButtonTitle:nil otherButtonTitles:@"Library", @"Camera", nil];
    actionSheet.tag=100;
    [actionSheet showInView:self.view];
    
}
- (IBAction)touchedDescription:(UITapGestureRecognizer *)sender {
    [self userInteractionEnabled:NO];
    [self animation_showAddDescriptionView];
    NSLog(@"desc");
}

- (IBAction)touchedPhoneNumber:(UITapGestureRecognizer*)sender {
    [self userInteractionEnabled:NO];
    [self animation_showAddPhoneNumberView];
    NSLog(@"phone");
    
}

#pragma mark Action Sheet delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if(actionSheet.tag == 100){
        if (buttonIndex == 0){
            [self takePicture:UIImagePickerControllerSourceTypePhotoLibrary];
        }else if(buttonIndex == 1){
            [self takePicture:UIImagePickerControllerSourceTypeCamera];
        }
    }
}

- (void)takePicture:(UIImagePickerControllerSourceType)sourceType{
    if ([UIImagePickerController isSourceTypeAvailable:
         UIImagePickerControllerSourceTypeCamera])
    {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.allowsEditing = YES;
        picker.sourceType = sourceType;
        
        [self presentViewController:picker animated:YES completion:NULL];
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    NSLog(@"taken");
    
    UIImage *picture_camera = [info objectForKey:UIImagePickerControllerEditedImage];
    // You have the image. You can use this to present the image in the next view like you require in `#3`.
    
    self.imageViewPP.alpha = 0.6;
    
    self.activityIndicatorImagePP.hidden = NO;
    [self.activityIndicatorImagePP startAnimating];
    [self.imageViewPP bringSubviewToFront:self.activityIndicatorImagePP];
    
    
    //save the photo into parse
    NSData *ParseimageData = UIImagePNGRepresentation(picture_camera);
    PFFile *imageFile = [PFFile fileWithName:@"image.png" data:ParseimageData];
    [PFUser currentUser][@"imagePP"] = imageFile;
    [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        
        self.imageViewPP.alpha = 1;
        self.activityIndicatorImagePP.hidden = YES;
        [self.activityIndicatorImagePP stopAnimating];
        
        if (succeeded && !error) {
            
            //save picture
            [ImageManagement saveImageWithData:UIImagePNGRepresentation(picture_camera) forName:@"imagePP"];
            self.imageViewPP.image = picture_camera;
            
        }else{
            //display error
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops" message:@"A problem occured while uploading your profile picture" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alert show];
        }
    }];
    
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}
//******************************************************************


- (IBAction)cancel:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
