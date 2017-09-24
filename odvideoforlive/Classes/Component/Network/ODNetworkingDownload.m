//
//  ODODNetworkingDownload.m
//  dianyingba
//
//  Created by 罗飞 on 23/09/2017.
//  Copyright © 2017 one. All rights reserved.
//

#import "ODNetworkingDownload.h"

@implementation ODNetworkingDownload


+(void)GET:(NSString *)uri complete:(void(^)(NSData * data,NSError * error))complete{
    
    NSMutableURLRequest *request=[[NSMutableURLRequest alloc]initWithURL:[NSURL URLWithString:uri]];
    [request setValue:@"Mozilla/5.0 (iPhone; CPU iPhone OS 10_3 like Mac OS X) AppleWebKit/603.1.30 (KHTML, like Gecko) Version/10.3 Mobile/14E277 Safari/603.1.30" forHTTPHeaderField:@"User-Agent"];
    request.timeoutInterval=30;
    NSURLSession *session=[NSURLSession sharedSession];
    
    NSURLSessionDataTask *task= [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if(complete)complete(data,error);
        });
    }];
    
    [task resume];
}


+(void)POST:(NSString *)uri parameters:(NSDictionary *)parameters complete:(void(^)(void))complete{
    
    
    
}

@end
