//
//  ODHomeViewController.m
//  dianyingba
//
//  Created by 罗飞 on 23/09/2017.
//Copyright © 2017 one. All rights reserved.
//

#import "ODHomeViewController.h"
#import "ODNetworking.h"
#import "ODHomeViewCollectionViewCell.h"
#import "OCGumbo+Query.h"
#import "Constant.h"
#import "ODVideoItem.h"
#import "ODVideoDetailViewController.h"
#import <MJRefresh/MJRefresh.h>
#import <MBProgressHUD/MBProgressHUD.h>
#import <SVProgressHUD/SVProgressHUD.h>

@interface ODHomeViewController ()<UICollectionViewDelegate,UICollectionViewDataSource>

#pragma mark - --- 属性定义 ---

@property(nonatomic,strong) NSArray<ODVideoItem *> * data;

@property(nonatomic,assign) NSInteger  currentPage;



@end

@implementation ODHomeViewController

#pragma mark - --- 生命周期 ---

-(instancetype)init{
    if (self=[super init]) {
        [self loadConfig];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initViewLayout];
    
    [self initViewEvents];
    
    [self initViewDataSource];
    
}

#pragma mark - --- 初始化事件 ---

-(void)loadConfig{
    self.urlString=@"http://www.dianyingbar.com/dian-shi-ju/guo-chan-dian-shi-ju";
}

-(void)initViewLayout{
    self.view.backgroundColor=[UIColor groupTableViewBackgroundColor];
    
    [self.view addSubview:self.collectionView];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    
    self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc]initWithTitle:@"全部" style:UIBarButtonItemStylePlain target:self action:@selector(switchDataSource)];
}

-(void)initViewEvents{
    
    
    self.collectionView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadDataSource)];

    self.collectionView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreDataSource)];

}

-(void)initViewDataSource{
    
    [self.collectionView.mj_header beginRefreshing];
}

-(void)loadDataSource{
    self.navigationItem.rightBarButtonItem.title=self.allDataSource?@"国产":@"全部";
    self.currentPage=1;
    
    [self loadDataSource:self.currentPage];
}

-(void)switchDataSource{
    self.allDataSource=!self.allDataSource;
    if (self.allDataSource) {
        self.urlString=@"http://www.dianyingbar.com/dian-shi-ju";
    }else{
        self.urlString=@"http://www.dianyingbar.com/dian-shi-ju/guo-chan-dian-shi-ju";
    }
    [self loadDataSource];
}

-(void)loadMoreDataSource{
    [self loadDataSource:self.currentPage];
}


-(void)loadDataSource:(NSInteger)idx{
    if (idx==1) {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    }
    NSString *urlString=self.urlString;
    if (idx>1) {
        urlString=[NSString stringWithFormat:@"%@/page/%lu",urlString,idx];
    }
    [ODNetworking GET:urlString complete:^(NSData *data, NSError *error) {
        if (idx==1) {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        }
        [self.collectionView.mj_header endRefreshing];
        [self.collectionView.mj_footer endRefreshing];
        
        if (data) {
            NSString *htmlString=[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
            
            [self parseHtmlString:htmlString];
        }else{
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            [SVProgressHUD showErrorWithStatus:error.localizedDescription];
            [SVProgressHUD dismissWithDelay:2];
        }
    }];
}

-(void)parseHtmlString:(NSString *)htmlString{
//    NSString *htmlString=[NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"home.html" ofType:nil] encoding:NSUTF8StringEncoding error:nil];
    OCGumboDocument *document = [[OCGumboDocument alloc] initWithHTMLString:htmlString];
    NSArray<OCGumboElement *> *menus= document.Query(@"body").find(@"section.container").find(@"article");
    NSMutableArray *array=[NSMutableArray arrayWithCapacity:menus.count];
    for (OCGumboElement *element in menus) {
        NSString *target= element.Query(@"a.thumbnail").first().attr(@"href");
        NSString *imageUrlString=element.Query(@"a.thumbnail").find(@"img").first().attr(@"data-original");
        NSString *title=element.Query(@"h2").find(@"a").first().attr(@"title");
        
        ODVideoItem *item=[[ODVideoItem alloc]init];
        item.imageUri=imageUrlString;
        item.targetUri=target;
        item.title=title;
        
        [array addObject:item];
    }
    
    if (!array.count) {
        [SVProgressHUD showErrorWithStatus:@"数据解析失败"];
        [SVProgressHUD dismissWithDelay:2];
        return;
    }
    
    if (self.currentPage==1) {
        self.data=[array copy];
    }else{
        NSMutableArray *array1=[NSMutableArray arrayWithArray:self.data];
        [array1 addObjectsFromArray:array];
        self.data=[array1 copy];
    }
    
    self.currentPage++;
    
    dispatch_async(dispatch_get_main_queue(), ^{
       [self.collectionView reloadData];
    });
    
//    [self printElement:menus];
}

-(void)printElement:(NSArray<OCGumboElement *> *)array{
    for (OCGumboElement *element in array) {
        NSLog(@"%@",element.text());
    }
}

#pragma mark - --- dataSource ---

#pragma mark - --- override ---

#pragma mark - --- api event ---

#pragma mark - --- model event ---

#pragma mark - --- view event ---

#pragma mark - --- delegate ---

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.data.count;
}
- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identified=@"C";
    ODHomeViewCollectionViewCell *view=[collectionView dequeueReusableCellWithReuseIdentifier:identified forIndexPath:indexPath];
    view.data=self.data[indexPath.row];
    return view;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    ODVideoItem *model = self.data[indexPath.row];
    ODVideoDetailViewController *view=[[ODVideoDetailViewController alloc]init];
    view.targerUri=model.targetUri;
    self.hidesBottomBarWhenPushed=YES;
    [self.navigationController pushViewController:view animated:YES];
    self.hidesBottomBarWhenPushed=NO;
}

#pragma mark - --- observer ---

#pragma mark - --- private ---

#pragma mark - --- getter / setter ---

-(UICollectionView *)collectionView{
    if(_collectionView)return _collectionView;
    
    UICollectionViewFlowLayout *layout=[[UICollectionViewFlowLayout alloc]init];
    layout.itemSize=CGSizeMake(100, 200);
    layout.sectionInset=UIEdgeInsetsMake(10, 10, 10, 10);
    
    UICollectionView *view=[[UICollectionView alloc]initWithFrame:CGRectNull collectionViewLayout:layout];
    [view registerClass:[ODHomeViewCollectionViewCell class] forCellWithReuseIdentifier:@"C"];
    view.backgroundColor=[UIColor clearColor];
    view.delegate=self;
    view.dataSource=self;
    
    _collectionView=view;
    
    return _collectionView;
}

@end

