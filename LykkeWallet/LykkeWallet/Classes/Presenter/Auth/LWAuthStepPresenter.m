//
//  LWAuthStepPresenter.m
//  LykkeWallet
//
//  Created by Георгий Малюков on 09.12.15.
//  Copyright © 2015 Lykkex. All rights reserved.
//

#import "LWAuthStepPresenter.h"


@implementation LWAuthStepPresenter


#pragma mark - TKPresenter

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}


#pragma mark - Properties

- (LWAuthStep)stepId {
    NSAssert(0, @"Must be overridden.");
    return LWAuthStepEntryPoint;
}

@end
