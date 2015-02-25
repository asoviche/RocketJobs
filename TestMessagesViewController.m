//
//  TestMessagesViewController.m
//  Cash Now
//
//  Created by amaury soviche on 19/05/14.
//  Copyright (c) 2014 Amaury Soviche. All rights reserved.
//

#import "TestMessagesViewController.h"
#import <Parse/Parse.h>
#import "DetailJobForConversationViewController.h"
#import "ProfileJobApplicantViewController.h"


@interface TestMessagesViewController ()

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIView *viewMessage;
@property (strong, nonatomic) IBOutlet UITextView *TextView;
@property (strong, nonatomic) IBOutlet UIButton *buttonSend;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *buttonDetail;
@property(nonatomic) CGRect frameView;
@property(nonatomic) CGRect frameViewTableView;

@property (strong, nonatomic) IBOutlet UITextField *textFieldNameProfile;

@end

@implementation TestMessagesViewController{
    NSString *path;

    NSMutableArray *MessagesSortedByDate;
    
    int nbMessages;
    
    NSMutableArray *messagesFromTheOther;
    
    NSTimer *timer_observeChange;
    
    NSString *nameOtherUser;
    
//    Reachability *internetReachableFoo;
    
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

-(void) viewWillAppear:(BOOL)animated{
    
    self.textFieldNameProfile.delegate=self;
    
    self.TextView.font = [UIFont fontWithName:@"OpenSans-Regular" size:16];
    self.TextView.layer.cornerRadius=2;
    self.TextView.clipsToBounds=YES;
    self.buttonSend.layer.cornerRadius=2;
    self.buttonSend.clipsToBounds=YES;
    
    self.viewMessage.backgroundColor = UIColorFromRGB(0x225378);
    self.viewMessage.alpha = 0.8;
    self.viewMessage.hidden=YES;//changed
    
    self.buttonSend.titleLabel.font = [UIFont fontWithName:@"OpenSans-Regular" size:16];
    
    self.textFieldNameProfile.font = [UIFont fontWithName:@"OpenSans-Regular" size:16];
    
//    [self testInternetConnection];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults addObserver:self
               forKeyPath:@"ListConversationsHaveToBeUpdated"
                  options:NSKeyValueObservingOptionNew
                  context:NULL];
}

-(void) viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObserver:self forKeyPath:@"ListConversationsHaveToBeUpdated"];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.TextView.delegate=self;
    self.tableView.delegate=self;
    self.tableView.dataSource=self;
    
    self.tableView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - self.ChatView.frame.size.height);
    
    self.ChatView = [[THChatInput alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 60, self.view.frame.size.width, 60)];
    self.ChatView.hidden=NO;
    self.ChatView.delegate = self;
    [self.view addSubview:self.ChatView];
    self.ChatView.lblPlaceholder.text = @"";
    
    //************
    // acces plist file
    NSError *error;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); //1
    NSString *documentsDirectory = [paths objectAtIndex:0]; //2
    path = [documentsDirectory stringByAppendingPathComponent:@"Conversations.plist"]; //3
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if (![fileManager fileExistsAtPath: path]) //4
    {
        NSLog(@"tout bon");
        NSString *bundle = [[NSBundle mainBundle] pathForResource:@"Conversations" ofType:@"plist"]; //5
        [fileManager copyItemAtPath:bundle toPath: path error:&error]; //6
    }
    
    [self refreshAllMessages];
    
//    timer_observeChange = [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(ObserveChange) userInfo:nil repeats:YES];
    
    //set the view message frame
//    self.viewMessage.frame = CGRectMake(0, self.view.frame.size.height - self.viewMessage.frame.size.height, self.viewMessage.frame.size.width, self.viewMessage.frame.size.height);
//    
//    self.frameView = self.viewMessage.frame;
//    self.frameViewTableView = self.tableView.frame;
    
}

#pragma mark KVO

-(void)observeValueForKeyPath:(NSString *)keyPath
                     ofObject:(id)object
                       change:(NSDictionary *)change
                      context:(void *)context
{
    if ([keyPath isEqualToString:@"ListConversationsHaveToBeUpdated"]) {
        
        NSMutableArray *ListConversationsHaveToBeUpdated = [[[NSUserDefaults standardUserDefaults] objectForKey:@"ListConversationsHaveToBeUpdated"] mutableCopy];
        
        if ([ListConversationsHaveToBeUpdated containsObject:self.KeyForConversation]) {
            
            NSLog(@"this conv has to be updated ! ");
            [self refreshAllMessages];
            [ListConversationsHaveToBeUpdated removeObject:self.KeyForConversation];
            [[NSUserDefaults standardUserDefaults] setObject:ListConversationsHaveToBeUpdated forKey:@"ListConversationsHaveToBeUpdated"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }
}

#pragma mark TextViewChat

-(void)textViewDidBeginEditing:(UITextView *)textView{
    
    [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.viewMessage.frame = CGRectMake(0, self.view.frame.size.height - self.viewMessage.frame.size.height -216, self.view.frame.size.width, self.viewMessage.frame.size.height);
        self.tableView.frame = CGRectMake(0, 0, self.tableView.frame.size.width, self.viewMessage.frame.origin.y);
    } completion:^(BOOL finished) {
        
    }];
    
    if ([MessagesSortedByDate count] != 0) {
//        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:([MessagesSortedByDate count]-1)] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        if (self.tableView.contentSize.height > self.tableView.frame.size.height) {
//            [self.tableView setContentOffset:CGPointMake(0, self.tableView.contentSize.height - self.tableView.frame.size.height + 10)];
            CGPoint bottomOffset = CGPointMake(0, [self.tableView contentSize].height - self.tableView.frame.size.height);
            [self.tableView setContentOffset:bottomOffset animated:YES];
        }
    }
}

- (void)chat:(THChatInput*)input sendWasPressed:(NSString*)text{
    NSLog(@"sendWasPressed");

    [self send:nil];
}
//- (void)chatKeyboardWillShow:(THChatInput*)cinput{
//    
//    NSLog(@"chatKeyboardWillShow");
//    [UIView animateWithDuration:0.25f animations:^{
////        CGRect frame = self.tableView.frame;
////        frame.size.height = self.ChatView.frame.origin.y;
////        self.tableView.frame = frame;
//        self.tableView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.ChatView.frame.origin.y);
////        self.tableView.frame = CGRectMake(0, 0, self.tableView.frame.size.width, self.viewMessage.frame.origin.y);
//    }];
//    
//}

-(void) chatKeyboardDidShow:(THChatInput *)cinput{
//    [self.tableView setContentOffset:CGPointMake(0, self.tableView.contentSize.height - self.tableView.frame.size.height )];

    
    [UIView animateWithDuration:0.25f animations:^{
        //        CGRect frame = self.tableView.frame;
        //        frame.size.height = self.ChatView.frame.origin.y;
        //        self.tableView.frame = frame;
        self.tableView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.ChatView.frame.origin.y);
        //        self.tableView.frame = CGRectMake(0, 0, self.tableView.frame.size.width, self.viewMessage.frame.origin.y);
    } completion:^(BOOL finished) {
        
        if ([self.tableView contentSize].height  > self.tableView.frame.size.height) {
            
            CGPoint bottomOffset = CGPointMake(0, [self.tableView contentSize].height - self.tableView.frame.size.height);
            [self.tableView setContentOffset:bottomOffset animated:YES];
        }
    }];
}



-(void)chatKeyboardWillHide:(THChatInput *)cinput{
    [UIView animateWithDuration:0.25f animations:^{
        CGRect frame = self.tableView.frame;
        frame.size.height = self.ChatView.frame.origin.y;
        self.tableView.frame = frame;
        //        self.tableView.frame = CGRectMake(0, 0, self.tableView.frame.size.width, self.viewMessage.frame.origin.y);
    }];
}

- (IBAction)send:(UIButton *)sender {
    
    //check if the text lenght != 0 && not contains only white spaces
    if (self.ChatView.textView.text.length > 0 && [[self.ChatView.textView.text stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]] length] != 0) {
        
        //write datas
        NSMutableDictionary *data = [[NSMutableDictionary alloc] initWithContentsOfFile: path];
        
        NSDictionary *FakeMessage = [[NSDictionary alloc] initWithObjectsAndKeys:self.ChatView.textView.text,@"Content" ,
                                     (NSDate *)[NSDate date], @"Date",
                                     @"YES", @"FromMe",
                                     @"fake id",@"MessageID",nil];
        //        self.TextView.text = @"";
        [MessagesSortedByDate addObject:FakeMessage];
        
        //        if ([data objectForKey:self.KeyForConversation]) {
        //
        //            NSMutableArray *messages =[[NSMutableArray alloc] initWithArray: [[data objectForKey:self.KeyForConversation] allObjects]];
        //            [messages addObject:FakeMessage];
        //
        //            [data setObject:messages forKey:self.KeyForConversation];
        //
        //            if ([data writeToFile:path atomically:YES]){
        //                NSLog(@"saved to file");
        //            }
        //        }
        
        
        //save message to DB
        PFObject *MessageToStoreDB = [PFObject objectWithClassName:@"Messages"];
        MessageToStoreDB[@"recipientIds"] = self.OtherUserID;
        MessageToStoreDB[@"senderIds"] = [PFUser currentUser].objectId;
        MessageToStoreDB[@"Content"] = self.ChatView.textView.text;
        MessageToStoreDB[@"JobId"] = self.JobId;
        MessageToStoreDB[@"seen"] = @"NO";
        
        //        [self.viewMessage setUserInteractionEnabled:NO];

        //        self.TextView.editable=NO;
        self.ChatView.alpha=0.7;
        self.ChatView.sendButton.enabled = NO;
        
        [MessageToStoreDB saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            
            
            
            // add elements to data file and write data to file
            NSDictionary *messageToSend = [[NSDictionary alloc] initWithObjectsAndKeys:self.ChatView.textView.text,@"Content" ,
                                           (NSDate *)[NSDate date], @"Date",
                                           @"YES", @"FromMe",
                                           MessageToStoreDB.objectId,@"MessageID",nil];
            
                [self.ChatView adjustTextInputHeightForText:@"" animated:YES];
                self.ChatView.textView.text = @"";
                self.ChatView.sendButton.enabled = YES;
                self.ChatView.alpha=1;
            
            
            
            if ([data objectForKey:self.KeyForConversation]) {
                
                
                //NOW*******************************************************
                NSDictionary *StateAndMessages = [data objectForKey:self.KeyForConversation];
                
                NSMutableDictionary *JobState = [StateAndMessages objectForKey:@"JobState"];
                [JobState setObject:@"YES" forKey:@"Seen"];
                [JobState setObject:[NSDate date] forKey:@"LastUpdate"];
                NSMutableArray *ArrayMessages = [StateAndMessages objectForKey:@"ArrayMessages"];
                [ArrayMessages addObject:messageToSend];
                
                
                
                NSDictionary *newStateAndMessages = [NSDictionary dictionaryWithObjectsAndKeys:JobState,@"JobState",ArrayMessages,@"ArrayMessages", nil];
                
                
                [data setObject:newStateAndMessages forKey:self.KeyForConversation];
                
                if ([data writeToFile:path atomically:YES]){
                    NSLog(@"saved to file 1");
                }

            }
            
            NSLog(@"desc totale : %@", [data description]);
            
            //handle the table view
            [self.tableView reloadData];
            
            if ([MessagesSortedByDate count] != 0) {
//                [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:([MessagesSortedByDate count]-1)] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
                CGPoint bottomOffset = CGPointMake(0, [self.tableView contentSize].height - self.tableView.frame.size.height);
                [self.tableView setContentOffset:bottomOffset animated:YES];
            }
            
        }];
        
        
        
        
        //SEND THE PUSH NOTIFICATION ****************************
        
        PFQuery *query = [PFUser query];
        [query getObjectInBackgroundWithId:self.OtherUserID block:^(PFObject *OtherUser, NSError *error) {
            
//            PFUser *OtherUser = (PFUser*)[query getObjectWithId:self.OtherUserID];
            NSLog(@"user : %@", [OtherUser description]);
            
            // Create our Installation query
            PFQuery *pushQuery = [PFInstallation query];
            [pushQuery whereKey:@"user" equalTo:OtherUser];
            [pushQuery whereKey:@"active" equalTo:[NSNumber numberWithBool:YES]];
            
            NSDictionary *dataPush = [NSDictionary dictionaryWithObjectsAndKeys:
                                      @"new message for a Job", @"alert",
                                      @"Increment", @"badge",
                                      self.OtherUserID , @"OtherUserId",
                                      @"a" , @"notifMessage",
                                      nil];
            
            // Send push notification to query
            PFPush *push = [[PFPush alloc] init];
            [push setQuery:pushQuery];
            [push setData:dataPush];
            [push sendPushInBackground];
        }];
    }
}


- (IBAction)send_save:(UIButton *)sender {
    
    //check if the text lenght != 0 && not contains only white spaces
    if (self.TextView.text.length > 0 && [[self.TextView.text stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]] length] != 0) {
        
        //write datas
        NSMutableDictionary *data = [[NSMutableDictionary alloc] initWithContentsOfFile: path];
        
        NSDictionary *FakeMessage = [[NSDictionary alloc] initWithObjectsAndKeys:self.TextView.text,@"Content" ,
                                     (NSDate *)[NSDate date], @"Date",
                                     @"YES", @"FromMe",
                                     @"fake id",@"MessageID",nil];
        //        self.TextView.text = @"";
        [MessagesSortedByDate addObject:FakeMessage];
        
        //        if ([data objectForKey:self.KeyForConversation]) {
        //
        //            NSMutableArray *messages =[[NSMutableArray alloc] initWithArray: [[data objectForKey:self.KeyForConversation] allObjects]];
        //            [messages addObject:FakeMessage];
        //
        //            [data setObject:messages forKey:self.KeyForConversation];
        //
        //            if ([data writeToFile:path atomically:YES]){
        //                NSLog(@"saved to file");
        //            }
        //        }
        
        
        //save message to DB
        PFObject *MessageToStoreDB = [PFObject objectWithClassName:@"Messages"];
        MessageToStoreDB[@"recipientIds"] = self.OtherUserID;
        MessageToStoreDB[@"senderIds"] = [PFUser currentUser].objectId;
        MessageToStoreDB[@"Content"] = self.TextView.text;
        MessageToStoreDB[@"JobId"] = self.JobId;
        MessageToStoreDB[@"seen"] = @"NO";
        
        //        [self.viewMessage setUserInteractionEnabled:NO];
        self.buttonSend.enabled=NO;
        //        self.TextView.editable=NO;
        self.viewMessage.alpha=0.7;
        
        [MessageToStoreDB saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            
            // add elements to data file and write data to file
            NSDictionary *messageToSend = [[NSDictionary alloc] initWithObjectsAndKeys:self.TextView.text,@"Content" ,
                                           (NSDate *)[NSDate date], @"Date",
                                           @"YES", @"FromMe",
                                           MessageToStoreDB.objectId,@"MessageID",nil];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                self.TextView.text = @"";
                //               [self.viewMessage setUserInteractionEnabled:YES];
                self.buttonSend.enabled=YES;
                self.viewMessage.alpha=1;
            });
            
            
            
            if ([data objectForKey:self.KeyForConversation]) {
                
                
                //NOW*******************************************************
                NSDictionary *StateAndMessages = [data objectForKey:self.KeyForConversation];
                
                NSMutableDictionary *JobState = [StateAndMessages objectForKey:@"JobState"];
                [JobState setObject:@"YES" forKey:@"Seen"];
                [JobState setObject:[NSDate date] forKey:@"LastUpdate"];
                NSMutableArray *ArrayMessages = [StateAndMessages objectForKey:@"ArrayMessages"];
                [ArrayMessages addObject:messageToSend];
                
                
                
                NSDictionary *newStateAndMessages = [NSDictionary dictionaryWithObjectsAndKeys:JobState,@"JobState",ArrayMessages,@"ArrayMessages", nil];
                
                
                [data setObject:newStateAndMessages forKey:self.KeyForConversation];
                
                if ([data writeToFile:path atomically:YES]){
                    NSLog(@"saved to file 1");
                }
                
                
                
                //                //before
                //                NSMutableArray *messages =[[NSMutableArray alloc] initWithArray: [[data objectForKey:self.KeyForConversation] allObjects]];
                //                [messages addObject:messageToSend];
                //
                //
                //                [data setObject:messages forKey:self.KeyForConversation];
                //
                //                if ([data writeToFile:path atomically:YES]){
                //                    NSLog(@"saved to file");
                //                }
            }
            
            
            
            
            NSLog(@"desc totale : %@", [data description]);
            
            
            //handle the table view
            [self.tableView reloadData];
            
            if ([MessagesSortedByDate count] != 0) {
                [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:([MessagesSortedByDate count]-1)] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
            }
            
        }];
        
        
        dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            //SEND THE PUSH NOTIFICATION ****************************
            
            PFQuery *query = [PFUser query];
            PFUser *OtherUser = (PFUser*)[query getObjectWithId:self.OtherUserID];
            NSLog(@"user : %@", [OtherUser description]);
            
            // Create our Installation query
            PFQuery *pushQuery = [PFInstallation query];
            [pushQuery whereKey:@"user" equalTo:OtherUser];
            [pushQuery whereKey:@"active" equalTo:[NSNumber numberWithBool:YES]];
            
            NSDictionary *dataPush = [NSDictionary dictionaryWithObjectsAndKeys:
                                      @"new message for a Job", @"alert",
                                      @"Increment", @"badge",
                                      self.OtherUserID , @"OtherUserId",
                                      @"a" , @"notifMessage",
                                      nil];
            
            // Send push notification to query
            PFPush *push = [[PFPush alloc] init];
            [push setQuery:pushQuery];
            [push setData:dataPush];
            [push sendPushInBackground];
            
        });
    }
}







- (IBAction)JobDetails:(UIBarButtonItem *)sender {
    [self performSegueWithIdentifier:@"jobDetails" sender:self];
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    NSLog(@"allo");
    [self performSegueWithIdentifier:@"next" sender:self];
    return NO;
}

-(void) refreshAllMessages {
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        //all the stuff in the plist file
        NSMutableDictionary *savedStock = [[NSMutableDictionary alloc] initWithContentsOfFile: path];
        NSLog(@"saved stock : %@", [savedStock description]);
        
        //load only the messages and not the states !!!!*******************************************************
        
        NSDictionary *StateAndMessages = [savedStock objectForKey:self.KeyForConversation];
        
        NSMutableDictionary *JobState = [StateAndMessages objectForKey:@"JobState"];
        NSMutableArray *ArrayMessages = [StateAndMessages objectForKey:@"ArrayMessages"];
        

        //change the state of the conversation*************************
        [JobState setObject:@"YES" forKey:@"Seen"];
        
        NSDictionary *newStateAndMessages = [NSDictionary dictionaryWithObjectsAndKeys:JobState,@"JobState",ArrayMessages,@"ArrayMessages", nil];
        [savedStock setObject:newStateAndMessages forKey:self.KeyForConversation];
        
        if ([savedStock writeToFile:path atomically:YES]){
            NSLog(@"saved to file 1");
        }
        //*****************************************************************************************************
        
        messagesFromTheOther = ArrayMessages;
        
        NSLog(@"saved stock with id : %@", [messagesFromTheOther description]);
        
        //sort the array
        
        NSSortDescriptor *sortByDate = [NSSortDescriptor sortDescriptorWithKey:@"Date"
                                                                     ascending:YES];
        
        NSArray *sortDescriptors = [NSArray arrayWithObject:sortByDate];
        
        NSLog(@"desc du sort : %@", [sortByDate description]);
        
        MessagesSortedByDate = [[NSMutableArray alloc] initWithArray:[messagesFromTheOther sortedArrayUsingDescriptors:sortDescriptors]];
        
        NSLog(@"desc : %@", messagesFromTheOther);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            self.textFieldNameProfile.text = [JobState objectForKey:@"otherUserName"];
            [self.tableView reloadData];
            
            
            if ([MessagesSortedByDate count] != 0) {
                //        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:([MessagesSortedByDate count]-1)] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
                if (self.tableView.contentSize.height > self.tableView.frame.size.height) {
                    
                    
//                    [self.tableView setContentOffset:CGPointMake(0, self.tableView.contentSize.height - self.tableView.frame.size.height + 20)];
                    CGPoint bottomOffset = CGPointMake(0, [self.tableView contentSize].height - self.tableView.frame.size.height);
                    [self.tableView setContentOffset:bottomOffset animated:YES];
                }
            }
        });
        
    });
}



//-(void) ObserveChange {
//    
//    NSMutableDictionary *savedStock = [[NSMutableDictionary alloc] initWithContentsOfFile: path];
//    
//    //previous count
//    int nbMessageBefore = (int) [messagesFromTheOther count];
//    
//    NSLog(@"le compte : %d", nbMessageBefore);
//    
//    NSDictionary *StateAndMessages = [savedStock objectForKey:self.KeyForConversation];
//    messagesFromTheOther = [StateAndMessages objectForKey:@"ArrayMessages"]; //get the new array of messages
//    
//    //    messagesFromTheOther = [savedStock objectForKey:self.KeyForConversation];
//    
//    if ([messagesFromTheOther count] != nbMessageBefore) {
//        NSLog(@"erreur ici : %@", [messagesFromTheOther description]);
//        [self refreshAllMessages];
//    }
//}

-(NSString *) cutToNthWord : (NSString *)orig atIndex: (NSInteger) idx
{
    NSArray *comps = [orig componentsSeparatedByString:@" "];
    NSArray *sub = [comps subarrayWithRange:NSMakeRange(idx, comps.count - idx)];
    return [sub componentsJoinedByString:@" "];
}




#pragma mark - Table view

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [MessagesSortedByDate count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    NSLog(@"section : %ld", (long)indexPath.section);
    
    if ([[MessagesSortedByDate objectAtIndex:indexPath.section] isKindOfClass:[NSDictionary class]]) {
        
        NSDictionary *message = [MessagesSortedByDate objectAtIndex:indexPath.section];
        
        if([message objectForKey:@"Content"] != nil){
            
            UITextView *textView =  (UITextView*)[cell.contentView viewWithTag:200];
            
            textView.editable=YES;
            textView.contentMode = UIViewContentModeCenter;
            textView.font = [UIFont fontWithName:@"OpenSans-Light" size:14];
            textView.editable=NO;
            textView.layer.cornerRadius=4;
            textView.clipsToBounds=YES;
            textView.text = [message objectForKey:@"Content"];
            
            
            //handle the color of the textView
            if ([[message objectForKey:@"FromMe"] isEqualToString:@"NO"]) {

                textView.layer.borderWidth = 1;
                textView.layer.borderColor = UIColorFromRGB(0x7ed321).CGColor;
                
                textView.frame = CGRectMake( 10 , textView.frame.origin.y, textView.frame.size.width, textView.frame.size.height);
                textView.textColor = UIColorFromRGB(0x7ed321);
            }
            else {
                textView.frame = CGRectMake( [UIScreen mainScreen].bounds.size.width - textView.frame.size.width -10, textView.frame.origin.y, textView.frame.size.width, textView.frame.size.height);
                
                textView.layer.borderWidth = 1;
                textView.layer.borderColor = UIColorFromRGB(0x20abc1).CGColor;
                textView.textColor =UIColorFromRGB(0x20abc1);
            }
        }
    }


    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dic = MessagesSortedByDate[indexPath.section];
//    CGSize textSize = [[dic objectForKey:@"Content"] sizeWithFont:[UIFont systemFontOfSize:16] constrainedToSize:CGSizeMake(200, 20000) lineBreakMode:NSLineBreakByCharWrapping];
    
    UIFont *font = [UIFont systemFontOfSize:16];
    NSDictionary *attrsDictionary = [NSDictionary dictionaryWithObject:font forKey:NSFontAttributeName];
    NSMutableAttributedString *mutableText = [[NSMutableAttributedString alloc] initWithString:[dic objectForKey:@"Content"] attributes:attrsDictionary ];

    NSLog(@"size new : %f", [self textViewHeightForAttributedText:mutableText andWidth:200]);
    return ([self textViewHeightForAttributedText:mutableText andWidth:200] + 15);
    
//    NSLog(@"text : %@", [dic objectForKey:@"Content"]);
//    NSLog(@"size for height : %f at section : %d", textSize.height , indexPath.section);
//    
//    return textSize.height < 60 ? 60 : textSize.height;
}


- (CGFloat)textViewHeightForAttributedText: (NSAttributedString*)text andWidth: (CGFloat)width {
    UITextView *calculationView = [[UITextView alloc] init];
    [calculationView setAttributedText:text];
    CGSize size = [calculationView sizeThatFits:CGSizeMake(width, FLT_MAX)];
    return size.height;
}




#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if ([segue.identifier isEqualToString:@"next"]) {
        ProfileJobApplicantViewController* controller = [segue destinationViewController] ;
        controller.UserJobProvider = self.OtherUserID;
    }else{
        DetailJobForConversationViewController *detailJobVc = [segue destinationViewController];
        detailJobVc.JobId = self.JobId;
    }
}



- (IBAction)GoBack:(id)sender {
    [timer_observeChange invalidate];
    [self.navigationController popViewControllerAnimated:YES];

}


#pragma mark gestures

- (IBAction)Tap:(UITapGestureRecognizer *)sender {
    [self.TextView resignFirstResponder];
    [self.ChatView.textView resignFirstResponder];
    NSLog(@"Tap");
    
    [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.viewMessage.frame=self.frameView;
//        self.tableView.frame = self.frameViewTableView;
        self.tableView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - self.ChatView.frame.size.height);
    } completion:^(BOOL finished) {
        
    }];
}


@end