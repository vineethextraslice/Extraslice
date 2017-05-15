//
//  SignupController.m
//  WalkNPay
//
//  Created by Irshad on 12/8/15.
//  Copyright © 2015 extraslice. All rights reserved.
//

#import "SignupController.h"
#import "NSString+AESCrypt.h"
#include <CommonCrypto/CommonDigest.h>
#include <CommonCrypto/CommonHMAC.h>
#import "WnPWebServiceDAO.h"
#import "WnPConstants.h"
#import "WnPUtilities.h"
#import "WnPUserModel.h"
#import "WnPUserDAO.h"
@interface SignupController ()
@property(nonatomic) BOOL tcChecked;
@property(strong,nonatomic) WnPConstants *wnpCont;

@end

@implementation SignupController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.wnpCont=[[WnPConstants alloc]init];
    self.signupBtn.backgroundColor=[self.wnpCont getThemeBaseColor];
    self.cancelBtn.backgroundColor=[self.wnpCont getThemeBaseColor];
    self.utils = [[WnPUtilities alloc]init];
    self.tcChecked=FALSE;
    NSDictionary *underlineAttribute = @{NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle)};
    self.tcLabel.attributedText = [[NSAttributedString alloc] initWithString:@"Terms and Conditions" attributes:underlineAttribute];
    
    UITapGestureRecognizer *tcLabelTap = [[UITapGestureRecognizer alloc] initWithTarget:self action: @selector(showTC:)];
    tcLabelTap.numberOfTapsRequired = 1;
    tcLabelTap.numberOfTouchesRequired = 1;
    [self.tcLabel setUserInteractionEnabled:YES];
    [self.tcLabel addGestureRecognizer:tcLabelTap];
    
    UITapGestureRecognizer *tcCheckTap = [[UITapGestureRecognizer alloc] initWithTarget:self action: @selector(checkTC:)];
    tcCheckTap.numberOfTapsRequired = 1;
    tcCheckTap.numberOfTouchesRequired = 1;
    [self.tcCheckbox setUserInteractionEnabled:YES];
    [self.tcCheckbox addGestureRecognizer:tcCheckTap];
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

- (void) createUser {
   
    WnPUserModel *userModel =[[WnPUserModel alloc] init];
    WnPUserDAO *userDAO = [[WnPUserDAO alloc]init];
    @try {
        userModel = [userDAO createUser:self.email.text Password:self.password.text];
        UIAlertAction *alert = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        UIAlertController *controller = [UIAlertController alertControllerWithTitle:nil message:@"Successful. Please use the verification code sent to your email for login" preferredStyle:UIAlertControllerStyleAlert];
        [controller addAction:alert];
        [self presentViewController:controller animated:YES completion:nil];
    }
    @catch (NSException *exception) {
        NSLog(@"Caught exception %@", exception);
        //[self.utils showErrorMessage:self.errorLyt contView:self.errorLabel errorLabel:exception.reason];
        self.errorLabel.text=exception.reason;
    }
    
}

- (IBAction)signUp:(id)sender {
    if (self.email.text == nil || self.email.text.length ==0) {
         [self.utils showErrorMessage:self.errorView contView:self.errorLabel errorLabel:@"Please enter a valid email"];
    }else if (self.password.text == nil || self.password.text.length ==0) {
        [self.utils showErrorMessage:self.errorView contView:self.errorLabel errorLabel:@"Please enter a valid email"];
    } else if (self.confPassword.text == nil || self.confPassword.text.length ==0) {
        [self.utils showErrorMessage:self.errorView contView:self.errorLabel errorLabel:@"Please confirm your password"];
    }else if (![self.password.text isEqual:self.confPassword.text]) {
        [self.utils showErrorMessage:self.errorView contView:self.errorLabel errorLabel:@"Your password does not match with confirm password"];
    }else if (!self.tcChecked) {
        [self.utils showErrorMessage:self.errorView contView:self.errorLabel errorLabel:@"Please accept terms and conditions"];
    }else{
        [self createUser];
    }
}

- (IBAction)cancelSignup:(id)UIG {
    
    UIStoryboard *stryBrd = [UIStoryboard storyboardWithName:@"LoginScreen" bundle:nil];
    UIViewController *viewCtrl=[stryBrd instantiateViewControllerWithIdentifier:@"LoginScreen"];
    if(viewCtrl != nil){
        viewCtrl.modalTransitionStyle=UIModalTransitionStyleFlipHorizontal;
        [self presentViewController:viewCtrl animated:YES completion:nil];
    }
}

- (void)showTC:(UITapGestureRecognizer *) rec{
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, screenRect.size.width, screenRect.size.height)];
 
    webView.tag=55;
    NSURL *url = [NSURL URLWithString:@"http://walknpaydev01.cloudapp.net:8181/privacy/privacy.html"];
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
    [webView loadRequest:requestObj];
    [self.view addSubview:webView];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button addTarget:self
               action:@selector(closeTC:)
     forControlEvents:UIControlEventTouchDown];
    [button setTitle:@"Close" forState:UIControlStateNormal];
    button.frame = CGRectMake(((screenRect.size.width/2)-55), 30, 110, 30);
    [button addTarget:self action:@selector(closeTC:) forControlEvents:UIControlEventTouchUpInside];
    button.backgroundColor=[self.wnpCont getThemeBaseColor];
    [webView addSubview:button];
    
}

- (void)checkTC:(UITapGestureRecognizer *) rec{
    if(self.tcChecked){
        self.tcChecked=FALSE;
        [self.tcCheckbox setImage:[UIImage imageNamed:@"checkbox_unsel.png"]];
    }else{
        self.tcChecked=TRUE;
         [self.tcCheckbox setImage:[UIImage imageNamed:@"checkbox_sel.png"]];
    }
    
}
- (void)closeTC:(UITapGestureRecognizer *) rec{
    
     [[self.view viewWithTag:55] removeFromSuperview];
}
- (void)hideKeyBoard:(UITapGestureRecognizer *) rec{
    [self.view endEditing:YES];
}



@end
