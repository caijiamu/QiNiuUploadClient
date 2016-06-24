//
//  JMQNUploadManagerClient.m
//  qiniuDemo
//
//  Created by caijiamu on 16/6/23.
//  Copyright © 2016年 cloud.wood-group. All rights reserved.
//

#import "JMQNUploadManagerClient.h"
#import "JMQNUploadManagerShare.h"
#import "JMQNUploadManagerHelper.h"
#define User @"data/wood/IOS"
@implementation JMQNUploadManagerClient
+ (void)uploadData:(NSData *)data dataType:(qiniuUploadDataType)dataType WithToken:(NSString *)token qiniuPrefix:(NSString *)qiniuPrefix progress:(QNUpProgressHandler)progress success:(void (^)(NSString *url))success failure:(void (^)(NSString *status))failure
{
    QNUploadOption *option = [[QNUploadOption alloc]initWithMime:nil progressHandler:progress params:nil checkCrc:NO cancellationSignal:nil];
    NSString *uuid = [[self getUUIDStringOne]stringByReplacingOccurrencesOfString:@"-" withString:@""];
    NSString *dataKey = [NSString stringWithFormat:@"%@/%@.png",User,uuid];
    //视频
    if (dataType == qiniuUploadDataVideo) {
        dataKey = [NSString stringWithFormat:@"%@/%@.mp4",User,uuid];
    }
    JMQNUploadManagerShare *uploadManager = [[JMQNUploadManagerShare alloc]init];
    [uploadManager putData:data key:dataKey token:token complete:^(QNResponseInfo *info, NSString *key, NSDictionary *resp) {
        if (info.statusCode == 200 && resp) {
            NSLog(@"上传成功");
            if (success) {
                NSString *imageUrl = [NSString stringWithFormat:@"%@%@",qiniuPrefix,dataKey];
                success(imageUrl);
            }
        }else{
           
        }
    } option:option];
}


+ (void)uploadImageArray:(NSArray *)imageArr WithToken:(NSString *)token qiniuPrefix:(NSString *)qiniuPrefix progress:(ProgressHander)progress success:(void (^)(NSArray *imageUrlArr))success failure:(void (^)(NSString *status))failure
{
    NSInteger totalLenth = [self summationFromImageArray:imageArr];
    
    NSMutableArray *imageUrl = @[].mutableCopy;
    JMQNUploadManagerHelper *managerHelper = [JMQNUploadManagerHelper new];
    __block NSInteger currentLength = 0;
    __block NSInteger loadingCount = 0;
    __weak typeof(managerHelper) weakmanagerHelper = managerHelper;
    //成功
    [managerHelper setSingleSuccessBlock:^(NSString *url) {
        if (success) {
            loadingCount++;
            [imageUrl addObject:url];
            if (imageUrl.count == imageArr.count) {
                success(imageUrl);
                return ;
            }
            //上传下一张图片
            [self uploadData:UIImageJPEGRepresentation(imageArr[loadingCount], 1) dataType:qiniuUploadDataImage WithToken:token qiniuPrefix:qiniuPrefix progress:^(NSString *key, float percent) {
                if (progress) {
                    NSData *data = UIImageJPEGRepresentation(imageArr[loadingCount], 1);
                    NSInteger presentLenth = currentLength + percent * [@(data.length) integerValue];
                    if (percent == 1) {
                        currentLength = presentLenth;
                    }
                    progress(totalLenth,presentLenth,presentLenth/(float)totalLenth);
                }
            } success:weakmanagerHelper.singleSuccessBlock failure:weakmanagerHelper.singleFailBlcok];
        }
    }];
    //失败
    [managerHelper setSingleFailBlcok:^(NSString *state) {
        if (failure) {
            failure(state);
        }
    }];
    
    [self uploadData:UIImageJPEGRepresentation(imageArr[loadingCount], 1) dataType:qiniuUploadDataImage WithToken:token qiniuPrefix:qiniuPrefix progress:^(NSString *key, float percent) {
        if (progress) {
            NSData *data = UIImageJPEGRepresentation(imageArr[loadingCount], 1);
            NSInteger presentLenth = currentLength + percent * [@(data.length) integerValue];
            if (percent == 1) {
                currentLength = presentLenth;
            }
            progress(totalLenth,presentLenth,presentLenth/(float)totalLenth);
        }
    } success:weakmanagerHelper.singleSuccessBlock failure:weakmanagerHelper.singleFailBlcok];
}

+ (void)GCDUploadImageArray:(NSArray *)imageArr WithToken:(NSString *)token qiniuPrefix:(NSString *)qiniuPrefix progress:(singleProgressHander)progress allImageProgress:(ProgressHander)allprogress success:(void (^)(NSArray *imageUrlArr))success failure:(void (^)(NSString *status))failure
{
    NSMutableArray *imageUrl = @[].mutableCopy;
    __block NSInteger currentLength = 0;
    NSInteger totalLenth = [self summationFromImageArray:imageArr];
    // 获得全局并发queue
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    size_t count = imageArr.count;
    dispatch_apply(count, queue, ^(size_t i) {
        NSLog(@"%@---%zu",[NSThread currentThread],i);
        NSData *data = UIImageJPEGRepresentation(imageArr[i], 1);
        [self uploadData:data dataType:qiniuUploadDataImage WithToken:token qiniuPrefix:qiniuPrefix progress:^(NSString *key, float percent) {
            if (progress) {
                progress(percent,i);
            }
            if (allprogress) {
                NSData *data = UIImageJPEGRepresentation(imageArr[i], 1);
                NSInteger presentLenth = currentLength + percent * [@(data.length) integerValue];
                if (percent == 1) {
                    currentLength = presentLenth;
                }
                allprogress(totalLenth,presentLenth,presentLenth/(float)totalLenth);
            }
        } success:^(NSString *url) {
            [imageUrl addObject:url];
            if (imageUrl.count == imageArr.count) {
                if (success) {
                    success(imageUrl);
                }
            }
            
        } failure:^(NSString *status) {
            if (failure) {
                failure(status);
            }
            //失败，重新上传一次
            NSData *data = UIImageJPEGRepresentation(imageArr[i], 1);
            [self uploadData:data dataType:qiniuUploadDataImage WithToken:token qiniuPrefix:qiniuPrefix progress:^(NSString *key, float percent) {
                if (progress) {
                    progress(percent,i);
                }
                if (allprogress) {
                    NSData *data = UIImageJPEGRepresentation(imageArr[i], 1);
                    NSInteger presentLenth = currentLength + percent * [@(data.length) integerValue];
                    if (percent == 1) {
                        currentLength = presentLenth;
                    }
                    allprogress(totalLenth,presentLenth,presentLenth/(float)totalLenth);
                }
            } success:^(NSString *url) {
                [imageUrl addObject:url];
                if (imageUrl.count == imageArr.count) {
                    if (success) {
                        success(imageUrl);
                    }
                }
            } failure:^(NSString *status) {
                if (failure) {
                    failure(status);
                }
            }];
        }];
    });
    

}



/**
 *  所有图片的大小
 *  @param imageArr 图片源数组
 *
 *  @return 返回图片总大小
 */
+(NSInteger)summationFromImageArray:(NSArray *)imageArr
{
    NSInteger sum = 0;
    for (UIImage *image in imageArr) {
        NSData *imageData = UIImageJPEGRepresentation(image, 1);
        sum += imageData.length;
    }
    return sum;
}


/**
 *  获取UUID
 */
+(NSString*) getUUIDStringOne
{
    CFUUIDRef uuidObj = CFUUIDCreate(nil);
    NSString *uuidString = (__bridge_transfer NSString*)CFUUIDCreateString(nil, uuidObj);
    CFRelease(uuidObj);
    
    return uuidString;
}

/**
 *  获取UUID
 */
+(NSString *)getUUIDStringTwo
{
    UIDevice *device = [UIDevice currentDevice];//创建设备对象
    NSUUID *UUID = [device identifierForVendor];
    NSString * deviceID = [UUID UUIDString];
    deviceID = [deviceID stringByReplacingOccurrencesOfString:@"-" withString:@""];
    return deviceID;
}
@end
