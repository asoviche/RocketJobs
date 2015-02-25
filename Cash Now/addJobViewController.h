//
//  addJobViewController.h
//  Cash Now
//
//  Created by amaury soviche on 06.05.14.
//  Copyright (c) 2014 Amaury Soviche. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

@interface addJobViewController : UIViewController<UITextFieldDelegate, UIImagePickerControllerDelegate,UINavigationControllerDelegate, MKMapViewDelegate,CLLocationManagerDelegate , UITextViewDelegate>

@property BOOL newMedia;

@end
