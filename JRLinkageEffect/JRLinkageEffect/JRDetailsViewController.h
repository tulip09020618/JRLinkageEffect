//
//  JRDetailsViewController.h
//  JRLinkageEffect
//
//  Created by hqtech on 2018/4/9.
//  Copyright © 2018年 tulip. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JRDetailsViewController : UIViewController

/**
 视频列表页中的视频数据
 */
@property (nonatomic, strong) NSArray *videos;

/**
 当前要播放的视频所在位置
 */
@property (nonatomic, assign) NSInteger index;

#pragma mark -start-下拉刷新/上拉加载数据需要
/**
 当前页数
 */
@property (nonatomic, assign) NSInteger page;

/**
 上拉控件状态
 */
@property (nonatomic, assign) MJRefreshState footerState;
#pragma mark -end-下拉刷新/上拉加载数据需要

@end
