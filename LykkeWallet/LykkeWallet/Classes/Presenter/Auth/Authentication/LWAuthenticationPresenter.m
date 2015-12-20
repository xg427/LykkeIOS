//
//  LWAuthenticationPresenter.m
//  LykkeWallet
//
//  Created by Alexander Pukhov on 20.12.15.
//  Copyright © 2015 Lykkex. All rights reserved.
//

#import "LWAuthenticationPresenter.h"
#import "LWAuthenticationData.h"
#import "LWTextField.h"
#import "LWValidator.h"
#import "TKPresenter+Loading.h"


@interface LWAuthenticationPresenter () <LWTextFieldDelegate, LWAuthManagerDelegate> {
    LWTextField *emailField;
    LWTextField *passwordField;
}

@property (weak, nonatomic) IBOutlet TKContainer *emailContainer;
@property (weak, nonatomic) IBOutlet TKContainer *passwordContainer;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;

@end


@implementation LWAuthenticationPresenter

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = Localize(@"title.authentication");
    
#warning TODO: move to common function
    // init fields
    LWTextField *(^createField)(TKContainer *, NSString *) = ^LWTextField *(TKContainer *container, NSString *placeholder) {
        LWTextField *f = [LWTextField new];
        //        f.delegate = self;
        f.keyboardType = UIKeyboardTypeASCIICapable;
        f.placeholder = placeholder;
        [container attach:f];
        
        return f;
    };
    
    emailField = createField(self.emailContainer, Localize(@"auth.email"));
    emailField.keyboardType = UIKeyboardTypeEmailAddress;
    emailField.enabled = NO;
    
    passwordField = createField(self.passwordContainer, Localize(@"auth.password"));
    passwordField.secure = YES;
    passwordField.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self validateProceedButtonState];
    
    // load email
    emailField.text = self.email;
    // focus first name
    [passwordField becomeFirstResponder];
}


#pragma mark - LWTextFieldDelegate

- (void)textFieldDidChangeValue:(LWTextField *)textFieldInput {
    if (!self.isVisible) { // prevent from being processed if controller is not presented
        return;
    }
    
    // check button state
    [self validateProceedButtonState];
}


#pragma mark - Private

- (BOOL)canProceed {
    BOOL isValidEmail = [LWValidator validateEmail:emailField.text];
    BOOL isValidPassword = [LWValidator validatePassword:passwordField.text];
    return (isValidEmail && isValidPassword);
}


#pragma mark - Utils

#warning TODO: move to common function
- (void)validateProceedButtonState {
    BOOL canProceed = [self canProceed];
    
    NSString *proceedImage = (canProceed) ? @"ButtonOK" : @"ButtonOKInactive";
    UIColor *proceedColor = (canProceed) ? [UIColor whiteColor] : [UIColor lightGrayColor];
    BOOL enabled = (canProceed);
    
    [self.loginButton setBackgroundImage:[UIImage imageNamed:proceedImage] forState:UIControlStateNormal];
    [self.loginButton setTitleColor:proceedColor forState:UIControlStateNormal];
    self.loginButton.enabled = enabled;
}

- (IBAction)loginClicked:(id)sender {
    if ([self canProceed]) {
        [self setLoading:YES];
        
        LWAuthenticationData *data = [LWAuthenticationData new];
        data.email = emailField.text;
        data.password = passwordField.text;
        
        [[LWAuthManager instance] requestAuthentication:data];
    }
}


#pragma mark - LWAuthManagerDelegate

- (void)authManagerDidAuthenticate:(LWAuthManager *)manager {
    [self setLoading:NO];
    
#warning TODO: navigate depends on status
    /*if (status.documentTypeRequired != nil) {
        // navigate to selfie camera presenter
        [((LWAuthNavigationController *)self.navigationController)
         navigateToStep:LWAuthStepRegisterSelfie
         preparationBlock:nil];
    }
    else {
        // navigate to verification
        // ...
    }*/
}

- (void)authManager:(LWAuthManager *)manager didFailWithReject:(NSDictionary *)reject context:(GDXRESTContext *)context {
    [self showReject:reject];
}

@end
