//
//  LWCameraOverlayPresenter.m
//  LykkeWallet
//
//  Created by Георгий Малюков on 26.12.15.
//  Copyright © 2015 Lykkex. All rights reserved.
//

#import "LWCameraOverlayPresenter.h"


@interface LWCameraOverlayPresenter () {
    
}

#pragma mark - Actions

- (IBAction)closeButtonClick:(id)sender;
- (IBAction)selectFileButtonClick:(id)sender;
- (IBAction)takePictureButtonClick:(id)sender;
- (IBAction)switchButtonClick:(id)sender;


#pragma mark - Outlets

@property (weak, nonatomic) IBOutlet UIButton        *switchButton;
@property (weak, nonatomic) IBOutlet UIButton        *libraryButton;
@property (weak, nonatomic) IBOutlet UILabel         *subtitleLabel;
@property (weak, nonatomic) IBOutlet UINavigationBar *navigationBar;

@end


@implementation LWCameraOverlayPresenter


#pragma mark - Lifecycle

- (void)updateView {
    [self localize];
    self.libraryButton.hidden = self.isSelfieView;
    self.switchButton.hidden = self.isSelfieView;
}


#pragma mark - TKPresenter

- (void)localize {
    
    self.navigationBar.topItem.title = [Localize(@"register.title") uppercaseString];
    self.subtitleLabel.text = Localize(@"register.camera.title.selfie");
}


#pragma mark - Actions

- (IBAction)closeButtonClick:(id)sender {
    [self.pickerReference.delegate imagePickerControllerDidCancel:self.pickerReference];
    [self.pickerReference dismissViewControllerAnimated:NO completion:nil];
}

- (IBAction)selectFileButtonClick:(id)sender {
    NSAssert(0, @"What do you want to do here?");
}

- (IBAction)takePictureButtonClick:(id)sender {
    [self.pickerReference takePicture];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.pickerReference dismissViewControllerAnimated:NO completion:nil];
    });
}

- (IBAction)switchButtonClick:(id)sender {
    if (self.pickerReference.cameraDevice == UIImagePickerControllerCameraDeviceFront) {
        self.pickerReference.cameraDevice = UIImagePickerControllerCameraDeviceRear;
    }
    else {
        self.pickerReference.cameraDevice = UIImagePickerControllerCameraDeviceFront;
    }
}

@end
