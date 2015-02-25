//
//  AddDescriptionView.h
//  Cash Now
//
//  Created by amaury soviche on 25/02/15.
//  Copyright (c) 2015 Amaury Soviche. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AddDescriptionDelegate <NSObject>

-(void) AddDescriptionDelegate_saved;
-(void) AddDescriptionDelegate_canceled;

@end

@interface AddDescriptionView : UIView

@property (strong, nonatomic) IBOutlet UIView *addDescriptionView;
@property (nonatomic, assign) id<AddDescriptionDelegate> delegate;
-(void) showKeyboard;
@end
