//
//  NearbySearchViewController.m
//  GDMapDemo
//
//  Created by caohanchao on 16/8/7.
//  Copyright © 2016年 caohanchao. All rights reserved.
//

#import "NearbySearchViewController.h"

#import <MAMapKit/MAMapKit.h>
#import <AMapFoundationKit/AMapFoundationKit.h>
#import <AMapSearchKit/AMapSearchKit.h>
#import <AMapSearchKit/AMapCommonObj.h>
#import "POIAnnotation.h"
#import "PoiDetailViewController.h"
@interface NearbySearchViewController ()<UITextFieldDelegate,AMapNearbySearchManagerDelegate>

{
    
    AMapNearbySearchManager * _nearbyManager;
    UIButton *_cancelButton;
    NSInteger _index;
}

@property(nonatomic,strong)UITextField *keyTextfiled;


@end

@implementation NearbySearchViewController



#pragma mark -init

-(void)initNav
{
    
    UIView *view =[[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 84)];
    view.backgroundColor =
    [UIColor colorWithRed:0.16 green:0.56 blue:0.99 alpha:1.00];
    
    
    UILabel *title =[[UILabel alloc]initWithFrame:CGRectMake(self.view.frame.size.width/2-40, 20, 80, 30)];
    //    title.center =view.center;
    title.text =@"附近搜索";
    [view addSubview:title];
    
    self.keyTextfiled =[[UITextField alloc]initWithFrame:CGRectMake(50, 50, self.view.frame.size.width-100, 30)];
    self.keyTextfiled.delegate =self;
    self.keyTextfiled.backgroundColor =[UIColor colorWithRed:0.55 green:0.73 blue:0.95 alpha:1.00];
    self.keyTextfiled.placeholder = @"请输入搜索关键词";
    self.keyTextfiled.layer.cornerRadius = 5;
    self.keyTextfiled.layer.masksToBounds = YES;
    self.keyTextfiled.textAlignment = NSTextAlignmentCenter;
    self.keyTextfiled.returnKeyType = UIReturnKeySearch;
    [view addSubview:self.keyTextfiled];
    
    UIButton *searchBtn =[UIButton buttonWithType:UIButtonTypeCustom];
    searchBtn.frame =CGRectMake(self.view.frame.size.width-40, 50, 30, 30);
    [searchBtn setImage:[UIImage imageNamed:@"search"] forState:UIControlStateNormal];
    [searchBtn addTarget:self action:@selector(searchAction) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:searchBtn];
    
    
    _cancelButton = [UIButton buttonWithType:UIButtonTypeSystem];
    
    _cancelButton.frame = CGRectMake(10,50, 30, 30);
//    _cancelButton.autoresizingMask = UIViewAutoresizingFlexibleRightMargin |
//    UIViewAutoresizingFlexibleTopMargin;
//        _cancelButton.backgroundColor = [UIColor whiteColor];
//    _cancelButton.layer.cornerRadius = 5;
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


#pragma mark - Action

-(void)searchAction
{
    
    [_mapView removeAnnotations:_mapView.annotations];
    [self.view endEditing:YES];
    if (_currentLocation == nil || _search == nil)
    {
        NSLog(@"search failed");
        
        return;
    }
    else
    {
        AMapPOIAroundSearchRequest *request = [[AMapPOIAroundSearchRequest alloc] init];
        
        request.location            = [AMapGeoPoint locationWithLatitude:_currentLocation.coordinate.latitude longitude:_currentLocation.coordinate.longitude];
        request.keywords            = self.keyTextfiled.text;
        /* 按照距离排序. */
        request.sortrule            = 0;
        request.requireExtension    = YES;
        request.page =_index++;
        request.offset = 10;
        
        
        [_search AMapPOIAroundSearch:request];
//         _index ++;
    
    }
    
    
//    AMapPlaceSearchRequest *request = [[AMapPlaceSearchRequest alloc] init];
//    request.searchType = AMapSearchType_PlaceAround;
//    request.location = [AMapGeoPoint locationWithLatitude:_currentLocation.coordinate.latitude
//                                                longitude:_currentLocation.coordinate.longitude];
//    request.keywords = @"餐饮";
//    [_search AMapPlaceSearch:request];
    
    
}



-(void)cancelClick
{

    [self.navigationController popViewControllerAnimated:YES];
}



#pragma mark - MAMapViewDelegate

- (void)mapView:(MAMapView *)mapView annotationView:(MAAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    id<MAAnnotation> annotation = view.annotation;
    
    if ([annotation isKindOfClass:[POIAnnotation class]])
    {
        POIAnnotation *poiAnnotation = (POIAnnotation*)annotation;
        
        PoiDetailViewController *detail = [[PoiDetailViewController alloc] init];
        detail.poi = poiAnnotation.poi;
        
        /* 进入POI详情页面. */
        [self.navigationController pushViewController:detail animated:YES];
    }
}

- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id<MAAnnotation>)annotation
{
    if ([annotation isKindOfClass:[POIAnnotation class]])
    {
        static NSString *poiIdentifier = @"poiIdentifier";
        MAPinAnnotationView *poiAnnotationView = (MAPinAnnotationView*)[_mapView dequeueReusableAnnotationViewWithIdentifier:poiIdentifier];
        if (poiAnnotationView == nil)
        {
            poiAnnotationView = [[MAPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:poiIdentifier];
        }
        
        poiAnnotationView.canShowCallout = YES;
        poiAnnotationView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        
        return poiAnnotationView;
    }
    
    return nil;
}

// POI 搜索回调. 
- (void)onPOISearchDone:(AMapPOISearchBaseRequest *)request response:(AMapPOISearchResponse *)response
{
    
    NSLog(@"response.pois.count:%ld",response.pois.count);
    
    if (response.pois.count == 0)
    {
        return;
    }
    
    NSMutableArray *poiAnnotations = [NSMutableArray arrayWithCapacity:response.pois.count];
    
    [response.pois enumerateObjectsUsingBlock:^(AMapPOI *obj, NSUInteger idx, BOOL *stop) {
        
        [poiAnnotations addObject:[[POIAnnotation alloc] initWithPOI:obj]];
        
    }];
    
    /* 将结果以annotation的形式加载到地图上. */
    [_mapView addAnnotations:poiAnnotations];
    
    /* 如果只有一个结果，设置其为中心点. */
    if (poiAnnotations.count == 1)
    {
        [_mapView setCenterCoordinate:[poiAnnotations[0] coordinate]];
    }
    /* 如果有多个结果, 设置地图使所有的annotation都可见. */
    else
    {
        [_mapView showAnnotations:poiAnnotations animated:NO];
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    _mapView.frame =CGRectMake(0, 84, self.view.frame.size.width, self.view.frame.size.height-84);
    self.navigationController.navigationBar.hidden =YES;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [_nearbyManager stopAutoUploadNearbyInfo];
    _nearbyManager.delegate = nil;
    
    
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    
    [self initNav];
    
    _index = 0;
//    [self initNearbySearch];
    // Do any additional setup after loading the view.
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
