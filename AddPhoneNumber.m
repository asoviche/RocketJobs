//
//  AddPhoneNumber.m
//  Cash Now
//
//  Created by amaury soviche on 25/02/15.
//  Copyright (c) 2015 Amaury Soviche. All rights reserved.
//

#import "AddPhoneNumber.h"

@interface AddPhoneNumber ()

@property (strong, nonatomic) IBOutlet UITextField *textFieldPhoneNumber;

@end

@implementation AddPhoneNumber


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (!self) return nil;
    
    //1. load xib file
    [[NSBundle mainBundle] loadNibNamed:@"AddPhoneNumber" owner:self options:nil];
    
    //2. adjust bounds
    self.bounds = self.addPhoneNumberView.bounds;
    
    //3. add as a subview
    [self addSubview:self.addPhoneNumberView];
    
    self.textFieldPhoneNumber.text = [[NSUserDefaults standardUserDefaults]stringForKey:@"phoneNumber"];
    
    
    return self;
}

-(void) showKeyboard{
    [self.textFieldPhoneNumber becomeFirstResponder];
    
}

#pragma mark IBActions

- (IBAction)save:(id)sender {
    [[NSUserDefaults standardUserDefaults] setObject:self.textFieldPhoneNumber.text forKey:@"phoneNumber"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self.textFieldPhoneNumber resignFirstResponder];
    [self.delegate AddPhoneNumberDelegate_saved];
}

- (IBAction)cancel:(id)sender {
    [self.textFieldPhoneNumber resignFirstResponder];
    [self.delegate AddPhoneNumberDelegate_canceled];
}

@end
