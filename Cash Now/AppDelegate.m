//
//  AppDelegate.m
//  Cash Now
//
//  Created by amaury soviche on 06.05.14.
//  Copyright (c) 2014 Amaury Soviche. All rights reserved.
//

#import "AppDelegate.h"
#import <Parse/Parse.h>
#import "ViewController.h"
#import <ParseFacebookUtils/PFFacebookUtils.h>

#import "LogInViewControllerCustom.h"

@implementation AppDelegate{
//    BOOL allowCheckDatabase;
}



//receives the notification when the application is open from a notification
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.

    //PARSE
    [Parse setApplicationId:@"7tBiHO4i8Pa6UuRyb34KrP7O4mpRaO7Z52IXgYZi"
                  clientKey:@"PjxJwHgYRmQvEezJwBbfFoqDioJidGyuv2rUrklv"];
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    
    //FACEBOOK
    [PFFacebookUtils initializeFacebook];
    
    //TWITTER
    [PFTwitterUtils initializeWithConsumerKey:@"2479959061-FkXN3UqR2LJPXLs2zjRz9V7EY4LEFKSPRCYg2YG"
                               consumerSecret:@"BwBRZI8PfGUbL3ggFM1CXjU3FgJygZInSeh2Vqr7RjbBK"];
    

    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    //analytics for push notifications
    if (application.applicationState != UIApplicationStateBackground) {
        // Track an app open here if we launch with a push, unless
        // "content_available" was used to trigger a background push (introduced
        // in iOS 7). In that case, we skip tracking here to avoid double
        // counting the app-open.
        BOOL preBackgroundPush = ![application respondsToSelector:@selector(backgroundRefreshStatus)];
        BOOL oldPushHandlerOnly = ![self respondsToSelector:@selector(application:didReceiveRemoteNotification:fetchCompletionHandler:)];
        BOOL noPushPayload = ![launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
        if (preBackgroundPush || oldPushHandlerOnly || noPushPayload) {
            [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
        }
    }
    
    // Register for Push Notitications, if running iOS 8
    if ([application respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        UIUserNotificationType userNotificationTypes = (UIUserNotificationTypeAlert |
                                                        UIUserNotificationTypeBadge |
                                                        UIUserNotificationTypeSound);
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes
                                                                                 categories:nil];
        [application registerUserNotificationSettings:settings];
        [application registerForRemoteNotifications];
    } else {
        // Register for Push Notifications before iOS 8
        [application registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge |
                                                         UIRemoteNotificationTypeAlert |
                                                         UIRemoteNotificationTypeSound)];
    }
    
    
//    LogInViewControllerCustom *loginController=[[UIStoryboard storyboardWithName:@"Storyboard" bundle:nil] instantiateViewControllerWithIdentifier:@"LogInVc"]; //or the homeController
//    UINavigationController *navController=[[UINavigationController alloc]initWithRootViewController:loginController];
//    self.window.rootViewController=navController;
    
//    if ([PFUser currentUser]) {
//        NSLog(@"good categroy 2");
//        [self GoToDataBaseToRefreshMessages];
//    }
    
    
//    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//    [defaults addObserver:self
//               forKeyPath:@"ListConversationsHaveToBeUpdated"
//                  options:NSKeyValueObservingOptionNew
//                  context:NULL];
    

    return YES;
}

//receives the notification when the application is open !
- (void)application:(UIApplication *)application
didReceiveRemoteNotification:(NSDictionary *)userInfo
fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))handler {
    
//    //analytics for push notifications
//    if (application.applicationState == UIApplicationStateInactive) {
//        // The application was just brought from the background to the foreground,
//        // so we consider the app as having been "opened by a push notification."
//        [PFAnalytics trackAppOpenedWithRemoteNotificationPayload:userInfo];
//    }
//    
//    NSLog(@"notification : %@", [userInfo description]);
//    
//    // HANDLE THE RECEIVED NOTIFICATION ********************************* MESSAGE / APPLICANT
//    
//    if ([PFUser currentUser] && [userInfo objectForKey:@"notifMessage"] ) {
//        NSLog(@"good categroy");
//        [self GoToDataBaseToRefreshMessages];
//    }
//    else if([PFUser currentUser] && [userInfo objectForKey:@"deleteConv"]){
//        [self deleteConversationForJobId:[userInfo objectForKey:@"JobId"] andOtherUserId:[userInfo objectForKey:@"userId"]];
//    }
//    
//    NSLog(@" current vc : %@", self.window.rootViewController.navigationController.visibleViewController.class);
}

- (void)application:(UIApplication *)application
didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    // Store the deviceToken in the current Installation and save it to Parse.
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    [currentInstallation saveInBackground];
}
//
////callback for push notifications
//- (void)application:(UIApplication *)application
//didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)newDeviceToken {
//    // Store the deviceToken in the current installation and save it to Parse.
//    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
//    [currentInstallation setDeviceTokenFromData:newDeviceToken];
//    [currentInstallation addUniqueObject:@"Giants" forKey:@"channels"];
//    [currentInstallation saveInBackground];
//}
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error{
    NSLog(@"error : %@", [error description]);
}
//receive notifications when the app is active
- (void)application:(UIApplication *)application
didReceiveRemoteNotification:(NSDictionary *)userInfo {
    [PFPush handlePush:userInfo];
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    return [FBAppCall handleOpenURL:url
                  sourceApplication:sourceApplication
                        withSession:[PFFacebookUtils session]];
}


- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    [FBAppCall handleDidBecomeActiveWithSession:[PFFacebookUtils session]];
    
    //clear the badge when the application is opened
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    if (currentInstallation.badge != 0) {
        currentInstallation.badge = 0;
        [currentInstallation saveEventually];
    }
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [[PFFacebookUtils session] close];
}








//CONVERSATION METHODS

-(void) GoToDataBaseToRefreshMessages{
    
//    allowCheckDatabase = NO;
    
    //look database for all messages with the good receipient id
//    dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    
        PFQuery *queryAllMessages = [PFQuery queryWithClassName:@"Messages"];
        [queryAllMessages whereKey:@"recipientIds" equalTo:[PFUser currentUser].objectId];
        [queryAllMessages whereKey:@"seen" equalTo:@"NO"];
        [queryAllMessages findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            
            for (PFObject *message in objects) {
                
                PFQuery *queryJob = [PFQuery queryWithClassName:@"Job"];
                [queryJob getObjectInBackgroundWithId:message[@"JobId"] block:^(PFObject *Job, NSError *error) {
                    
                    NSLog(@"author of the job : %@ and current user : %@", Job[@"Author"] , (PFUser*)[PFUser currentUser]);
                    NSString *KeyForConversation;
                    
                    
                    if ([[Job[@"Author"] objectId] isEqualToString: [PFUser currentUser].objectId] ) {
                        KeyForConversation = [NSString stringWithFormat:@"%@ %@ %@ %@", message[@"JobId"], message[@"senderIds"],@"MyJob:YES", Job[@"Description"] ];
                        NSLog(@"from me");
                    }else{
                        KeyForConversation = [NSString stringWithFormat:@"%@ %@ %@ %@", message[@"JobId"], message[@"senderIds"],@"MyJob:NO", Job[@"Description"] ];
                        NSLog(@"not from me : %@ and my obj id", [Job[@"Author"] objectId] );
                    }
                    
                    //create and store the message
                    NSDictionary *Message = [[NSDictionary alloc] initWithObjectsAndKeys:message[@"Content"], @"Content" ,
                                             @"NO", @"FromMe",
                                             message.objectId ,@"MessageID",
                                             message.createdAt, @"Date",nil];
                    
                    //create conversqation OR store message in previous conversation
                    [self storeMessageWith_KeyForConversation:KeyForConversation andMessage:Message];
                    
                    message[@"seen"]=@"YES";
                    [message saveInBackground];
                    
                    
                    
//                    //store the image of the job
//                    PFFile *ImageFile = Job[@"Picture"];
//                    [ImageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
//                        if (!error) {
//                            
//                            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//                            NSString *documentsDirectory = [paths objectAtIndex:0];
//                            NSString *imagePath =[documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png",Job.objectId]];
//                            
//                            if (![data writeToFile:imagePath atomically:NO])
//                            {
//                                NSLog((@"Failed to cache image data to disk"));
//                                
//                            }
//                            else
//                            {
//                                NSLog(@"the cachedImagedPath is %@",data);
//                                [[NSUserDefaults standardUserDefaults] setObject:imagePath forKey: Job.objectId];
//                                [[NSUserDefaults standardUserDefaults] synchronize];
//                            }
//                            
//                        }
//                    }];
                    
                }];
            }
//            allowCheckDatabase = YES;
        }];
        
//    });
}


-(void) storeMessageWith_KeyForConversation : (NSString *) KeyForConversation andMessage:(NSDictionary*)FirstMessageDescription{
    
    NSError *error;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); //1
    NSString *documentsDirectory = [paths objectAtIndex:0]; //2
    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"Conversations.plist"]; //3
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if (![fileManager fileExistsAtPath: path]) //4
    {
        NSLog(@"file does not exist");
        NSString *bundle = [[NSBundle mainBundle] pathForResource:@"Conversations" ofType:@"plist"]; //5
        [fileManager copyItemAtPath:bundle toPath: path error:&error]; //6
    }
    
    //all the stuff in the plist file
    NSMutableDictionary *data = [[NSMutableDictionary alloc] initWithContentsOfFile: path];
    //NSLog(@"description plist before  : %@", [data description]);
    
    if ( ![data objectForKey:KeyForConversation]) { //no conversation yet : create one
        NSLog(@"create new conv");
        
        //store the name of the other user
        PFQuery *query = [PFUser query];
        NSString *otherUserName = [[[[KeyForConversation componentsSeparatedByString:@" "] objectAtIndex:1] componentsSeparatedByString:@" "]objectAtIndex:0];
        
        [query getObjectInBackgroundWithId:otherUserName block:^(PFObject *user, NSError *error) {

            //create dictionary to order jobs ( last massage date + BOOL seen )  //careful for date *******************************************************
            NSDictionary *JobState = [NSDictionary dictionaryWithObjectsAndKeys:[NSDate date], @"LastUpdate",
                                      @"NO", @"Seen" ,
                                      user[@"name"], @"otherUserName", nil]; //modif conv
            NSArray *array = [[NSArray alloc] initWithObjects: FirstMessageDescription , nil];
            
            NSDictionary *StateAndMessagesDic =[NSDictionary dictionaryWithObjectsAndKeys:JobState, @"JobState",
                                                array, @"ArrayMessages" , nil];
            [data setObject:StateAndMessagesDic forKey:KeyForConversation];
            
            
            if([data writeToFile:path atomically:YES])
            {
                NSLog(@"saved to plist");
                [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:@"areAllJobsSeen"];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
            
        }];
        
        //store the job in plist file
        PFQuery *queryJob = [PFQuery queryWithClassName:@"Job"];
        [queryJob getObjectInBackgroundWithId:[[KeyForConversation componentsSeparatedByString:@" "] objectAtIndex:0] block:^(PFObject *job, NSError *error) {
            
            
            //        PFObject *job = [PFQuery getObjectOfClass:@"Job" objectId:[[KeyForConversation componentsSeparatedByString:@" "] objectAtIndex:0]];
            [self saveJobToPlistWithId:job.objectId Picture:nil Description:job[@"Description"] Price:job[@"Price"] Hour:job[@"Hour"] Date:[job[@"DateJob"] description] location:nil];
            
            //store the image of the job
            PFFile *ImageFile = job[@"Picture"];
            [ImageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                if (!error) {
                    
                    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                    NSString *documentsDirectory = [paths objectAtIndex:0];
                    NSString *imagePath =[documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png",job.objectId]];
                    
                    if (![data writeToFile:imagePath atomically:NO])
                    {
                        NSLog((@"Failed to cache image data to disk"));
                        
                    }
                    else
                    {
                        NSLog(@"the cachedImagedPath is %@",data);
                        [[NSUserDefaults standardUserDefaults] setObject:imagePath forKey: job.objectId];
                        if([[NSUserDefaults standardUserDefaults] synchronize]){
                            NSLog(@"saved nsuserdefault");
                        }else{
                            NSLog(@"did not saved nsuserdefault");
                        }
                    }
                    
                }
            }];
            
        }];
        
    }else{ //already a conversation
        
        
        //NOW*******************************************************
        NSDictionary *StateAndMessages = [data objectForKey:KeyForConversation];
        
        NSMutableDictionary *JobState = [StateAndMessages objectForKey:@"JobState"];
        NSMutableArray *ArrayMessages = [StateAndMessages objectForKey:@"ArrayMessages"];
        
        //change the state of the conversation
        [JobState setObject:@"NO" forKey:@"Seen"];
        [JobState setObject:[NSDate date] forKey:@"LastUpdate"];
        
        //add the message to the array of messages
        [ArrayMessages addObject:FirstMessageDescription];
        
        NSDictionary *newStateAndMessages = [NSDictionary dictionaryWithObjectsAndKeys:JobState,@"JobState",ArrayMessages,@"ArrayMessages", nil];
        
        
        [data setObject:newStateAndMessages forKey:KeyForConversation];
        
        if ([data writeToFile:path atomically:YES]){
            NSLog(@"saved to file 1");
            
            [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:@"areAllJobsSeen"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            NSMutableArray *ListConversationsHaveToBeUpdated;
            if ([[NSUserDefaults standardUserDefaults]objectForKey:@"ArrayConvToBeUpdated"] == nil) {
                NSLog(@"nil for set");
                if (KeyForConversation)
                    ListConversationsHaveToBeUpdated = [NSMutableArray arrayWithObject:KeyForConversation];
            }else{
                NSLog(@"not nil for set");
                ListConversationsHaveToBeUpdated = [[NSUserDefaults standardUserDefaults]objectForKey:@"ArrayConvToBeUpdated"];
                [ListConversationsHaveToBeUpdated addObject:KeyForConversation];
                ListConversationsHaveToBeUpdated = [[[NSSet setWithArray: ListConversationsHaveToBeUpdated] allObjects] mutableCopy]; // delete multiple objects
            }
            NSLog(@"Set of converstion having to be updated : %@", [ListConversationsHaveToBeUpdated description]);
            [[NSUserDefaults standardUserDefaults] setObject:ListConversationsHaveToBeUpdated  forKey:@"ListConversationsHaveToBeUpdated"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        
        
    }
    
    
}


-(void) saveJobToPlistWithId:(NSString*)JobId Picture : (UIImage*)Image Description:(NSString*)description Price:(NSString*)price2 Hour:(NSString*)hour2 Date:(NSString*)date2 location:(PFGeoPoint*)geoPoint{
    
    NSError *error;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); //1
    NSString *documentsDirectory = [paths objectAtIndex:0]; //2
    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"JobsList.plist"]; //3
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if (![fileManager fileExistsAtPath: path]) //4
    {
        NSLog(@"file does not exist");
        NSString *bundle = [[NSBundle mainBundle] pathForResource:@"JobsList" ofType:@"plist"]; //5
        [fileManager copyItemAtPath:bundle toPath: path error:&error]; //6
    }
    
    //all the stuff in the plist file
    NSMutableDictionary *data = [[NSMutableDictionary alloc] initWithContentsOfFile: path];
    NSLog(@"plist for jobs  before : %@", data);
    
    //save the job
    
    NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys: description, @"description", price2, @"price", hour2 , @"hour", date2 , @"date" , [NSDate date] , @"last_update", @"NO" , @"seen",  nil];
    NSLog(@"description dictionary : %@",dictionary );
    
    if (![data objectForKey:JobId]) {
        
        [data setObject:dictionary forKey:JobId];
        
        if([data writeToFile:path atomically:YES]){
            NSLog(@"saved");
        }
    }
    
    NSLog(@"plist for jobs  after : %@", data);
}


-(void) deleteConversationForJobId:(NSString*)JobId andOtherUserId:(NSString*)otherUserId {
    
    //regenerate the key with job id and other user id
    
    PFQuery *query = [PFQuery queryWithClassName:@"Job"];
    [query getObjectInBackgroundWithId:JobId block:^(PFObject *Job, NSError *error) {
        
        NSString *KeyForConversation;
        
        if ([[Job[@"Author"] objectId] isEqualToString: [PFUser currentUser].objectId] ) {
            KeyForConversation = [NSString stringWithFormat:@"%@ %@ %@ %@", JobId, otherUserId , @"MyJob:YES", Job[@"Description"] ];
            NSLog(@"from me");
        }else{
            KeyForConversation = [NSString stringWithFormat:@"%@ %@ %@ %@", JobId, otherUserId , @"MyJob:NO", Job[@"Description"] ];
            NSLog(@"not from me : %@ and my obj id", [Job[@"Author"] objectId] );
        }
        
        //delete it from plist file
        NSError *error2;
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); //1
        NSString *documentsDirectory = [paths objectAtIndex:0]; //2
        NSString *path = [documentsDirectory stringByAppendingPathComponent:@"Conversations.plist"]; //3
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        
        if (![fileManager fileExistsAtPath: path]) //4
        {
            NSLog(@"file does not exist");
            NSString *bundle = [[NSBundle mainBundle] pathForResource:@"Conversations" ofType:@"plist"]; //5
            [fileManager copyItemAtPath:bundle toPath: path error:&error2]; //6
        }
        
        //all the stuff in the plist file
        NSMutableDictionary *data = [[NSMutableDictionary alloc] initWithContentsOfFile: path];
        
        //delete the conversation
        [data removeObjectForKey:KeyForConversation];
        [data writeToFile:path atomically:YES];
    }];
}


#pragma mark checkForJobsStates

-(BOOL) areJobsSeen{
    
    NSError *error;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); //1
    NSString *documentsDirectory = [paths objectAtIndex:0]; //2
    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"Conversations.plist"]; //3
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if (![fileManager fileExistsAtPath: path]) //4
    {
        NSString *bundle = [[NSBundle mainBundle] pathForResource:@"Conversations" ofType:@"plist"]; //5
        [fileManager copyItemAtPath:bundle toPath: path error:&error]; //6
    }
    
    NSMutableDictionary *savedStock = [[NSMutableDictionary alloc] initWithContentsOfFile: path];
    NSLog(@"STATE BASE : %@", [[savedStock allKeys] description]);
    
    for (NSString *key in [savedStock allKeys]) {
        
        NSDictionary * dicJob = [savedStock objectForKey:key];
        if ([[[dicJob objectForKey:@"JobState"] objectForKey:@"Seen" ] isEqualToString:@"NO"]) {
            
            return NO;
        }
    }
    
    return YES;
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if ([keyPath isEqualToString:@"ListConversationsHaveToBeUpdated"]) {
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:[self areJobsSeen]] forKey:@"areAllJobsSeen"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        });
    }
}

@end
