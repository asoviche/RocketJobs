//
//  AddPhoneNumber.h
//  Cash Now
//
//  Created by amaury soviche on 25/02/15.
//  Copyright (c) 2015 Amaury Soviche. All rights reserved.
//

#import <UIKit/UIKit.h>



@protocol AddPhoneNumberDelegate <NSObject>

-(void) AddPhoneNumberDelegate_saved;
-(void) AddPhoneNumberDelegate_canceled;

@end


@interface AddPhoneNumber : UIView

@property (strong, nonatomic) IBOutlet UIView *addPhoneNumberView;
@property (nonatomic, assign) id<AddPhoneNumberDelegate> delegate;
-(void) showKeyboard;
@end
