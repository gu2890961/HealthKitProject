//
//  HealthKitManager.h
//  运动轨迹
//
//  Created by gupeng on 2017/4/7.
//  Copyright © 2017年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <HealthKit/HealthKit.h>//获取系统步数
@interface GPHealthKitManager : NSObject
@property (nonatomic, strong) HKHealthStore *healthStore;
+(id)shareInstance;
/*
 *  @brief  检查是否支持获取健康数据
 */
- (void)authorizeHealthKit:(void(^)(BOOL success, NSError *error))compltion;
/*!
 *  @brief  写权限
 *  @return 集合
 */
- (NSSet *)dataTypesToWrite;
/*!
 *  @brief  读权限
 *  @return 集合
 */
- (NSSet *)dataTypesRead;

//获取步数
- (void)getStepCount:(void(^)(double value, NSError *error))completion;
//获取公里数
- (void)getDistance:(void(^)(double value, NSError *error))completion;
/*!
 *  @brief  当天时间段
 *
 *  @return 时间段
 */
+ (NSPredicate *)predicateForSamplesToday;

@end
