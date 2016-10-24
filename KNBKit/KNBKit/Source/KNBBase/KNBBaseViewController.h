//
//  KNBBaseViewController.h
//  KenuoTraining
//
//  Created by 吴申超 on 16/2/26.
//  Copyright © 2016年 Robert. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MJRefresh.h"

typedef void(^KNMJFooterLoadCompleteBlock)(NSInteger page);
typedef void(^KNMJHeaderLoadCompleteBlock)(NSInteger page);

@interface KNBBaseViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *knbTableView;
@property (nonatomic, strong) UITableView *knGroupTableView;
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, assign) NSInteger requestPage; //加载页数

/**
 *  添加导航右边按钮
 *
 *  @param imgName 图片
 *  @param sel     sel
 */
- (void)addRightBarItemImageName:(NSString *)imgName sel:(SEL)sel;

/**
 *  添加导航左边按钮
 *
 *  @param imgName 图片
 *  @param sel     sel
 */
- (void)addleftBarItemImageName:(NSString *)imgName sel:(SEL)sel;

/**
 *  添加导航按钮
 *
 *  @param title 标题
 *  @param sel   sel
 */
- (void)addRightBarItemTitle:(NSString *)title sel:(SEL)sel;


/**
 *  默认自带返回按钮
 *
 *  @param title 返回按钮旁边的按钮
 *  @param sel   按钮事件
 */
- (void)addLeftBarItemTitle:(NSString *)title sel:(SEL)sel;


/**
 *  添加下拉加载更多
 */
- (void)addMJRefreshHeadView:(KNMJHeaderLoadCompleteBlock)completeBlock;

/**
 *  添加上拉加载更多
 */
- (void)addMJRefreshFootView:(KNMJFooterLoadCompleteBlock)completeBlock;

- (void)requestSuccess:(BOOL)success requestEnd:(BOOL)end;

@end
