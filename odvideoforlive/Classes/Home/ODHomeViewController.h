//
//  ODHomeViewController.h
//  dianyingba
//
//  Created by 罗飞 on 23/09/2017.
//  Copyright © 2017 one. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Masonry/Masonry.h>

@interface ODHomeViewController : UIViewController

@property(nonatomic,strong) UICollectionView * collectionView;

@property(nonatomic,strong) NSString * urlString;

@property(nonatomic,assign) BOOL  allDataSource;

-(void)loadConfig;

-(void)initViewLayout;

-(void)initViewEvents;

-(void)initViewDataSource;

-(void)loadDataSource;

-(void)loadDataSource:(NSInteger)idx;

@end
