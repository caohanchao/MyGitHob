//
//  RouteSearchViewController.m
//  GDMapDemo
//
//  Created by caohanchao on 16/8/7.
//  Copyright © 2016年 caohanchao. All rights reserved.
//

#import "RouteSearchViewController.h"
#import "MANaviRoute.h"
#import "CommonUtility.h"
const NSString *RoutePlanningViewControllerStartTitle       = @"起点";
const NSString *RoutePlanningViewControllerDestinationTitle = @"终点";
const NSInteger RoutePlanningPaddingEdge                    = 20;

@interface RouteSearchViewController ()<MAMapViewDelegate,UITextFieldDelegate>
{
    UIButton *_cancelButton;
    UITextField * _startPoint;
    UITextField * _endPoint;
    UISegmentedControl *_segment;
    
    MAPointAnnotation *startAnnotation;
    MAPointAnnotation *endAnnotation;
}


@property (nonatomic, strong) UIBarButtonItem *previousItem;
@property (nonatomic, strong) UIBarButtonItem *nextItem;

//路线
@property (nonatomic, strong) AMapRoute *route;

@property(nonatomic,strong)AMapGeocodeSearchRequest *request1;
@property(nonatomic,strong)AMapGeocodeSearchRequest *request2;

//路径规划类型
@property (nonatomic) AMapRoutePlanningType routePlanningType;

/* 当前路线方案索引值. */
@property (nonatomic) NSInteger currentCourse;
/* 路线方案个数. */
@property (nonatomic) NSInteger totalCourse;

/* 起始点经纬度. */
@property (nonatomic) AMapGeoPoint* startCoordinate;
/* 终点经纬度. */
@property (nonatomic) AMapGeoPoint* endCoordinate;


/* 用于显示当前路线方案. */
@property (nonatomic) MANaviRoute * naviRoute;


@end


@implementation RouteSearchViewController


#pragma mark - 懒加载
-(AMapGeocodeSearchRequest *)request1
{
    if (!_request1)
    {
        _request1 = [[AMapGeocodeSearchRequest alloc]init];
    }
    return _request1;

}

-(AMapGeocodeSearchRequest *)request2
{
    if (!_request2)
    {
        _request2 = [[AMapGeocodeSearchRequest alloc]init];
    }
    return _request2;
    
}


//在地图上添加Annotations
- (void)addDefaultAnnotations:(AMapGeocodeSearchRequest *)request
{
    if (request == _request1)
    {
        [_mapView removeAnnotation:startAnnotation];
        startAnnotation = [[MAPointAnnotation alloc] init];
        startAnnotation.coordinate = CLLocationCoordinate2DMake(self.startCoordinate.latitude, self.startCoordinate.longitude);
        startAnnotation.title      = (NSString*)RoutePlanningViewControllerStartTitle;
        startAnnotation.subtitle   = [NSString stringWithFormat:@"{%f, %f}", self.startCoordinate.latitude, self.startCoordinate.longitude];
         [_mapView addAnnotation:startAnnotation];
    }
    else
    {
        [_mapView removeAnnotation:endAnnotation];
        endAnnotation = [[MAPointAnnotation alloc] init];
        endAnnotation.coordinate = CLLocationCoordinate2DMake(self.endCoordinate.latitude, self.endCoordinate.longitude);
        endAnnotation.title      = (NSString*)RoutePlanningViewControllerDestinationTitle;
        endAnnotation.subtitle   = [NSString stringWithFormat:@"{%f, %f}", self.endCoordinate.latitude, self.endCoordinate.longitude];

        
        [_mapView addAnnotation:endAnnotation];
    }
    
}


#pragma mark - init
-(void)initNav
{
    
    UIView *view =[[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 104)];
    view.backgroundColor =
    [UIColor colorWithRed:0.16 green:0.56 blue:0.99 alpha:1.00];
    
    UIButton *searchBtn =[UIButton buttonWithType:UIButtonTypeCustom];
    searchBtn.frame =CGRectMake(self.view.frame.size.width-40, 50, 30, 30);
    [searchBtn setImage:[UIImage imageNamed:@"search"] forState:UIControlStateNormal];
    [searchBtn addTarget:self action:@selector(searchAction) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:searchBtn];
    
    /**************1.分段选取器**************/
    //参数数组里存放的是字符串（标题）或者图片
    _segment = [[UISegmentedControl alloc] initWithItems:@[@"步行",@"公交",@"驾车"]];
    _segment.frame = CGRectMake(self.view.frame.size.width/2-90, 20,180 , 30);
    //设置哪个分段处于选中状态
    _segment.selectedSegmentIndex = 0;
    
    //添加响应事件
//    事件类型 UIControlEventValueChanged
    [_segment addTarget:self action:@selector(segmentValueAction:) forControlEvents:UIControlEventValueChanged];
    //设置内容渲染颜色
    _segment.tintColor = [UIColor whiteColor];
    [view addSubview:_segment];
    
    
    //起点
    _startPoint = [[UITextField alloc]initWithFrame:CGRectMake(100,55 , self.view.frame.size.width-200, 20)];
    _startPoint.borderStyle =UITextBorderStyleRoundedRect;
    _startPoint.placeholder =@"起点";
    _startPoint.delegate = self;
//    _startPoint.text = _currentLocation;
    _startPoint.textAlignment = NSTextAlignmentCenter;
    _startPoint.returnKeyType = UIReturnKeySearch;
    [view addSubview:_startPoint];
    
    //终点
    _endPoint = [[UITextField alloc]initWithFrame:CGRectMake(100,80 , self.view.frame.size.width-200, 20)];
    _endPoint.borderStyle =UITextBorderStyleRoundedRect;
    _endPoint.placeholder =@"终点";
    _endPoint.delegate = self;
    _endPoint.textAlignment = NSTextAlignmentCenter;
    _endPoint.returnKeyType = UIReturnKeySearch;
    [view addSubview:_endPoint];
    
    
    _cancelButton = [UIButton buttonWithType:UIButtonTypeSystem];
    
    _cancelButton.frame = CGRectMake(10,50, 30, 30);
    
    [_cancelButton setTitle:@"⬅️" forState:UIControlStateNormal];
    _cancelButton.titleLabel.font = [UIFont systemFontOfSize:30];
    [_cancelButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    //    _cancelButton.titleLabel.font = [UIFont systemFontOfSize:15];
    [_cancelButton addTarget:self action:@selector(cancelClick)
            forControlEvents:UIControlEventTouchUpInside];
    
    [view addSubview:_cancelButton];
    [self.view addSubview:view];

}


#pragma mark - 选择器下标 转换 路线规划类型
/* 将selectedIndex 转换为响应的AMapRoutePlanningType. */
- (AMapRoutePlanningType)searchTypeForSelectedIndex:(NSInteger)selectedIndex
{
    AMapRoutePlanningType navitgationType = 0;
    
    switch (selectedIndex)
    {
        case 0: navitgationType = AMapRoutePlanningTypeDrive;   break;
        case 1: navitgationType = AMapRoutePlanningTypeWalk; break;
        case 2: navitgationType = AMapRoutePlanningTypeBus;     break;
        default:NSAssert(NO, @"%s: selectedindex = %ld is invalid for RoutePlanning", __func__, (long)selectedIndex); break;
    }
    
    return navitgationType;
}


#pragma mark - Action

-(void)segmentValueAction:(UISegmentedControl *)segmentedControl
{
    self.routePlanningType = [self searchTypeForSelectedIndex:segmentedControl.selectedSegmentIndex];
    
    self.route = nil;
    self.totalCourse   = 0;
    self.currentCourse = 0;
    
//    [self updateDetailUI];
//    [self updateCourseUI];
    
    [self clear];
    
    if ([_startPoint.text isEqualToString:@""] && [_endPoint.text isEqualToString:@""])
    {
        return;
    }
    else
    {
        /* 发起路径规划搜索请求. */
        [self SearchNaviWithType:self.routePlanningType];
    }
    
    

}

-(void)cancelClick
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)searchAction
{
    [self clear];
    [self showSearch];
//    [self SearchNaviWithType:self.routePlanningType];
    [self.view endEditing:YES];
//    [self addDefaultAnnotations];
    
}

-(void)showSearch
{

    
    dispatch_group_t group = dispatch_group_create();
    
    dispatch_group_async(group, dispatch_get_global_queue(0,0), ^{
        self.request1 = [[AMapGeocodeSearchRequest alloc]init];
        
        self.request1.address = _startPoint.text;
        // 并行执行的线程一
        [_search AMapGeocodeSearch: self.request1];

    });
    dispatch_group_async(group, dispatch_get_global_queue(0,0), ^{
        self.request2 = [[AMapGeocodeSearchRequest alloc]init];
        
        self.request2.address = _endPoint.text;
        // 并行执行的线程二
        [_search AMapGeocodeSearch: self.request2];
        
    });
    
    
    dispatch_group_notify(group, dispatch_get_global_queue(0,0), ^{
        // 汇总结果
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            
//        [self SearchNaviWithType:self.routePlanningType];
//           NSLog(@"起点:%@ 终点:%@",self.startCoordinate,self.endCoordinate);
//            [self addDefaultAnnotations];
        });
        

        
    });
    
    
    NSLog(@"起点:%@ 终点:%@",self.startCoordinate,self.endCoordinate);
    

}


/* 根据routePlanningType来执行响应的路径规划搜索*/
- (void)SearchNaviWithType:(AMapRoutePlanningType)searchType
{
    switch (searchType)
    {
        case AMapRoutePlanningTypeDrive:
        {
            [self searchRoutePlanningDrive];
            
            break;
        }
        case AMapRoutePlanningTypeWalk:
        {
            [self searchRoutePlanningWalk];
            
            break;
        }
        case AMapRoutePlanningTypeBus:
        {
            [self searchRoutePlanningBus];
            
            break;
        }
    }
}

#pragma mark - AMapSearchDelegate

/* 路径规划搜索回调. */
- (void)onRouteSearchDone:(AMapRouteSearchBaseRequest *)request response:(AMapRouteSearchResponse *)response
{
    if (response.route == nil)
    {
        return;
    }
    
    self.route = response.route;
    [self updateTotal];
    self.currentCourse = 0;
    
//    [self updateCourseUI];
//    [self updateDetailUI];
    
    [self presentCurrentCourse];
    
    
}

- (void)updateTotal
{
    NSUInteger total = 0;
    
    if (self.route != nil)
    {
        switch (self.routePlanningType)
        {
            case AMapRoutePlanningTypeDrive   :
            case AMapRoutePlanningTypeWalk    : total = self.route.paths.count;    break;
            case AMapRoutePlanningTypeBus     : total = self.route.transits.count; break;
            default: total = 0; break;
        }
    }
    
    self.totalCourse = total;
}

- (void)presentCurrentCourse
{
    /* 公交路径规划. */
    if (self.routePlanningType == AMapRoutePlanningTypeBus)
    {
        self.naviRoute = [MANaviRoute naviRouteForTransit:self.route.transits[self.currentCourse]];
    }
    /* 步行，驾车路径规划. */
    else
    {
        MANaviAnnotationType type = self.routePlanningType == AMapRoutePlanningTypeDrive ? MANaviAnnotationTypeDrive : MANaviAnnotationTypeWalking;
        self.naviRoute = [MANaviRoute naviRouteForPath:self.route.paths[self.currentCourse] withNaviType:type showTraffic:YES];
    }
    
    [self.naviRoute addToMapView:_mapView];
    
    
    
    
    /* 缩放地图使其适应polylines的展示. */
    [_mapView setVisibleMapRect:[CommonUtility mapRectForOverlays:self.naviRoute.routePolylines]
                        edgePadding:UIEdgeInsetsMake(RoutePlanningPaddingEdge, RoutePlanningPaddingEdge, RoutePlanningPaddingEdge, RoutePlanningPaddingEdge)
                           animated:YES];
}


/* 更新"上一个", "下一个"按钮状态. */
- (void)updateCourseUI
{
    /* 上一个. */
    self.previousItem.enabled = (self.currentCourse > 0);
    
    /* 下一个. */
    self.nextItem.enabled = (self.currentCourse < self.totalCourse - 1);
}

/* 更新"详情"按钮状态. */
- (void)updateDetailUI
{
    self.navigationItem.rightBarButtonItem.enabled = self.route != nil;
}

/* 清空地图上已有的路线. */
- (void)clear
{
    [self.naviRoute removeFromMapView];
}

#pragma mark - RoutePlanning Search

/* 公交路径规划搜索. */
- (void)searchRoutePlanningBus
{
    AMapTransitRouteSearchRequest *navi = [[AMapTransitRouteSearchRequest alloc] init];
    
    navi.requireExtension = YES;
    navi.city             = _startPoint.text;
    
    /* 出发点. */
    navi.origin = [AMapGeoPoint locationWithLatitude:self.startCoordinate.latitude
                                           longitude:self.startCoordinate.longitude];
    /* 目的地. */
    navi.destination = [AMapGeoPoint locationWithLatitude:self.endCoordinate.latitude
                                                longitude:self.endCoordinate.longitude];
    
    [_search AMapTransitRouteSearch:navi];
}

/* 步行路径规划搜索. */
- (void)searchRoutePlanningWalk
{
    AMapWalkingRouteSearchRequest *navi = [[AMapWalkingRouteSearchRequest alloc] init];
    
    /* 提供备选方案*/
    navi.multipath = 1;
    
    /* 出发点. */
    navi.origin = [AMapGeoPoint locationWithLatitude:self.startCoordinate.latitude
                                           longitude:self.startCoordinate.longitude];
    /* 目的地. */
    navi.destination = [AMapGeoPoint locationWithLatitude:self.endCoordinate.latitude
                                                longitude:self.endCoordinate.longitude];
    
    [_search AMapWalkingRouteSearch:navi];
}

/* 驾车路径规划搜索. */
- (void)searchRoutePlanningDrive
{
    AMapDrivingRouteSearchRequest *navi = [[AMapDrivingRouteSearchRequest alloc] init];
    
    navi.requireExtension = YES;
    navi.strategy = 5;
    /* 出发点. */
    navi.origin = [AMapGeoPoint locationWithLatitude:self.startCoordinate.latitude
                                           longitude:self.startCoordinate.longitude];
    /* 目的地. */
    navi.destination = [AMapGeoPoint locationWithLatitude:self.endCoordinate.latitude
                                                longitude:self.endCoordinate.longitude];
    
    [_search AMapDrivingRouteSearch:navi];
}




//实现正向地理编码的回调函数
- (void)onGeocodeSearchDone:(AMapGeocodeSearchRequest *)request response:(AMapGeocodeSearchResponse *)response
{
    
    if(response.geocodes.count == 0)
    {
        return;
    }
    
    //通过AMapGeocodeSearchResponse对象处理搜索结果

    for (id obj in response.geocodes)
    {

        AMapGeocode *code  = obj;
        if (request ==_request1)
        {
            self.startCoordinate = code.location;
            
            
            NSLog(@"起点:%lf,%lf",code.location.longitude,code.location.latitude);
            
            [self addDefaultAnnotations:_request1];
        
            
        }
        else
        {
            self.endCoordinate =code.location;
            NSLog(@"终点:%lf,%lf",code.location.longitude,code.location.latitude);
            
            [self addDefaultAnnotations:_request2];

        }
        
        [self SearchNaviWithType:self.routePlanningType];

       
    }
    
    
//    [self addDefaultAnnotations];

}



#pragma mark - MAMapViewDelegate

- (MAOverlayRenderer *)mapView:(MAMapView *)mapView rendererForOverlay:(id<MAOverlay>)overlay
{
    if ([overlay isKindOfClass:[LineDashPolyline class]])
    {
        MAPolylineRenderer *polylineRenderer = [[MAPolylineRenderer alloc] initWithPolyline:((LineDashPolyline *)overlay).polyline];
        
        polylineRenderer.lineWidth   = 7;
        polylineRenderer.strokeColor = [UIColor blueColor];
        
        return polylineRenderer;
    }
    if ([overlay isKindOfClass:[MANaviPolyline class]])
    {
        MANaviPolyline *naviPolyline = (MANaviPolyline *)overlay;
        MAPolylineRenderer *polylineRenderer = [[MAPolylineRenderer alloc] initWithPolyline:naviPolyline.polyline];
        
        polylineRenderer.lineWidth = 8;
        
        if (naviPolyline.type == MANaviAnnotationTypeWalking)
        {
            polylineRenderer.strokeColor = self.naviRoute.walkingColor;
        }
        else
        {
            polylineRenderer.strokeColor = self.naviRoute.routeColor;
        }
        
        return polylineRenderer;
    }
    if ([overlay isKindOfClass:[MAMultiPolyline class]])
    {
        MAMultiColoredPolylineRenderer * polylineRenderer = [[MAMultiColoredPolylineRenderer alloc] initWithMultiPolyline:overlay];
        
        polylineRenderer.lineWidth = 10;
        polylineRenderer.strokeColors = [self.naviRoute.multiPolylineColors copy];
        polylineRenderer.gradient = YES;
        
        return polylineRenderer;
    }
    
    return nil;
}

- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id<MAAnnotation>)annotation
{

    if ([annotation isKindOfClass:[MAPointAnnotation class]])
    {
        static NSString *routePlanningCellIdentifier = @"RoutePlanningCellIdentifier";
        
        MAAnnotationView *poiAnnotationView = (MAAnnotationView*)[_mapView dequeueReusableAnnotationViewWithIdentifier:routePlanningCellIdentifier];
        if (poiAnnotationView == nil)
        {
            poiAnnotationView = [[MAAnnotationView alloc] initWithAnnotation:annotation
                                                             reuseIdentifier:routePlanningCellIdentifier];
        }
        
        poiAnnotationView.canShowCallout = YES;
        
        if ([annotation isKindOfClass:[MANaviAnnotation class]])
        {
            switch (((MANaviAnnotation*)annotation).type)
            {
                case MANaviAnnotationTypeBus:
                    poiAnnotationView.image = [UIImage imageNamed:@"bus"];
                    break;
                    
                case MANaviAnnotationTypeDrive:
                    poiAnnotationView.image = [UIImage imageNamed:@"car"];
                    break;
                    
                case MANaviAnnotationTypeWalking:
                    poiAnnotationView.image = [UIImage imageNamed:@"man"];
                    break;
                    
                default:
                    break;
            }
        }
        else
        {
            /* 起点. */
            if ([[annotation title] isEqualToString:(NSString*)RoutePlanningViewControllerStartTitle])
            {
                poiAnnotationView.image = [UIImage imageNamed:@"startPoint"];
            }
            /* 终点. */
            else if([[annotation title] isEqualToString:(NSString*)RoutePlanningViewControllerDestinationTitle])
            {
                poiAnnotationView.image = [UIImage imageNamed:@"endPoint"];
            }
            
        }
        
        return poiAnnotationView;
    }
    
    return nil;
}

-(void)viewWillAppear:(BOOL)animated
{
    _mapView.frame = CGRectMake(0, 104, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds)-60-36);

}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor =[UIColor colorWithRed:0.55 green:0.73 blue:0.95 alpha:1.00];
    
    
    [self initNav];
    
    
    // Do any additional setup after loading the view.
}

//- (id)init
//{
//    if (self = [super init])
//    {
//        self.startCoordinate        = [AMapGeoPoint locationWithLatitude:39.910267 longitude:116.370888];
//        self.endCoordinate  =[AMapGeoPoint locationWithLatitude:39.989872 longitude:116.481956];
//    }
//    
//    return self;
//}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    
    [self searchAction];
    [textField resignFirstResponder];
    return YES;
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
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
