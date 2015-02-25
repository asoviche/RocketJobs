//
//  AddDescriptionView.m
//  Cash Now
//
//  Created by amaury soviche on 25/02/15.
//  Copyright (c) 2015 Amaury Soviche. All rights reserved.
//

#import "AddDescriptionView.h"

@interface AddDescriptionView()

@property (strong, nonatomic) IBOutlet UITextView *textViewDescription;

@end

@implementation AddDescriptionView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (!self) return nil;
    
    //1. load xib file
    [[NSBundle mainBundle] loadNibNamed:@"AddDescriptionView" owner:self options:nil];
    
    //2. adjust bounds
    self.bounds = self.addDescriptionView.bounds;
    
    //3. add as a subview
    [self addSubview:self.addDescriptionView];
    
    self.textViewDescription.text = [[NSUserDefaults standardUserDefaults]stringForKey:@"About"];
    
    
    return self;
}

-(void) showKeyboard{
    [self.textViewDescription becomeFirstResponder];

}

#pragma mark IBActions

- (IBAction)save:(id)sender {
    [[NSUserDefaults standardUserDefaults] setObject:self.textViewDescription.text forKey:@"About"];
    [self.textViewDescription resignFirstResponder];
    [self.delegate AddDescriptionDelegate_saved];
}

- (IBAction)cancel:(id)sender {
    [self.textViewDescription resignFirstResponder];
    [self.delegate AddDescriptionDelegate_canceled];
}


@end
