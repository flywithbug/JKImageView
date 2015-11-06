//
//  UIImageView+JKWebCache.m
//  JKImageView
//
//  Created by Jack on 15/11/6.
//  Copyright © 2015年 Jack. All rights reserved.
//

#import "UIImageView+JKWebCache.h"


@implementation UIImageView (JKWebCache)

#pragma mark-Thread
- (void)jk_setImage_ThreadWithURL:(NSURL *)url
{
    NSThread *thread = [[NSThread alloc]initWithTarget:self selector:@selector(downLoadImage:) object:url];
    [thread start];
}


- (void)downLoadImage:(NSURL *)url
{
    //在子线程中完成下载
    NSData *data = [[NSData alloc] initWithContentsOfURL:url];
    UIImage *image = [[UIImage alloc]initWithData:data];
    if(image == nil){
        //这里可以写下载失败方法
    }else{
        //这里写成功回调， 回调到主线程   这个就是所谓的线程间通讯，除了可以更新主线程的数据外，还可以更新其他线程的比如使用用:performSelector:onThread:withObject:waitUntilDone:
        [self performSelectorOnMainThread:@selector(updateUI:) withObject:image waitUntilDone:YES];
        
    }
}

-(void)updateUI:(UIImage*) image
{
    self.image = image;
}


#pragma mark-Operation
- (void)jk_setimage_OperationWithURL:(NSURL *)url
{
    //NSBlockOperation
    [self jkNSBlockOperationWithURL:url];
    //NSInvocationOperation
//    [self jkNSInvocationOperationWithURL:url];
  
}

- (void)jkNSBlockOperationWithURL:(NSURL *)url
{
    //1.创建NSBlockOperation对象
    NSBlockOperation *operationblock = [NSBlockOperation blockOperationWithBlock:^{
        [self downLoadImage:url];
    }];
    // 开始执行任务(这里还是同步执行)
    //    [operationblock start];
    
    
    //    //图片每次调用此方法都初始化一个队列是不对的，
    NSOperationQueue *queue = [[NSOperationQueue alloc]init];
    //    // 1. 一旦将操作添加到操作队列，操作就会启动
    //    [queue addOperation:operation];
    [queue addOperation:operationblock];
}

- (void)jkNSInvocationOperationWithURL:(NSURL *)url
{
    //创建操作（最后的object参数是传递给selector方法的参数）这个只是操作，
    //如果不放入NSOperationQueue 队列，执行的时候还是在主线程
    NSInvocationOperation *operation = [[NSInvocationOperation alloc]initWithTarget:self
                                                                              selector:@selector(downLoadImage:)
                                                                                object:url];
//    如果使用start，会在当前线程启动操作
//    [operation start];
    
    
    
    // 图片每次调用此方法都初始化一个队列是不对的，
    NSOperationQueue *queue = [[NSOperationQueue alloc]init];
    // 一旦将操作添加到操作队列，操作就会启动
    [queue addOperation:operation];
}




#pragma mark-GCD

//使用GCD
- (void)jk_setImage_GCDWithURL:(NSURL *)url
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSData * data = [[NSData alloc]initWithContentsOfURL:url];
        UIImage *image = [[UIImage alloc]initWithData:data];
        if (data != nil) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.image = image;
            });
        }   
    });
}


@end
