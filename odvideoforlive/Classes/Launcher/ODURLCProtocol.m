//
//  ODURLCProtocol.m
//  dianyingba
//
//  Created by 罗飞 on 24/09/2017.
//  Copyright © 2017 one. All rights reserved.
//

#import "ODURLCProtocol.h"

static NSString * const URLProtocolHandledKey=@"URLProtocolHandledKey";

@interface ODURLCProtocol()<NSURLConnectionDelegate>

@property (nonatomic, strong) NSURLConnection *connection;

@end

@implementation ODURLCProtocol

+ (BOOL)canInitWithRequest:(NSURLRequest *)request
{
    
//    NSLog(@"request.URL.absoluteString = %@",request.URL.absoluteString);
    
    if ([self blockURL:request.URL]) {
        NSLog(@"request.URL.absoluteString is blocked: %@",request.URL.absoluteString);
        return NO;
    }
    
    if ([request.URL.path.lowercaseString hasSuffix:@"m3u8"]||[request.URL.path.lowercaseString hasSuffix:@"mp4"]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"VideoUrlString" object:request.URL.absoluteString];

        return NO;
    }
    
    //只处理http和https请求
    NSString *scheme = [[request URL] scheme];
    if ( ([scheme caseInsensitiveCompare:@"http"] == NSOrderedSame ||
          [scheme caseInsensitiveCompare:@"https"] == NSOrderedSame))
    {
        //看看是否已经处理过了，防止无限循环
        if ([NSURLProtocol propertyForKey:URLProtocolHandledKey inRequest:request]) {
            return NO;
        }
        
        return YES;
    }
    return NO;
}

+(BOOL)blockURL:(NSURL *)url{
    NSSet *set=[NSSet setWithObjects:@"baidu.com",
                @"flvsp.com",
                @"cnzz.com",
                @"baosmx.com",
                @"qqee.org",
                @"bdimg.com",
                @"mmstat.com",
                nil];
    
    for (NSString *item in set) {
        if([url.host hasSuffix:item])return YES;
    }
    
    return NO;
}


+ (NSURLRequest *) canonicalRequestForRequest:(NSURLRequest *)request {
//    NSMutableURLRequest *mutableReqeust = [request mutableCopy];
//    mutableReqeust = [self redirectHostInRequset:mutableReqeust];
    return request;
}

+ (BOOL)requestIsCacheEquivalent:(NSURLRequest *)a toRequest:(NSURLRequest *)b
{
    return [super requestIsCacheEquivalent:a toRequest:b];
}

- (void)startLoading
{
    NSMutableURLRequest *mutableReqeust = [[self request] mutableCopy];
    //标示改request已经处理过了，防止无限循环
    [NSURLProtocol setProperty:@YES forKey:URLProtocolHandledKey inRequest:mutableReqeust];
    
    if ([ODURLCProtocol blockURL:mutableReqeust.URL]) {
        NSLog(@"request.URL.absoluteString is blocked: %@",mutableReqeust.URL.absoluteString);
        return;
    }
    
    self.connection = [NSURLConnection connectionWithRequest:mutableReqeust delegate:self];
}

- (void)stopLoading
{
    [self.connection cancel];
}

- (void) connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
}

- (void) connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.client URLProtocol:self didLoadData:data];
}

- (void) connectionDidFinishLoading:(NSURLConnection *)connection {
    [self.client URLProtocolDidFinishLoading:self];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [self.client URLProtocol:self didFailWithError:error];
}



@end
