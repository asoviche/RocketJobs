//
//  LogInViewControllerCustom.m
//  Cash Now
//
//  Created by amaury soviche on 13.05.14.
//  Copyright (c) 2014 Amaury Soviche. All rights reserved.
//

#import "LogInViewControllerCustom.h"
#import "ViewController.h"
#import <ParseFacebookUtils/PFFacebookUtils.h>

#import "ImageManagement.h"

@interface LogInViewControllerCustom ()
@property (strong, nonatomic) IBOutlet UIImage *profilePicture;
@property (strong,nonatomic) IBOutlet NSMutableData *imageData;
@property (strong, nonatomic) IBOutlet UIView *viewSupp;
@end

@implementation LogInViewControllerCustom


#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]


-(void) viewWillAppear:(BOOL)animated{
    self.view.backgroundColor = UIColorFromRGB(0x225378);
    self.viewSupp.backgroundColor =UIColorFromRGB(0x3c77a4);
    
    self.navigationController.navigationBar.barTintColor = UIColorFromRGB(0x225378);
//    self.navigationController.navigationBar.translucent = NO;
    [self.navigationController setNavigationBarHidden:YES];
    
    self.viewSupp.layer.cornerRadius = 2.0f;

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSLog(@"viewDidLoad");
    
    self.activityIndicator.hidden=YES;
}



#pragma mark - Login mehtods

/* Login to facebook method */
- (IBAction)loginButtonTouchHandler:(id)sender  {
    
    self.activityIndicator.hidden=NO;
    [self.activityIndicator startAnimating];
    
    // Set permissions required from the facebook user account
    NSArray *permissionsArray = @[];
    
    // Login PFUser using facebook
    [PFFacebookUtils logInWithPermissions:permissionsArray block:^(PFUser *user, NSError *error) {
      
        NSLog(@"user : %@", [user description]);
        
        if (!user) {
            
            [_activityIndicator stopAnimating]; // Hide loading indicator
            
            if (!error) {
                NSLog(@"Uh oh. The user cancelled the Facebook login.");
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Log In Error" message:@"Uh oh. The user cancelled the Facebook login." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Dismiss", nil];
                [alert show];
            } else {
                NSLog(@"Uh oh. An error occurred: %@", error);
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Log In Error" message:[error description] delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Dismiss", nil];
                [alert show];
            }
        } else if (user.isNew) {

            [self findInformationsFacebook];

            // Associate the device with a user
            PFInstallation *installation = [PFInstallation currentInstallation];
            installation[@"user"] = [PFUser currentUser];
            [installation saveInBackground];
            
            [self performSegueWithIdentifier:@"next" sender:self];

        } else {
            
            [[NSUserDefaults standardUserDefaults] setObject:user[@"About"] forKey:@"About"];
            [[NSUserDefaults standardUserDefaults] setObject:user[@"name"] forKey:@"name"];
            [[NSUserDefaults standardUserDefaults] setObject:user[@"phoneNumber"] forKey:@"phoneNumber"];
            [[NSUserDefaults standardUserDefaults] setObject:@"$" forKey:@"currency"];
            [[NSUserDefaults standardUserDefaults] setObject:@"20" forKey:@"distanceForSearch"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            //DOWLOAD IMAGE PP
            PFFile *userImageFile = user[@"imagePP"];
            [userImageFile getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error) {
                if (!error) {
                    [ImageManagement saveImageWithData:imageData forName:@"imagePP"];
                }
            }];
            
            // Associate the device with a user
            PFInstallation *installation = [PFInstallation currentInstallation];
            installation[@"user"] = [PFUser currentUser];
            installation[@"channels"] = @[@"Giants"];
            [installation setObject:[NSNumber numberWithBool:YES] forKey:@"active"];
            [installation saveInBackground];
            
            [self performSegueWithIdentifier:@"next" sender:self];
        }
    }];
    
    [_activityIndicator startAnimating]; // Show loading indicator until login is finished
}

-(void) findInformationsFacebook{
    NSLog(@"facebook infos");
    
    FBRequest *request = [FBRequest requestForMe];
    
    // Send request to Facebook
    [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        
        if (!error) {
         
            // result is a dictionary with the user's Facebook data
            NSDictionary *userData = (NSDictionary *)result;
            
            NSString *facebookID = userData[@"id"];
            [[NSUserDefaults standardUserDefaults] setObject:facebookID forKey:@"facebookID"];
            
            NSString *name = userData[@"name"];
            [[NSUserDefaults standardUserDefaults] setObject:name forKey:@"name"];
            [PFUser currentUser][@"name"] = name;

            [[NSUserDefaults standardUserDefaults] setObject:@"$" forKey:@"currency"];
            [[NSUserDefaults standardUserDefaults] setObject:@"20" forKey:@"distanceForSearch"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            [[PFUser currentUser] saveEventually];
            
            
            //IMAGE PROFILE
            
            _imageData = [[NSMutableData alloc] init]; // the data will be loaded in here
            NSURL *pictureURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large&return_ssl_resources=1", facebookID]];
            NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:pictureURL
                                                                      cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                                  timeoutInterval:2.0f];
            // Run network request asynchronously
            NSURLConnection *urlConnection = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
        }
    }];
}

// DOWNLOAD PROFILE PICTURE ***********************************
// Called every time a chunk of the data is received
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [_imageData appendData:data]; // Build the image
    
}
// Called when the entire image is finished downloading
- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    // Set the image in the header imageView
    
    _profilePicture = [[UIImage alloc] initWithData:_imageData];
    [ImageManagement saveImageWithData:_imageData forName:@"imagePP"];
    NSLog(@"image pp to save : %@", [ImageManagement getImageFromMemoryWithName:@"imagePP"]);

    
    
//    [[NSUserDefaults standardUserDefaults] setObject:UIImagePNGRepresentation(_profilePicture) forKey:@"profilePricture"];
//    [[NSUserDefaults standardUserDefaults] setObject:_imageData forKey:@"dataPhoto"];
//
//
//    //save the profile picture ( FACEBOOK ) into userDefault
//    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
//    NSData *imageData = [NSKeyedArchiver archivedDataWithRootObject:_profilePicture];
//    [userDefaults setObject:imageData forKey:@"Image : 5"];
//    
//
//
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        
//        //faire la photo
//        NSData *imageDataUpload = UIImagePNGRepresentation(_profilePicture);
//        PFFile *imageFile = [PFFile fileWithName:@"image.png" data:imageDataUpload];
//        
//        //    if (userImageFile5 == nil) {
//        [imageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
//            if (!error) {
//                [PFUser currentUser][@"Image5"] = imageFile;
//                [[PFUser currentUser] saveEventually];
//            }
//        }];
//        //}
//    });
//    
//
//    label About for profile page
//    [[NSUserDefaults standardUserDefaults] setObject:[PFUser currentUser][@"About"] forKey:@"About"];
//    
//
//
//    //TAKE ALL IMAGES OF THE PROFILE FROM PARSE
//    
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        
//        PFFile *userImageFile5 = [PFUser currentUser][[NSString stringWithFormat:@"Image5" ]];
//        
//       // if (userImageFile5 != nil) {
//            
//            [userImageFile5 getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error) {
//                if (!error) {
//                    NSLog(@"5");
//                    UIImage *imageProfile = [UIImage imageWithData:imageData];
//                    //store the image into the userDefault
//                    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
//                    NSData *imageDataProfile = [NSKeyedArchiver archivedDataWithRootObject:imageProfile];
//                    [userDefaults setObject:imageDataProfile forKey:[NSString stringWithFormat:@"Image : 5" ]];
//                    
//                    
//                }
//            }];
//       // }
//        
//        PFFile *userImageFile4 = [PFUser currentUser][[NSString stringWithFormat:@"Image4" ]];
//        [userImageFile4 getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error) {
//            if (!error) {
//                NSLog(@"4");
//                UIImage *imageProfile = [UIImage imageWithData:imageData];
//                //store the image into the userDefault
//                NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
//                NSData *imageDataProfile = [NSKeyedArchiver archivedDataWithRootObject:imageProfile];
//                [userDefaults setObject:imageDataProfile forKey:[NSString stringWithFormat:@"Image : 4" ]];
//                
//            }
//        }];
//        
//        PFFile *userImageFile3 = [PFUser currentUser][[NSString stringWithFormat:@"Image3" ]];
//        [userImageFile3 getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error) {
//            if (!error) {
//                NSLog(@"3");
//                UIImage *imageProfile = [UIImage imageWithData:imageData];
//                //store the image into the userDefault
//                NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
//                NSData *imageDataProfile = [NSKeyedArchiver archivedDataWithRootObject:imageProfile];
//                [userDefaults setObject:imageDataProfile forKey:[NSString stringWithFormat:@"Image : 3" ]];
//                
//            }
//        }];
//        
//        PFFile *userImageFile2 = [PFUser currentUser][[NSString stringWithFormat:@"Image2" ]];
//        [userImageFile2 getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error) {
//            if (!error) {
//                NSLog(@"2");
//                UIImage *imageProfile = [UIImage imageWithData:imageData];
//                //store the image into the userDefault
//                NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
//                NSData *imageDataProfile = [NSKeyedArchiver archivedDataWithRootObject:imageProfile];
//                [userDefaults setObject:imageDataProfile forKey:[NSString stringWithFormat:@"Image : 2" ]];
//                
//            }
//        }];
//        
//        PFFile *userImageFile1 = [PFUser currentUser][[NSString stringWithFormat:@"Image1" ]];
//        [userImageFile1 getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error) {
//            if (!error) {
//                NSLog(@"1");
//                UIImage *imageProfile = [UIImage imageWithData:imageData];
//                //store the image into the userDefault
//                NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
//                NSData *imageDataProfile = [NSKeyedArchiver archivedDataWithRootObject:imageProfile];
//                [userDefaults setObject:imageDataProfile forKey:[NSString stringWithFormat:@"Image : 1" ]];
//                
//            }
//        }];
//        
//        PFFile *userImageFile0 = [PFUser currentUser][[NSString stringWithFormat:@"Image0" ]];
//        [userImageFile0 getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error) {
//            if (!error) {
//                NSLog(@"0");
//                UIImage *imageProfile = [UIImage imageWithData:imageData];
//                //store the image into the userDefault
//                NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
//                NSData *imageDataProfile = [NSKeyedArchiver archivedDataWithRootObject:imageProfile];
//                [userDefaults setObject:imageDataProfile forKey:[NSString stringWithFormat:@"Image : 0" ]];
//                
//            }
//        }];
//    
//    });
    
    
    
}


@end
