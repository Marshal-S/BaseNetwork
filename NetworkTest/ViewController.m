//
//  ViewController.m
//  NetworkTest
//
//  Created by 李帅 on 2021/4/24.
//

#import "ViewController.h"

@interface ViewController ()<NSURLSessionDelegate, NSURLSessionDataDelegate, NSURLSessionDownloadDelegate>

@property (nonatomic, strong) NSMutableData *responseData;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
}


#pragma mark --下载普通图片数据
- (void)loadImage {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSURL *url = [NSURL URLWithString:@"https://t7.baidu.com/it/u=4162611394,4275913936&fm=193&f=GIF"];
        NSData *imgData = [NSData dataWithContentsOfURL:url];
        dispatch_async(dispatch_get_main_queue(), ^{
            //加载图片信息
//            self.imageView.image = [UIImage imageWithData:imgData];
        });
    });
}

#pragma mark --get、post的block请求
- (void)getDataBlock {
    //测试url不能访问
    NSURL *url = [NSURL URLWithString:@"https://www.test.com/login?uid=abc&pwd=123"];
    NSURLSession *session = [NSURLSession sharedSession];
    //开始以block的形式下载
    //注意:这种请求方式只能为GET
    NSURLSessionTask *task = [session dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
//        data：响应体信息（期望的数据）
//        response：响应头信息，主要是对服务器端的描述
//        error：错误信息，如
        if (!error) {
            //请求成功，data为json格式的序列化数据，请使用NSJSONSerialization来反序列化处理
        }
    }];
    //开始执行任务
    [task resume];
}

- (void)postDataBlock {
    NSURL *url = [NSURL URLWithString:@"https://www.test.com/login?uid=abc&pwd=123"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    //使用该方式可以
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"askdhfkashdkfsidfusdf" forHTTPHeaderField:@"token"];
    // 默认为GET，POST请求方法需要设置
    request.HTTPMethod = @"POST";
    request.timeoutInterval = 30.0;
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        //        data：响应体信息（期望的数据）
        //        response：响应头信息，主要是对服务器端的描述
        //        error：错误信息，如
        if (!error) {
            //请求成功，data为json格式的序列化数据，请使用NSJSONSerialization来反序列化处理
        }
    }];
    [task resume];
}


#pragma mark --请求代理
//使用代理下载
- (void)postDataDelegate {
    self.responseData = [NSMutableData data];
    
    NSURL *url = [NSURL URLWithString:@"https://www.test.com/login?uid=abc&pwd=123"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    //使用该方式可以
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"askdhfkashdkfsidfusdf" forHTTPHeaderField:@"token"];
    // 默认为GET，POST请求方法需要设置
    request.HTTPMethod = @"POST";
    request.timeoutInterval = 30.0;
    //使用默认的会话配置，代理和代理回调队列
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionTask *task = [session dataTaskWithRequest:request];
    [task resume];
}

//代理方法

//1.接收到服务器响应的时候调用该方法
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
                                 didReceiveResponse:(NSURLResponse *)response
                                  completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler
{
    /*
     NSURLSessionResponseCancel = 0,        默认的处理方式，取消
     NSURLSessionResponseAllow = 1,         接收服务器返回的数据
     NSURLSessionResponseBecomeDownload = 2,变成一个下载请求
     NSURLSessionResponseBecomeStream        变成一个流
     */
    completionHandler(NSURLSessionResponseAllow);
}

//2.接收到服务器返回数据的时候会调用该方法，如果数据较大那么该方法可能会调用多次
-(void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data
{
    [self.responseData appendData:data];
}

//3.当请求(下载)完成(成功|失败)的时候会调用该方法，如果请求失败，则error有值
-(void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    if(error == nil)
    {
        //请求成功
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:self.responseData options:kNilOptions error:nil];
        NSLog(@"%@",dict);
    }else {
        //请求失败
    }
}

#pragma mark --下载

//如果想支持断点续联下载，那么需要下载一个url前检查是否本地已经有对应的下载文件，如果有检查其是否下载完毕，没有下载完毕，继续下载即可

- (void)downloadBlock {
    NSURL *url = [NSURL URLWithString:@"https://pic.ibaotu.com/00/48/71/79a888piCk9g.mp4"];
    //设置后台下载会话配置
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:@"testBackgroundIdentifier"];
    //允许请求通过蜂窝路由
    config.allowsCellularAccess = YES;
    config.timeoutIntervalForRequest = 30;
    //通过block的形式下载，location下载的url,里面有path可以直接打开或者删除移动 就不多说了
//    [NSURLSession sessionWithConfiguration:config];
//    [session downloadTaskWithURL:url completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {
//        if (!error) {
//            //下载成功可以播放
//        }
//    }];
    //使用代理下载
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    
    //断点续传
//    1.检查文件路径是否存在 通过NSFileManager可以查看
//    2.不存在直接下载，存在获取数据文件继续下载
//    NSData *resumeData = [NSData dataWithContentsOfFile:@"地址"];
//    3.继续下载
//    [session downloadTaskWithResumeData:resumeData];
//    4.后台下载需要注意开启后台任务，避免下载过程出现问题，下载完成可以关闭后台任务
//    [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^(){}];
    
    
    [session downloadTaskWithURL:url];
}

-(void)URLSession:(nonnull NSURLSession *)session downloadTask:(nonnull NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite{
    //获取下载完成百分比
    //float downPro = 1.0 * totalBytesWritten / totalBytesExpectedToWrite;
}
/*
 2.下载完成之后调用该方法
 */
-(void)URLSession:(nonnull NSURLSession *)session downloadTask:(nonnull NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(nonnull NSURL *)location{
//    NSLog(@"location == %@",location.path);
    //可以通过location获取地址，移动或者删除
}

- (void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session{
    NSLog(@"所有后台任务已经完成: %@",session.configuration.identifier);
}

@end
