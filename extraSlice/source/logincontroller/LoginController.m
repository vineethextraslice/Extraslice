//
//  ViewController.m
//  extraSlice
//
//  Created by Administrator on 19/06/16.
//  Copyright © 2016 Extraslice Inc. All rights reserved.
//

#import "LoginController.h"
#import "SelectPlanController.h"
#import "Utilities.h"
#import "UserModel.h"
#import "UserDAO.h"
#import "WnPConstants.h"
#import "MenuController.h"
#import "ResetPwdController.h"

@interface LoginController ()
@property(strong,nonatomic) Utilities *utils;
@property(strong,nonatomic) WnPConstants *wnpCont;
@property(nonatomic) BOOL rmChecked;
@property(nonatomic,strong) UIView *popup;
@property(nonatomic,strong) UILabel *popupError;
@property(nonatomic,strong) UITextField *vrify;
@property(nonatomic,strong) UITextField *nePassword;
@property(nonatomic,strong) UITextField *confnePassword;
@property(nonatomic,strong) UserDAO *userDAO;


@end

@implementation LoginController

- (void)viewDidLoad {
    [super viewDidLoad];
     self.wnpCont = [[WnPConstants alloc]init];
     self.userDAO = [[UserDAO alloc]init];
     [self.wnpCont setColor:0];
    self.errorLyt.hidden = true;
    self.utils=[[Utilities alloc]init];
    self.password.delegate =self;
    self.email.delegate =self;
    self.errorLytHeight.constant = 0;
        
    UITapGestureRecognizer *signUpTap = [[UITapGestureRecognizer alloc] initWithTarget:self action: @selector(selectPlans:)];
    signUpTap.numberOfTapsRequired = 1;
    signUpTap.numberOfTouchesRequired = 1;
    [self.signUp setUserInteractionEnabled:YES];
    [self.signUp addGestureRecognizer:signUpTap];
    UITapGestureRecognizer *tcCheckTap = [[UITapGestureRecognizer alloc] initWithTarget:self action: @selector(checkTC:)];
    tcCheckTap.numberOfTapsRequired = 1;
    tcCheckTap.numberOfTouchesRequired = 1;
    [self.rememberMe setUserInteractionEnabled:YES];
    [self.rememberMe addGestureRecognizer:tcCheckTap];
    UITapGestureRecognizer *resetPwdTap = [[UITapGestureRecognizer alloc] initWithTarget:self action: @selector(resetPassword:)];
    resetPwdTap.numberOfTapsRequired = 1;
    resetPwdTap.numberOfTouchesRequired = 1;
    [self.forgotPwd setUserInteractionEnabled:YES];
    [self.forgotPwd addGestureRecognizer:resetPwdTap];
     //  [self.utils showTextOnKeyBoard:self.password];
   // [self.utils showTextOnKeyBoard:self.email];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    self.rmChecked=[userDefaults boolForKey:@"Remember"];
    if(self.rmChecked){
        [self.rememberMe setImage:[UIImage imageNamed:@"checkbox_sel.png"]];
        NSString *uName=[userDefaults stringForKey:@"userName"];
        NSString *pwd=[userDefaults stringForKey:@"password"];
        if(uName != nil){
            self.email.text=uName;
        }
        if(pwd != nil){
            self.password.text=[self.utils decode:pwd];
                [self.view endEditing:YES];
        }
    }else{
        [self.rememberMe setImage:[UIImage imageNamed:@"checkbox_unsel.png"]];
       // [self.email becomeFirstResponder];
                        
    }
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}
-(void)textFieldDidBeginEditing:(UITextField *)textField{
    UIImage *blueBGImg = [UIImage imageNamed:@"edt_bg_blue.png"];
    textField.background = blueBGImg;
    [self.utils setViewMovedUp:YES ParentView:self.view CurrTextView:textField];
}
-(void) textFieldDidEndEditing:(UITextField *)textField{
   [self.utils setViewMovedUp:NO ParentView:self.view CurrTextView:textField];
    UIImage *blueBGImg = [UIImage imageNamed:@"edt_bg_grey.png"];
    textField.background = blueBGImg;
    
}

- (void)checkTC:(UITapGestureRecognizer *) rec{
    if(self.rmChecked){
        self.rmChecked=FALSE;
        [self.rememberMe setImage:[UIImage imageNamed:@"checkbox_unsel.png"]];
    }else{
        self.rmChecked=TRUE;
        [self.rememberMe setImage:[UIImage imageNamed:@"checkbox_sel.png"]];
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)verifyAndLogin:(id)sender {
    self.errorText.text= @"";
    self.errorLyt.hidden = true;
    self.errorLytHeight.constant = 0;
    if (self.email.text == nil || self.email.text.length ==0) {
      self.errorText.text= @"Please enter a valid email";
      self.errorLyt.hidden = false;
         self.errorLytHeight.constant = 30;
    }else if (self.password.text == nil || self.password.text.length ==0) {
        self.errorText.text= @"Please enter a valid password";
        self.errorLyt.hidden = false;
        self.errorLytHeight.constant = 30;
    } else{
        [self getUser];
    }
}
- (void)getUser
{
    //dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *error = nil;
        UserModel *userMdel = nil;
        NSString *userName = self.email.text;
        NSString *password = self.password.text;
        /*UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        CGAffineTransform transform = CGAffineTransformMakeScale(2.0f, 2.0f);
        indicator.transform = transform;
        indicator.frame = CGRectMake(0.0, 0.0, 80.0, 80.0);
        indicator.center = self.view.center;
        [self.view addSubview:indicator];
        [indicator bringSubviewToFront:self.view];*/
       
       
        //[indicator startAnimating];
        @try{
            userMdel = [self.userDAO getUser:userName Password:password];
        }@catch(NSException *exp){
            error= exp.description;
        }

        //dispatch_async(dispatch_get_main_queue(), ^{
           // [indicator stopAnimating];
            if(error != nil){
                self.errorLytHeight.constant = 30;
                self.errorText.text= error;
                self.errorLyt.hidden = false;
            }else{
                if(userMdel != nil){
                    [self.utils setLoggedinUser:userMdel];
                    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                    [userDefaults setBool:self.rmChecked forKey:@"Remember"];
                    if(self.rmChecked){
                        [userDefaults setObject:userMdel.userName forKey:@"userName"];
                        [userDefaults setObject:userMdel.password forKey:@"password"];
                    }
                    if(userMdel.verificationCode != (id)[NSNull null] && userMdel.verificationCode != nil && userMdel.verificationCode.length>0){
                        [self showVerificationPopup];
                    }else if(userMdel.usingTempPwd){
                        [self showPasswordChangePopup];
                    }else{
                        UIStoryboard *stryBrd = [UIStoryboard storyboardWithName:@"MenuController" bundle:nil];
                        MenuController *viewCtrl=[stryBrd instantiateViewControllerWithIdentifier:@"MenuController"];
                        if(viewCtrl != nil){
                            viewCtrl.viewName=@"Home";
                            viewCtrl.modalTransitionStyle=UIModalTransitionStyleCoverVertical;
                            [self.utils loadViewControlleWithAnimation:self NextController:viewCtrl];
                        }
                    }
                }

            }
       // });
    //});
}


- (void)selectPlans:(UITapGestureRecognizer *) rec{
    UIStoryboard *stryBrd = [UIStoryboard storyboardWithName:@"SelectPlan" bundle:nil];
    SelectPlanController *viewCtrl=[stryBrd instantiateViewControllerWithIdentifier:@"SelectPlan"];
    [self.utils loadViewControlleWithAnimation:self NextController:viewCtrl];
}

- (void)resetPassword:(UITapGestureRecognizer *) rec{
    UIStoryboard *stryBrd = [UIStoryboard storyboardWithName:@"ResetPwd" bundle:nil];
    ResetPwdController *viewCtrl=[stryBrd instantiateViewControllerWithIdentifier:@"ResetPwd"];
    [self.utils loadViewControlleWithAnimation:self NextController:viewCtrl];
}

-(void) showPasswordChangePopup
{
    //self.crtOrgError.text=@"";
    //self.crtOrgError.hidden=true;
    
    self.view.backgroundColor=[UIColor grayColor];
    for(UIView *subViews in [self.view subviews]){
        subViews.alpha=0.2;
        subViews.userInteractionEnabled=false;
    }
    float centerX = self.view.center.x;
    float centerY = self.view.center.y;
    
    self.view.userInteractionEnabled=false;
    self.popup=[[UIView alloc] initWithFrame:CGRectMake(centerX-135,centerY-115,270,230)];
    self.popup.backgroundColor = [UIColor whiteColor];
    self.popup.layer.borderColor = [self.wnpCont getThemeBaseColor].CGColor;
    self.popup.layer.borderWidth = 1.0f;
    self.popup.alpha=1.0;
    //  [self.view addSubview:self.crtOrgPopup];
    [[UIApplication sharedApplication].keyWindow addSubview:self.popup];
    
    UILabel *headerLbl =[[UILabel alloc] initWithFrame:CGRectMake(0,0,270,35)];
    headerLbl.text=@"Change password";
    headerLbl.textAlignment=NSTextAlignmentCenter;
    UIFont *txtFont = [headerLbl.font fontWithSize:fontSize];
    headerLbl.font = txtFont;
    headerLbl.textColor=[UIColor whiteColor];
    headerLbl.backgroundColor=[self.wnpCont getThemeBaseColor];
    [self.popup addSubview:headerLbl];
    
    self.popupError = [[UILabel alloc] initWithFrame:CGRectMake(35, 37 , 200, 55)];
    self.popupError.hidden=true;
    self.popupError.numberOfLines=-1;
    self.popupError.textAlignment=NSTextAlignmentCenter;
    [self.popup addSubview: self.popupError];
    
    self.nePassword =[[UITextField alloc] initWithFrame:CGRectMake(35,95,200,30)];
    self.nePassword.placeholder=@"New Password";
    self.nePassword.secureTextEntry=true;
    self.nePassword.textAlignment=NSTextAlignmentCenter;
    self.nePassword.textColor=[UIColor blackColor];
    self.nePassword.background=[UIImage imageNamed:@"edt_bg_grey.png"];
    [self.popup addSubview:self.nePassword];
    
    self.confnePassword =[[UITextField alloc] initWithFrame:CGRectMake(35,140,200,30)];
    self.confnePassword.placeholder=@"Confirm Password";
    self.confnePassword.secureTextEntry=true;
    self.confnePassword.textAlignment=NSTextAlignmentCenter;
    self.confnePassword.textColor=[UIColor blackColor];
    self.confnePassword.background=[UIImage imageNamed:@"edt_bg_grey.png"];
    [self.popup addSubview:self.confnePassword];
    self.nePassword.delegate=self;
    self.confnePassword.delegate=self;
    UIButton *submitBtn = [[UIButton alloc] initWithFrame:CGRectMake(85,185,100,30)];
    submitBtn.backgroundColor=[UIColor grayColor];
    [submitBtn setTitle: @"Submit" forState: UIControlStateNormal];
    submitBtn.userInteractionEnabled=TRUE;
    [submitBtn addTarget:self action:@selector(changePassword:) forControlEvents: UIControlEventTouchUpInside];
    [self.popup addSubview:submitBtn];
    submitBtn.backgroundColor=[self.wnpCont getThemeBaseColor];
    
    UITapGestureRecognizer *viewTap = [[UITapGestureRecognizer alloc] initWithTarget:self action: @selector(hideKeyBord)];
    viewTap.numberOfTapsRequired = 1;
    viewTap.numberOfTouchesRequired = 1;
    [self.self.popup setUserInteractionEnabled:YES];
    [self.self.popup addGestureRecognizer:viewTap];
}
-(void) showVerificationPopup
{
    //self.crtOrgError.text=@"";
    //self.crtOrgError.hidden=true;
    
    self.view.backgroundColor=[UIColor grayColor];
    for(UIView *subViews in [self.view subviews]){
        subViews.alpha=0.2;
        subViews.userInteractionEnabled=false;
    }
    float centerX = self.view.center.x;
    float centerY = self.view.center.y;
    
    self.view.userInteractionEnabled=false;
    self.popup=[[UIView alloc] initWithFrame:CGRectMake(centerX-135,centerY-115,270,230)];
    self.popup.backgroundColor = [UIColor whiteColor];
    self.popup.layer.borderColor = [self.wnpCont getThemeBaseColor].CGColor;
    self.popup.layer.borderWidth = 1.0f;
    self.popup.alpha=1.0;
    //  [self.view addSubview:self.crtOrgPopup];
    [[UIApplication sharedApplication].keyWindow addSubview:self.popup];
    
    UILabel *headerLbl =[[UILabel alloc] initWithFrame:CGRectMake(0,0,270,35)];
    headerLbl.text=@"Verfication code";
    headerLbl.textAlignment=NSTextAlignmentCenter;
    UIFont *txtFont = [headerLbl.font fontWithSize:fontSize];
    headerLbl.font = txtFont;
    headerLbl.textColor=[UIColor whiteColor];
    headerLbl.backgroundColor=[self.wnpCont getThemeBaseColor];
    [self.popup addSubview:headerLbl];
    
    self.popupError = [[UILabel alloc] initWithFrame:CGRectMake(35, 37 , 200, 55)];
    self.popupError.hidden=true;
    self.popupError.numberOfLines=-1;
    self.popupError.textColor=[UIColor redColor];
    self.popupError.textAlignment=NSTextAlignmentCenter;
    [self.popup addSubview: self.popupError];
    
    self.vrify =[[UITextField alloc] initWithFrame:CGRectMake(35,95,200,30)];
    self.vrify.placeholder=@"Verification code";
    self.vrify.textAlignment=NSTextAlignmentCenter;
    self.vrify.textColor=[UIColor blackColor];
    [self.popup addSubview:self.vrify];
    
    UILabel *resend =[[UILabel alloc] initWithFrame:CGRectMake(35,140,200,30)];
    resend.text=@"Resend verification code";
    resend.textAlignment=NSTextAlignmentCenter;
    resend.textColor=[self.wnpCont getThemeBaseColor];
    self.vrify.background=[UIImage imageNamed:@"edt_bg_grey.png"];
    
    [self.popup addSubview:resend];
    self.vrify.delegate=self;
    UIButton *submitBtn = [[UIButton alloc] initWithFrame:CGRectMake(85,185,100,30)];
    submitBtn.backgroundColor=[UIColor grayColor];
    [submitBtn setTitle: @"Submit" forState: UIControlStateNormal];
    submitBtn.userInteractionEnabled=TRUE;
    [submitBtn addTarget:self action:@selector(updateVerificationCode:) forControlEvents: UIControlEventTouchUpInside];
    [self.popup addSubview:submitBtn];
    submitBtn.backgroundColor=[self.wnpCont getThemeBaseColor];
    
    UITapGestureRecognizer *viewTap = [[UITapGestureRecognizer alloc] initWithTarget:self action: @selector(hideKeyBord)];
    viewTap.numberOfTapsRequired = 1;
    viewTap.numberOfTouchesRequired = 1;
    [self.popup setUserInteractionEnabled:YES];
    [self.popup addGestureRecognizer:viewTap];
    
    UITapGestureRecognizer *resentTap = [[UITapGestureRecognizer alloc] initWithTarget:self action: @selector(resendVerificationCode:)];
    resentTap.numberOfTapsRequired = 1;
    resentTap.numberOfTouchesRequired = 1;
    [resend setUserInteractionEnabled:YES];
    [resend addGestureRecognizer:resentTap];
}
-(void)changePassword:(id)sender{
    self.popupError.textColor=[UIColor redColor];
    if(self.nePassword.text == nil || self.nePassword.text.length==0){
        self.popupError.text=@"Please enter new password";
        self.popupError.hidden=false;
    }else if(self.confnePassword.text == nil || self.confnePassword.text.length==0){
        self.popupError.text=@"Please confirm new password";
        self.popupError.hidden=false;
    }else if([self.confnePassword.text isEqualToString: self.nePassword.text]){
        [self.utils getLoggedinUser].password=[self.utils encode:self.nePassword.text];
        [self updateUser];
    }else{
        self.popupError.text=@"Password does not match with confirm password";
        self.popupError.hidden=false;
    }
    
}

- (void)updateUser
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *error = nil;
        UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        CGAffineTransform transform = CGAffineTransformMakeScale(2.0f, 2.0f);
        indicator.transform = transform;
        indicator.frame = CGRectMake(0.0, 0.0, 80.0, 80.0);
        indicator.center = self.view.center;
        [self.view addSubview:indicator];
        [indicator bringSubviewToFront:self.view];
        [indicator startAnimating];
        @try{
            [self.userDAO updateUser:[self.utils getLoggedinUser]];
        }@catch(NSException *exp){
            error= exp.description;
        }

        
        dispatch_async(dispatch_get_main_queue(), ^{
            [indicator stopAnimating];
            if(error != nil){
                self.popupError.text= error;
                self.popupError.hidden = false;
            }else{
                UIStoryboard *stryBrd = [UIStoryboard storyboardWithName:@"MenuController" bundle:nil];
                MenuController *viewCtrl=[stryBrd instantiateViewControllerWithIdentifier:@"MenuController"];
                [self.popup removeFromSuperview];
                for(UIView *subViews in self.view.subviews){
                    subViews.alpha=1.0;
                    subViews.userInteractionEnabled=TRUE;
                }
                self.view.alpha=1.0;
                self.view.userInteractionEnabled=TRUE;
                self.view.backgroundColor = [UIColor whiteColor];
                if(viewCtrl != nil){
                    viewCtrl.viewName=@"Home";
                    viewCtrl.modalTransitionStyle=UIModalTransitionStyleCoverVertical;
                    [self.utils loadViewControlleWithAnimation:self NextController:viewCtrl];
                }
            }
        });
    });
}

-(void)updateVerificationCode:(id)sender{
    self.popupError.textColor=[UIColor redColor];
    if(self.vrify.text == nil || self.vrify.text.length==0){
        self.popupError.text=@"Please enter verifiction code";
        self.popupError.hidden=false;
    }else if([self.vrify.text isEqualToString: [self.utils getLoggedinUser].verificationCode]){
        [self.utils getLoggedinUser].verificationCode=@"";
        [self updateUser];
    }else{
        self.popupError.text=@"Verification code does not match";
        self.popupError.hidden=false;
    }
    
}
- (void)resendVerificationCode:(UITapGestureRecognizer *) rec{
    self.popupError.textColor=[UIColor redColor];
    @try{
        [self resendVerificationCodeBg];
    }@catch(NSException *exp){
        self.popupError.text= exp.description;
        self.popupError.hidden = false;
    }
}

- (void)resendVerificationCodeBg
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *error = nil;
        UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        CGAffineTransform transform = CGAffineTransformMakeScale(2.0f, 2.0f);
        indicator.transform = transform;
        indicator.frame = CGRectMake(0.0, 0.0, 80.0, 80.0);
        indicator.center = self.view.center;
        [self.view addSubview:indicator];
        [indicator bringSubviewToFront:self.view];
        [indicator startAnimating];
        @try{
            [self.userDAO resendVericationCode:[self.utils getLoggedinUser]];
        }@catch(NSException *exp){
            error= exp.description;
        }
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [indicator stopAnimating];
            if(error != nil){
                self.popupError.text= error;
                self.popupError.hidden = false;
            }else{
                self.popupError.textColor=[UIColor blueColor];
                self.popupError.text=@"New verification code send to you email";
                [self.popup removeFromSuperview];
                for(UIView *subViews in self.view.subviews){
                    subViews.alpha=1.0;
                    subViews.userInteractionEnabled=TRUE;
                }
                self.view.alpha=1.0;
                self.view.userInteractionEnabled=TRUE;
                self.view.backgroundColor = [UIColor whiteColor];            }
        });
    });
}

-(void) hideKeyBord{
    [self.view endEditing:YES];
}
/*
-(void) spinActivityIndicator:(BOOL)isLoading{
    if(isLoading){
        [self.view bringSubviewToFront:self.loading];
        [self.loading startAnimating];
    }else{
        [self.loading stopAnimating];
    }
}*/

@end
