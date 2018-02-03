//
//  ODHomeViewCollectionViewCell.m
//  dianyingba
//
//  Created by 罗飞 on 23/09/2017.
//  Copyright © 2017 one. All rights reserved.
//

#import "ODHomeViewCollectionViewCell.h"
#import <SDWebImage/UIImageView+WebCache.h>

@implementation ODHomeViewCollectionViewCell

-(instancetype)initWithFrame:(CGRect)frame{
    if (self=[super initWithFrame:frame]) {
        [self initViewLayout];
    }
    return self;
}

-(void)initViewLayout{
    [self.contentView addSubview:self.imageView];
    [self.contentView addSubview:self.titleLabel];
    
    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.mas_equalTo(0);
        make.height.mas_equalTo(140);
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.mas_equalTo(0);
        make.bottom.mas_equalTo(-5);
    }];
}


-(void)setData:(ODVideoItem *)data{
    [self.imageView sd_setImageWithURL:[NSURL URLWithString:data.imageUri]];
    self.titleLabel.text=data.title;
}

-(UIImageView *)imageView{
    if(_imageView)return _imageView;
    
     UIImageView *imageView=[[UIImageView alloc]init];
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.clipsToBounds=YES;
    _imageView=imageView;
    
    return _imageView;
}

-(UILabel *)titleLabel{
    if(_titleLabel)return _titleLabel;
    
    UILabel *label=[[UILabel alloc]init];
    label.textAlignment=NSTextAlignmentCenter;
    label.font=[UIFont systemFontOfSize:13];
    label.numberOfLines=3;
//    label.textColor=[UIColor blackColor];
    _titleLabel=label;
    
    return _titleLabel;
}


@end
