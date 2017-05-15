//
//  ForgotPwdController.h
//  extraSlice
//
//  Created by Administrator on 19/06/16.
//  Copyright © 2016 Extraslice Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ResetPwdController : UIViewController<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *email;
- (IBAction)backToHome:(id)sender;
- (IBAction)resetPassword:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *errorText;
@property (weak, nonatomic) IBOutlet UIView *errorLyt;
@property (weak, nonatomic) IBOutlet UIView *goBackView;
@property (weak, nonatomic) IBOutlet UIImageView *goBackImage;

@end
