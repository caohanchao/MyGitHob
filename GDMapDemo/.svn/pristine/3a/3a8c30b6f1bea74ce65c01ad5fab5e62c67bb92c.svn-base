//
//  WeatherSearchViewController.m
//  GDMapDemo
//
//  Created by caohanchao on 16/8/7.
//  Copyright © 2016年 caohanchao. All rights reserved.
//

#import "WeatherSearchViewController.h"
#import <AMapSearchKit/AMapSearchKit.h>

@interface WeatherSearchViewController ()<AMapSearchDelegate,UITextFieldDelegate>
{
    AMapSearchAPI *_search;
    UIButton *_cancelButton;

}

@property(nonatomic,strong)UITextField *keyTextfiled;
@property(nonatomic,strong)NSMutableArray *label3Array;

@end

@implementation WeatherSearchViewController

//-(NSMutableArray *)label3Array
//{
//    if (!_label3Array)
//    {
//        _label3Array = [[NSMutableArray alloc]init];
//        
//    }
//    return _label3Array;
//}

-(NSMutableArray *)label3Array
{
    if (!_label3Array)
    {
        _label3Array = [[NSMutableArray alloc]init];

    }
    return _label3Array;
    
}


#pragma mark -init
-(void)initNav
{
    
    UIView *view =[[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 84)];
    view.backgroundColor =
    [UIColor colorWithRed:0.16 green:0.56 blue:0.99 alpha:1.00];
    
    
    UILabel *title =[[UILabel alloc]initWithFrame:CGRectMake(self.view.frame.size.width/2-40, 20, 80, 30)];
    //    title.center =view.center;
    title.text =@"天气搜索";
    [view addSubview:title];
    
    self.keyTextfiled =[[UITextField alloc]initWithFrame:CGRectMake(50, 50, self.view.frame.size.width-100, 30)];
    self.keyTextfiled.delegate =self;
    self.keyTextfiled.backgroundColor =[UIColor colorWithRed:0.55 green:0.73 blue:0.95 alpha:1.00];
    self.keyTextfiled.placeholder = @"请输入搜索城市";
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

    [_cancelButton setTitle:@"⬅️" forState:UIControlStateNormal];
    _cancelButton.titleLabel.font = [UIFont systemFontOfSize:30];
    [_cancelButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    //    _cancelButton.titleLabel.font = [UIFont systemFontOfSize:15];
    [_cancelButton addTarget:self action:@selector(cancelClick)
            forControlEvents:UIControlEventTouchUpInside];
    
    [view addSubview:_cancelButton];
    [self.view addSubview:view];
    
}

-(void)initSearch
{
    //初始化检索对象
    _search = [[AMapSearchAPI alloc] init];
    _search.delegate = self;

}


#pragma mark - Action
-(void)cancelClick
{
    [self.navigationController popViewControllerAnimated:YES];
}

UILabel *label;
UILabel *label1;
UILabel *label2;
UILabel *label3;


-(void)searchAction
{
    [label removeFromSuperview];
    [label1 removeFromSuperview];
    [label2 removeFromSuperview];
    
    
    for (UILabel *lab in _label3Array)
    {
        [lab removeFromSuperview];
    }
    
    
    //构造AMapWeatherSearchRequest对象，配置查询参数
    AMapWeatherSearchRequest *request1 = [[AMapWeatherSearchRequest alloc] init];
    request1.city = self.keyTextfiled.text;
    request1.type = AMapWeatherTypeLive; //AMapWeatherTypeLive为实时天气；AMapWeatherTypeForecase为预报天气
    
    //发起行政区划查询
    [_search AMapWeatherSearch:request1];
    
    
    AMapWeatherSearchRequest *request2 = [[AMapWeatherSearchRequest alloc] init];
    request2.city = self.keyTextfiled.text;
    request2.type = AMapWeatherTypeForecast; //AMapWeatherTypeLive为实时天气；AMapWeatherTypeForecase为预报天气
    
    //发起行政区划查询
    [_search AMapWeatherSearch:request2];
    
    [self.view endEditing:YES];
    
}


#pragma mark-添加天气视图

-(void)addViewOfWeather:(AMapLocalWeatherLive *)live
{
    label =[[UILabel alloc]initWithFrame:CGRectMake(self.view.frame.size.width/2-50, 100, 100, 50)];
    //
    label.text =[NSString stringWithFormat:@"%@%@",live.province,live.city];
    label.font =[UIFont systemFontOfSize:20];
    label.textColor = [UIColor orangeColor];
    label.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:label];
    
    label1 =[[UILabel alloc]initWithFrame:CGRectMake(self.view.frame.size.width/2-40, 150, 80, 80)];
    //
    label1.text =[NSString stringWithFormat:@"%@°",live.temperature];
    label1.font =[UIFont systemFontOfSize:30];
    label1.textColor = [UIColor orangeColor];
    label1.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:label1];
    
    
    label2 =[[UILabel alloc]initWithFrame:CGRectMake(self.view.frame.size.width/2-150, 250, 300, 40)];
    label2.text =[NSString stringWithFormat:@"天气:%@ 风向:%@风 风度:%@级 湿度:%@%%",live.weather,live.windDirection,live.windPower,live.humidity];
    label2.font =[UIFont systemFontOfSize:15];
    label2.textColor = [UIColor orangeColor];
    label2.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:label2];
    
//    NSLog(@"天气:%@ 温度:%@ 风向:%@ 风度:%@ 湿度:%@",live.weather,live.temperature,live.windDirection,live.windPower,live.humidity);


}



-(void)addWeather:(AMapLocalWeatherForecast *)forecast
{
    _label3Array = [[NSMutableArray alloc]init];
    for (int i = 0; i<forecast.casts.count-1; i++)
    {
        label3 = [[UILabel alloc]initWithFrame:CGRectMake(10,300+(i*60) , self.view.frame.size.width-20, 60)];
        label3.textAlignment = NSTextAlignmentCenter;
        label3.font = [UIFont systemFontOfSize:22];
        label3.text =[NSString stringWithFormat:@"%@ 周%@            %@/%@",forecast.casts[i+1].date,forecast.casts[i+1].week,forecast.casts[i+1].dayTemp,forecast.casts[i+1].nightTemp];
        label3.textColor = [UIColor orangeColor];
        
        [_label3Array addObject:label3];
        NSLog(@"array:%ld",_label3Array.count);
        
        [self.view addSubview:label3];
        
    }
}



#pragma mark -AMapSearchDelegate
- (void)onWeatherSearchDone:(AMapWeatherSearchRequest *)request response:(AMapWeatherSearchResponse *)response
{
    //如果是实时天气
    if(request.type == AMapWeatherTypeLive)
    {
        if(response.lives.count == 0)
        {
            return;
        }
        for (AMapLocalWeatherLive *live in response.lives) {
            @autoreleasepool {
                
                [self addViewOfWeather:live];
            }
            
            
            
            
            NSLog(@"天气:%@ 温度:%@ 风向:%@ 风度:%@ 湿度:%@",live.weather,live.temperature,live.windDirection,live.windPower,live.humidity);
            
        }
    }
    //如果是预报天气
    else
    {
        if(response.forecasts.count == 0)
        {
            return;
        }
        for (AMapLocalWeatherForecast *forecast in response.forecasts) {
            
//            NSArray *weatherArray = forecast.casts;
            
            [self addWeather:forecast];
            
//            @property (nonatomic, copy) NSString *date; //!< 日期
//            @property (nonatomic, copy) NSString *week; //!< 星期
//            @property (nonatomic, copy) NSString *dayWeather; //!< 白天天气现象
//            @property (nonatomic, copy) NSString *nightWeather;//!< 晚上天气现象
//            @property (nonatomic, copy) NSString *dayTemp; //!< 白天温度
//            @property (nonatomic, copy) NSString *nightTemp; //!< 晚上温度
//            @property (nonatomic, copy) NSString *dayWind; //!< 白天风向
//            @property (nonatomic, copy) NSString *nightWind; //!< 晚上风向
//            @property (nonatomic, copy) NSString *dayPower; //!< 白天风力
//            @property (nonatomic, copy) NSString *nightPower; //!< 晚上风力
            
        }
    }
    
}


//
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

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor =[UIColor colorWithRed:0.55 green:0.73 blue:0.95 alpha:1.00];
    [self initNav];
    
    [self initSearch];
    
    // Do any additional setup after loading the view.
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
