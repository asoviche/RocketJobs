//
//  MyAnnotation.h
//  GPUImage
//
//  Created by amaury soviche on 29/05/14.
//  Copyright (c) 2014 Brad Larson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface MyAnnotation : NSObject <MKAnnotation>

@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic, copy, readonly) NSString *title;

-(id) initWithCoordinates: (CLLocationCoordinate2D) paramCoordinates title: (NSString *) title;

@end
