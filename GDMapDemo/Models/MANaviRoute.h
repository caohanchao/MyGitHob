//
//  MANaviRoute.h
//  OfficialDemo3D
//
//  Created by yi chen on 1/7/15.
//  Copyright (c) 2015 songjian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MAMapKit/MAMapKit.h>
#import <AMapSearchKit/AMapSearchAPI.h>
#import "MANaviAnnotation.h"
#import "MANaviPolyline.h"
#import "LineDashPolyline.h"

@interface MANaviRoute : NSObject

/// 是否显示annotation, 显示路况的情况下无效。
@property (nonatomic, assign) BOOL anntationVisible;


@property (nonatomic, strong) NSArray *routePolylines;
@property (nonatomic, strong) NSArray *naviAnnotations;
@property (nonatomic, strong) UIColor *routeColor;
@property (nonatomic, strong) UIColor *walkingColor;
@property (nonatomic, strong) NSArray<UIColor *> *multiPolylineColors;

- (void)addToMapView:(MAMapView *)mapView;

- (void)removeFromMapView;

- (void)setNaviAnnotationVisibility:(BOOL)visible;

+ (instancetype)naviRouteForTransit:(AMapTransit *)transit;
+ (instancetype)naviRouteForPath:(AMapPath *)path withNaviType:(MANaviAnnotationType)type showTraffic:(BOOL)showTraffic;
+ (instancetype)naviRouteForPolylines:(NSArray *)polylines andAnnotations:(NSArray *)annotations;

- (instancetype)initWithTransit:(AMapTransit *)transit;
- (instancetype)initWithPath:(AMapPath *)path withNaviType:(MANaviAnnotationType)type showTraffic:(BOOL)showTraffic;
- (instancetype)initWithPolylines:(NSArray *)polylines andAnnotations:(NSArray *)annotations;

@end
