//
//  FirstTimePhoneNumberView.m
//  Cash Now
//
//  Created by amaury soviche on 25/02/15.
//  Copyright (c) 2015 Amaury Soviche. All rights reserved.
//

#import "FirstTimePhoneNumberView.h"

@interface FirstTimePhoneNumberView()
@property (strong, nonatomic) IBOutlet UITextField *textFieldPhoneNumber;
@end

@implementation FirstTimePhoneNumberView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (!self) return nil;
    
    //1. load xib file
    [[NSBundle mainBundle] loadNibNamed:@"FirstTimePhoneNumberView" owner:self options:nil];
    
    //2. adjust bounds
    self.bounds = self.firstTimePhoneNumberView.bounds;
    
    //3. add as a subview
    [self addSubview:self.firstTimePhoneNumberView];
    
    self.textFieldPhoneNumber.text = [[NSUserDefaults standardUserDefaults]stringForKey:@"phoneNumber"];
    
    
    return self;
}

-(void) showKeyboard{
    [self.textFieldPhoneNumber becomeFirstResponder];
    
}

#pragma mark IBActions

- (IBAction)save:(id)sender {
    [[NSUserDefaults standardUserDefaults] setObject:self.textFieldPhoneNumber.text forKey:@"phoneNumber"];
    [self.textFieldPhoneNumber resignFirstResponder];
    [self.delegate FirstTimePhoneNumberDelegate_saved];
}

- (IBAction)cancel:(id)sender {
    [self.textFieldPhoneNumber resignFirstResponder];
    [self.delegate FirstTimePhoneNumberDelegate_canceled];
}

@end

