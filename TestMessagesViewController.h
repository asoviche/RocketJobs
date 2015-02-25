//
//  TestMessagesViewController.h
//  Cash Now
//
//  Created by amaury soviche on 19/05/14.
//  Copyright (c) 2014 Amaury Soviche. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "Reachability.h"
#import "THChatInput.h"

@interface TestMessagesViewController : UIViewController<UITableViewDataSource,THChatInputDelegate, UITableViewDelegate, UITextFieldDelegate>{
//    Reachability* internetReachable;
//    Reachability* hostReachable;
//    @Class Reachability;
    
}

@property (nonatomic, strong) NSString *JobId;
@property (nonatomic, strong) NSString *OtherUserID;
@property (nonatomic, strong) NSString *OtherUserName;
@property (nonatomic, strong) NSString *PlistName;

@property (nonatomic, strong) NSString *KeyForConversation;

@property (strong, nonatomic)  THChatInput *ChatView;


@end
