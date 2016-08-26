//
//  NavViewController.m
//  GDMapDemo
//
//  Created by caohanchao on 16/8/7.
//  Copyright © 2016年 caohanchao. All rights reserved.
//

#import "NavViewController.h"
#import "SpeechSynthesizer.h"
#import "DriveNaviViewController.h"
#import "QuickStartAnnotationView.h"
#import <AMapFoundationKit/AMapFoundationKit.h>

//高德导航SchemeUrl接口
#define AMAPSchemeUrl @"iosamap://navi?sourceApplication=%@&backScheme=%@&lat=%f&lon=%f&dev=0&style=2"

#define AMAPGPSUrl @"iosamap://viewMap?sourceApplication=%@&poiname=%@&lat=%@&lon=%@&dev=0"


@interface NavViewController ()<MAMapViewDelegate, AMapSearchDelegate, AMapNaviDriveManagerDelegate, DriveNaviViewControllerDelegate>
{
    UIButton *_cancelButton;
    
    AMapNaviPoint *_endPoint;
    
    MAUserLocation *_userLocation;
    
    NSMutableArray *_poiAnnotations;

}

@property (nonatomic, strong) MAMapView *mapView;

@property (nonatomic, strong) AMapSearchAPI *search;

@property (nonatomic, strong) AMapNaviDriveManager *driveManager;

@end

@implementation NavViewController


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = YES;
    self.navigationController.toolbarHidden = NO;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.mapView setShowsUserLocation:YES];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.navigationController.toolbarHidden =YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initNav];
    
    [self initProperties];
    
    [self initToolBar];
    
    [self initMapView];
    
    [self initDriveManager];
    
    [self initSearch];
    // Do any additional setup after loading the view.
}




- (void)initDriveManager
{
    if (self.driveManager == nil)
    {
        self.driveManager = [[AMapNaviDriveManager alloc] init];
        [self.driveManager setDelegate:self];
    }
}

-(void)initNav
{
    
    UIView *view =[[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 64)];
    view.backgroundColor =
    [UIColor colorWithRed:0.16 green:0.56 blue:0.99 alpha:1.00];
    
    
    UILabel *title =[[UILabel alloc]initWithFrame:CGRectMake(self.view.frame.size.width/2-40, 20, 80, 30)];
    title.text =@"导航";
    title.textAlignment = NSTextAlignmentCenter;
    [view addSubview:title];
    
    
    UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [rightBtn setTitle:@"➡️" forState:UIControlStateNormal];
    rightBtn.titleLabel.font = [UIFont systemFontOfSize:30];
    [rightBtn addTarget:self action:@selector(openGDAppAction) forControlEvents:UIControlEventTouchUpInside];
     rightBtn.frame = CGRectMake(self.view.frame.size.width-50,20, 40, 40);
    [view addSubview:rightBtn];
    
    _cancelButton = [UIButton buttonWithType:UIButtonTypeSystem];
    
    _cancelButton.frame = CGRectMake(10,20, 40, 40);
    [_cancelButton setTitle:@"⬅️" forState:UIControlStateNormal];
    _cancelButton.titleLabel.font = [UIFont systemFontOfSize:30];
    [_cancelButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    //    _cancelButton.titleLabel.font = [UIFont systemFontOfSize:15];
    [_cancelButton addTarget:self action:@selector(cancelClick)
            forControlEvents:UIControlEventTouchUpInside];
    ;
    [view addSubview:_cancelButton];
    [self.view addSubview:view];
    
}

-(void)openGDAppAction
{
    [AMapURLSearch getLatestAMapApp];

}

-(void)cancelClick
{
    
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)initProperties
{
    _poiAnnotations = [[NSMutableArray alloc] init];
}

- (void)initMapView
{
    if (self.mapView == nil)
    {
        self.mapView = [[MAMapView alloc] initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height-64)];
        [self.mapView setDelegate:self];
        
        [self.view addSubview:self.mapView];
    }
}



- (void)initSearch
{
    if (self.search == nil)
    {
        self.search = [[AMapSearchAPI alloc] init];
        self.search.delegate = self;
    }
}

- (void)initToolBar
{
    UIBarButtonItem *flexbleItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                 target:self
                                                                                 action:nil];
    
    UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithItems:
                                            [NSArray arrayWithObjects:
                                             @"餐饮",
                                             @"酒店",
                                             @"电影",
                                             nil]];
    
    segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
    [segmentedControl addTarget:self action:@selector(searchAction:) forControlEvents:UIControlEventValueChanged];
    
    UIBarButtonItem *searchTypeItem = [[UIBarButtonItem alloc] initWithCustomView:segmentedControl];
    
    self.toolbarItems = [NSArray arrayWithObjects:flexbleItem, searchTypeItem, flexbleItem, nil];
}

#pragma mark - Search

- (void)searchAction:(UISegmentedControl *)segmentedControl
{
    AMapPOIAroundSearchRequest *request = [[AMapPOIAroundSearchRequest alloc] init];
    
    if (_userLocation)
    {
        request.location = [AMapGeoPoint locationWithLatitude:_userLocation.location.coordinate.latitude
                                                    longitude:_userLocation.location.coordinate.longitude];
    }
    else
    {
        request.location = [AMapGeoPoint locationWithLatitude:39.990459 longitude:116.471476];
    }
    
    request.keywords            = [segmentedControl titleForSegmentAtIndex:segmentedControl.selectedSegmentIndex];
    request.sortrule            = 1;
    request.requireExtension    = NO;
    
    [self.search AMapPOIAroundSearch:request];
}

#pragma mark - Actions

- (void)routePlanAction
{
    [self.driveManager calculateDriveRouteWithEndPoints:@[_endPoint]
                                              wayPoints:nil
                                        drivingStrategy:AMapNaviDrivingStrategySingleDefault];
}

#pragma mark - DriveNaviView Delegate

- (void)driveNaviViewCloseButtonClicked
{
    [self.driveManager stopNavi];
    
    //停止语音
    [[SpeechSynthesizer sharedSpeechSynthesizer] stopSpeak];
    
    [self.navigationController popViewControllerAnimated:NO];
}

#pragma mark - AMapNaviDriveManager Delegate

- (void)driveManager:(AMapNaviDriveManager *)driveManager error:(NSError *)error
{
    NSLog(@"error:{%ld - %@}", (long)error.code, error.localizedDescription);
}

- (void)driveManagerOnCalculateRouteSuccess:(AMapNaviDriveManager *)driveManager
{
    NSLog(@"onCalculateRouteSuccess");
    
    DriveNaviViewController *driveVC = [[DriveNaviViewController alloc] init];
    [driveVC setDelegate:self];
    
    //将driveView添加到AMapNaviDriveManager中
    [self.driveManager addDataRepresentative:driveVC.driveView];
    
    [self.navigationController pushViewController:driveVC animated:NO];
    [self.driveManager startGPSNavi];
}

- (void)driveManager:(AMapNaviDriveManager *)driveManager onCalculateRouteFailure:(NSError *)error
{
    NSLog(@"onCalculateRouteFailure:{%ld - %@}", (long)error.code, error.localizedDescription);
}

- (void)driveManager:(AMapNaviDriveManager *)driveManager didStartNavi:(AMapNaviMode)naviMode
{
    NSLog(@"didStartNavi");
}

- (void)driveManagerNeedRecalculateRouteForYaw:(AMapNaviDriveManager *)driveManager
{
    NSLog(@"needRecalculateRouteForYaw");
}

- (void)driveManagerNeedRecalculateRouteForTrafficJam:(AMapNaviDriveManager *)driveManager
{
    NSLog(@"needRecalculateRouteForTrafficJam");
}

- (void)driveManager:(AMapNaviDriveManager *)driveManager onArrivedWayPoint:(int)wayPointIndex
{
    NSLog(@"onArrivedWayPoint:%d", wayPointIndex);
}

- (void)driveManager:(AMapNaviDriveManager *)driveManager playNaviSoundString:(NSString *)soundString soundStringType:(AMapNaviSoundType)soundStringType
{
    NSLog(@"playNaviSoundString:{%ld:%@}", (long)soundStringType, soundString);
    
    [[SpeechSynthesizer sharedSpeechSynthesizer] speakString:soundString];
}

- (void)driveManagerDidEndEmulatorNavi:(AMapNaviDriveManager *)driveManager
{
    NSLog(@"didEndEmulatorNavi");
}

- (void)driveManagerOnArrivedDestination:(AMapNaviDriveManager *)driveManager
{
    NSLog(@"onArrivedDestination");
}

#pragma mark - Search Delegate

- (void)AMapSearchRequest:(id)request didFailWithError:(NSError *)error
{
    NSLog(@"SearchError:{%@}", error.localizedDescription);
}

- (void)onPOISearchDone:(AMapPOISearchBaseRequest *)request response:(AMapPOISearchResponse *)response
{
    if (response.pois.count == 0)
    {
        return;
    }
    
    [self.mapView removeAnnotations:_poiAnnotations];
    [_poiAnnotations removeAllObjects];
    
    [response.pois enumerateObjectsUsingBlock:^(AMapPOI *obj, NSUInteger idx, BOOL *stop) {
        
        MAPointAnnotation *annotation = [[MAPointAnnotation alloc] init];
        [annotation setCoordinate:CLLocationCoordinate2DMake(obj.location.latitude, obj.location.longitude)];
        [annotation setTitle:obj.name];
        [annotation setSubtitle:obj.address];
        
        [_poiAnnotations addObject:annotation];
    }];
    
    [self showPOIAnnotations];
}

- (void)showPOIAnnotations
{
    [self.mapView addAnnotations:_poiAnnotations];
    
    if (_poiAnnotations.count == 1)
    {
        self.mapView.centerCoordinate = [(MAPointAnnotation *)_poiAnnotations[0] coordinate];
    }
    else
    {
        [self.mapView showAnnotations:_poiAnnotations animated:NO];
    }
}

#pragma mark - MapView Delegate

- (void)mapView:(MAMapView *)mapView didUpdateUserLocation:(MAUserLocation *)userLocation updatingLocation:(BOOL)updatingLocation
{
    if (updatingLocation)
    {
        _userLocation = userLocation;
    }
    
    if ([_poiAnnotations count] == 0)
    {
        MAPointAnnotation *annotation = [[MAPointAnnotation alloc] init];
        [annotation setCoordinate:CLLocationCoordinate2DMake(_userLocation.coordinate.latitude, _userLocation.coordinate.longitude)];
        [annotation setTitle:@"当前位置"];
        [annotation setSubtitle:@"开始导航"];
        
        [_poiAnnotations addObject:annotation];
        
        [self showPOIAnnotations];
    }
}

- (void)mapView:(MAMapView *)mapView annotationView:(MAAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    if ([view.annotation isKindOfClass:[MAPointAnnotation class]])
    {
        MAPointAnnotation *annotation = (MAPointAnnotation *)view.annotation;
        
        _endPoint = [AMapNaviPoint locationWithLatitude:annotation.coordinate.latitude
                                              longitude:annotation.coordinate.longitude];
        
        //配置导航参数
        AMapNaviConfig * config = [[AMapNaviConfig alloc] init];
        config.destination = view.annotation.coordinate;//终点坐标，Annotation的坐标
        
        
        config.appScheme = [self getApplicationScheme];
        config.appName = [self getApplicationName];
        config.strategy =AMapDrivingStrategyShortest;
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"请选择导航方式" preferredStyle:UIAlertControllerStyleAlert];
        
        
        
        //判断是否安装高德地图
        if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"iosamap://"]])
        
        {
            UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"调用高德地图导航" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
#warning 提示 这里的两个方法都可以跳转到地图
        /*
         Method1: 这里是系统调用的方法
         
                NSString *urlString = [[NSString stringWithFormat:AMAPSchemeUrl,config.appName,config.appScheme,config.destination.latitude, config.destination.longitude] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
         
               [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
        */
                
         /*    
          Method2: 这里是高德封装好的API,配置后可以直接使用,
         */
                [AMapURLSearch openAMapNavigation:config];
            }];
            [alert addAction:action1];

           
        }
        
        //判断是否安装百度地图
        if ( [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"baidumap://"]])
        {
            UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"调用百度地图导航" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                
                NSString *urlString = [[NSString stringWithFormat:@"baidumap://map/direction?origin={{我的位置}}&destination=latlng:%f,%f|name=目的地&mode=driving&coord_type=gcj02",config.destination.latitude, config.destination.longitude] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                
                NSLog(@"%@",urlString);
                
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
                
            }];
            
            [alert addAction:action2];
        }
        
        
        
        UIAlertAction *action3 = [UIAlertAction actionWithTitle:@"调用本地导航" style:0 handler:^(UIAlertAction * _Nonnull action) {
        
                [self routePlanAction];

        }];
        
        
        [alert addAction:action3];
        
        
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
        [alert addAction:action];
        
        [self presentViewController:alert animated:YES completion:nil];
 
        
    }
}

- (NSString *)getApplicationName
{
    NSDictionary *bundleInfo = [[NSBundle mainBundle] infoDictionary];
    return [bundleInfo valueForKey:@"CFBundleDisplayName"] ?: [bundleInfo valueForKey:@"CFBundleName"];
}

- (NSString *)getApplicationScheme
{
    NSDictionary *bundleInfo    = [[NSBundle mainBundle] infoDictionary];
    NSString *bundleIdentifier  = [[NSBundle mainBundle] bundleIdentifier];
    
    NSArray *URLTypes           = [bundleInfo valueForKey:@"CFBundleURLTypes"];
    
    NSString *scheme;
    for (NSDictionary *dic in URLTypes)
    {
        NSString *URLName = [dic valueForKey:@"CFBundleURLName"];
        if ([URLName isEqualToString:bundleIdentifier])
        {
            scheme = [[dic valueForKey:@"CFBundleURLSchemes"] objectAtIndex:0];
            break;
        }
    }
//    NSLog(@"%@",scheme);
    return scheme;
}


- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id<MAAnnotation>)annotation
{
    if ([annotation isKindOfClass:[MAPointAnnotation class]])
    {
        static NSString *pointReuseIndetifier = @"QuickStartAnnotationView";
        QuickStartAnnotationView *annotationView = (QuickStartAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:pointReuseIndetifier];
        
        if (annotationView == nil)
        {
            annotationView = [[QuickStartAnnotationView alloc] initWithAnnotation:annotation
                                                                  reuseIdentifier:pointReuseIndetifier];
        }
        
        annotationView.canShowCallout = YES;
        annotationView.draggable = NO;
        
        return annotationView;
    }
    
    return nil;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
