//
//  JMQNUploadManagerHelper.m
//  qiniuDemo
//
//  Created by caijiamu on 16/6/23.
//  Copyright © 2016年 cloud.wood-group. All rights reserved.
//

#import "JMQNUploadManagerHelper.h"

@implementation JMQNUploadManagerHelper
+(instancetype)shareInstance
{
    return [[JMQNUploadManagerHelper alloc]init];
}
+(instancetype)allocWithZone:(struct _NSZone *)zone
{
    static JMQNUploadManagerHelper *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [super allocWithZone:zone];
    });
    return instance;
}
@end
