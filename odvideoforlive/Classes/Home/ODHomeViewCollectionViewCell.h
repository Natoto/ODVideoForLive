//
//  ODHomeViewCollectionViewCell.h
//  dianyingba
//
//  Created by 罗飞 on 23/09/2017.
//  Copyright © 2017 one. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ODVideoItem.h"
#import <Masonry/Masonry.h>


@interface ODHomeViewCollectionViewCell : UICollectionViewCell

@property(nonatomic,strong) UIImageView * imageView;

@property(nonatomic,strong) UILabel * titleLabel;



@property(nonatomic,strong) ODVideoItem * data;


@end
