//
//  RootViewController.m
//  GDMapDemo
//
//  Created by caohanchao on 16/8/7.
//  Copyright © 2016年 caohanchao. All rights reserved.
//

#import "RootViewController.h"



#import "NearbySearchViewController.h"
#import "RouteSearchViewController.h"
#import "WeatherSearchViewController.h"
#import "NavViewController.h"



@interface RootViewController ()<MAMapViewDelegate,AMapSearchDelegate,UITableViewDelegate,UITableViewDataSource>
{
    NSMutableArray *_messageContents;
    int _messageCount;
    int _notificationCount;
    
}
@property (nonatomic) CGFloat level;
@property(nonatomic,copy)NSArray *dataArray;
@end

@implementation RootViewController



//懒加载
-(NSArray *)dataArray
{
    if (!_dataArray)
    {
        _dataArray =[NSArray arrayWithObjects:@"附近搜索",@"路线搜索",@"天气搜索",@"导航", nil];
        
    }
    return _dataArray;
}




#pragma mark -init


UIButton * _locationButton;
UIButton * _mapTypeButton;
UIButton * _showTrafficButton;
UIButton * _heatMapButton;
UIButton * _overlayButton;
UIButton * _moreButton;
UIButton * _bigButton;
UIButton * _smallButton;


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
    
    
    _moreButton = [UIButton buttonWithType:UIButtonTypeSystem];
    _moreButton.frame = CGRectMake(self.view.frame.size.width-50,20, 40, 40);
    _moreButton.autoresizingMask = UIViewAutoresizingFlexibleRightMargin |
    UIViewAutoresizingFlexibleTopMargin;
    //    _moreButton.backgroundColor = [UIColor whiteColor];
    _moreButton.layer.cornerRadius = 5;
    [_moreButton setTitle:@"➕" forState:UIControlStateNormal];
    [_moreButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    _moreButton.titleLabel.font = [UIFont systemFontOfSize:15];
    [_moreButton addTarget:self action:@selector(presentTableViewAction)
          forControlEvents:UIControlEventTouchUpInside];
    ;
    [view addSubview:_moreButton];
    [self.view addSubview:view];
    
    
}

//
-(void)initControls
{
    //定位类型
    _locationButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _locationButton.frame = CGRectMake(20, CGRectGetHeight(_mapView.bounds) - 80, 40, 40);
    _locationButton.autoresizingMask = UIViewAutoresizingFlexibleRightMargin |
    UIViewAutoresizingFlexibleTopMargin;
    _locationButton.backgroundColor = [UIColor whiteColor];
    _locationButton.layer.cornerRadius = 5;
    [_locationButton addTarget:self action:@selector(locateAction)
              forControlEvents:UIControlEventTouchUpInside];
    [_locationButton setImage:[UIImage imageNamed:@"location_no"] forState:UIControlStateNormal];
    //    [_locationButton setImage:[UIImage imageNamed:@"location_yes"] forState:UIControlStateSelected];
    
    [_mapView addSubview:_locationButton];
    
    
    //地图类型
    _mapTypeButton =[UIButton buttonWithType:UIButtonTypeSystem];
    _mapTypeButton.frame =CGRectMake(80,CGRectGetHeight(_mapView.bounds) - 80, 40, 40);
    _mapTypeButton.autoresizingMask = UIViewAutoresizingFlexibleRightMargin |
    UIViewAutoresizingFlexibleTopMargin;
    _mapTypeButton.layer.cornerRadius = 5;
    [_mapTypeButton setTitle:@"普通" forState:UIControlStateNormal];
    [_mapTypeButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    _mapTypeButton.titleLabel.font = [UIFont systemFontOfSize:15];
    _mapTypeButton.backgroundColor =[UIColor colorWithRed:0.80 green:0.93 blue:0.91 alpha:1.00];
    [_mapTypeButton addTarget:self action:@selector(MapTypeSelectOfAction)
             forControlEvents:UIControlEventTouchUpInside];
    [_mapView addSubview:_mapTypeButton];
    
    //交通路况
    _showTrafficButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _showTrafficButton.frame = CGRectMake(140, CGRectGetHeight(_mapView.bounds) - 80, 40, 40);
    _showTrafficButton.autoresizingMask = UIViewAutoresizingFlexibleRightMargin |
    UIViewAutoresizingFlexibleTopMargin;
    _showTrafficButton.backgroundColor = [UIColor colorWithRed:0.80 green:0.93 blue:0.91 alpha:1.00];
    _showTrafficButton.layer.cornerRadius = 5;
    [_showTrafficButton setTitle:@"🚦" forState:UIControlStateNormal];
    [_showTrafficButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    _showTrafficButton.titleLabel.font = [UIFont systemFontOfSize:18];
    [_showTrafficButton addTarget:self action:@selector(showTrafficAction)
                 forControlEvents:UIControlEventTouchUpInside];
    ;
    
    [_mapView addSubview:_showTrafficButton];
    
    
    //热力图
    
    _heatMapButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _heatMapButton.frame = CGRectMake(200, CGRectGetHeight(_mapView.bounds) - 80, 40, 40);
    _heatMapButton.autoresizingMask = UIViewAutoresizingFlexibleRightMargin |
    UIViewAutoresizingFlexibleTopMargin;
    _heatMapButton.backgroundColor = [UIColor colorWithRed:0.80 green:0.93 blue:0.91 alpha:1.00];
    _heatMapButton.layer.cornerRadius = 5;
    [_heatMapButton setTitle:@"Heat" forState:UIControlStateNormal];
    [_heatMapButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    _heatMapButton.titleLabel.font = [UIFont systemFontOfSize:15];
    [_heatMapButton addTarget:self action:@selector(showHeatMapAction)
             forControlEvents:UIControlEventTouchUpInside];
    ;
    
    [_mapView addSubview:_heatMapButton];
    
    
    //自定义_overlayButton
    _overlayButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _overlayButton.frame = CGRectMake(260, CGRectGetHeight(_mapView.bounds) - 80, 40, 40);
    _overlayButton.autoresizingMask = UIViewAutoresizingFlexibleRightMargin |
    UIViewAutoresizingFlexibleTopMargin;
    _overlayButton.backgroundColor = [UIColor colorWithRed:0.80 green:0.93 blue:0.91 alpha:1.00];
    _overlayButton.layer.cornerRadius = 5;
    [_overlayButton setTitle:@"🌕" forState:UIControlStateNormal];
    [_overlayButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    _overlayButton.titleLabel.font = [UIFont systemFontOfSize:18];
    [_overlayButton addTarget:self action:@selector(showCircleAction)
             forControlEvents:UIControlEventTouchUpInside];
    ;
    [_mapView addSubview:_overlayButton];
    
    
    _bigButton = [UIButton buttonWithType:UIButtonTypeSystem];
    _bigButton.frame =CGRectMake(CGRectGetMaxX(_mapView.bounds)-60, CGRectGetMaxY(_mapView.bounds)-200, 40, 40);
    
    _bigButton.autoresizingMask = UIViewAutoresizingFlexibleRightMargin |
    UIViewAutoresizingFlexibleTopMargin;
    _bigButton.backgroundColor = [UIColor colorWithRed:0.80 green:0.93 blue:0.91 alpha:1.00];
    _bigButton.layer.cornerRadius = 5;
    [_bigButton setTitle:@"➕" forState:UIControlStateNormal];
    [_bigButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    _bigButton.titleLabel.font = [UIFont systemFontOfSize:18];
    [_bigButton addTarget:self action:@selector(showMoreBigAction)
             forControlEvents:UIControlEventTouchUpInside];
    ;
    [_mapView addSubview:_bigButton];
    
    
    _smallButton = [UIButton buttonWithType:UIButtonTypeSystem];
    _smallButton.frame =CGRectMake(CGRectGetMaxX(_mapView.bounds)-60, CGRectGetMaxY(_mapView.bounds)-260, 40, 40);
    
    _smallButton.autoresizingMask = UIViewAutoresizingFlexibleRightMargin |
    UIViewAutoresizingFlexibleTopMargin;
    _smallButton.backgroundColor = [UIColor colorWithRed:0.80 green:0.93 blue:0.91 alpha:1.00];
    _smallButton.layer.cornerRadius = 5;
    [_smallButton setTitle:@"➖" forState:UIControlStateNormal];
    [_smallButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    _smallButton.titleLabel.font = [UIFont systemFontOfSize:18];
    [_smallButton addTarget:self action:@selector(showMoreSmallAction)
         forControlEvents:UIControlEventTouchUpInside];
    ;
    [_mapView addSubview:_smallButton];
    
}

- (void)initSearch
{
    _search = [[AMapSearchAPI alloc]init];
    _search.delegate =self;
    
}



-(void)initMapView
{
    [AMapServices sharedServices].apiKey  =APIKey;
    
    _mapView = [[MAMapView alloc]initWithFrame:CGRectMake(0, 60, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds)-60)];
    _mapView.delegate =self;
    _mapView.compassOrigin =CGPointMake(_mapView.compassOrigin.x, 22);
    _mapView.scaleOrigin =CGPointMake(_mapView.scaleOrigin.x, 22);
    [self.view addSubview:_mapView];
    
    //打开定位功能
    _mapView.showsUserLocation = YES;
    
    //    _mapView.userTrackingMode = MAUserTrackingModeFollowWithHeading ;
    
}


#pragma mark -Action


MACircle *circle;
//创建圆
-(void)showCircleAction
{
    if(!circle)
    {
        circle = [MACircle circleWithCenterCoordinate:CLLocationCoordinate2DMake(_currentLocation.coordinate.latitude, _currentLocation.coordinate.longitude) radius:1000];
        //在地图上添加圆
        [_mapView addOverlay: circle];
    }
    else
    {
        [_mapView removeOverlay:circle];
        circle =nil;
    }
    
    
}


//通过按钮改变定位方式
-(void)locateAction
{
        [_mapView setZoomLevel:15];
        switch (_mapView.userTrackingMode)
        {
            case 0:
            {
                [_mapView setUserTrackingMode:MAUserTrackingModeFollow animated:YES];
                _mapView.showsUserLocation = YES;
            }
                break;
            case 1:
            {
                [_mapView setUserTrackingMode:MAUserTrackingModeFollowWithHeading animated:YES];
                _mapView.showsUserLocation = YES;

            }
                break;
            case 2:
            {
                [_mapView setUserTrackingMode:MAUserTrackingModeNone animated:YES];
                _mapView.showsUserLocation = NO;

            }
                break;
            default:
                break;
        }
    
//    if (_mapView.userTrackingMode != MAUserTrackingModeFollow)
//    {
//        [_mapView setUserTrackingMode:MAUserTrackingModeFollow animated:YES];
//    }
//    else
//    {
//        [_mapView setUserTrackingMode:MAUserTrackingModeNone animated:YES];
//    }
    
    
}

//地图类型
-(void)MapTypeSelectOfAction
{
    //    _mapView.mapType
    switch (_mapView.mapType) {
        case 0:
        {
            _mapView.mapType = MAMapTypeSatellite;
            [_mapTypeButton setTitle:@"卫星" forState:UIControlStateNormal];
        }
            break;
        case 1:
        {
            _mapView.mapType =MAMapTypeStandardNight;
            [_mapTypeButton setTitle:@"夜间" forState:UIControlStateNormal];
        }
            break;
        case 2:
        {
            _mapView.mapType =MAMapTypeStandard;
            [_mapTypeButton setTitle:@"普通" forState:UIControlStateNormal];
            
            
        }
            break;
        default:
            break;
    }
    
}
//逆地理编码
-(void)reGeoAction
{
    if(_currentLocation)
    {
        AMapReGeocodeSearchRequest *request = [[AMapReGeocodeSearchRequest alloc] init];
        request.location = [AMapGeoPoint locationWithLatitude:_currentLocation.coordinate.latitude longitude:_currentLocation.coordinate.longitude];
        [_search AMapReGoecodeSearch:request];
        
    }
    
}

//交通路况
-(void)showTrafficAction
{
    _mapView.showTraffic =!_mapView.showTraffic;
}

//地图放大
-(void)showMoreBigAction
{
    self.level = _mapView.zoomLevel;
    self.level++;
    if (self.level<20)
    {
        [_mapView setZoomLevel:self.level];
    }
    
}
//地图缩小
-(void)showMoreSmallAction
{
    self.level = _mapView.zoomLevel;
    self.level--;
    if (self.level>3)
    {
        [_mapView setZoomLevel:self.level];
    }
}

#warning 这里的热力图需要从本地的json数据包中取出数据,与百度地图中的自有数据不同,需要添加热力图数据包

MAHeatMapTileOverlay  *_heatMapTileOverlay;
//热力图
-(void)showHeatMapAction
{
    
    //构造热力图图层对象
    if (!_heatMapTileOverlay)
    {
        _heatMapTileOverlay = [[MAHeatMapTileOverlay alloc] init];
        
        //    heatMapTileOverlay.allowRetinaAdapting =YES;
        //构造热力图数据，从locations.json中读取经纬度
        _heatMapTileOverlay.opacity = 0.6;
        NSMutableArray* data = [NSMutableArray array];
        
        NSData *jsdata = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"heatMapData" ofType:@"json"]];
        
        
        @autoreleasepool {
            
            if (jsdata)
            {
                NSArray *dicArray = [NSJSONSerialization JSONObjectWithData:jsdata options:NSJSONReadingAllowFragments error:nil];
                
                for (NSDictionary *dic in dicArray)
                {
                    MAHeatMapNode *node = [[MAHeatMapNode alloc] init];
                    CLLocationCoordinate2D coordinate;
                    coordinate.latitude = [dic[@"lat"] doubleValue];
                    coordinate.longitude = [dic[@"lng"] doubleValue];
                    node.coordinate = coordinate;
                    
                    node.intensity = 1;//设置权重
                    [data addObject:node];
                }
            }
            _heatMapTileOverlay.data = data;
            
            //构造渐变色对象
            MAHeatMapGradient *gradient = [[MAHeatMapGradient alloc] initWithColor:@[[UIColor blueColor],[UIColor greenColor], [UIColor redColor]] andWithStartPoints:@[@(0.2),@(0.5),@(0.9)]];
            _heatMapTileOverlay.gradient = gradient;
            
            //将热力图添加到地图上
            [_mapView addOverlay: _heatMapTileOverlay];
        }
    }
    else
    {
        [_mapView removeOverlay:_heatMapTileOverlay];
        _heatMapTileOverlay = nil;
    }
    
    
}

//弹起tableview菜单
-(void)presentTableViewAction
{
    
    if (!_bg)
    {
        _bg =[[UIView alloc]initWithFrame:CGRectMake(_moreButton.frame.origin.x-40,0,80, 170)];
        _bg.backgroundColor = [UIColor lightGrayColor];
        [_mapView addSubview:_bg];
        
        
        _tableView = [[UITableView alloc]initWithFrame:CGRectMake(_bg.bounds.origin.x, _bg.bounds.origin.y+5, _bg.bounds.size.width, _bg.bounds.size.height-10) style:UITableViewStylePlain];
        _tableView.delegate =self;
        _tableView.dataSource =self;
        _tableView.scrollEnabled =YES;
        //        _tableView.backgroundColor =[UIColor redColor];
        [_bg addSubview:_tableView];
        
        
        
    }
    else
    {
        
        [UIView animateWithDuration:0.3 animations:^{
            
            _bg.transform = CGAffineTransformMakeScale(0.1,_mapView.frame.size.height/_mapView.frame.size.height/10);
            
        } completion:^(BOOL finished) {
            [_bg removeFromSuperview];
            _bg = nil;
            _tableView =nil;
            _tableView.delegate = nil;
            _tableView.dataSource =nil;
        }];
        
    }
    
    
    
}

#pragma mark -MAMapViewDelegate


- (MAOverlayRenderer *)mapView:(MAMapView *)mapView rendererForOverlay:(id <MAOverlay>)overlay
{
    if ([overlay isKindOfClass:[MACircle class]])
    {
        
        MACircleRenderer *render = [[MACircleRenderer alloc] initWithCircle:overlay];
        
        render.lineWidth = 2.f;
        render.strokeColor = [UIColor colorWithRed:0.6 green:0.6 blue:0.6 alpha:0.8];
        render.fillColor = [UIColor colorWithRed:0.55 green:0.73 blue:0.95 alpha:0.80];
        render.lineDash = YES;//YES表示虚线绘制，NO表示实线绘制
        
        return render;
    }
    //热力图回调
    if ([overlay isKindOfClass:[MATileOverlay class]])
    {
        MATileOverlayRenderer *render = [[MATileOverlayRenderer alloc] initWithTileOverlay:overlay];
        
        return render;
    }
    
    
    return nil;
    
}


//监听定位模式状态的回调方法
- (void)mapView:(MAMapView *)mapView didChangeUserTrackingMode:(MAUserTrackingMode)mode animated:(BOOL)animated
{
        switch (mode)
        {
            case MAUserTrackingModeNone:
            {

                [_locationButton setImage:[UIImage imageNamed:@"location_no"] forState:UIControlStateNormal];
            }
                break;
            case MAUserTrackingModeFollow:
            {

                [_locationButton setImage:[UIImage imageNamed:@"location_yes"]
                                 forState:UIControlStateNormal];
            }
                break;
            case MAUserTrackingModeFollowWithHeading:
            {

                [_locationButton setImage:[UIImage imageNamed:@"location"]
                                 forState:UIControlStateNormal];
            }
                break;
            default:
                break;
        }
//    if (mode == MAUserTrackingModeNone)
//    {
//        [_locationButton setImage:[UIImage imageNamed:@"location_no"] forState:UIControlStateNormal];
//    }
//    else
//    {
//        [_locationButton setImage:[UIImage imageNamed:@"location_yes"]
//                         forState:UIControlStateNormal];
//    }
//    
//    NSLog(@"mode:%ld",mode);
}

//选中Annotation后调用
- (void)mapView:(MAMapView *)mapView didSelectAnnotationView:(MAAnnotationView *)view
{
    // 选中定位annotation的时候进行逆地理编码查询
    if ([view.annotation isKindOfClass:[MAUserLocation class]])
    {
        [self reGeoAction];
    }
}

//更新定位地址回调
- (void)mapView:(MAMapView *)mapView didUpdateUserLocation:(MAUserLocation *)userLocation updatingLocation:(BOOL)updatingLocation
{
    //    NSLog(@"userLocation: %@", userLocation.location);
    _currentLocation = [userLocation.location copy];
}

#pragma mark -AMapSearchDelegate
//失败回调
- (void)searchRequest:(id)request didFailWithError:(NSError *)error
{
    NSLog(@"request :%@, error :%@", request, error);
}


//成功回调
- (void)onReGeocodeSearchDone:(AMapReGeocodeSearchRequest *)request response:(AMapReGeocodeSearchResponse *)response
{
    NSLog(@"response :%@", response);
    
    
    NSString *title = response.regeocode.addressComponent.city;
    if (title.length == 0)
    {
        title = response.regeocode.addressComponent.province;
    }
    
    _mapView.userLocation.title = title;
    _mapView.userLocation.subtitle = response.regeocode.formattedAddress;
    
}

#pragma mark -UITableViewDataSource / UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell =[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CellID"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.text = self.dataArray[indexPath.row];
    cell.textLabel.font =[UIFont systemFontOfSize:12];
    
    return  cell;
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40;
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row)
    {
        case Nearby_ROW:

            [self pushViewControllers:@"NearbySearchViewController"];
            
            break;
        case Route_ROW:
            
            [self pushViewControllers:@"RouteSearchViewController"];
            
            break;
        case Weather_ROW:
            
            [self pushViewControllers:@"WeatherSearchViewController"];
            
            break;
        case Nav_ROW:
            
            [self pushViewControllers:@"NavViewController"];
            
            break;
        default:
            break;
    }
}

-(void)pushViewControllers:(NSString *)vc
{
    
    
    Class class = NSClassFromString(vc);
    
    id  obj = [[class  alloc] init];
    
    [self.navigationController pushViewController:obj animated:YES];
    
    [UIView animateWithDuration:0.3 animations:^{
        
        _bg.transform = CGAffineTransformMakeScale(0.1,_mapView.frame.size.height/_mapView.frame.size.height/10);
        
    } completion:^(BOOL finished) {
        [_bg removeFromSuperview];
        _bg = nil;
        _tableView =nil;
        _tableView.delegate = nil;
        _tableView.dataSource =nil;
    }];
    [_mapView removeFromSuperview];
  
    
}


-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [UIView animateWithDuration:0.3 animations:^{
        
        _bg.transform = CGAffineTransformMakeScale(0.1,_mapView.frame.size.height/_mapView.frame.size.height/10);
        
    } completion:^(BOOL finished) {
        [_bg removeFromSuperview];
        _bg = nil;
        _tableView =nil;
        _tableView.delegate = nil;
        _tableView.dataSource =nil;
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initNav];
    
    [self initMapView];
    
    [self initSearch];
    
    [self initControls];
    
    [self addObserveOfPushType];
    // Do any additional setup after loading the view, typically from a nib.
}


-(void)viewWillAppear:(BOOL)animated
{
    
    
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden =YES;
    [self initMapView];
    
    [self initSearch];
    [self initControls];
    //    self.navigationBarHidden = YES;
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    
    _search.delegate =nil;
    _search =nil;
    
    [self clear];
    
    

}

-(void)clear
{
    [_locationButton removeFromSuperview];
    [_mapTypeButton removeFromSuperview];
    [_showTrafficButton removeFromSuperview];
    [_heatMapButton removeFromSuperview];
    [_overlayButton removeFromSuperview];
    [_mapView removeFromSuperview];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (void)addNotificationCount {
    _notificationCount++;
    [self reloadNotificationCountLabel];
}

- (void)reloadNotificationCountLabel {
//    
//    _notificationCountLabel.text =
//    [NSString stringWithFormat:@"%d", _notificationCount];
}

- (void)dealloc {
    [self unObserveAllNotifications];
}



#pragma mark - push
-(void)addObserveOfPushType
{
    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    [defaultCenter addObserver:self
                      selector:@selector(networkDidSetup:)
                          name:kJPFNetworkDidSetupNotification
                        object:nil];
    [defaultCenter addObserver:self
                      selector:@selector(networkDidClose:)
                          name:kJPFNetworkDidCloseNotification
                        object:nil];
    [defaultCenter addObserver:self
                      selector:@selector(networkDidRegister:)
                          name:kJPFNetworkDidRegisterNotification
                        object:nil];
    [defaultCenter addObserver:self
                      selector:@selector(networkDidLogin:)
                          name:kJPFNetworkDidLoginNotification
                        object:nil];
    [defaultCenter addObserver:self
                      selector:@selector(networkDidReceiveMessage:)
                          name:kJPFNetworkDidReceiveMessageNotification
                        object:nil];
    [defaultCenter addObserver:self
                      selector:@selector(serviceError:)
                          name:kJPFServiceErrorNotification
                        object:nil];
    
    
    
}




- (void)unObserveAllNotifications {
    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    [defaultCenter removeObserver:self
                             name:kJPFNetworkDidSetupNotification
                           object:nil];
    [defaultCenter removeObserver:self
                             name:kJPFNetworkDidCloseNotification
                           object:nil];
    [defaultCenter removeObserver:self
                             name:kJPFNetworkDidRegisterNotification
                           object:nil];
    [defaultCenter removeObserver:self
                             name:kJPFNetworkDidLoginNotification
                           object:nil];
    [defaultCenter removeObserver:self
                             name:kJPFNetworkDidReceiveMessageNotification
                           object:nil];
    [defaultCenter removeObserver:self
                             name:kJPFServiceErrorNotification
                           object:nil];
}


- (void)networkDidSetup:(NSNotification *)notification {
//    _netWorkStateLabel.text = @"已连接";
    NSLog(@"已连接");

}

- (void)networkDidClose:(NSNotification *)notification {
//    _netWorkStateLabel.text = @"未连接。。。";
    NSLog(@"未连接");
    
}

- (void)networkDidRegister:(NSNotification *)notification {
    
    NSLog(@"%@", [notification userInfo]);
//    _netWorkStateLabel.text = @"已注册";

    [[notification userInfo] valueForKey:@"RegistrationID"];

    NSLog(@"已注册");
}

- (void)networkDidLogin:(NSNotification *)notification {

    NSLog(@"已登录");
    
    if ([JPUSHService registrationID]) {
        
        NSLog(@"get RegistrationID :%@",[JPUSHService registrationID]);
    }
}

- (void)networkDidReceiveMessage:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
//    NSString *title = [userInfo valueForKey:@"title"];
    NSString *content = [userInfo valueForKey:@"content"];
    NSDictionary *extra = [userInfo valueForKey:@"extras"];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
    
//    NSString *currentContent = [NSString stringWithFormat:@"收到自定义消息:%@\ntitle:%@\ncontent:%@\nextra:%@\n",[NSDateFormatter localizedStringFromDate:[NSDate date]dateStyle:NSDateFormatterNoStyle timeStyle:NSDateFormatterMediumStyle],
//                                title, content, [self logDic:extra]];
    NSString *currentContent = [NSString stringWithFormat:@"收到自定义消息:%@\ncontent:%@\n",[NSDateFormatter localizedStringFromDate:[NSDate date]dateStyle:NSDateFormatterNoStyle timeStyle:NSDateFormatterMediumStyle],
                                 content];
    NSLog(@"%@", currentContent);
    
    [_messageContents insertObject:currentContent atIndex:0];

    NSString *allContent = [NSString
                            stringWithFormat:@"%@收到消息:\n%@\nextra:%@",
                            [NSDateFormatter
                             localizedStringFromDate:[NSDate date]
                             dateStyle:NSDateFormatterNoStyle
                             timeStyle:NSDateFormatterMediumStyle],
                            [_messageContents componentsJoinedByString:nil],
                            [self logDic:extra]];
    NSLog(@"%@", allContent);
    
    UIAlertController *alert =[UIAlertController alertControllerWithTitle:@"极光推送" message: currentContent preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *action1 =[UIAlertAction actionWithTitle:@"返回" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action){
        //            NSLog(@"返回");
    }];
    
    [alert addAction:action1];
    [self presentViewController:alert animated:YES completion:nil];
    
//
//    _messageContentView.text = allContent;
//    _messageCount++;
//    [self reloadMessageCountLabel];
}

-(void)presentAlert:(NSString *)message
{
    UIAlertController *alert =[UIAlertController alertControllerWithTitle:@"极光推送" message: message preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *action1 =[UIAlertAction actionWithTitle:@"返回" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action){
        //            NSLog(@"返回");
    }];
    
    [alert addAction:action1];
    [self presentViewController:alert animated:YES completion:nil];
}
// log NSSet with UTF8
// if not ,log will be \Uxxx
- (NSString *)logDic:(NSDictionary *)dic {
    if (![dic count]) {
        return nil;
    }
    NSString *tempStr1 =
    [[dic description] stringByReplacingOccurrencesOfString:@"\\u"
                                                 withString:@"\\U"];
    NSString *tempStr2 =
    [tempStr1 stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
    NSString *tempStr3 =
    [[@"\"" stringByAppendingString:tempStr2] stringByAppendingString:@"\""];
    NSData *tempData = [tempStr3 dataUsingEncoding:NSUTF8StringEncoding];
    NSString *str =
    [NSPropertyListSerialization propertyListFromData:tempData
                                     mutabilityOption:NSPropertyListImmutable
                                               format:NULL
                                     errorDescription:NULL];
    return str;
}

- (void)serviceError:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    NSString *error = [userInfo valueForKey:@"error"];
    NSLog(@"%@", error);
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
