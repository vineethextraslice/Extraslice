//
//  ForgotPwd.m
//  WalkNPay
//
//  Created by Administrator on 14/12/15.
//  Copyright © 2015 Extraslice. All rights reserved.
//

#import "ForgotPwd.h"
#import "WnPWebServiceDAO.h"
#import "WnPConstants.h"
#import "WnPUtilities.h"
#import "WnPUserDAO.h"
@interface ForgotPwd ()
@property(strong,nonatomic) WnPUtilities *utils;
@property(strong,nonatomic) WnPConstants *wnpCont;

@end

@implementation ForgotPwd

- (void)viewDidLoad {
    [super viewDidLoad];
    self.wnpCont=[[WnPConstants alloc]init];
    self.utils = [[WnPUtilities alloc] init];
    self.submitBtn.backgroundColor=[self.wnpCont getThemeBaseColor];
    self.cancelBtn.backgroundColor=[self.wnpCont getThemeBaseColor];
    self.email.layer.borderColor = [self.wnpCont getThemeBaseColor].CGColor;
    self.email.layer.borderWidth = 1.0f;
    self.headerView.backgroundColor=[self.wnpCont getThemeBaseColor];
    
    UITapGestureRecognizer *viewTap = [[UITapGestureRecognizer alloc] initWithTarget:self action: @selector(hideKeyBoard:)];
    viewTap.numberOfTapsRequired = 1;
    viewTap.numberOfTouchesRequired = 1;
    [self.view setUserInteractionEnabled:YES];
    [self.view addGestureRecognizer:viewTap];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (void) restPassword {
    WnPUserDAO *userDAO = [[WnPUserDAO alloc]init];
    NSString *status= [userDAO resetPassword:self.email.text];
    if([status isEqualToString:@"SUCCESS"]){
        UIAlertAction *alert = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        UIAlertController *controller = [UIAlertController alertControllerWithTitle:nil message:@"new password sent to your email" preferredStyle:UIAlertControllerStyleAlert];
        [controller addAction:alert];
        [self presentViewController:controller animated:YES completion:nil];
    }else{
        [self.utils showErrorMessage:self.errorLyt contView:self.errorText errorLabel:status];
    }
    
}
- (IBAction)cancelAction:(id)sender {
    UIStoryboard *stryBrd = [UIStoryboard storyboardWithName:@"LoginScreen" bundle:nil];
    UIViewController *viewCtrl=[stryBrd instantiateViewControllerWithIdentifier:@"LoginScreen"];
    if(viewCtrl != nil){
        viewCtrl.modalTransitionStyle=UIModalTransitionStyleFlipHorizontal;
        [self presentViewController:viewCtrl animated:YES completion:nil];
    }
}

- (IBAction)submitAction:(id)sender {
    if (self.email.text == nil || self.email.text.length ==0) {
        [self.utils showErrorMessage:self.errorLyt contView:self.errorText errorLabel:@"Please enter a valid email"];
        
    }else{
        [self restPassword];
    }
}

- (void)hideKeyBoard:(UITapGestureRecognizer *) rec{
    [self.view endEditing:YES];
}
@end
