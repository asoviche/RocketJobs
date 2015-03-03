//
//  JobLocationViewController.h
//  Cash Now
//
//  Created by amaury soviche on 03/03/15.
//  Copyright (c) 2015 Amaury Soviche. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import <Parse/Parse.h>

@interface JobLocationViewController : UIViewController<MKMapViewDelegate,CLLocationManagerDelegate>

@property PFGeoPoint *geoPointLocation;

@end
