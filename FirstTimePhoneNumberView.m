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
@property (strong, nonatomic) IBOutlet UIButton *buttonSkipJob;
@property (strong, nonatomic) IBOutlet UIButton *buttonSave;
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
    
    self.buttonSave.enabled = NO;
    
    
    return self;
}

-(void) showKeyboard{
    [self.textFieldPhoneNumber becomeFirstResponder];
    
}

#pragma mark IBActions

- (IBAction)save:(id)sender {
    [[NSUserDefaults standardUserDefaults] setObject:self.textFieldPhoneNumber.text forKey:@"phoneNumber"];
    [self.textFieldPhoneNumber resignFirstResponder];
    [self.delegate FirstTimePhoneNumberDelegate_savedWithCurrentJobId:self.currentJobId];
}

- (IBAction)cancel:(id)sender {
    [self.textFieldPhoneNumber resignFirstResponder];
    [self.delegate FirstTimePhoneNumberDelegate_canceled];
}

#pragma mark textField delagate

- (IBAction)textFieldEditingChanged:(UITextField *)sender {
    if (self.textFieldPhoneNumber.text.length != 0) {
        self.buttonSave.enabled = YES;
    }else{
        self.buttonSave.enabled = NO;
    }
    
}

@end

