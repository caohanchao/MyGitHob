//
//  RootViewController.h
//  GDMapDemo
//
//  Created by caohanchao on 16/8/7.
//  Copyright © 2016年 caohanchao. All rights reserved.
//


#import <MAMapKit/MAMapKit.h>
#import <AMapFoundationKit/AMapFoundationKit.h>
#import <AMapSearchKit/AMapSearchKit.h>

#import <UIKit/UIKit.h>

//分区枚举
typedef enum
{
    Nearby_ROW = 0,
    Route_ROW,
    Weather_ROW,
    Nav_ROW,
    
}ROWS;

@interface RootViewController : UIViewController

{
    MAMapView *_mapView;
    AMapSearchAPI *_search;
    CLLocation *_currentLocation;
    
    UIView * _bg;
    UITableView *_tableView;
    
}

-(void)presentAlert:(NSString *)message;



@end
