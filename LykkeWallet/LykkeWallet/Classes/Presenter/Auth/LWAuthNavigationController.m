//
//  LWAuthNavigationController.m
//  LykkeWallet
//
//  Created by Георгий Малюков on 09.12.15.
//  Copyright © 2015 Lykkex. All rights reserved.
//

#import "LWAuthNavigationController.h"
#import "LWAuthEntryPointPresenter.h"
#import "LWAuthValidationPresenter.h"

#import "LWRegisterBasePresenter.h"
#import "LWRegisterFullNamePresenter.h"
#import "LWRegisterPhonePresenter.h"
#import "LWRegisterPasswordPresenter.h"
#import "LWRegisterConfirmPasswordPresenter.h"

#import "LWAuthenticationPresenter.h"
#import "LWAuthValidationPresenter.h"
#import "LWAuthPINEnterPresenter.h"
#import "LWRegisterCameraSelfiePresenter.h"
#import "LWKYCSubmitPresenter.h"
#import "LWKYCPendingPresenter.h"
#import "LWKYCInvalidDocumentsPresenter.h"
#import "LWKYCRestrictedPresenter.h"
#import "LWKYCSuccessPresenter.h"
#import "LWRegisterPINSetupPresenter.h"

// tab presenters
#import "LWTabController.h"
#import "LWWalletsPresenter.h"
#import "LWTradingPresenter.h"
#import "LWHistoryPresenter.h"
#import "LWSettingsPresenter.h"

#import "LWKeychainManager.h"


@interface LWAuthNavigationController () {
    NSArray *classes;
    NSMutableDictionary<NSNumber *, LWAuthStepPresenter *> *activeSteps;
}


#pragma mark - Root Controller Configuration

+ (LWAuthStepPresenter *)authPresenter;
- (void)setRootAuthScreen;
- (void)setRootMainTabScreen;


#pragma mark - Utils

- (UITabBarItem *)createTabBarItemWithTitle:(NSString *)title withImage:(NSString *)image;

@end


@implementation LWAuthNavigationController


#pragma mark - Root

- (instancetype)init {
    self = [super initWithRootViewController:[LWAuthNavigationController authPresenter]];
    if (self) {
        _currentStep = ([LWKeychainManager instance].isAuthenticated
                        ? LWAuthStepValidation
                        : LWAuthStepEntryPoint);
        // set controllers classes
        classes = @[LWAuthValidationPresenter.class,
                    LWAuthEntryPointPresenter.class,
                    //LWAuthPINEnterPresenter.class,
                    LWAuthenticationPresenter.class,

                    LWRegisterFullNamePresenter.class,
                    LWRegisterPhonePresenter.class,
                    LWRegisterPasswordPresenter.class,
                    LWRegisterConfirmPasswordPresenter.class,
                    
                    LWRegisterCameraSelfiePresenter.class,
                    LWRegisterCameraPresenter.class,
                    LWRegisterCameraPresenter.class,
                    LWKYCSubmitPresenter.class,
                    LWKYCPendingPresenter.class,
                    LWKYCInvalidDocumentsPresenter.class,
                    LWKYCRestrictedPresenter.class,
                    LWKYCSuccessPresenter.class,
                    LWRegisterPINSetupPresenter.class];
        activeSteps = [NSMutableDictionary new];
        activeSteps[@(self.currentStep)] = self.viewControllers.firstObject;
    }
    return self;
}


#pragma mark - Common

- (void)navigateToStep:(LWAuthStep)step preparationBlock:(LWAuthStepPushPreparationBlock)block {
    // check whether we can just unwind to step
    if ([activeSteps.allKeys containsObject:@(step)]) {
        [self popToViewController:activeSteps[@(step)] animated:YES];
    }
    else {
        // otherwise create new step presenter
        LWAuthStepPresenter *presenter = [classes[step] new];
        activeSteps[@(step)] = presenter;
        // prevent lazy view loading
        NSLog(@"PreventingLazyLoad: %@", presenter.view);
        // prepare to push if necessary
        if (block) {
            block(presenter);
        }
        [self pushViewController:presenter animated:YES];
    }
    // change current step
    _currentStep = step;
}

- (void)navigateWithKYCStatus:(NSString *)status withPinEntered:(BOOL)isPinEntered isAuthentication:(BOOL)isAuthentication {
    NSLog(@"KYC GetStatus: %@", status);
    
    if ([status isEqualToString:@"NeedToFillData"]) {
        [self navigateToStep:LWAuthStepRegisterKYCInvalidDocuments preparationBlock:nil];
    }
    else if ([status isEqualToString:@"RestrictedArea"]) {
        [self navigateToStep:LWAuthStepRegisterKYCRestricted preparationBlock:nil];
    }
    else if ([status isEqualToString:@"Rejected"] || [status isEqualToString:@"Pending"]) {
        [self navigateToStep:LWAuthStepRegisterKYCPending preparationBlock:nil];
    }
    else if ([status isEqualToString:@"Ok"]) {
        if (!isAuthentication) {
            [self navigateToStep:LWAuthStepRegisterKYCSuccess preparationBlock:nil];
        }
        else {
            if (isPinEntered) {
                [self setRootMainTabScreen];
            }
            else  {
                [self navigateToStep:LWAuthStepRegisterPINSetup preparationBlock:nil];
            }
        }
    }
    else {
        NSAssert(0, @"Unknown KYC status.");
    }
}


#pragma mark - Auth

- (void)logout {
    [activeSteps removeAllObjects];
    [self setRootAuthScreen];
}


#pragma mark - Root Controller Configuration

+ (LWAuthStepPresenter *)authPresenter {
    return ([LWKeychainManager instance].isAuthenticated
            ? [LWAuthValidationPresenter new]
            : [LWAuthEntryPointPresenter new]);
}

- (void)setRootAuthScreen {
    [self setViewControllers:@[[LWAuthNavigationController authPresenter]] animated:NO];
}

- (void)setRootMainTabScreen {
    LWTabController *tab = [LWTabController new];
    
    LWWalletsPresenter *pWallets = [LWWalletsPresenter new];
    pWallets.tabBarItem = [self createTabBarItemWithTitle:@"tab.wallets"
                                                withImage:@"WalletsTab"];
    LWTradingPresenter *pTrading = [LWTradingPresenter new];
    pTrading.tabBarItem = [self createTabBarItemWithTitle:@"tab.trading"
                                                withImage:@"TradingTab"];
    LWHistoryPresenter *pHistory = [LWHistoryPresenter new];
    pHistory.tabBarItem = [self createTabBarItemWithTitle:@"tab.history"
                                                withImage:@"HistoryTab"];
    LWSettingsPresenter *pSettings = [LWSettingsPresenter new];
    pSettings.tabBarItem = [self createTabBarItemWithTitle:@"tab.settings"
                                                 withImage:@"SettingsTab"];    
    // init tab controller
    tab.viewControllers = @[pWallets, pTrading, pHistory, pSettings];
    tab.tabBar.tintColor = [UIColor colorWithHexString:MAIN_COLOR];
    
    [self setViewControllers:@[tab] animated:NO];
}


#pragma mark - Utils

- (UITabBarItem *)createTabBarItemWithTitle:(NSString *)title withImage:(NSString *)image {
    return [[UITabBarItem alloc] initWithTitle:Localize(title)
                                         image:[UIImage imageNamed:image]
                                 selectedImage:nil];
}


#pragma mark - UINavigationController

- (UIViewController *)popViewControllerAnimated:(BOOL)animated {
    UIViewController *result = [super popViewControllerAnimated:animated];
    // clean steps
    for (NSNumber *key in activeSteps.allKeys) {
        if (![self.viewControllers containsObject:activeSteps[key]]) {
            [activeSteps removeObjectForKey:key];
        }
    }
    return result;
}

@end
