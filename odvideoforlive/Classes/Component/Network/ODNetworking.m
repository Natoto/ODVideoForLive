//
//  ODNetworking.m
//  dianyingba
//
//  Created by 罗飞 on 23/09/2017.
//  Copyright © 2017 one. All rights reserved.
//

#import "ODNetworking.h"
#import "ODNetworkingDownload.h"

@implementation ODNetworking

+(void)GET:(NSString *)uri complete:(void(^)(NSData * data,NSError * error))complete{
    [ODNetworkingDownload GET:uri complete:complete];
}

+(void)POST:(NSString *)uri parameters:(NSDictionary *)parameters complete:(void(^)(void))complete{
    
}

@end
