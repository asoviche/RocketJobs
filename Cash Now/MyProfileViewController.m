//
//  MyProfileViewController.m
//  Cash Now
//
//  Created by amaury soviche on 02/10/14.
//  Copyright (c) 2014 Amaury Soviche. All rights reserved.
//

#import "MyProfileViewController.h"
#import <ParseFacebookUtils/PFFacebookUtils.h>
#import <Parse/Parse.h>
#import "SWRevealViewController.h"


@interface MyProfileViewController ()
@property (strong, nonatomic) IBOutlet UIBarButtonItem *buttonEdit;

@property (strong, nonatomic) IBOutlet UIImageView *image1;

@property (strong, nonatomic) IBOutletCollection(UIImageView) NSArray *images;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *buttonCollection;

@property (strong, nonatomic) IBOutlet UILabel *informationsLabel;
@property (strong, nonatomic) IBOutlet UILabel *AboutName;

@property (strong, nonatomic) IBOutlet UITextView *textViewDescription;

@property (strong, nonatomic) IBOutlet UIView *viewSupp;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *sidebarButton;
@end

@implementation MyProfileViewController{
    
    bool initialized; //see if the view has already been loaded -> when loading a view for taking a picture
    UIImageView *imageToBeModified;
    NSInteger tagToModifyImageView;
    
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSLog(@"did load");
    
    self.sidebarButton.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.barTintColor = UIColorFromRGB(0x225378);
    // Set the side bar button action. When it's tapped, it'll show up the sidebar.
    _sidebarButton.target = self.revealViewController;
    _sidebarButton.action = @selector(revealToggle:);
    
    // Set the gesture
    [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    
    //menu button
    //    self.sidebarButton.tintColor = [UIColor whiteColor];
    //    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:0.14 green:0.8 blue:0.9 alpha:1];
    //    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    [self.view setBackgroundColor:[UIColor colorWithRed:0.89 green:0.89 blue:0.89 alpha:1]];
    [self.viewSupp setBackgroundColor:[UIColor colorWithRed:0.89 green:0.89 blue:0.89 alpha:1]];
    
    for (UIButton *button in self.buttonCollection) {
        button.hidden=YES;
        button.enabled=NO;
        [button setTitle:@"" forState:UIControlStateNormal];
        //        [button addTarget:self action:@selector(changePicture:) forControlEvents:UIControlEventTouchUpInside];
        [button addTarget:self action:@selector(chooseCameraLibrary:) forControlEvents:UIControlEventTouchUpInside];
        
    }
    
    //    self.informationsLabel.hidden=YES;
    
    self.AboutName.frame = CGRectMake(self.AboutName.frame.origin.x, self.informationsLabel.frame.origin.y, self.AboutName.frame.size.width, self.AboutName.frame.size.height);
}

-(void) viewWillAppear:(BOOL)animated{
    //initialization
    NSLog(@"will appear");
    
    self.AboutName.hidden=YES;
    
    if (initialized == NO) {
        
        
        self.textViewDescription.text = [[NSUserDefaults standardUserDefaults]stringForKey:@"About"];
        self.textViewDescription.delegate=self;
        [self.textViewDescription setUserInteractionEnabled:NO];
        
        self.AboutName.alpha=0;
        if ([[NSUserDefaults standardUserDefaults]stringForKey:@"name"]) {
            
            NSString *name = [[NSUserDefaults standardUserDefaults]stringForKey:@"name"];
            NSString *age = [[NSUserDefaults standardUserDefaults]stringForKey:@"age"];
            NSLog(@"age = %@" , age);
            
            _AboutName.text = [NSString stringWithFormat:@"About %@", name];
            _informationsLabel.text=name;
        }
        
        // HANDLE THE IMAGES *********************************
        
        //prendre la photo de profil dans userdefault
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        UIImage *image_archived = (UIImage*)[NSKeyedUnarchiver unarchiveObjectWithData:[userDefaults objectForKey:@"Image : 5"]];
        if (image_archived) self.image1.image = image_archived;
        else self.image1.backgroundColor = [UIColor whiteColor];
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
    
    //    self.informationsLabel.frame = CGRectMake(self.informationsLabel.frame.origin.x + 170, self.informationsLabel.frame.origin.y , self.informationsLabel.frame.size.width, self.informationsLabel.frame.size.height);
    
    for (UIImageView *image in self.images) {
        image.alpha=1;
    }
    
    self.textViewDescription.hidden=NO;
    //    self.informationsLabel.hidden=YES;
    self.AboutName.alpha=1;
    
    for (UIButton *button in self.buttonCollection) {
        button.hidden=NO;
        button.enabled=YES;
    }
}




- (IBAction)touchedTextViewDescription:(UITapGestureRecognizer *)sender {
    if ([self.textViewDescription isUserInteractionEnabled]) {
        
        [self.textViewDescription becomeFirstResponder];
        
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
    
    if([text isEqualToString:@"\n"]){
        return YES;
    }else if([[textView text] length] > 500){
        
        return NO;
    }
    
    return YES;
}




- (IBAction)edit:(id)sender {
    
    if ([self.buttonEdit.title isEqualToString:@"Edit"]) {
        
        [self.buttonEdit setTitle:@"Done"];
        [self.textViewDescription setUserInteractionEnabled:YES];
        
        [UIView animateWithDuration:0.4
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseIn
                         animations:^{
                             
                             self.image1.frame = CGRectMake(self.image1.frame.origin.x,self.image1.frame.origin.y,195,195);
                             
                             //                             self.informationsLabel.frame = CGRectMake(self.informationsLabel.frame.origin.x - 170, self.informationsLabel.frame.origin.y , self.informationsLabel.frame.size.width, self.informationsLabel.frame.size.height);
                             
                             self.textViewDescription.layer.borderWidth = 1;
                             self.textViewDescription.clipsToBounds =YES;
                             
                         }completion:^(BOOL finished){
                             // do something if needed
                             [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
                                 for (UIImageView *image in self.images) {
                                     image.alpha=1;
                                 }
                                 self.textViewDescription.hidden=NO;
                                 self.AboutName.alpha=1;
                             } completion:nil];
                             
                             for (UIButton *button in self.buttonCollection) {
                                 button.hidden=NO;
                                 button.enabled=YES;
                             }
                             
                         }];
        
    }
    else {
        
        [self.buttonEdit setTitle:@"Edit"];
        [self tap:nil];         //if the keyboard is still active, risign it and put the view down
        [self.textViewDescription setUserInteractionEnabled:NO];
        [self.textViewDescription resignFirstResponder];
        
        //gestion du label About et sauver dans parse
        [[NSUserDefaults standardUserDefaults] setObject:self.textViewDescription.text forKey:@"About"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [PFUser currentUser][@"About"] = self.textViewDescription.text;
        [[PFUser currentUser] saveInBackground];
        
        [UIView animateWithDuration:0.4
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseIn
                         animations:^{
                             
                             for (UIImageView *image in self.images) {
                                 image.alpha=0;
                             }
                             
                             self.AboutName.alpha=0;
                             
   
                            self.view.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height );
                                
                         }completion:^(BOOL finished){
                             // do something if needed
                             [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
                                 
                                 self.image1.frame = CGRectMake(self.image1.frame.origin.x,self.image1.frame.origin.y,300,300);
                                 
                                 //                                 self.informationsLabel.frame = CGRectMake(self.image1.frame.origin.x, 400, self.informationsLabel.frame.size.width, self.informationsLabel.frame.size.height);
                                 
                                 self.textViewDescription.layer.borderWidth = 0;
                                 self.textViewDescription.clipsToBounds =YES;
                                 
                             } completion:^(BOOL finished) {
                                 
                             }];
                             
                         }];
    }
    
}



- (IBAction)tap:(id)sender {
    
    NSLog(@"tap func");
    
    if ([self.buttonEdit.title isEqualToString:@"Done"]) {
        
        [[NSUserDefaults standardUserDefaults] setObject:self.textViewDescription.text forKey:@"About"];
        [[NSUserDefaults standardUserDefaults]synchronize];
        [PFUser currentUser][@"About"] = self.textViewDescription.text;
        [[PFUser currentUser] saveInBackground];
        
        [self.textViewDescription resignFirstResponder];
        [self.view endEditing:YES];
        
        for (UIButton *button in self.buttonCollection) {
            
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

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if(actionSheet.tag == 100){
        if (buttonIndex == 0){
            [self takePicture:UIImagePickerControllerSourceTypePhotoLibrary];
        }else if(buttonIndex == 1){
            [self takePicture:UIImagePickerControllerSourceTypeCamera];
        }
    }
}
-(void)chooseCameraLibrary:(UIButton*)button{
    
    NSLog(@"button tag for pic : %d", button.tag);
    tagToModifyImageView = [self.buttonCollection indexOfObject:button];
    
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:@"Please choose between :" delegate:self cancelButtonTitle:@"cancel" destructiveButtonTitle:nil otherButtonTitles:@"library", @"camera", nil];
    actionSheet.tag=100;
    [actionSheet showInView:self.view];
}

- (void)takePicture:(UIImagePickerControllerSourceType)sourceType{
    if ([UIImagePickerController isSourceTypeAvailable:
         UIImagePickerControllerSourceTypeCamera])
    {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.allowsEditing = YES;
        picker.sourceType = sourceType;
        //        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        //        picker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
        
        [self presentViewController:picker animated:YES completion:NULL];
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES completion:nil];
    //    self.AboutName.hidden = YES;
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    NSLog(@"taken");
    
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
    
    //    self.AboutName.hidden = YES;
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}
//******************************************************************


- (IBAction)cancel:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
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

//- (void)didReceiveMemoryWarning
//{
//    [super didReceiveMemoryWarning];
//    // Dispose of any resources that can be recreated.
//}




@end
