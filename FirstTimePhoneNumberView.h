//
//  FirstTimePhoneNumberView.h
//  Cash Now
//
//  Created by amaury soviche on 25/02/15.
//  Copyright (c) 2015 Amaury Soviche. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FirstTimePhoneNumberDelegate <NSObject>

-(void) FirstTimePhoneNumberDelegate_saved;
-(void) FirstTimePhoneNumberDelegate_canceled;

@end

@interface FirstTimePhoneNumberView : UIView

@property (strong, nonatomic) IBOutlet UIView *firstTimePhoneNumberView;
@property (nonatomic, assign) id<FirstTimePhoneNumberDelegate> delegate;
-(void) showKeyboard;

@end
