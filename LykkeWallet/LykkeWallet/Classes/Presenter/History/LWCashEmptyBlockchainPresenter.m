//
//  LWCashEmptyBlockchainPresenter.m
//  LykkeWallet
//
//  Created by Alexander Pukhov on 15.03.16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWCashEmptyBlockchainPresenter.h"
#import "LWLeftDetailTableViewCell.h"
#import "LWCashInOutHistoryItemType.h"
#import "LWAssetPairModel.h"
#import "LWAssetDealModel.h"
#import "LWAssetModel.h"
#import "LWConstants.h"
#import "LWCache.h"
#import "LWMath.h"
#import "UIViewController+Navigation.h"


@interface LWCashEmptyBlockchainPresenter () {
    UIRefreshControl *refreshControl;
}

@end


@implementation LWCashEmptyBlockchainPresenter

static int const kNumberOfRows = 3;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self registerCellWithIdentifier:kLeftDetailTableViewCellIdentifier
                                name:kLeftDetailTableViewCell];
    
    NSString *type = (self.model.amount.intValue >= 0
                      ? Localize(@"history.cash.out")
                      : Localize(@"history.cash.in"));
    
    NSString *base = [LWAssetModel
                      assetByIdentity:self.model.asset
                      fromList:[LWCache instance].baseAssets];
    
    self.title = [NSString stringWithFormat:@"%@ %@", base, type];
    
    [self setBackButton];
    [self setRefreshControl];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [self setHideKeyboardOnTap:NO]; // gesture recognizer deletion
}

- (void)setRefreshControl
{
    UIView *refreshView = [[UIView alloc] initWithFrame:CGRectMake(0, 5, 0, 0)];
    [self.tableView insertSubview:refreshView atIndex:0];
    
    refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.tintColor = [UIColor blackColor];
    [refreshControl addTarget:self action:@selector(updateStatus)
             forControlEvents:UIControlEventValueChanged];
    [refreshView addSubview:refreshControl];
}


#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return kNumberOfRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LWLeftDetailTableViewCell *cell = (LWLeftDetailTableViewCell *)[tableView dequeueReusableCellWithIdentifier:kLeftDetailTableViewCellIdentifier];
    
    [self updateTitleCell:cell row:indexPath.row];
    [self updateValueCell:cell row:indexPath.row];
    
    return cell;
}


#pragma mark - UITableViewDelegate

- (void)viewDidLayoutSubviews
{
}


#pragma mark - Utils

- (void)updateTitleCell:(LWLeftDetailTableViewCell *)cell row:(NSInteger)row {
    NSString *const titles[kNumberOfRows] = {
        Localize(@"history.cash.asset"),
        Localize(@"history.cash.amount"),
        Localize(@"history.cash.blockchain")
    };
    cell.titleLabel.text = titles[row];
}

- (void)updateValueCell:(LWLeftDetailTableViewCell *)cell row:(NSInteger)row {

    NSString *volumeString = [LWMath priceString:self.model.amount
                                       precision:[NSNumber numberWithInt:0]
                                      withPrefix:@""];
    
    NSString *const values[kNumberOfRows] = {
        self.model.asset,
        volumeString,
        Localize(@"history.cash.progress")
    };
    
    cell.detailLabel.text = values[row];
    [cell.detailLabel setTextColor:[UIColor colorWithHexString:kMainDarkElementsColor]];
}

- (void)updateStatus {
#warning TODO:
}


#pragma mark - LWAuthManagerDelegate

- (void)authManager:(LWAuthManager *)manager didFailWithReject:(NSDictionary *)reject context:(GDXRESTContext *)context {
    [refreshControl endRefreshing];
    
    //[self showReject:reject response:context.task.response code:context.error.code willNotify:YES];
}

@end