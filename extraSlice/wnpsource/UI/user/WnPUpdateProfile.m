//
//  UpdateProfile.m
//  walkNPay
//
//  Created by Administrator on 28/01/16.
//  Copyright © 2016 Extraslice Inc. All rights reserved.
//

#import "WnPUpdateProfile.h"
#import "WnPConstants.h"
#import "WnPUtilities.h"
#import "WnPUserDAO.h"
#import "MenuController.h"
@interface WnPUpdateProfile ()
@property (strong,nonatomic) WnPConstants *wnpCont;
@property(strong,nonatomic) WnPUtilities *utils;
@end

@implementation WnPUpdateProfile

- (void)viewDidLoad {
    self.wnpCont=[[WnPConstants alloc]init];
    self.utils=[[WnPUtilities alloc]init];
    [super viewDidLoad];
    self.header.backgroundColor=[self.wnpCont getThemeBaseColor];
    self.cancelBtn.backgroundColor=[self.wnpCont getThemeBaseColor];
    self.sumbitBtn.backgroundColor=[self.wnpCont getThemeBaseColor];
    self.header.backgroundColor=[self.wnpCont getThemeBaseColor];
    [self.view setBounds:CGRectMake(0,0, 270,390)];
    self.view.layer.borderColor= [self.wnpCont getThemeBaseColor].CGColor;
    self.view.layer.borderWidth = 1.0f;
    self.userModel=[self.wnpCont getUserModel];
    NSLog(@"%@",((self.userModel.lastName == NULL) ? @"ddd" : self.userModel.lastName));
  
    self.lastName.text= (self.userModel.lastName == (id)[NSNull null]) ? @"" : self.userModel.lastName;
    self.firstName.text=(self.userModel.firstName == (id)[NSNull null]) ? @"" : self.userModel.firstName;;
    self.addr1.text=(self.userModel.addressLine1 == (id)[NSNull null]) ? @"" : self.userModel.addressLine1;
    self.addr2.text=(self.userModel.addressLine2 == (id)[NSNull null]) ? @"" : self.userModel.addressLine2;
    self.addr3.text=(self.userModel.addressLine3 == (id)[NSNull null]) ? @"" : self.userModel.addressLine3;
    self.zip.text=(self.userModel.zip == (id)[NSNull null]) ? @"" : self.userModel.zip;
    self.state.text=(self.userModel.state == (id)[NSNull null]) ? @"" : self.userModel.state;

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

- (IBAction)submitChanges:(id)sender {
    WnPUserDAO *userDao=[[WnPUserDAO alloc]init];
    self.userModel.lastName=self.lastName.text;
    self.userModel.firstName=self.firstName.text;
    self.userModel.addressLine1=self.addr1.text;
    self.userModel.addressLine2=self.addr2.text;
    self.userModel.addressLine3=self.addr3.text;
    self.userModel.zip=self.zip.text;
    self.userModel.state=self.state.text;
    
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
- (IBAction)cancelPopup:(id)sender {
    self.parentViewController.view.backgroundColor=[UIColor whiteColor];
    for(UIView *subViews in [self.parentViewController.view subviews]){
        subViews.alpha=1.0;
        [subViews setUserInteractionEnabled:YES];
    }
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
}

- (void)hideKeyBoard:(UITapGestureRecognizer *) rec{
    [self.view endEditing:YES];
}
@end
