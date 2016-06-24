//
//  JMQNUploadManagerHelper.h
//  qiniuDemo
//
//  Created by caijiamu on 16/6/23.
//  Copyright © 2016年 cloud.wood-group. All rights reserved.
//  七牛请求帮助单例（成功，失败回调）

#import <Foundation/Foundation.h>

@interface JMQNUploadManagerHelper : NSObject

@property (nonatomic, copy) void (^singleSuccessBlock)(NSString *);
@property (nonatomic, copy) void (^singleFailBlcok)(NSString *);

+(instancetype)shareInstance;
@end
