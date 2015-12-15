//
//  LWKYCSuccessPresenter.m
//  LykkeWallet
//
//  Created by Георгий Малюков on 15.12.15.
//  Copyright © 2015 Lykkex. All rights reserved.
//

#import "LWKYCSuccessPresenter.h"
#import "LWRegistrationData.h"


@interface LWKYCSuccessPresenter () {
    
}

@property (weak, nonatomic) IBOutlet UILabel  *headerLabel;
@property (weak, nonatomic) IBOutlet UILabel  *textLabel;
@property (weak, nonatomic) IBOutlet UIButton *okButton;

@end


@implementation LWKYCSuccessPresenter


#pragma mark - TKPresenter

- (void)localize {
    self.headerLabel.text = Localize(@"register.kyc.success.header");
    [self.okButton setTitle:[Localize(@"register.kyc.success.okButton") uppercaseString]
                             forState:UIControlStateNormal];
}


#pragma mark - Properties

- (void)setRegistrationData:(LWRegistrationData *)registrationData {
    _registrationData = registrationData;
    
    self.textLabel.text = [NSString stringWithFormat:Localize(@"register.kyc.success"),
                           self.registrationData.firstName,
                           self.registrationData.lastName];
}

@end
