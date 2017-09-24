//
//  ODSearchViewController.m
//  dianyingba
//
//  Created by 罗飞 on 24/09/2017.
//Copyright © 2017 one. All rights reserved.
//

#import "ODSearchViewController.h"

static NSString * const SearchPreString=@"http://www.dianyingbar.com/?s=";

@interface ODSearchViewController ()<UITextFieldDelegate>

#pragma mark - --- 属性定义 ---

@property(nonatomic,strong) UITextField * textField;

@end

@implementation ODSearchViewController

#pragma mark - --- 生命周期 ---


#pragma mark - --- 初始化事件 ---

-(void)loadConfig{
    self.urlString=@"http://www.dianyingbar.com/?s=";
}

-(void)initViewLayout{
    [super initViewLayout];
    
    [self.view addSubview:self.textField];
    
    [self.textField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(30);
        make.left.mas_equalTo(30);
        make.right.mas_equalTo(-30);
        make.height.mas_equalTo(34);
    }];
    
    [self.collectionView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(64);
        make.bottom.mas_equalTo(-49);
        make.left.right.mas_equalTo(0);
    }];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:NO];
}

#pragma mark - --- dataSource ---

#pragma mark - --- override ---

#pragma mark - --- api event ---

#pragma mark - --- model event ---

#pragma mark - --- view event ---

#pragma mark - --- delegate ---

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    if (textField.text.length) {
        NSString *string=[textField.text stringByAddingPercentEncodingWithAllowedCharacters:[[NSCharacterSet characterSetWithCharactersInString:textField.text] invertedSet]];
        self.urlString=[NSString stringWithFormat:@"%@%@",SearchPreString,string];
//        self.urlString=[self.urlString stringByAddingPercentEncodingWithAllowedCharacters:[[NSCharacterSet characterSetWithCharactersInString:self.urlString] invertedSet]];
        [self loadDataSource];
    }
    
    [textField resignFirstResponder];
    
    return NO;
}

#pragma mark - --- observer ---

#pragma mark - --- private ---

#pragma mark - --- getter / setter ---

-(UITextField *)textField{
    if(_textField)return _textField;
    
    UITextField *view=[[UITextField alloc]init];
    view.clearButtonMode=UITextFieldViewModeWhileEditing;
    view.placeholder=@"搜索";
    view.returnKeyType=UIReturnKeySearch;
    view.delegate=self;
    view.layer.borderWidth=.5f;
    view.layer.borderColor=[UIColor lightGrayColor].CGColor;
    
    _textField=view;
    
    return _textField;
}

@end

