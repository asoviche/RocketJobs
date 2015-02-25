//
//  ProfileViewController.m
//  Cash Now
//
//  Created by amaury soviche on 06.05.14.
//  Copyright (c) 2014 Amaury Soviche. All rights reserved.
//

#import "ProfileViewController.h"
#import <FacebookSDK/FacebookSDK.h>
#import <Parse/Parse.h>

#import "SWRevealViewController.h"

@interface ProfileViewController ()
@property (strong, nonatomic) IBOutlet UIButton *buttonCamera;
@property (strong, nonatomic) IBOutlet UIButton *buttonEdit;

@property (strong, nonatomic) IBOutlet UIImage *profilePicture;
@property (strong, nonatomic) IBOutlet UIImageView *image1;
@property (strong, nonatomic) IBOutletCollection(UIImageView) NSArray *images;

@property (strong, nonatomic) IBOutlet UILabel *informationsLabel;
@property (strong, nonatomic) IBOutlet UILabel *AboutName;
@property (strong, nonatomic) IBOutlet UILabel *LabelAbout;


@property (strong, nonatomic) IBOutlet UITextView *textViewDescription;
@property (strong, nonatomic) IBOutlet UILabel *description;



@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *buttonCollection;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *sidebarButton;
@property (strong, nonatomic) IBOutlet UIView *viewSupp;
@end

@implementation ProfileViewController{
    bool initialized;
    UIImageView *imageToBeModified;
    NSInteger tagToModifyImageView;
    
            #define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
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
    
    NSLog(@"did load");
    
    //menu button
    self.sidebarButton.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:0.14 green:0.8 blue:0.9 alpha:1];
        [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    [self.view setBackgroundColor:[UIColor colorWithRed:0.89 green:0.89 blue:0.89 alpha:1]];
        [self.viewSupp setBackgroundColor:[UIColor colorWithRed:0.89 green:0.89 blue:0.89 alpha:1]];
    
    // Set the side bar button action. When it's tapped, it'll show up the sidebar.
    _sidebarButton.target = self.revealViewController;
    _sidebarButton.action = @selector(revealToggle:);

    // Set the gesture
    [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];


    
    for (UIButton *button in self.buttonCollection) {
        button.hidden=YES;
        button.enabled=NO;
        [button setTitle:@"" forState:UIControlStateNormal];
        [button addTarget:self action:@selector(changePicture:) forControlEvents:UIControlEventTouchUpInside];
    }
}
- (IBAction)showSlideBar:(id)sender {
    self.description.enabled=NO;
    [self.textViewDescription setUserInteractionEnabled:NO];
    NSLog(@"desiable ");
}



- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSUInteger newLength = [textField.text length] + [string length] - range.length;
    return (newLength > 38) ? NO : YES;
}

- (IBAction)revealSlideController:(UIBarButtonItem *)sender {
    [self.description resignFirstResponder];
    [self.textViewDescription resignFirstResponder];
}

- (IBAction)touchedTextViewDescription:(UITapGestureRecognizer *)sender {
    if ([self.textViewDescription isUserInteractionEnabled]) {
        
    
    [self.textViewDescription becomeFirstResponder];
    
    NSLog(@"change desc func");
    
    [UIView animateWithDuration:0.2
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         
                         
                         self.view.frame = CGRectMake(0, -250, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height );
                         
                         
                         
                     }completion:^(BOOL finished){
                         // do something if needed
                     }];
    
    for (UIButton *button in self.buttonCollection) {
        button.hidden=YES;
    }
    }
    
    
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    NSLog(@"werwe");
    
    if([text isEqualToString:@"\n"]){
        NSLog(@"oooooh");
        return YES;
    }else if([[textView text] length] > 500){
        
        return NO;
    }
    
    return YES;
}

-(void) viewWillAppear:(BOOL)animated{
    //initialization
    NSLog(@"will appear");
    
    if (initialized == NO) {
        NSLog(@"will appear2");
        

        self.buttonEdit.titleLabel.font = [UIFont fontWithName:@"OpenSans-Light" size:16];
        self.informationsLabel.font = [UIFont fontWithName:@"OpenSans-Regular" size:18];
        self.AboutName.font = [UIFont fontWithName:@"OpenSans-Regular" size:16];
        self.LabelAbout.font = [UIFont fontWithName:@"OpenSans-Light" size:16];
        self.textViewDescription.font = [UIFont fontWithName:@"OpenSans-Light" size:14];
        
        NSShadow *shadow = [[NSShadow alloc] init];
        shadow.shadowColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.8];
        shadow.shadowOffset = CGSizeMake(0, 1);
        [[UINavigationBar appearance] setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:
                                                               
                                                               shadow, NSShadowAttributeName,
                                                               [UIFont fontWithName:@"OpenSans-Regular" size:21.0], NSFontAttributeName, nil]];

        
        self.navigationController.navigationBar.barTintColor = UIColorFromRGB(0x225378);
        
        self.description.hidden=YES;
//        self.textViewDescription.hidden=YES;
        self.description.alpha = 0;
        self.description.text = [[NSUserDefaults standardUserDefaults]stringForKey:@"About"];
        self.textViewDescription.text = [[NSUserDefaults standardUserDefaults]stringForKey:@"About"];
        self.description.textColor = UIColorFromRGB(0x225378);

        
        //label About
        self.LabelAbout.hidden = YES;
        if ([[NSUserDefaults standardUserDefaults]stringForKey:@"About"]) {
            self.LabelAbout.text = [[NSUserDefaults standardUserDefaults]stringForKey:@"About"];
        }else self.LabelAbout.text = @"";
        _LabelAbout.textColor = UIColorFromRGB(0x225378);
        
//        self.description.delegate=self;
        self.textViewDescription.delegate=self;
        [self.textViewDescription setUserInteractionEnabled:NO];

        
        self.AboutName.alpha=0;
        if ([[NSUserDefaults standardUserDefaults]stringForKey:@"name"]) {
            
            NSString *name = [[NSUserDefaults standardUserDefaults]stringForKey:@"name"];
            NSString *age = [[NSUserDefaults standardUserDefaults]stringForKey:@"age"];
            NSLog(@"age = %@" , age);
            
            _AboutName.text = [NSString stringWithFormat:@"About %@", name];
            _AboutName.textColor = UIColorFromRGB(0x225378);
            
//            UIFont *boldFont = [UIFont boldSystemFontOfSize:20];
//            NSDictionary *attrs = [NSDictionary dictionaryWithObjectsAndKeys:
//                                   boldFont, NSFontAttributeName,nil];
//            NSMutableAttributedString *attributedText =
//            [[NSMutableAttributedString alloc] initWithString:name
//                                                   attributes:attrs];
//            
//
//            [_informationsLabel setAttributedText:attributedText];
            _informationsLabel.text=name;
            _informationsLabel.textColor = UIColorFromRGB(0x225378);
        }
        
        // HANDLE THE IMAGES *********************************
        
        //prendre la photo de profil dans userdefault
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        UIImage *image_archived = (UIImage*)[NSKeyedUnarchiver unarchiveObjectWithData:[userDefaults objectForKey:@"Image : 5"]];
        if (image_archived) self.image1.image = image_archived;
        else self.image1.backgroundColor = [UIColor whiteColor];
        //self.image1.image =  _profilePicture;
        self.image1.layer.cornerRadius = 3;
        self.image1.clipsToBounds=YES;

    
        int i = 0 ;
        for (UIImageView *image in self.images) {
            
            image.alpha=0;// small images are hidden at the beginning
            image.clipsToBounds=YES;
            image.layer.cornerRadius = 3;

            
            //Retrieving the images in the small images
            UIImage *image_archived = (UIImage*)[NSKeyedUnarchiver unarchiveObjectWithData:[userDefaults objectForKey:[NSString stringWithFormat:@"Image : %ld", (unsigned long)[self.images indexOfObject:image]]]];
            if (image_archived) {
                image.image = image_archived;
                NSLog(@"image found");
            }else{
               [image setBackgroundColor:[UIColor whiteColor]];
                NSLog(@"image not found");
            }
            i++;
        }
        
        initialized = YES;
    }else{
        
        //replace all uielements after taking a picture from the camera
        [self UIEditMode];
   }
}

//function to replace all elements after taking a picture
-(void) UIEditMode{
    
    self.image1.frame = CGRectMake(self.image1.frame.origin.x,self.image1.frame.origin.y,195,195);
    
//    self.informationsLabel.frame = CGRectMake(self.informationsLabel.frame.origin.x , [UIScreen mainScreen].bounds.size.height +50, self.informationsLabel.frame.size.width, self.informationsLabel.frame.size.height);

    self.informationsLabel.frame = CGRectMake(self.informationsLabel.frame.origin.x + 170, self.informationsLabel.frame.origin.y , self.informationsLabel.frame.size.width, self.informationsLabel.frame.size.height);
    
    for (UIImageView *image in self.images) {
        image.alpha=1;
    }
    
//    self.description.hidden=NO;
    self.textViewDescription.hidden=NO;
    self.description.alpha = 1;
    self.AboutName.alpha=1;
    
    for (UIButton *button in self.buttonCollection) {
        button.hidden=NO;
        button.enabled=YES;
    }
}



- (IBAction)edit:(id)sender {
    
    NSLog(@"edit func");
    
    if ([self.buttonEdit.titleLabel.text isEqualToString:@"Edit"]) {
        
        [self.textViewDescription setUserInteractionEnabled:YES];
        
        [self.buttonEdit setTitle:@"Done" forState:UIControlStateNormal];
        
        [UIView animateWithDuration:0.4
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseIn
                         animations:^{
                             
                             self.image1.frame = CGRectMake(self.image1.frame.origin.x,self.image1.frame.origin.y,195,195);
                             
//                             self.informationsLabel.frame = CGRectMake(self.informationsLabel.frame.origin.x, [UIScreen mainScreen].bounds.size.height +50, self.informationsLabel.frame.size.width, self.informationsLabel.frame.size.height);

                            self.informationsLabel.frame = CGRectMake(self.informationsLabel.frame.origin.x - 170, self.informationsLabel.frame.origin.y , self.informationsLabel.frame.size.width, self.informationsLabel.frame.size.height);
                             
                             self.LabelAbout.frame = CGRectMake(self.LabelAbout.frame.origin.x, [UIScreen mainScreen].bounds.size.height + 70, self.LabelAbout.frame.size.width, self.LabelAbout.frame.size.height);
                             
                         }completion:^(BOOL finished){
                             // do something if needed
                             [self animation_small_pictures];
                             
                             for (UIButton *button in self.buttonCollection) {
                                 button.hidden=NO;
                                 button.enabled=YES;
                             }
                             
                         }];
        
    }
    else {
        //enregister les modifs dans parse et dans le telephone
        
        
        //if the keyboard is still active, risign it and put the view down
        [self tap:nil];
        
        [self.buttonEdit setTitle:@"Edit" forState:UIControlStateNormal];
        
        [self.textViewDescription setUserInteractionEnabled:NO];

        
        //gestion du label About et sauver dans parse
//        self.LabelAbout.text = self.description.text;
        self.LabelAbout.text = self.textViewDescription.text;
        [[NSUserDefaults standardUserDefaults] setObject:self.LabelAbout.text forKey:@"About"];
        [PFUser currentUser][@"About"] = self.LabelAbout.text;
        [[PFUser currentUser] saveInBackground];
        
        [UIView animateWithDuration:0.4
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseIn
                         animations:^{
                             
                             for (UIImageView *image in self.images) {
                                 image.alpha=0;
                             }
                             
                             self.description.alpha = 0;
//                             self.textViewDescription.alpha=0;
                             self.AboutName.alpha=0;
                             
                             
                         }completion:^(BOOL finished){
                             // do something if needed
                             [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
                                 
                                 self.image1.frame = CGRectMake(self.image1.frame.origin.x,self.image1.frame.origin.y,300,300);
                                
                                 self.informationsLabel.frame = CGRectMake(self.image1.frame.origin.x, 400, self.informationsLabel.frame.size.width, self.informationsLabel.frame.size.height);
                                 
                                 self.LabelAbout.frame = CGRectMake(self.LabelAbout.frame.origin.x, self.informationsLabel.frame.origin.y + 45, self.LabelAbout.frame.size.width, self.LabelAbout.frame.size.height);
                                 
                             } completion:^(BOOL finished) {
                                 
                             }];
                             
                         }];
    }
    
}

-(void) animation_small_pictures{
    
    NSLog(@"anim func");
    
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        
        for (UIImageView *image in self.images) {
            image.alpha=1;
        }
        
//        self.description.hidden=NO;
        self.textViewDescription.hidden=NO;
        self.description.alpha = 1;
        self.AboutName.alpha=1;
        
    } completion:^(BOOL finished) {
        
    }];
}

- (IBAction)tap:(id)sender {
    
    NSLog(@"tap func");
    
    if ([self.buttonEdit.titleLabel.text isEqualToString:@"Done"]) {
        
        //gestion du label About et sauver dans parse
//        self.LabelAbout.text = self.description.text;
        self.LabelAbout.text = self.textViewDescription.text;
        [[NSUserDefaults standardUserDefaults] setObject:self.LabelAbout.text forKey:@"About"];
        [PFUser currentUser][@"About"] = self.LabelAbout.text;
        [[PFUser currentUser] saveInBackground];

        
        [self.description resignFirstResponder];
        [self.textViewDescription resignFirstResponder];
        [self.view endEditing:YES];
        
        for (UIButton *button in self.buttonCollection) {
//            button.hidden=NO;
            button.enabled=NO;
        }
        
        [UIView animateWithDuration:0.2
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseIn
                         animations:^{
                             
                             
                             self.view.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height );
                             
                             
                             
                         }completion:^(BOOL finished){
                             // do something if needed
                         }];
    }
}

- (IBAction)changingDescription:(UITextField *)sender {
    NSLog(@"change desc func");
    
    [UIView animateWithDuration:0.2
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         
                         
                         self.view.frame = CGRectMake(0, -250, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height );
                         
                         
                         
                     }completion:^(BOOL finished){
                         // do something if needed
                     }];
    
    for (UIButton *button in self.buttonCollection) {
        button.hidden=YES;
    }
}



// TAKE PICTURE *************************************************

-(IBAction)changePicture :(UIButton *) sender {
    //on prend le numero du bouton dans la collection
    tagToModifyImageView = [self.buttonCollection indexOfObject:sender];
    [self takePicture:self];
}


- (IBAction)takePicture:(id)sender {
    if ([UIImagePickerController isSourceTypeAvailable:
         UIImagePickerControllerSourceTypeCamera])
    {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.allowsEditing = YES;
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        
        [self presentViewController:picker animated:YES completion:NULL];
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    
    [self dismissViewControllerAnimated:YES completion:nil];

}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *picture_camera = [info objectForKey:UIImagePickerControllerEditedImage];
    // You have the image. You can use this to present the image in the next view like you require in `#3`.
    
    // save the image in the userDefault
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSData *imageData = [NSKeyedArchiver archivedDataWithRootObject: picture_camera];
    [userDefaults setObject:imageData forKey:[NSString stringWithFormat:@"Image : %ld", (long)tagToModifyImageView]];
    
    if (tagToModifyImageView != 5) {
        NSLog(@"lol");
        UIImageView *imageToModify = _images[tagToModifyImageView];
        imageToModify.image = picture_camera;
    }
    else{ // grande image
        _image1.image = picture_camera;
    }
    
    //save the photo into parse
    NSData *ParseimageData = UIImagePNGRepresentation(picture_camera);
    PFFile *imageFile = [PFFile fileWithName:@"image.png" data:ParseimageData];
    NSString *ImageParseName = [NSString stringWithFormat:@"Image%ld", (long)tagToModifyImageView];
    [PFUser currentUser][ImageParseName] = imageFile;
    [[PFUser currentUser] saveInBackground];
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}
//******************************************************************


/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

//- (void)didReceiveMemoryWarning
//{
//    [super didReceiveMemoryWarning];
//    // Dispose of any resources that can be recreated.
//}


@end
