//
//  LWKYCPresenter.m
//  LykkeWallet
//
//  Created by Георгий Малюков on 15.12.15.
//  Copyright © 2015 Lykkex. All rights reserved.
//

#import "LWKYCPresenter.h"


@interface LWKYCPresenter () {
    
}

@end

@implementation LWKYCPresenter


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // hide navigation bar
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    // managers
    [LWAuthManager instance].delegate = self;
}

@end