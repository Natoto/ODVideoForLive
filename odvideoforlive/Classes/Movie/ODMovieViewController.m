//
//  ODMovieViewController.m
//  dianyingba
//
//  Created by 罗飞 on 24/09/2017.
//Copyright © 2017 one. All rights reserved.
//

#import "ODMovieViewController.h"

@interface ODMovieViewController ()

#pragma mark - --- 属性定义 ---


@end

@implementation ODMovieViewController

#pragma mark - --- 生命周期 ---



#pragma mark - --- 初始化事件 ---

-(void)loadConfig{
    self.urlString=@"http://www.dianyingbar.com/all-dian-ying/guo-chan-dian-ying";
}

-(void)switchDataSource{
    self.allDataSource=!self.allDataSource;
    if (self.allDataSource) {
        self.urlString=@"http://www.dianyingbar.com/all-dian-ying";
    }else{
        self.urlString=@"http://www.dianyingbar.com/all-dian-ying/guo-chan-dian-ying";
    }
    [self loadDataSource];
}

#pragma mark - --- dataSource ---

#pragma mark - --- override ---

#pragma mark - --- api event ---

#pragma mark - --- model event ---

#pragma mark - --- view event ---

#pragma mark - --- delegate ---

#pragma mark - --- observer ---

#pragma mark - --- private ---

#pragma mark - --- getter / setter ---

@end

