//
//  MyAnnotation.m
//  GPUImage
//
//  Created by amaury soviche on 29/05/14.
//  Copyright (c) 2014 Brad Larson. All rights reserved.
//

#import "MyAnnotation.h"

@implementation MyAnnotation


-(id) initWithCoordinates: (CLLocationCoordinate2D) paramCoordinates title:(NSString *)title{
    
    self= [super init];
    
    if (self!=nil) {
        _coordinate = paramCoordinates;
        _title = title;
    }
    
    return self;
}
@end
