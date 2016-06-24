//
//  JMQNUploadManagerClient.h
//  qiniuDemo
//
//  Created by caijiamu on 16/6/23.
//  Copyright © 2016年 cloud.wood-group. All rights reserved.
//  七牛请求封装

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <QiniuSDK.h>
typedef NS_ENUM(NSInteger,qiniuUploadDataType)
{
   qiniuUploadDataImage = 0, //图片
   qiniuUploadDataVideo //视频
};
//所有图片的进度
typedef void(^ProgressHander)(CGFloat maxProgress,CGFloat currentProgress,CGFloat precent);

//单张图片的进度（i记录当前图片）
typedef void(^singleProgressHander)(CGFloat percent,NSInteger i);

@interface JMQNUploadManagerClient : NSObject
/**
 * 单张图片或单个视频上传
 *
 *  @param data        字符流（0，1）
 *  @param dataType    数据类型
 *  @param token       token
 *  @param qiniuPrefix 七牛前缀
 *  @param progress    进度值
 *  @param success     成功回调
 *  @param failure     失败回调
 */
+ (void)uploadData:(NSData *)data dataType:(qiniuUploadDataType)dataType WithToken:(NSString *)token qiniuPrefix:(NSString *)qiniuPrefix progress:(QNUpProgressHandler)progress success:(void (^)(NSString *url))success failure:(void (^)(NSString *status))failure;

/**
 *  同步顺序上传多张图片
 *
 *  @param imageArr    图片数组源
 *  @param token       token
 *  @param qiniuPrefix 七牛前缀
 *  @param progress    进度值
 *  @param success     成功回调
 *  @param failure     失败回调
 */
+ (void)uploadImageArray:(NSArray *)imageArr WithToken:(NSString *)token qiniuPrefix:(NSString *)qiniuPrefix progress:(ProgressHander)progress success:(void (^)(NSArray *imageUrlArr))success failure:(void (^)(NSString *status))failure;

/**
 *  GCD异步上传多张图片
 *
 *  @param imageArr    图片数组源
 *  @param token       token
 *  @param qiniuPrefix 七牛前缀
 *  @param progress    进度值(单张)
 *  @param allImageProgress  所有图片进度值
 *  @param success     成功回调
 *  @param failure     失败回调
 */
+ (void)GCDUploadImageArray:(NSArray *)imageArr WithToken:(NSString *)token qiniuPrefix:(NSString *)qiniuPrefix progress:(singleProgressHander)progress allImageProgress:(ProgressHander)allprogress success:(void (^)(NSArray *imageUrlArr))success failure:(void (^)(NSString *status))failure;

@end
