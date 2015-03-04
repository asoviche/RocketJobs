//
//  MapView.m
//  Cash Now
//
//  Created by amaury soviche on 01/03/15.
//  Copyright (c) 2015 Amaury Soviche. All rights reserved.
//

#import "MapView.h"

@interface MapView()

@property (strong, nonatomic) CLLocationManager *myLocation;

@property (strong, nonatomic) IBOutlet UIButton *buttonCancel;
@property (strong, nonatomic) IBOutlet UIButton *buttonOk;



@end

@implementation MapView{
//    MyAnnotation *annotation;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (!self) return nil;
    
    //1. load xib file
    [[NSBundle mainBundle] loadNibNamed:@"MapView" owner:self options:nil];
    
    //2. adjust bounds
    self.bounds = self.mapView.bounds;
    
    //3. add as a subview
    [self addSubview:self.mapView];
    
    
    
    self.layer.cornerRadius = 5;
    self.clipsToBounds=YES;
    
    self.map.delegate=self;
    self.myLocation.delegate=self;
    
    UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc]
                                          initWithTarget:self action:@selector(handleLongPress:)];
    lpgr.minimumPressDuration = 1.0; //user needs to press for 2 seconds
    [self.map addGestureRecognizer:lpgr];
    
    self.buttonCancel.layer.cornerRadius = 3;
    self.buttonOk.layer.cornerRadius = 3;
    self.buttonOk.titleLabel.font = [UIFont fontWithName:@"OpenSans-Light" size:16];
    self.buttonCancel.titleLabel.font = [UIFont fontWithName:@"OpenSans-Light" size:16];
    
    


    return self;
}

-(void) showMapView{
    self.map.delegate=self;
    self.map.showsUserLocation =YES;
    [self.myLocation startUpdatingLocation];
    
    NSLog(@"annotations : %@", [self.map.annotations description]);
    
    self.buttonOk.enabled = NO;
    self.buttonOk.alpha = 0.5;
    for (id annotation in self.map.annotations) {
        
        NSLog(@"annotation : %@", [annotation description]);
        if ([annotation isKindOfClass:[MyAnnotation class]]) {
            NSLog(@"done ");
            self.buttonOk.enabled = YES;
            self.buttonOk.alpha = 1;
        }
    }
    
    

}

- (void)handleLongPress:(UIGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state != UIGestureRecognizerStateBegan){
        return;
    }
    
    [self.map removeAnnotations:self.map.annotations];
    
    CGPoint touchPoint = [gestureRecognizer locationInView:self.map];
    CLLocationCoordinate2D touchMapCoordinate = [self.map convertPoint:touchPoint toCoordinateFromView:self.map];
    
    MyAnnotation *annotationMap = [[MyAnnotation alloc] initWithCoordinates:touchMapCoordinate title:@"Job's location"];
    [self.map addAnnotation:annotationMap];
    [self.map setSelectedAnnotations:@[annotationMap]];

    self.buttonOk.enabled = YES;
    self.buttonOk.alpha = 1;
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
    MKCoordinateRegion region;
    MKCoordinateSpan span;
    span.latitudeDelta = 0.013;
    span.longitudeDelta = 0.013;
    CLLocationCoordinate2D location;
    location.latitude = userLocation.coordinate.latitude;
    location.longitude = userLocation.coordinate.longitude;
    region.span = span;
    region.center = location;
    [self.map setRegion:region animated:YES];
    
    [self.myLocation stopUpdatingLocation];
    
    self.map.delegate=nil;
}

#pragma mark IBActions

- (IBAction)clickedOk:(id)sender {
    if (self.map.annotations.count > 0) {
        [self.delegate MapViewDelegate_clickedOkWithLocation:[self.map.annotations firstObject]];
    }else{
        [self.map removeAnnotations:self.map.annotations];
        [self.delegate MapViewDelegate_clickedCancel];
    }
}

- (IBAction)clickedCancel:(id)sender {
    [self.delegate MapViewDelegate_clickedCancel];
}

@end
