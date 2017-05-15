//
//  ChangePassword.m
//  walkNPay
//
//  Created by Administrator on 28/01/16.
//  Copyright © 2016 Extraslice Inc. All rights reserved.
//

#import "WnPChangePassword.h"
#import "WnPConstants.h"
#import "WnPUtilities.h"
#import "WnPUserDAO.h"
#import "MenuController.h"

@interface WnPChangePassword ()
@property (strong,nonatomic) WnPConstants *wnpCont;
@property(strong,nonatomic) WnPUtilities *utils;

@end

@implementation WnPChangePassword

- (void)viewDidLoad {
    self.wnpCont=[[WnPConstants alloc]init];
    self.utils=[[WnPUtilities alloc]init];
    [super viewDidLoad];
    self.userModel=[self.wnpCont getUserModel];
    self.header.backgroundColor=[self.wnpCont getThemeBaseColor];
    self.cancelBtn.backgroundColor=[self.wnpCont getThemeBaseColor];
    self.submitBtn.backgroundColor=[self.wnpCont getThemeBaseColor];
    self.header.backgroundColor=[self.wnpCont getThemeBaseColor];
    [self.view setBounds:CGRectMake(0,0, 240,250)];
    self.view.layer.borderColor= [self.wnpCont getThemeBaseColor].CGColor;
    self.view.layer.borderWidth = 1.0f;
    UITapGestureRecognizer *viewTap = [[UITapGestureRecognizer alloc] initWithTarget:self action: @selector(hideKeyBoard:)];
    viewTap.numberOfTapsRequired = 1;
    viewTap.numberOfTouchesRequired = 1;
    [self.view setUserInteractionEnabled:YES];
    [self.view addGestureRecognizer:viewTap];
   
}

- (void)hideKeyBoard:(UITapGestureRecognizer *) rec{
    [self.view endEditing:YES];
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

- (IBAction)cancelPopup:(id)sender {
    self.parentViewController.view.backgroundColor=[UIColor whiteColor];
    for(UIView *subViews in [self.parentViewController.view subviews]){
        subViews.alpha=1.0;
        [subViews setUserInteractionEnabled:YES];
    }
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
}
- (IBAction)sumbitChange:(id)sender {
    if (self.currPwd.text == nil || self.currPwd.text.length ==0) {
        [self.utils showErrorMessage:self.errorView contView:self.errorLabel errorLabel:@"Please enter current password"];
    }else if (self.nPassword.text == nil || self.nPassword.text.length ==0) {
        [self.utils showErrorMessage:self.errorView contView:self.errorLabel errorLabel:@"Please enter new password"];
    } else if (self.confPwd.text == nil || self.confPwd.text.length ==0) {
        [self.utils showErrorMessage:self.errorView contView:self.errorLabel errorLabel:@"Please confirm your password"];
    }else if (![self.nPassword.text isEqual:self.confPwd.text]) {
        [self.utils showErrorMessage:self.errorView contView:self.errorLabel errorLabel:@"Your password does not match with confirm password"];
    }else if (![self.currPwd.text isEqual:[self.utils decode:self.userModel.password]]) {
        [self.utils showErrorMessage:self.errorView contView:self.errorLabel errorLabel:@"Current password is incorrect"];
    }else{
        WnPUserDAO *userDao=[[WnPUserDAO alloc]init];
        self.userModel.password=[self.utils encode:self.nPassword.text];
        @try {
            self.userModel= [userDao updateUser:self.userModel];
            [self.wnpCont setUserModel:self.userModel];
            self.parentViewController.view.backgroundColor=[UIColor whiteColor];
            for(UIView *subViews in [self.parentViewController.view subviews]){
                subViews.alpha=1.0;
                [subViews setUserInteractionEnabled:YES];
            }
            [self.view removeFromSuperview];
           
            UIStoryboard *stryBrd = [UIStoryboard storyboardWithName:@"MenuController" bundle:nil];
            MenuController *viewCtrl=[stryBrd instantiateViewControllerWithIdentifier:@"MenuController"];
            if(viewCtrl != nil){
                viewCtrl.loadScanpopup =YES;
                viewCtrl.modalTransitionStyle=UIModalTransitionStyleFlipHorizontal;
                viewCtrl.viewName=@"Name";
                [self presentViewController:viewCtrl animated:YES completion:nil];
            }
             [self removeFromParentViewController];
        }
        @catch (NSException *exception) {
            [self.utils showErrorMessage:self.errorView contView:self.errorLabel errorLabel:exception.description];
        }
       
       
        
    }
    
    
    
}
@end
