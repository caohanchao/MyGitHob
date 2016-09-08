//
//  MonitoringRegionViewController.m
//  officialDemoLoc
//
//  Created by 刘博 on 15/12/10.
//  Copyright © 2015年 AutoNavi. All rights reserved.
//

static NSString *cir1Identifier =@"circleRegion100";
static NSString *cir2Identifier =@"circleRegion200";

#import "MonitoringRegionViewController.h"



@interface MonitoringRegionViewController ()<MAMapViewDelegate, AMapLocationManagerDelegate>
{
    UIButton * _backBtn;
}
@property (nonatomic, strong) NSMutableArray *regions;


@property(nonatomic,assign)CLLocationCoordinate2D coordinate;

@end



@implementation MonitoringRegionViewController

#pragma mark - Add Regions

- (void)getCurrentLocation
{
    //获取一次用户的当前位置，方便添加地理围栏
    __weak typeof(self) weakSelf = self;
    [self.locationManager requestLocationWithReGeocode:NO completionBlock:^(CLLocation *location, AMapLocationReGeocode *regeocode, NSError *error) {
        [weakSelf addCircleReionForCoordinate:location.coordinate];
        NSLog(@"%lf,%lf",location.coordinate.latitude,location.coordinate.longitude);
    }];
    
    
    
}

- (void)addCircleReionForCoordinate:(CLLocationCoordinate2D)coordinate
{
    
    //创建圆形地理围栏
    AMapLocationCircleRegion *cirRegion100 = [[AMapLocationCircleRegion alloc] initWithCenter:coordinate
                                                                                       radius:100.0
                                                                                   identifier:cir1Identifier];
    
    AMapLocationCircleRegion *cirRegion200 = [[AMapLocationCircleRegion alloc] initWithCenter:coordinate
                                                                                       radius:200.0
                                                                                   identifier:cir2Identifier];
    
    //添加地理围栏
    [self.locationManager startMonitoringForRegion:cirRegion100];
    [self.locationManager startMonitoringForRegion:cirRegion200];
    
    //保存地理围栏
    [self.regions addObject:cirRegion100];
    [self.regions addObject:cirRegion200];
    
    //添加地理围栏对应的Overlay，方便查看
    MACircle *circle200 = [MACircle circleWithCenterCoordinate:coordinate radius:100.0];
    MACircle *circle300 = [MACircle circleWithCenterCoordinate:coordinate radius:200.0];
    [self.mapView addOverlay:circle200];
    [self.mapView addOverlay:circle300];
    
    [self.mapView setVisibleMapRect:circle300.boundingMapRect];
}

#pragma mark - Action Handle

- (void)configLocationManager
{
    self.locationManager = [[AMapLocationManager alloc] init];

    [self.locationManager setDelegate:self];
    
    //设置期望定位精度
    [self.locationManager setDesiredAccuracy:kCLLocationAccuracyHundredMeters];
    
    //设置不允许系统暂停定位
    [self.locationManager setPausesLocationUpdatesAutomatically:NO];
    
    //设置允许在后台定位
    [self.locationManager setAllowsBackgroundLocationUpdates:YES];
}

#pragma mark - AMapLocationManagerDelegate

- (void)amapLocationManager:(AMapLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"locationError:{%ld;%@}", (long)error.code, error.localizedDescription);
}

- (void)amapLocationManager:(AMapLocationManager *)manager didStartMonitoringForRegion:(AMapLocationRegion *)region
{
    NSLog(@"didStartMonitoringForRegion:%@", region);
}

- (void)amapLocationManager:(AMapLocationManager *)manager monitoringDidFailForRegion:(AMapLocationRegion *)region withError:(NSError *)error
{
    NSLog(@"monitoringDidFailForRegion:%@", error.localizedDescription);
}

- (void)amapLocationManager:(AMapLocationManager *)manager didEnterRegion:(AMapLocationRegion *)region
{
    
    NSLog(@"didEnterRegion:%@", region);
    
    UIAlertController *alert =[UIAlertController alertControllerWithTitle:@"消息" message:[NSString stringWithFormat:@"进入了该区域"]  preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *action1 =[UIAlertAction actionWithTitle:@"返回" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action){
        //            NSLog(@"返回");
    }];
    
    [alert addAction:action1];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)amapLocationManager:(AMapLocationManager *)manager didExitRegion:(AMapLocationRegion *)region
{
    NSLog(@"didExitRegion:%@", region);
    UIAlertController *alert =[UIAlertController alertControllerWithTitle:@"消息" message:[NSString stringWithFormat:@"离开了该区域"]  preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *action1 =[UIAlertAction actionWithTitle:@"返回" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action){
        //            NSLog(@"返回");
    }];
    
    [alert addAction:action1];
    [self presentViewController:alert animated:YES completion:nil];
    
}

- (void)amapLocationManager:(AMapLocationManager *)manager didDetermineState:(AMapLocationRegionState)state forRegion:(AMapLocationRegion *)region
{
    NSLog(@"didDetermineState:%@; state:%ld", region, (long)state);
}

#pragma mark - Initialization

- (void)initMapView
{
    if (self.mapView == nil)
    {
        self.mapView = [[MAMapView alloc] initWithFrame:CGRectMake(0, 60, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds)-60)];
        [self.mapView setDelegate:self];
        
        [self.view addSubview:self.mapView];
    }
}


-(void)initNav
{
    UIView *view =[[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 64)];
    view.backgroundColor =
    [UIColor colorWithRed:0.16 green:0.56 blue:0.99 alpha:1.00];
    
    
    UILabel *title =[[UILabel alloc]initWithFrame:CGRectMake(self.view.frame.size.width/2-40, 20, 80, 40)];
    //    title.center =view.center;
    title.text =@"高德地图";
    title.textAlignment = NSTextAlignmentCenter;
    [view addSubview:title];
    
    
    _backBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    _backBtn.frame = CGRectMake(20,20, 40, 40);
    _backBtn.autoresizingMask = UIViewAutoresizingFlexibleRightMargin |
    UIViewAutoresizingFlexibleTopMargin;
    //    _moreButton.backgroundColor = [UIColor whiteColor];
    _backBtn.layer.cornerRadius = 5;
    [_backBtn setTitle:@"返回" forState:UIControlStateNormal];
    [_backBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    _backBtn.titleLabel.font = [UIFont systemFontOfSize:20];
    [_backBtn addTarget:self action:@selector(comeBackAction)
          forControlEvents:UIControlEventTouchUpInside];
    ;
    [view addSubview:_backBtn];
    [self.view addSubview:view];
}

-(void)comeBackAction
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Life Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    _coordinate = CLLocationCoordinate2DMake(30.458806, 114.415014);
    
    [self initNav];
    
    [self initMapView];
    
    

    [self configLocationManager];
    
    self.regions = [[NSMutableArray alloc] init];
    
    self.mapView.showsUserLocation = YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
//    self.navigationController.toolbar.translucent   = YES;
    self.navigationController.navigationBar.hidden    = YES;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self getCurrentLocation];
//    [self addCircleReionForCoordinate:_coordinate];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    //停止地理围栏
    [self.regions enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self.locationManager stopMonitoringForRegion:(AMapLocationRegion *)obj];
    }];
}

#pragma mark - MAMapViewDelegate

- (MAOverlayRenderer *)mapView:(MAMapView *)mapView rendererForOverlay:(id <MAOverlay>)overlay
{
//    if ([overlay isKindOfClass:[MAPolygon class]])
//    {
//        MAPolygonRenderer *polylineRenderer = [[MAPolygonRenderer alloc] initWithPolygon:overlay];
//        polylineRenderer.lineWidth = 5.0f;
//        polylineRenderer.strokeColor = [UIColor redColor];
//        
//        return polylineRenderer;
//    }
     if ([overlay isKindOfClass:[MACircle class]])
    {
        MACircleRenderer *circleRenderer = [[MACircleRenderer alloc] initWithCircle:overlay];
        circleRenderer.lineWidth = 5.0f;
        circleRenderer.strokeColor = [UIColor blueColor];
        
        return circleRenderer;
    }
    
    return nil;
}

@end
