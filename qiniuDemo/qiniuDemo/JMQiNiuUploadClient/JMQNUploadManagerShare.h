//
//  JMQNUploadManagerShare.h
//  qiniuDemo
//
//  Created by caijiamu on 16/6/23.
//  Copyright © 2016年 cloud.wood-group. All rights reserved.
//  七牛请求单例

#import <Foundation/Foundation.h>
#import <QNUploadManager.h>
@interface JMQNUploadManagerShare : QNUploadManager
+(instancetype)shareInstance;
@end
