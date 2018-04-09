//
//  JRHomeViewController.m
//  JRLinkageEffect
//
//  Created by hqtech on 2018/4/9.
//  Copyright © 2018年 tulip. All rights reserved.
//

#import "JRHomeViewController.h"
#import "JRDetailsViewController.h"

@interface JRHomeViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation JRHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.navigationItem.title = @"首页";
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.tableFooterView = [[UIView alloc] init];
}

#pragma mark - UITableViewDelegate, UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 20;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellID = @"cellID";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    
    cell.textLabel.text = [NSString stringWithFormat:@"第%ld行", (long)indexPath.row];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSMutableArray *videos = [NSMutableArray array];
    for (NSInteger i = 0; i < 20; i ++) {
        [videos addObject:@"测试数据"];
    }
    
    JRDetailsViewController *detailsVC = [[JRDetailsViewController alloc] initWithNibName:@"JRDetailsViewController" bundle:nil];
    detailsVC.videos = videos;
    detailsVC.index = indexPath.row;
    detailsVC.footerState = MJRefreshStateIdle;
    detailsVC.page = 2;
    [self.navigationController pushViewController:detailsVC animated:YES];
}

@end
