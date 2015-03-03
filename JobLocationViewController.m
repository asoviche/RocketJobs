//
//  JobLocationViewController.m
//  Cash Now
//
//  Created by amaury soviche on 03/03/15.
//  Copyright (c) 2015 Amaury Soviche. All rights reserved.
//

#import "JobLocationViewController.h"
#import "MyAnnotation.h"


@interface JobLocationViewController ()

@property (strong, nonatomic) IBOutlet MKMapView *map;
@property (strong, nonatomic) CLLocationManager *myLocation;

@end

@implementation JobLocationViewController{
    MyAnnotation *annotation;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.map.delegate=self;
    self.myLocation.delegate=self;
    
    
    CLLocationCoordinate2D locationCoordinate = CLLocationCoordinate2DMake(self.geoPointLocation.latitude, self.geoPointLocation.longitude);

    annotation = [[MyAnnotation alloc] initWithCoordinates:locationCoordinate title:@"Job location"];
    [self.map addAnnotation:annotation];
//    [self.map setSelectedAnnotations:@[annotation]];
    
    MKCoordinateRegion region;
    MKCoordinateSpan span;
    span.latitudeDelta = 0.013;
    span.longitudeDelta = 0.013;
    CLLocationCoordinate2D location;
    location.latitude = locationCoordinate.latitude;
    location.longitude = locationCoordinate.longitude;
    region.span = span;
    region.center = location;
    [self.map setRegion:region animated:YES];
}

- (IBAction)back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
