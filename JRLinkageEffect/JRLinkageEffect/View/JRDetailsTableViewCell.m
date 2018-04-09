//
//  JRDetailsTableViewCell.m
//  JRLinkageEffect
//
//  Created by hqtech on 2018/4/9.
//  Copyright © 2018年 tulip. All rights reserved.
//

#import "JRDetailsTableViewCell.h"

@interface JRDetailsTableViewCell ()
@property (weak, nonatomic) IBOutlet UILabel *indexLabel;
@property (weak, nonatomic) IBOutlet UIImageView *videoThumbImgView;
@end

@implementation JRDetailsTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setImgName:(NSString *)imgName {
    _imgName = imgName;
    
    self.videoThumbImgView.image = [UIImage imageNamed:imgName];
}

- (void)setIndex:(NSInteger)index {
    _index = index;
    
    self.indexLabel.text = [NSString stringWithFormat:@"第%ld个视频", self.index];
}

@end
