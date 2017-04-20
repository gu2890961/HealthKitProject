//
//  ViewController.m
//  步数读写
//
//  Created by gupeng on 2017/4/7.
//  Copyright © 2017年 apple. All rights reserved.
//

#import "ViewController.h"
#import <HealthKit/HealthKit.h>
#import "GPHealthKitManager.h"
#define Color_RGB(r,g,b,a) ([UIColor colorWithRed:(r)/255. green:(g)/255. blue:(b)/255. alpha:(a)])
#define SCREEN  [UIScreen mainScreen].bounds.size
@interface ViewController ()<UITextFieldDelegate>{
    GPHealthKitManager *_manager;
    UITextField *numberTextField;
    UILabel * numberLabel;
    UIView * _bgVC;
}

@property (nonatomic, strong) HKHealthStore *healthStore;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
/*
 注意！！！
 Privacy - Health Share Usage Description 隐私——健康分享使用描述
 Privacy - Health Update Usage Description 隐私——健康更新使用描述
 ios10 以后再Plist里添加 这里已经加上
 
 开发账号也要勾选支持健康功能
 此应用使用的个人账号需要 安装上到手机上以后 去设置设备管理 信任一下就可以了
 
 透漏一下添加的步数可以同步到QQ运动哦，但是要注意不要一次性添加太多，QQ好像有限制 10万步左右就同步不上了 最好不要超过9万
 */
    
    
    
    
     _manager = [GPHealthKitManager shareInstance];
    if ([HKHealthStore isHealthDataAvailable]) {
        NSSet *writeDataTypes = [self dataTypesToWrite];//获取写权限
        NSSet *readDataTypes = [self dataTypesToRead];//获取写权限
        
        self.healthStore = [[HKHealthStore alloc] init];
        [self.healthStore requestAuthorizationToShareTypes:writeDataTypes readTypes:readDataTypes completion:^(BOOL success, NSError *error) {
            if (!success) {
                NSLog(@"fail");
            }
        }];
    }
    [self uiConfigure];
    
}
- (void)uiConfigure {
    _bgVC = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    _bgVC.backgroundColor = Color_RGB(0, 186, 111, 1);
    [self.view addSubview:_bgVC];
    [self setBgView];
    
     numberTextField = [[UITextField alloc] initWithFrame:CGRectMake(SCREEN.width/2-100 , 100, 200, 30)];
    [numberTextField setFont:[UIFont systemFontOfSize:15]];
    [numberTextField setBorderStyle:UITextBorderStyleRoundedRect];
    numberTextField.keyboardType=UIKeyboardTypeNumbersAndPunctuation;
    numberTextField.delegate = self;
    numberTextField.placeholder=@"请输入步数，负数是减少步数";
    [self.view addSubview:numberTextField];
    
    UIButton *addBtn = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN.width/2-50, 160, 100, 30)];
    [addBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    addBtn.backgroundColor=[UIColor redColor];
    [addBtn setTitle:@"添加" forState:UIControlStateNormal];
    [addBtn addTarget:self action:@selector(changeTest) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:addBtn];
    
    
    numberLabel = [[UILabel alloc] initWithFrame:CGRectMake(100, SCREEN.height/2+50, SCREEN.width/2, 50)];
    numberLabel.textAlignment=NSTextAlignmentCenter;
    numberLabel.font=[UIFont systemFontOfSize:15];
    [self.view addSubview:numberLabel];
    
    UIButton * getbtn = [UIButton buttonWithType:UIButtonTypeCustom];
    getbtn.frame=CGRectMake(SCREEN.width/2-50, numberLabel.frame.origin.y+numberLabel.frame.size.height, 100, 30);
    getbtn.backgroundColor=[UIColor redColor];
    getbtn.titleLabel.font=[UIFont systemFontOfSize:15];
    [getbtn setTitle:@"查询步数" forState:UIControlStateNormal];
    [getbtn addTarget:self action:@selector(getNewNumberClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:getbtn];
}

- (void)getNewNumberClick {
    [_manager authorizeHealthKit:^(BOOL success, NSError *error) {
        if (success) {
            NSLog(@"success");
            [_manager getStepCount:^(double value, NSError *error) {
                NSLog(@"1count-->%.0f", value);
                NSLog(@"1error-->%@", error.localizedDescription);
                dispatch_async(dispatch_get_main_queue(), ^{
                    numberLabel.text=[NSString stringWithFormat:@"%.f步", value];
                });
            }];
        }
        else {
            
        }
    }];

}
-(void)changeTest{
    if (numberTextField.text && ![numberTextField.text isEqualToString:@""]) {
        [self recordWeight:[numberTextField.text doubleValue]];
    }else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请输入步数" delegate:nil cancelButtonTitle:@"我知道了" otherButtonTitles:nil];
        [alert show];
    }
}

#pragma mark -- UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    return YES;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [numberTextField resignFirstResponder];
}

-(void)recordWeight:(double)step{
    //  categoryTypeForIdentifier:HKCategoryTypeIdentifierSleepAnalysis
    HKQuantityType *stepType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
    if ([HKHealthStore isHealthDataAvailable] ) {
        HKQuantity *stepQuantity = [HKQuantity quantityWithUnit:[HKUnit countUnit] doubleValue:step];
        HKQuantitySample *stepSample = [HKQuantitySample quantitySampleWithType:stepType quantity:stepQuantity startDate:[NSDate date] endDate:[NSDate date]];
        __block typeof(self) weakSelf = self;
        [self.healthStore saveObject:stepSample withCompletion:^(BOOL success, NSError *error) {
            if (success) {
                __block typeof(weakSelf) strongSelf = weakSelf;
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:step>0?@"步数已加上，可以装逼了":@"步数减了，为何不装逼了？" delegate:nil cancelButtonTitle:step>0?@"了解":@"不装了" otherButtonTitles:nil];
                    [alert show];
                    
                    strongSelf -> numberTextField.text = @"";
                    [strongSelf getNewNumberClick];
                });
                
                NSLog(@"The data has print");
            }else{
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"加步数失败" delegate:nil cancelButtonTitle:@"我知道了" otherButtonTitles:nil];
                [alert show];
                NSLog(@"The error is %@",error);
            }
        }];
    }
}
- (NSSet *)dataTypesToWrite {
    HKQuantityType *stepType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
    return [NSSet setWithObject:stepType];
}

- (NSSet *)dataTypesToRead {
    HKQuantityType *stepType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
    return [NSSet setWithObjects:stepType , nil];
}
- (void)setBgView {
    UIBezierPath * bPath = [UIBezierPath bezierPathWithRect:_bgVC.frame];
    UIBezierPath * aPath = [UIBezierPath bezierPath];
    [aPath moveToPoint:CGPointMake(0, SCREEN.height/2+80)];
    [aPath addQuadCurveToPoint:CGPointMake(SCREEN.width, SCREEN.height/2+80) controlPoint:CGPointMake(SCREEN.width/2, SCREEN.height/2)];
    [aPath addLineToPoint:CGPointMake(SCREEN.width, SCREEN.height)];
    [aPath addLineToPoint:CGPointMake(0, SCREEN.height)];
    [aPath addLineToPoint:CGPointMake(0, SCREEN.height/2+80)];
    CAShapeLayer * layer = [[CAShapeLayer alloc] init];
    [bPath appendPath:[aPath bezierPathByReversingPath]];
    layer.path = bPath.CGPath;
    [_bgVC.layer setMask:layer];
    
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
