//
//  ODODNetworkingDownload.h
//  dianyingba
//
//  Created by 罗飞 on 23/09/2017.
//  Copyright © 2017 one. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ODNetworkingDownload : NSObject

+(void)GET:(NSString *)uri complete:(void(^)(NSData * data,NSError * error))complete;

@end
