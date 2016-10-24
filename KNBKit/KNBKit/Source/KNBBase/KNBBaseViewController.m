//
//  KNBBaseViewController.m
//  KenuoTraining
//
//  Created by 吴申超 on 16/2/26.
//  Copyright © 2016年 Robert. All rights reserved.
//

#import "KNBBaseViewController.h"

@interface KNBBaseViewController ()

@property (nonatomic, copy) KNMJFooterLoadCompleteBlock footerCompleteBlock;

@end

@implementation KNBBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = KNB_BG_COLOR;
    self.requestPage = 1;
    if (self.navigationController.viewControllers.count > 1) {
        [self addleftBarItemImageName:@"icon_return" sel:@selector(leftBarButtonItemAction:)];
        CGRect newFrame = CGRectMake(0, 0, KNB_SCREEN_WIDTH, KNB_SCREEN_HEIGHT);
        self.knbTableView.frame = newFrame;
        self.knGroupTableView.frame = newFrame;
    }
}

- (void)addRightBarItemImageName:(NSString *)imgName sel:(SEL)sel {
    NSArray *items = [self barButtonImageName:imgName sel:sel leftEdg:20];
    self.navigationItem.rightBarButtonItems = items;
}

- (void)addleftBarItemImageName:(NSString *)imgName sel:(SEL)sel {
    NSArray *items = [self barButtonImageName:imgName sel:sel leftEdg:-30];
    self.navigationItem.leftBarButtonItems = items;
}


- (NSArray *)barButtonImageName:(NSString *)imgName sel:(SEL)sel leftEdg:(CGFloat)edg{
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.frame = CGRectMake(0, 0, 40, 44);
    [backBtn setImageEdgeInsets:UIEdgeInsetsMake(0, edg, 0, 0)];
    [backBtn setImage:[UIImage imageNamed:imgName] forState:UIControlStateNormal];
    [backBtn addTarget:self action:sel forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    UIBarButtonItem *placeHolditem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:self action:nil];
    return @[item, placeHolditem];
}

- (void)addRightBarItemTitle:(NSString *)title sel:(SEL)sel {
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:title style:UIBarButtonItemStylePlain target:self action:sel];
    self.navigationItem.rightBarButtonItem = rightItem;
}

- (void)addLeftBarItemTitle:(NSString *)title sel:(SEL)sel {
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_return"] style:UIBarButtonItemStylePlain target:self action:@selector(leftBarButtonItemAction:)];
    UIBarButtonItem *items = [[UIBarButtonItem alloc] initWithTitle:title style:UIBarButtonItemStylePlain target:self action:sel];
    leftItem.imageInsets = UIEdgeInsetsMake(0, -5, 0, -5);
    self.navigationItem.leftBarButtonItems = @[leftItem,items];
}


#pragma mark - UIBarButtonItemAction
- (void)leftBarButtonItemAction:(UIBarButtonItem *)item {
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
}

#pragma mark - Getting
- (UITableView *)knbTableView {
    if (!_knbTableView) {
        CGRect frame = CGRectMake(0, 0, KNB_SCREEN_WIDTH, KNB_SCREEN_HEIGHT - 49);
        _knbTableView = [[UITableView alloc] initWithFrame:frame style:UITableViewStylePlain];
        _knbTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _knbTableView.backgroundColor = KNB_BG_COLOR;
        _knbTableView.delegate = self;
        _knbTableView.dataSource = self;
    }
    return _knbTableView;
}

- (UITableView *)knGroupTableView { // group
    if (!_knGroupTableView) {
        CGRect frame = CGRectMake(0, 0, KNB_SCREEN_WIDTH, KNB_SCREEN_HEIGHT - 49);
        _knGroupTableView = [[UITableView alloc] initWithFrame:frame style:UITableViewStyleGrouped];
        _knGroupTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _knGroupTableView.backgroundColor = KNB_BG_COLOR;
        _knGroupTableView.delegate = self;
        _knGroupTableView.dataSource = self;
        _knGroupTableView.sectionFooterHeight = 0.1;
        _knGroupTableView.sectionHeaderHeight = 0.1;
    }
    return _knGroupTableView;
}


- (NSMutableArray *)dataArray {
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}

#pragma mark -  MJRefresh
- (void)addMJRefreshFootView:(KNMJFooterLoadCompleteBlock)completeBlock {
    self.knGroupTableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreData)];
    self.knbTableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreData)];
    self.footerCompleteBlock = completeBlock;
}

- (void)loadMoreData {
    self.requestPage += 1;
    if (self.footerCompleteBlock) {
        self.footerCompleteBlock(self.requestPage);
    }
}

- (void)requestSuccess:(BOOL)success requestEnd:(BOOL)end {
    [self.knGroupTableView.mj_header endRefreshing];
    [self.knGroupTableView.mj_footer endRefreshing];
    [self.knbTableView.mj_header endRefreshing];
    [self.knbTableView.mj_footer endRefreshing];
    
    if (end) {
        [self.knbTableView.mj_footer endRefreshingWithNoMoreData];
        [self.knGroupTableView.mj_footer endRefreshingWithNoMoreData];
        [self.knGroupTableView reloadData];
        [self.knbTableView reloadData];
        return;
    }
    if (!success && self.requestPage > 1) {
        self.requestPage -= 1;
    }
    else {
        [self.knGroupTableView reloadData];
        [self.knbTableView reloadData];
    }
}

- (void)addMJRefreshHeadView:(KNMJHeaderLoadCompleteBlock)completeBlock {
    KNB_WS(weakSelf);
    self.knbTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [weakSelf.knbTableView.mj_footer resetNoMoreData];
        weakSelf.requestPage = 1;
        if (completeBlock) {
            completeBlock(1);
        }
    }];
    
    self.knGroupTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [weakSelf.knGroupTableView.mj_footer resetNoMoreData];
        weakSelf.requestPage = 1;
        if (completeBlock) {
            completeBlock(1);
        }
    }];
}


@end
