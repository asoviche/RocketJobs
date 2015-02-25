//
//  FriendsViewController.m
//  Ribbit
//
//  Copyright (c) 2013 Treehouse. All rights reserved.
//

#import "FriendsViewController.h"
#import "TestMessagesViewController.h"
#import "SWRevealViewController.h"

@interface FriendsViewController ()

@property (weak, nonatomic) IBOutlet UIBarButtonItem *sidebarButton;
@property (nonatomic, strong) NSMutableArray *JobsArray; //ids of the jobs
@end

@implementation FriendsViewController{
    NSString *path;
    NSTimer *timer_observeChange;
    #define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSLog(@"view did load");

}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    

    NSLog(@"value : %@", self.activateBackButton);

    
    if ([self.activateBackButton isEqualToString:@"YES"]) {
        
        _sidebarButton.image = [UIImage imageNamed:@"back.png"];
        _sidebarButton.target = self;
        _sidebarButton.action = @selector(back:);
    }else{
        // Set the side bar button action. When it's tapped, it'll show up the sidebar.
        _sidebarButton.image = [UIImage imageNamed:@"icon-menu.png"];
        _sidebarButton.target = self.revealViewController;
        _sidebarButton.action = @selector(revealToggle:);
    }
    
    
    
    // acces with plist file
    NSError *error;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); //1
    NSString *documentsDirectory = [paths objectAtIndex:0]; //2
    path = [documentsDirectory stringByAppendingPathComponent:@"Conversations.plist"]; //3
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if (![fileManager fileExistsAtPath: path]) //4
    {
        NSString *bundle = [[NSBundle mainBundle] pathForResource:@"Conversations" ofType:@"plist"]; //5
        [fileManager copyItemAtPath:bundle toPath: path error:&error]; //6
    }
    
    //load one time
    [self reloadDataForArrays];
//    timer_observeChange = [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(reloadDataForArrays) userInfo:nil repeats:YES];
   
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults addObserver:self
               forKeyPath:@"ListConversationsHaveToBeUpdated"
                  options:NSKeyValueObservingOptionNew
                  context:NULL];
}

-(void) viewWillDisappear:(BOOL)animated
{
//    [timer_observeChange invalidate];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObserver:self forKeyPath:@"ListConversationsHaveToBeUpdated"];
}

#pragma mark KVO

-(void)observeValueForKeyPath:(NSString *)keyPath
                     ofObject:(id)object
                       change:(NSDictionary *)change
                      context:(void *)context
{
    if ([keyPath isEqualToString:@"ListConversationsHaveToBeUpdated"]) {
        
        [self reloadDataForArrays];
    }
}

-(void) reloadDataForArrays{
    //all the stuff in the plist file
    NSMutableDictionary *savedStock = [[NSMutableDictionary alloc] initWithContentsOfFile: path];
    NSArray *FriendsPlist = [[NSArray alloc] initWithArray:[savedStock allKeys]];

    NSLog(@"dic desc : %@", [savedStock description]);
    
    _JobsArray = [[NSMutableArray alloc] init];
//    [self.JobsArray removeAllObjects];
    

    //new method
    for (NSString *key in savedStock) {
        
        NSMutableDictionary *Job = [[NSMutableDictionary alloc]init];
        
        [Job setObject:key forKey:@"Key"];
        
        //save only the names in an array to make them appear in the tableview
        [Job setObject:[self cutToNthWord:[FriendsPlist objectAtIndex:[FriendsPlist indexOfObject:key]] atIndex:3] forKey:@"JobsDesciption"];
        
        //save the ids in the specidfic array
        NSString *JobId = [[[FriendsPlist objectAtIndex:[FriendsPlist indexOfObject:key]] componentsSeparatedByString:@" "] objectAtIndex:0];
        [Job setObject:JobId forKey:@"JobsId"];
        
        NSDictionary *StateAndMessages = [savedStock objectForKey:key];
    
        NSDictionary *state = [StateAndMessages objectForKey:@"JobState"];
        [Job setObject:[state objectForKey:@"Seen"] forKey:@"Seen"];
        [Job setObject:[state objectForKey:@"LastUpdate"] forKey:@"LastUpdate"];
        
        [self.JobsArray addObject:Job]; //fill the array of jobs
    }
    
    NSLog(@"description array jobs : %@", [self.JobsArray description]);
    
    [self CheckForJobsStates];
    
    //sort the array
    
    NSSortDescriptor *sortByDate = [NSSortDescriptor sortDescriptorWithKey:@"LastUpdate"
                                                                 ascending:NO];
    
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortByDate];
    
    NSLog(@"desc du sort : %@", [sortByDate description]);
    
    self.JobsArray = (NSMutableArray*)[self.JobsArray sortedArrayUsingDescriptors:sortDescriptors];
    
    
    [self.tableView reloadData];
}

-(void) CheckForJobsStates{
    for (NSDictionary *dicJob in self.JobsArray) {
        if ([[dicJob objectForKey:@"Seen" ]isEqualToString:@"NO"]) {
            
            [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:@"isAllJobsSeen"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            return;
        }
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:@"isAllJobsSeen"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(NSString *) cutToNthWord : (NSString *)orig atIndex: (NSInteger) idx
{
    NSArray *comps = [orig componentsSeparatedByString:@" "];
    NSArray *sub = [comps subarrayWithRange:NSMakeRange(idx, comps.count - idx)];
    return [sub componentsJoinedByString:@" "];
}


- (IBAction)back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
    [timer_observeChange invalidate];
}

#pragma mark - Table view data source + delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([_JobsArray count] == 0) {
        return 1;
    }else return [_JobsArray count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    UITextView *textView = (UITextView *)[cell viewWithTag:200];
    UIImageView *imageView = (UIImageView *)[cell viewWithTag:201];
    UITextField *TextField = (UITextField*)[cell viewWithTag:202];
    
    NSLog(@"cell for row at index");
    
    textView.font = [UIFont fontWithName:@"OpenSans-Light" size:14];
    TextField.font = [UIFont fontWithName:@"OpenSans-Light" size:14];
    
    if ([_JobsArray count] == 0) { //no applicants
        textView.text = @"You don't have any open conversations yet";
        imageView.image=nil;
        TextField.text = @"";
        textView.editable=YES;
        textView.textColor = UIColorFromRGB(0x225378);
        textView.font = [UIFont fontWithName:@"OpenSans-Light" size:14];
        textView.editable=NO;
        [cell setUserInteractionEnabled:NO];
        cell.backgroundColor = [UIColor whiteColor];
        textView.backgroundColor = [UIColor whiteColor];
        
    }else{// there are applicants
        
        textView.text =  [[_JobsArray objectAtIndex:indexPath.row] objectForKey:@"JobsDesciption"];
        textView.editable=YES;
        textView.textColor = UIColorFromRGB(0x225378);
        textView.font = [UIFont fontWithName:@"OpenSans-Light" size:14];
        textView.editable=NO;
        
        
        
        NSString *ImagePath = [[NSUserDefaults standardUserDefaults] objectForKey:[[_JobsArray objectAtIndex:indexPath.row] objectForKey:@"JobsId"]];
        NSLog(@"user default for imagePath : %@", ImagePath);
        
        if (ImagePath != nil ) {
            
            UIImage *customImage = [UIImage imageWithContentsOfFile:ImagePath];
            imageView.image = customImage;
            
            if (customImage == nil) {
                imageView.image = [UIImage imageNamed:[@"rand_picture_" stringByAppendingString:[NSString stringWithFormat:@"%d", arc4random()%5]]]; //random image
            }
            
            NSLog(@" image cell desciption : %@", [customImage description]);
        }else {
            imageView.image = [UIImage imageNamed:[@"rand_picture_" stringByAppendingString:[NSString stringWithFormat:@"%d", arc4random()%5]]]; //random image
        }
        
        
        TextField.textColor=UIColorFromRGB(0x225378);
        
        NSString *string1 = [[[[_JobsArray objectAtIndex:indexPath.row] objectForKey:@"Key"] componentsSeparatedByString:@" "] objectAtIndex:2];
        NSString *MyJob = [[string1 componentsSeparatedByString:@" "] objectAtIndex:0];
        
        if ([MyJob isEqualToString:@"MyJob:YES"]) {
            TextField.text = @"You posted this job";
            TextField.textColor = UIColorFromRGB(0x20abc1);
            
        }else{
            TextField.text = @"You applied for this job";
            TextField.textColor = UIColorFromRGB(0xa3e065);
        }
        
        if ([[[_JobsArray objectAtIndex:indexPath.row] objectForKey:@"Seen"] isEqualToString:@"NO"]) {
            cell.backgroundColor = [UIColor grayColor];
            textView.backgroundColor= [UIColor grayColor];
        }else {
            cell.backgroundColor = [UIColor whiteColor];
            textView.backgroundColor= [UIColor whiteColor];
        }
    }
    
    return cell;
}



- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    return 100;
}


// Override to support conditional editing of the table view.
// This only needs to be implemented if you are going to be returning NO
// for some items. By default, all items are editable.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return YES if you want the specified item to be editable.
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        //add code here for when you hit delete
        NSLog(@"delete");
        
        
        //SEND NOTIFICATION TO THE OTHER TO DELETE HIS CONVERSATION
        NSString *OtherUserId = [[[[[[_JobsArray objectAtIndex:indexPath.row] objectForKey:@"Key"] componentsSeparatedByString:@" "] objectAtIndex:1] componentsSeparatedByString:@" "] objectAtIndex:0];
        NSString *JobID = [[[[_JobsArray objectAtIndex:indexPath.row] objectForKey:@"Key"] componentsSeparatedByString:@" "] objectAtIndex:0];
        NSString *halfKeyForPush = [[JobID stringByAppendingString:@" "] stringByAppendingString:[PFUser currentUser].objectId];
        
        NSLog(@"half key : %@", halfKeyForPush);
        
        PFQuery *queryUser = [PFUser query];
        [queryUser getObjectInBackgroundWithId:OtherUserId block:^(PFObject *otherUser, NSError *error) {
            
            // Create our Installation query
            PFQuery *pushQuery = [PFInstallation query];
            [pushQuery whereKey:@"user" equalTo:otherUser];
            [pushQuery whereKey:@"active" equalTo:[NSNumber numberWithBool:YES]];
            
            
            NSDictionary *dataPush = [NSDictionary dictionaryWithObjectsAndKeys:
//                                      @"conversation deleted", @"alert",
                                      JobID, @"JobId",
                                      [PFUser currentUser].objectId , @"userId",
                                      @"a" , @"deleteConv",
                                      nil];
            
            
            // Send push notification to query
            PFPush *push = [[PFPush alloc] init];
            [push setQuery:pushQuery];
            [push setData:dataPush];
            [push sendPushInBackground];
        }];
        
        
        
        
        //REMOVE THE CONVERSATION TO THE CURRENT USER PHONE DATA PLIST
        
        [self.tableView setEditing:YES animated:YES];
        
        //all the stuff in the plist file
        NSMutableDictionary *savedStock = [[NSMutableDictionary alloc] initWithContentsOfFile: path];
        NSLog(@"saved stock before : %@", savedStock);
        [savedStock removeObjectForKey:[[_JobsArray objectAtIndex:indexPath.row] objectForKey:@"Key"]];
        NSLog(@"saved stock after : %@", savedStock);
        if([savedStock writeToFile:path atomically:YES]){
            NSLog(@"ok");
        }
        
        [self reloadDataForArrays];
        
        [tableView reloadData];
        
    }
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
//    [self performSegueWithIdentifier:@"goToConversation" sender:self.KeysForConversations[indexPath.row]];
    [self performSegueWithIdentifier:@"goToConversation" sender:[[_JobsArray objectAtIndex:indexPath.row] objectForKey:@"Key"]];
    
}



- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(NSString *)sender {
    
    [timer_observeChange invalidate];
    if ([segue.identifier isEqualToString:@"goToConversation"]) {
        
        TestMessagesViewController *viewController = (TestMessagesViewController *)segue.destinationViewController;
        
        NSLog(@"desc %@ ", [sender description]);
        
        viewController.KeyForConversation = sender;
        NSLog(@"key sent : %@", viewController.KeyForConversation);
        
        //send job's ID
        viewController.JobId=[[sender componentsSeparatedByString:@" "] objectAtIndex:0];

        NSString *otherUserId = [[sender componentsSeparatedByString:@" "] objectAtIndex:1];
        NSString *o2 = [[otherUserId componentsSeparatedByString:@" "] objectAtIndex:0];
        NSLog(@"good id : %@", o2);
        viewController.OtherUserID = o2;
        
        
    }
}

@end
