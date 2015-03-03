//
//  MapView.h
//  Cash Now
//
//  Created by amaury soviche on 01/03/15.
//  Copyright (c) 2015 Amaury Soviche. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import "MyAnnotation.h"

@protocol MapViewDelegate <NSObject>

-(void) MapViewDelegate_clickedOkWithLocation:(MyAnnotation*)annotation;
-(void) MapViewDelegate_clickedCancel;

@end

@interface MapView : UIView <MKMapViewDelegate,CLLocationManagerDelegate>

@property (nonatomic, assign) id<MapViewDelegate> delegate;
@property (strong, nonatomic) IBOutlet UIView *mapView;
@property (strong, nonatomic) IBOutlet MKMapView *map;
-(void) showMapView;

@end
