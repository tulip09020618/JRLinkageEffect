//
//  JRDetailsViewController.m
//  JRLinkageEffect
//
//  Created by hqtech on 2018/4/9.
//  Copyright © 2018年 tulip. All rights reserved.
//

#import "JRDetailsViewController.h"
#import "JRDetailsTableViewCell.h"

static CGFloat cellHeight = 200;
static NSString *cellID = @"Details";

@interface JRDetailsViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataSource;

// 遮盖层上的滚动视图，与tableView联动，用于控制tableView滑动
@property (nonatomic, strong) UIScrollView *scrollView;

@end

@implementation JRDetailsViewController

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    [self adapterIOS10];
}

#pragma mark 适配iOS10
- (void)adapterIOS10 {
    if (@available(iOS 11.0, *)) {
        
    }else {
        CGFloat tableY = 64;
        if (IS_IPHONE_X) {
            tableY = 88;
        }
        self.tableView.frame = CGRectMake(0, tableY, SCREEN_WIDTH, SCREEN_HEIGHT - tableY);
    }
}

#pragma mark 懒加载，初始化数据源
- (NSMutableArray *)dataSource {
    if (!_dataSource) {
        if (_videos) {
            _dataSource = [NSMutableArray arrayWithArray:_videos];
        }else {
            _dataSource = [NSMutableArray array];
        }
    }
    return _dataSource;
}

- (void)setVideos:(NSArray *)videos {
    _videos = videos;
    if (!_dataSource) {
        _dataSource = [NSMutableArray arrayWithArray:videos];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self setNav];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.tableFooterView = [[UIView alloc] init];
    [self.tableView registerNib:[UINib nibWithNibName:@"JRDetailsTableViewCell" bundle:nil] forCellReuseIdentifier:cellID];
    self.tableView.separatorColor = [UIColor colorWithHex:0x000000 andAlpha:0.3];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    // 添加半透明遮盖层
    [self addCoverView];
    
    // 设置tableView内容距离底边的高度(避免最底下视频无法滑动到可播放区域)
    // 44：导航栏高度(未算状态栏高度) 为了防止最后一个视频全屏播放时，隐藏状态栏对视频位置的影响
    [self setListBottomSpaceHeight:NO];
    
    // KVO监听tableView的contentSize变化
    [self.tableView addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:nil];
    
    // 初始化下拉刷新控件
    [self addMJRefresh];
    
    // KVO监听scrollView的刷新状态变化
    [self.scrollView.mj_header addObserver:self forKeyPath:@"state" options:NSKeyValueObservingOptionNew context:nil];
    [self.scrollView.mj_footer addObserver:self forKeyPath:@"state" options:NSKeyValueObservingOptionNew context:nil];
    [self.tableView.mj_header addObserver:self forKeyPath:@"state" options:NSKeyValueObservingOptionNew context:nil];
    [self.tableView.mj_footer addObserver:self forKeyPath:@"state" options:NSKeyValueObservingOptionNew context:nil];
    
    // 设置显示当前视频
    [self.tableView setContentOffset:CGPointMake(0, cellHeight * self.index)];
}

#pragma mark KVO监听tableView的contentSize变化
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"contentSize"]) {
        NSLog(@"KVO监听：%f", self.tableView.contentSize.height);
        if (self.scrollView.contentSize.height != (self.tableView.contentSize.height - cellHeight)) {
            NSLog(@"更新scrollView的contentSize：%f", self.tableView.contentSize.height);
            [self.scrollView setContentSize:CGSizeMake(self.tableView.contentSize.width, self.tableView.contentSize.height - cellHeight)];
            [self updateTableViewContentOffSet];
        }
        
    }else if ([keyPath isEqualToString:@"state"]) {
        // header
        if ([object isEqual:self.scrollView.mj_header]) {
            if (self.tableView.mj_header.state != self.scrollView.mj_header.state) {
                NSLog(@"更新table的header状态");
                self.tableView.mj_header.state = self.scrollView.mj_header.state;
            }
        }else if ([object isEqual:self.scrollView.mj_footer]) {
            if (self.tableView.mj_footer.state != self.scrollView.mj_footer.state) {
                NSLog(@"更新table的footer状态");
                self.tableView.mj_footer.state = self.scrollView.mj_footer.state;
            }
        }else if ([object isEqual:self.tableView.mj_header]) {
            if (self.scrollView.mj_header.state != self.tableView.mj_header.state) {
                NSLog(@"更新scroll的header状态");
                self.scrollView.mj_header.state = self.tableView.mj_header.state;
            }
        }else if ([object isEqual:self.tableView.mj_footer]) {
            if (self.scrollView.mj_footer.state != self.tableView.mj_footer.state) {
                NSLog(@"更新scroll的footer状态");
                self.scrollView.mj_footer.state = self.tableView.mj_footer.state;
            }
        }
        NSLog(@"新值：%@", [change objectForKey:NSKeyValueChangeNewKey]);
    }
}

- (void)dealloc {
    // 移除KVO监听
    [self.tableView removeObserver:self forKeyPath:@"contentSize" context:nil];
    [self.scrollView.mj_header removeObserver:self forKeyPath:@"state" context:nil];
    [self.scrollView.mj_footer removeObserver:self forKeyPath:@"state" context:nil];
    [self.tableView.mj_header removeObserver:self forKeyPath:@"state" context:nil];
    [self.tableView.mj_footer removeObserver:self forKeyPath:@"state" context:nil];
    
    NSLog(@"%@ dealloc",[self class]);
}

#pragma mark - KVO监听刷新控件的变化
- (void)addObserversToObj:(MJRefreshComponent *)refreshComponent
{
    NSKeyValueObservingOptions options = NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld;
    [refreshComponent.scrollView addObserver:refreshComponent forKeyPath:MJRefreshKeyPathContentOffset options:options context:nil];
}

- (void)removeObserversWithObj:(MJRefreshComponent *)refreshComponent
{
    [refreshComponent.superview removeObserver:refreshComponent forKeyPath:MJRefreshKeyPathContentOffset];
}

- (void)setNav {
    
    self.navigationItem.title = @"详情";
    
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"nav_back_white"] style:UIBarButtonItemStylePlain target:self action:@selector(goback)];
    self.navigationItem.leftBarButtonItem = leftItem;
    
}
- (void)goback {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - 添加刷新控件
- (void)addMJRefresh {
    // 设置回调（一旦进入刷新状态，就调用target的action，也就是调用self的loadNewData方法）
    MJRefreshNormalHeader *refreshHeader = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewData)];
    // 设置自动切换透明度(在导航栏下面自动隐藏)
    //    refreshHeader.automaticallyChangeAlpha = YES;
    // 隐藏时间
    refreshHeader.lastUpdatedTimeLabel.hidden = YES;
    // 设置header
    self.tableView.mj_header = refreshHeader;
    
    //设置上拉加载更多
    MJRefreshAutoNormalFooter *footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreData)];
    [footer setTitle:NSLocalizedString(@"点击或上拉加载更多", nil) forState:MJRefreshStateIdle];
    [footer setTitle:NSLocalizedString(@"正在加载更多的数据...", nil) forState:MJRefreshStateRefreshing];
    [footer setTitle:NSLocalizedString(@"已经全部加载完毕", nil) forState:MJRefreshStateNoMoreData];
    // 设置footer
    self.tableView.mj_footer = footer;
    // 设置上拉控件当前状态
    [self.tableView.mj_footer setState:self.footerState];
    if (self.footerState == MJRefreshStateNoMoreData) {
        [self setListBottomSpaceHeight:NO];
    }else {
        [self setListBottomSpaceHeight:YES];
    }
    
    [self addMJRefreshToScrollView];
}

#pragma mark 给scrollView添加下拉刷新控件
- (void)addMJRefreshToScrollView {
    // 设置回调（一旦进入刷新状态，就调用target的action，也就是调用self的loadNewData方法）
    MJRefreshNormalHeader *refreshHeader = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewDataWithScroll)];
    // 设置自动切换透明度(在导航栏下面自动隐藏)
    //    refreshHeader.automaticallyChangeAlpha = YES;
    // 隐藏时间
    refreshHeader.lastUpdatedTimeLabel.hidden = YES;
    // 设置字体颜色
    refreshHeader.stateLabel.textColor = [UIColor clearColor];
    // 设置header
    self.scrollView.mj_header = refreshHeader;
    
    //设置上拉加载更多
    MJRefreshAutoNormalFooter *footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreDataWithScroll)];
    [footer setTitle:NSLocalizedString(@"点击或上拉加载更多", nil) forState:MJRefreshStateIdle];
    [footer setTitle:NSLocalizedString(@"正在加载更多的数据...", nil) forState:MJRefreshStateRefreshing];
    [footer setTitle:NSLocalizedString(@"已经全部加载完毕", nil) forState:MJRefreshStateNoMoreData];
    // 设置字体颜色
    footer.stateLabel.textColor = [UIColor clearColor];
    // 设置footer
    self.scrollView.mj_footer = footer;
    // 设置上拉控件当前状态
    [self.scrollView.mj_footer setState:self.footerState];
}

#pragma mark 下拉刷新
- (void)loadNewData {
    
    NSLog(@"下拉刷新");
    
    [self.tableView.mj_footer setHidden:YES];
    
    self.page = 1;
    [self getMineParticipationalVideo:self.page];
    
}
- (void)loadNewDataWithScroll {
}

#pragma mark 上拉加载更多
- (void)loadMoreData {
    
    NSLog(@"上拉加载");
    
    [self getMineParticipationalVideo:self.page];
}
- (void)loadMoreDataWithScroll {
}

#pragma mark 获取我参与的视频列表
- (void)getMineParticipationalVideo:(NSInteger)page {
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        // n秒后异步执行这里的代码...
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
        //如果是下拉刷新，结束刷新状态
        if ([self.tableView.mj_header isRefreshing]) {
            // 拿到当前的下拉刷新控件，结束刷新状态
            [self.tableView.mj_header endRefreshing];
        }
        //上拉加载更多
        if ([self.tableView.mj_footer isRefreshing]) {
            [self.tableView.mj_footer endRefreshing];
            [self setListBottomSpaceHeight:YES];
        }
        
        NSMutableArray *modelArr = [NSMutableArray array];
        for (NSInteger i = 0; i < 10; i ++) {
            [modelArr addObject:[NSString stringWithFormat:@"测试数据"]];
        }
        
        if (self.page == 1) {
            self.dataSource = modelArr;
            [self.tableView.mj_footer setHidden:NO];
        }else {
            [self.dataSource addObjectsFromArray:modelArr];
        }
        [self.tableView reloadData];
        
        //上拉加载更多状态
        if (modelArr.count == 0) {
            [self.tableView.mj_footer endRefreshingWithNoMoreData];
            [self setListBottomSpaceHeight:NO];
        }else {
            [self.tableView.mj_footer endRefreshing];
            [self setListBottomSpaceHeight:YES];
        }
        self.page ++;
        
    });
    
}

#pragma mark - UITableViewDelegate, UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    JRDetailsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    
    NSString *imgName = [NSString stringWithFormat:@"video%ld.jpg", indexPath.row % 5];
    cell.imgName = imgName;
    
    cell.index = indexPath.row;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return cellHeight;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return cellHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

#pragma mark - UIScrollViewDelegate
///*
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    if (scrollView != self.tableView && scrollView != self.scrollView) {
        return;
    }
    
    // 减速停止
    //    NSLog(@"停止滚动1:%f", scrollView.contentOffset.y);
    // 修复位置
    [self updateTableViewContentOffSet];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    // 结束拖动
    if (scrollView == self.scrollView) {
        [self addObserversToObj:self.tableView.mj_header];
    }else if (scrollView == self.tableView) {
        [self addObserversToObj:self.scrollView.mj_header];
    }
    
    if (scrollView != self.tableView && scrollView != self.scrollView) {
        return;
    }
    
    // decelerate 减速
    if (decelerate) {
        // 减速
        //        NSLog(@"停止滚动3-yes:%f", scrollView.contentOffset.y);
    }else {
        // 停止
        //        NSLog(@"停止滚动3-no:%f", scrollView.contentOffset.y);
        // 修复位置
        [self updateTableViewContentOffSet];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    // 将要拖动
    if (scrollView == self.scrollView) {
        [self removeObserversWithObj:self.tableView.mj_header];
    }else if (scrollView == self.tableView) {
        [self removeObserversWithObj:self.scrollView.mj_header];
    }
}

#pragma mark 设置scrollView和tableView联动
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    //    // y < 0 时，只需要table随scroll滚动即可
    //    // 修复下拉刷新功能
    //    if (scrollView.contentOffset.y < 0 && scrollView == self.scrollView) {
    //        [self scrollViewContentOffsetDidChange];
    //    }
    
    if (scrollView == self.scrollView) {
        NSLog(@"正在滚动-scroll(>0):%f", scrollView.contentOffset.y);
        self.tableView.delegate = nil;
        [self.tableView setContentOffset:scrollView.contentOffset];
        self.tableView.delegate = self;
    }else if (scrollView == self.tableView && !self.scrollView.isDragging) {
        NSLog(@"正在滚动-table(>0):%f", scrollView.contentOffset.y);
        self.scrollView.delegate = nil;
        [self.scrollView setContentOffset:scrollView.contentOffset];
        self.scrollView.delegate = self;
    }
    
}
//*/

#pragma mark 滚动停止后，修复contentOffSet
- (void)updateTableViewContentOffSet {
    // 获取当前的contentOffSet
    CGFloat currentScrolledY = self.tableView.contentOffset.y;
    
    // 如果<0，则滚到顶部
    if (currentScrolledY < 0) {
        [self.tableView scrollsToTop];
        return;
    }
    
    NSLog(@"修正contentOffSet");
    
    // 如果>=0
    // 计算滚动了几个cell高度(四舍五入)
    NSInteger count = round(currentScrolledY / cellHeight);
    // 重置contentOffSet
    [self.tableView setContentOffset:CGPointMake(0, count * cellHeight) animated:YES];
}

#pragma mark - 添加半透明遮盖层
- (void)addCoverView {
    
    CGFloat navHeight = 64;
    if (IS_IPHONE_X) {
        navHeight = 88;
    }
    UIView *coverView = [[UIView alloc] initWithFrame:CGRectMake(0, cellHeight + navHeight - 1, SCREEN_WIDTH, SCREEN_HEIGHT - cellHeight - navHeight + 1)];
    coverView.backgroundColor = [UIColor colorWithHex:0x000000 andAlpha:0.77];
    [self.view addSubview:coverView];
    
    CGFloat imgHeight = 19;
    UIImageView *imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"mine_participational_lookMore"]];
    imgView.frame = CGRectMake(0, CGRectGetHeight(coverView.frame) - 35 - imgHeight, 20, imgHeight);
    imgView.center = CGPointMake(SCREEN_WIDTH / 2.0, imgView.center.y);
    [coverView addSubview:imgView];
    
    CGFloat labelHeight = 20;
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMinY(imgView.frame) - 10 - labelHeight, 200, labelHeight)];
    label.center = CGPointMake(imgView.center.x, label.center.y);
    label.text = @"浏览更多视频";
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont systemFontOfSize:16];
    label.textAlignment = NSTextAlignmentCenter;
    [coverView addSubview:label];
    
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(coverView.frame), CGRectGetHeight(self.tableView.frame) - cellHeight)];
    scrollView.contentSize = CGSizeMake(SCREEN_WIDTH, self.tableView.contentSize.height - cellHeight);
    scrollView.delegate = self;
    if (self.tableView.mj_header.state == MJRefreshStateNoMoreData) {
        [self setListBottomSpaceHeight:NO];
    }else {
        [self setListBottomSpaceHeight:YES];
    }
    [coverView addSubview:scrollView];
    self.scrollView = scrollView;
}

#pragma mark 设置视频列表下面空白区域高度
// 44：导航栏高度(未算状态栏高度) 为了防止最后一个视频全屏播放时，隐藏状态栏对视频位置的影响
- (void)setListBottomSpaceHeight:(BOOL)hasMoreData {
    if (!hasMoreData) {
        // 没有更多数据
        self.tableView.contentInset = UIEdgeInsetsMake(0, 0, SCREEN_HEIGHT - cellHeight - 44, 0);
        if (self.scrollView) {
            self.scrollView.contentInset = UIEdgeInsetsMake(0, 0, SCREEN_HEIGHT - cellHeight - 44, 0);
        }
    }else {
        self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
        if (self.scrollView) {
            self.scrollView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
        }
    }
}

@end
