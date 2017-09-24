//
//  ODURLProtocol.m
//  dianyingba
//
//  Created by 罗飞 on 23/09/2017.
//  Copyright © 2017 one. All rights reserved.
//

#import "ODURLProtocol.h"
#import "AppDelegate.h"

static NSString *URLProtocolHandledKey=@"URLProtocolHandledKey";

@interface ODURLProtocol()<NSURLSessionDelegate>

@property (nonnull,strong) NSURLSessionDataTask *task;

@end

@implementation ODURLProtocol

+ (BOOL)canInitWithRequest:(NSURLRequest *)request
{
    NSLog(@"request.URL.absoluteString = %@",request.URL.absoluteString);
    
    if ([self blockURL:request.URL]) {
        NSLog(@"request.URL.absoluteString is blocked: %@",request.URL.absoluteString);
        return NO;
    }
    
//    if ([request.URL.path.pathExtension caseInsensitiveCompare:@"m3u8"]==NSOrderedSame||[request.URL.path hasSuffix:@"m3u8"]) {
//
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"VideoUrlString" object:request.URL.absoluteString];
//
//        return NO;
//    }
    
    NSString *scheme = [[request URL] scheme];
    if ( ([scheme caseInsensitiveCompare:@"http"]  == NSOrderedSame ||
          [scheme caseInsensitiveCompare:@"https"] == NSOrderedSame ))
    {
        //看看是否已经处理过了，防止无限循环
        if ([NSURLProtocol propertyForKey:URLProtocolHandledKey inRequest:request])
            return NO;
        return YES;
    }
    return NO;
}

+(BOOL)blockURL:(NSURL *)url{
    NSSet *set=[NSSet setWithObjects:@"baidu.com",
                @"cnzz.com",
                @"baosmx.com",
                @"qqee.org",
                @"mmstat.com",
                nil];
    
    for (NSString *item in set) {
        if([url.host hasSuffix:item])return YES;
    }
    
    return NO;
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request
{
    return request;
}

+ (BOOL)requestIsCacheEquivalent:(NSURLRequest *)a toRequest:(NSURLRequest *)b
{
    return [super requestIsCacheEquivalent:a toRequest:b];
}

- (void)startLoading
{
    NSMutableURLRequest *mutableReqeust = [[self request] mutableCopy];
    //给我们处理过的请求设置一个标识符, 防止无限循环,
    [NSURLProtocol setProperty:@YES forKey:URLProtocolHandledKey inRequest:mutableReqeust];
    
    if ([ODURLProtocol blockURL:mutableReqeust.URL]) {
        
    }else{
        NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:nil];
        self.task = [session dataTaskWithRequest:self.request];
        [self.task resume];
    }
}

- (void)stopLoading
{
    if (self.task != nil)
    {
        [self.task  cancel];
    }
}


- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler {
    
    [[self client] URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageAllowed];

    completionHandler(NSURLSessionResponseAllow);
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    [[self client] URLProtocol:self didLoadData:[string dataUsingEncoding:NSUTF8StringEncoding]];
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(nullable NSError *)error {
    [self.client URLProtocolDidFinishLoading:self];
}


@end
