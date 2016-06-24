//
//  JMQNUploadManagerShare.m
//  qiniuDemo
//
//  Created by caijiamu on 16/6/23.
//  Copyright © 2016年 cloud.wood-group. All rights reserved.
//

#import "JMQNUploadManagerShare.h"

@implementation JMQNUploadManagerShare
+(instancetype)shareInstance
{
   return [[JMQNUploadManagerShare alloc]init];
}
+(instancetype)allocWithZone:(struct _NSZone *)zone
{
    static JMQNUploadManagerShare *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [super allocWithZone:zone];
    });
    return instance;
}
@end
