//
//  ViewController.m
//  qiniuDemo
//
//  Created by caijiamu on 16/6/23.
//  Copyright © 2016年 cloud.wood-group. All rights reserved.
//

#import "ViewController.h"
#import <AFHTTPSessionManager.h>
#import "JMQNUploadManagerShare.h"
#import "JMQNUploadManagerClient.h"
#import <YYWebImage/UIImageView+YYWebImage.h>
@interface ViewController ()
/**
 *  token
 */
@property (nonatomic, copy) NSString *token;
/**
 *  七牛前缀
 */
@property (nonatomic, copy) NSString *qiniuPrefix;
@property (strong, nonatomic) IBOutlet UIImageView *qiniuImageView;
/**
 *  进度视图
 */
@property (strong, nonatomic) IBOutlet UIProgressView *progress;
/**
 *  进度值
 */
@property (nonatomic, assign) CGFloat progressValue;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //异步测试
//    [self asyntest];
    
    //同步测试
//    [self syncTest];
}
-(void)asyntest
{
    dispatch_queue_t t1=dispatch_queue_create("1", NULL);
    dispatch_queue_t t2=dispatch_queue_create("2", NULL);
    dispatch_async(t1, ^{
        for (int i=0; i < 10; ++i) {
            NSLog(@"异步i===%d--%@",i,[NSThread currentThread]);
        }
        for (int i=0; i < 10; ++i) {
            NSLog(@"异步22i===%d--%@",i,[NSThread currentThread]);
        }
    });
//    dispatch_async(t2, ^{
//        for (int m=0; m < 10; ++m) {
//            NSLog(@"m===%d",m);
//        }
//        
//    });
}

-(void)syncTest
{
    dispatch_queue_t t1=dispatch_queue_create("1", NULL);
    dispatch_queue_t t2=dispatch_queue_create("2", NULL);
    dispatch_sync(t1, ^{
        for (int i=0; i < 10; ++i) {
            NSLog(@"同步i===%d---%@",i,[NSThread currentThread]);
        }
        
    });
//    dispatch_sync(t2, ^{
//        for (int m=0; m < 10; ++m) {
//            NSLog(@"m===%d",m);
//        }
//        
//    });
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}
- (IBAction)clickGetqiniuTokenInfo:(UIButton *)button
{
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc]init];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [manager GET:@"http://101.200.150.202:7004/base/qiNiu/tk/info" parameters:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        NSError *error = nil;
        NSDictionary *dataDic = [NSJSONSerialization JSONObjectWithData:(NSData *)responseObject options:NSJSONReadingMutableContainers error:&error];
        self.token = dataDic[@"token"];
        self.qiniuPrefix = dataDic[@"domain"];
        NSLog(@"获取token成功");
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
}


- (IBAction)upData:(UIButton *)button
{
//    [self upsingleImage];
//    [self upMoreImage];
      [self GCDUpMoreImage];
}

-(void)GCDUpMoreImage
{
    NSMutableArray *imageArr = @[[UIImage imageNamed:@"1"],[UIImage imageNamed:@"2"],[UIImage imageNamed:@"3"],[UIImage imageNamed:@"1"],[UIImage imageNamed:@"2"],[UIImage imageNamed:@"3"]].mutableCopy;
   [JMQNUploadManagerClient GCDUploadImageArray:imageArr WithToken:_token qiniuPrefix:[NSString stringWithFormat:@"%@/",_qiniuPrefix] progress:^(CGFloat percent, NSInteger i) {
       NSLog(@"单张图片%f---%ld",percent,(long)i);
   } allImageProgress:^(CGFloat maxProgress, CGFloat currentProgress, CGFloat precent) {
       NSLog(@"所有图片%f",precent);
       self.progressValue = precent;

   } success:^(NSArray *imageUrlArr) {
       NSLog(@"成功%@",imageUrlArr);
   } failure:^(NSString *status) {
       NSLog(@"失败%@",status);
   }];
}

/**
 *  上传多张图片(顺序)
 */
-(void)upMoreImage
{
    NSMutableArray *imageArr = @[[UIImage imageNamed:@"1"],[UIImage imageNamed:@"2"],[UIImage imageNamed:@"3"]].mutableCopy;
    [JMQNUploadManagerClient uploadImageArray:imageArr WithToken:_token qiniuPrefix:[NSString stringWithFormat:@"%@/",_qiniuPrefix] progress:^(CGFloat maxProgress, CGFloat currentProgress, CGFloat precent) {
        NSLog(@"%f",precent);
        self.progressValue = precent;
        
    } success:^(NSArray *imageUrlArr) {
        NSLog(@"%@",imageUrlArr);
    } failure:^(NSString *status) {
        NSLog(@"%@",status);
    }];
}
/**
 *  上传单张图片
 */
-(void)upsingleImage
{
    UIImage *image = [UIImage imageNamed:@"1"];
    NSData *imageData = UIImageJPEGRepresentation(image, 1);
    [JMQNUploadManagerClient uploadData:imageData dataType:qiniuUploadDataImage WithToken:_token qiniuPrefix:[NSString stringWithFormat:@"%@/",_qiniuPrefix] progress:^(NSString *key, float percent) {
        NSLog(@"key = %@,percent = %f",key,percent);
        self.progressValue = percent;
    } success:^(NSString *ImageUrl) {
        [self.qiniuImageView yy_setImageWithURL:[NSURL URLWithString:ImageUrl] placeholder:nil options:YYWebImageOptionProgressive completion:nil];
    } failure:^(NSString *status) {
        NSLog(@"%@",status);
        
    }];
}


-(void)setProgressValue:(CGFloat)progressValue
{
    _progressValue = progressValue;
    self.progress.progress = _progressValue;
    [self.view setNeedsLayout];
}

@end
