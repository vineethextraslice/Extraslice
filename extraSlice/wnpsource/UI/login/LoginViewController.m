//
//  ViewController.m
//  WalkNPay
//
//  Created by Irshad on 11/17/15.
//  Copyright © 2015 extraslice. All rights reserved.
//

#import "LoginViewController.h"
#import "MenuController.h"
#import "NSString+AESCrypt.h"
#include <CommonCrypto/CommonDigest.h>
#include <CommonCrypto/CommonHMAC.h>
#import "WnPWebServiceDAO.h"
#import "WnPConstants.h"
#import "WnPUtilities.h"
#import "WnPUserDAO.h"
#import "StoreDAO.h"
@interface LoginViewController ()
@property(strong,nonatomic) WnPConstants *wnpCont;
@property(nonatomic) BOOL rmChecked;
@property (nonatomic,strong) UILabel *lbl;
@end

@implementation LoginViewController

- (void) viewDidLoad {
    
    [super viewDidLoad];
    
    self.utils= [[WnPUtilities alloc] init];
   
    self.wnpCont=[[WnPConstants alloc]init];
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.distanceFilter = kCLDistanceFilterNone;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0){
        [self.locationManager requestWhenInUseAuthorization];
    }
    [self.locationManager startUpdatingLocation];

    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    int colorIndes = (int)[userDefaults integerForKey:@"theme"];
    self.rmChecked=[userDefaults boolForKey:@"Remember"];
    [self.remView bringSubviewToFront:self.remmbMe];
    
    UITapGestureRecognizer *tcCheckTap = [[UITapGestureRecognizer alloc] initWithTarget:self action: @selector(checkTC:)];
    tcCheckTap.numberOfTapsRequired = 1;
    tcCheckTap.numberOfTouchesRequired = 1;
    [self.remmbMe setUserInteractionEnabled:YES];
    [self.remmbMe addGestureRecognizer:tcCheckTap];
    
    UITapGestureRecognizer *tcViewTap = [[UITapGestureRecognizer alloc] initWithTarget:self action: @selector(checkTC:)];
    tcViewTap.numberOfTapsRequired = 1;
    tcViewTap.numberOfTouchesRequired = 1;
    [self.remView setUserInteractionEnabled:YES];
    [self.remView addGestureRecognizer:tcViewTap];
    
    
   
    
    [self.wnpCont setColor:colorIndes];
    [[UITextField appearance] setTintColor:[UIColor blackColor]];
    
    
    UITapGestureRecognizer *viewTap = [[UITapGestureRecognizer alloc] initWithTarget:self action: @selector(hideKeyBoard:)];
    viewTap.numberOfTapsRequired = 1;
    viewTap.numberOfTouchesRequired = 1;
    [self.view setUserInteractionEnabled:YES];
    [self.view addGestureRecognizer:viewTap];
    
    self.loginBtn.backgroundColor=[self.wnpCont getThemeBaseColor];
    self.emailValue.layer.borderColor = [self.wnpCont getThemeBaseColor].CGColor;
    self.emailValue.layer.borderWidth = 1.0f;
    self.passwordValue.layer.borderColor = [self.wnpCont getThemeBaseColor].CGColor;
    self.passwordValue.layer.borderWidth = 1.0f;
    self.headerView.backgroundColor=[self.wnpCont getThemeBaseColor];
    
    self.vLogin.backgroundColor=[self.wnpCont getThemeBaseColor];
    self.vCancel.backgroundColor=[self.wnpCont getThemeBaseColor];
    self.vEmail.layer.borderColor = [self.wnpCont getThemeBaseColor].CGColor;
    self.vEmail.layer.borderWidth = 1.0f;
    self.vPassword.layer.borderColor = [self.wnpCont getThemeBaseColor].CGColor;
    self.vPassword.layer.borderWidth = 1.0f;
    self.vVerifCode.layer.borderColor = [self.wnpCont getThemeBaseColor].CGColor;
    self.vVerifCode.layer.borderWidth = 1.0f;
    
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
    
    NSDictionary *underlineAttribute = @{NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle)};
    self.forgotPwd.attributedText = [[NSAttributedString alloc] initWithString:@"Forgot Password?"
                                                             attributes:underlineAttribute];
    NSDictionary *underlineAttribute1 = @{NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle)};
    self.signup.attributedText = [[NSAttributedString alloc] initWithString:@"Sign Up"
                                                                    attributes:underlineAttribute1];
    
    NSDictionary *resVerCode = @{NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle)};
    self.vResendvCode.attributedText = [[NSAttributedString alloc] initWithString:@"Resend verification code"
                                                                 attributes:resVerCode];

    self.forgotPwd.textColor=[self.wnpCont getThemeBaseColor];
    self.signup.textColor=[self.wnpCont getThemeBaseColor];
    self.vResendvCode.textColor=[self.wnpCont getThemeBaseColor];
    self.orText.textColor=[self.wnpCont getThemeBaseColor];
    
    UITapGestureRecognizer *frgtPwdUrl = [[UITapGestureRecognizer alloc] initWithTarget:self action: @selector(tapDetected:)];
    frgtPwdUrl.numberOfTapsRequired = 1;
    frgtPwdUrl.numberOfTouchesRequired = 1;
    [self.forgotPwd setUserInteractionEnabled:YES];
    [self.forgotPwd addGestureRecognizer:frgtPwdUrl];
    
    UITapGestureRecognizer *signupTap = [[UITapGestureRecognizer alloc] initWithTarget:self action: @selector(tapDetected:)];
    signupTap.numberOfTapsRequired = 1;
    signupTap.numberOfTouchesRequired = 1;
    [self.signup setUserInteractionEnabled:YES];
    [self.signup addGestureRecognizer:signupTap];
    
    UITapGestureRecognizer *tapResendVCode = [[UITapGestureRecognizer alloc] initWithTarget:self action: @selector(tapDetected:)];
    tapResendVCode.numberOfTapsRequired = 1;
    tapResendVCode.numberOfTouchesRequired = 1;
    [self.vResendvCode setUserInteractionEnabled:YES];
    [self.vResendvCode addGestureRecognizer:tapResendVCode];
    
   
    
    if(self.userModel != nil){
        self.vEmail.text=self.userModel.email;
        self.vPassword.text=[self.utils decode:self.userModel.password];
    }
    if(self.rmChecked){
        [self.remmbMe setImage:[UIImage imageNamed:@"checkbox_sel.png"]];
        NSString *uName=[userDefaults stringForKey:@"userName"];
        NSString *pwd=[userDefaults stringForKey:@"password"];
        if(uName != nil){
            self.emailValue.text=uName;
        }
        if(pwd != nil){
            self.passwordValue.text=[self.utils decode:pwd];
            [self.view endEditing:YES];
        }
    }else{
        [self.remmbMe setImage:[UIImage imageNamed:@"checkbox_unsel.png"]];
        [self.emailValue becomeFirstResponder];
    }
    UIToolbar *keyboardDoneButtonView = [[UIToolbar alloc] init];
    [keyboardDoneButtonView sizeToFit];
    keyboardDoneButtonView.backgroundColor=[UIColor grayColor];
   /* UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStylePlain target:self action:@selector(hideKeyBoard:)];
    [keyboardDoneButtonView setItems:[NSArray arrayWithObjects:doneButton, nil]];*/
   
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat tableWidth = screenRect.size.width-8;
    self.lbl=[[UILabel alloc] initWithFrame:CGRectMake(10, 5 , tableWidth-70, 30)];
    self.lbl.textColor = [UIColor blackColor];
    self.lbl.text=self.vVerifCode.text;
    self.lbl.layer.cornerRadius=3;
    self.lbl.backgroundColor=[UIColor whiteColor];
    self.lbl.layer.borderColor = [self.wnpCont getThemeBaseColor].CGColor;
    self.lbl.layer.borderWidth = 1.0f;

    [self.vVerifCode addTarget:self action:@selector(editQuantity:) forControlEvents: UIControlEventAllEditingEvents] ;
    [keyboardDoneButtonView addSubview:self.lbl];
   // NSDictionary *doneUndLined = @{NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle)};
    UILabel *doneBtn=[[UILabel alloc] initWithFrame:CGRectMake((tableWidth-50), 2 , 50, 30)];
    doneBtn.text = @"Done";
   
    
    
    doneBtn.textColor=[self.wnpCont getThemeBaseColor];
    
    UITapGestureRecognizer *doneRec = [[UITapGestureRecognizer alloc] initWithTarget:self action: @selector(hideKeyBoard:)];
    doneRec.numberOfTapsRequired = 1;
    doneRec.numberOfTouchesRequired = 1;
    [doneBtn setUserInteractionEnabled:YES];
    [doneBtn addGestureRecognizer:doneRec];
    [keyboardDoneButtonView addSubview:doneBtn];
   /* UIButton *goBtn = [[UIButton alloc] initWithFrame:CGRectMake((tableWidth-50), 5 , 50, 30)];
    goBtn.backgroundColor=[UIColor whiteColor];
    [goBtn setTitle: @"Done" forState: UIControlStateNormal];
    goBtn.layer.cornerRadius=3;
    goBtn.titleLabel.font=[UIFont systemFontOfSize:14.0];
    goBtn.clipsToBounds=TRUE;
    [goBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    goBtn.userInteractionEnabled=TRUE;
    goBtn.enabled=TRUE;
    [goBtn addTarget:self action:@selector(hideKeyBoard:) forControlEvents: UIControlEventTouchUpInside];
    [keyboardDoneButtonView addSubview:goBtn];*/
    self.vVerifCode.inputAccessoryView = keyboardDoneButtonView;
}

-(void)tapDetected:(UIGestureRecognizer *)recognizer {
    UIButton *btn = (UIButton *)recognizer.view;
   int tag = (int)btn.tag;
    switch (tag) {
        case 0:
        {
            UIStoryboard *stryBrd = [UIStoryboard storyboardWithName:@"ForgotPwd" bundle:nil];
            UIViewController *viewCtrl=[stryBrd instantiateViewControllerWithIdentifier:@"ForgotPwd"];
            if(viewCtrl != nil){
                viewCtrl.modalTransitionStyle=UIModalTransitionStyleFlipHorizontal;
                //[self presentViewController:viewCtrl animated:YES completion:nil];
                [self presentViewController:viewCtrl animated:YES completion:nil];
            }
            break;
        }
        case 1:
        {
            UIStoryboard *stryBrd = [UIStoryboard storyboardWithName:@"Signup" bundle:nil];
            UIViewController *viewCtrl=[stryBrd instantiateViewControllerWithIdentifier:@"Signup"];
            if(viewCtrl != nil){
                viewCtrl.modalTransitionStyle=UIModalTransitionStyleFlipHorizontal;
                [self presentViewController:viewCtrl animated:YES completion:nil];
            }
            
            break;
            
        }
        
       default:
            break;
    }
}



-(void)dismissKeyboard {
    [self.passwordValue resignFirstResponder];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)validateAndLogin:(id)sender {
    
  [self.utils hideErrorMessage:self.errorLyt];
    
    if (self.emailValue.text == nil || self.emailValue.text.length ==0) {
        [self.utils showErrorMessage:self.errorLyt contView:self.errorLabel errorLabel:@"Please enter a valid email"];
    }else if (self.passwordValue.text == nil || self.passwordValue.text.length ==0) {
        [self.utils showErrorMessage:self.errorLyt contView:self.errorLabel errorLabel:@"Please enter a valid password"];
    } else{
        [self getLogin];
    }
}
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    [self.wnpCont setUserLatLong:(double)newLocation.coordinate.latitude Longitude:(double)newLocation.coordinate.longitude];
    //[self.wnpCont setUserLatLong:47.631465 Longitude:-122.168807];
    [self.locationManager stopUpdatingLocation];
    
}

-(void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    switch (status) {
        case kCLAuthorizationStatusNotDetermined:
        case kCLAuthorizationStatusRestricted:
        case kCLAuthorizationStatusDenied:
        {
            // do some error handling
        }
            break;
        default:{
            [self.locationManager startUpdatingLocation];
        }
            break;
    }
}
- (void) getLogin {
    WnPUserDAO *userDAO = [[WnPUserDAO alloc]init];
    @try {
       self.userModel = [userDAO getUser:self.emailValue.text Password:self.passwordValue.text];
        [self.wnpCont setUserId:self.userModel.userId];
        [self.wnpCont setUserName:self.userModel.userName];
        [self.wnpCont setUserModel:self.userModel];
        
        StoreDAO *storeDao=[[StoreDAO alloc]init];
        NSArray *storeArray = [storeDao  getAllStoresForDealerByLocation:@1];
        if(storeArray.count ==1){
            StoreModel *strMdl = [storeArray objectAtIndex:0];
            [self.wnpCont setSelectedStoreId:strMdl.storeId];
            [self.wnpCont setCurrencyCode:strMdl.currencyCode];
            [self.wnpCont setCurrencySymbol:strMdl.currencySymbol];
        }
        
        [self.wnpCont setNumberOfStores:[NSNumber numberWithLong:storeArray.count]];
        

         NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setBool:self.rmChecked forKey:@"Remember"];
        if(self.rmChecked){
            [userDefaults setObject:self.userModel.userName forKey:@"userName"];
            [userDefaults setObject:self.userModel.password forKey:@"password"];
        }
        
        
        if (self.userModel.verificationCode == (id)[NSNull null] || self.userModel.verificationCode.length == 0 ){
            UIStoryboard *stryBrd = [UIStoryboard storyboardWithName:@"MenuController" bundle:nil];
            MenuController *viewCtrl=[stryBrd instantiateViewControllerWithIdentifier:@"MenuController"];
            if(viewCtrl != nil){
                viewCtrl.modalTransitionStyle=UIModalTransitionStyleFlipHorizontal;
                viewCtrl.viewName=@"Home";
                viewCtrl.resetPwd=self.userModel.usingTempPwd;
                [self presentViewController:viewCtrl animated:YES completion:nil];
            }
        }else{
            
            UIStoryboard *stryBrd = [UIStoryboard storyboardWithName:@"LoginScreen" bundle:nil];
            LoginViewController *viewCtrl=[stryBrd instantiateViewControllerWithIdentifier:@"LoginWithVerCode"];
            viewCtrl.userModel = self.userModel;
            if(viewCtrl != nil){
                viewCtrl.modalTransitionStyle=UIModalTransitionStyleFlipHorizontal;
                [self presentViewController:viewCtrl animated:YES completion:nil];
            }
        }

    }
    @catch (NSException *exception) {
        NSLog(@"Caught exception %@", exception);
         [self.utils showErrorMessage:self.errorLyt contView:self.errorLabel errorLabel:exception.reason];
    }
    
}


- (IBAction)LoginWithVerificationCode:(id)sender {
    [self.utils hideErrorMessage:self.errorLyt];
    
    NSLog(@"gggggggkjfgkjfdgjhdfgjhkhl;gfdkhl;fgkh;lfgkh");
    NSLog(@"%@",self.userModel.verificationCode);
    NSLog(@"%@",self.vVerifCode.text);
    
    if (self.vEmail.text == nil || self.vEmail.text.length ==0) {
        [self.utils showErrorMessage:self.vErrorLyt contView:self.vErrorMsg errorLabel:@"Please enter a valid email"];
    }else if (self.vPassword.text == nil || self.vPassword.text.length ==0) {
        [self.utils showErrorMessage:self.vErrorLyt contView:self.vErrorMsg errorLabel:@"Please enter a valid password"];
    }else if (self.vVerifCode.text == nil || self.vVerifCode.text.length ==0) {
        [self.utils showErrorMessage:self.vErrorLyt contView:self.vErrorMsg errorLabel:@"Please enter a valid verification code"];
    } else if (![self.vEmail.text isEqual:self.userModel.email]) {
        [self.utils showErrorMessage:self.vErrorLyt contView:self.vErrorMsg errorLabel:@"Username does not match"];
    }else if (![self.vPassword.text isEqual:[self.utils decode:self.userModel.password]]) {
        [self.utils showErrorMessage:self.vErrorLyt contView:self.vErrorMsg errorLabel:@"Password does not match"];
    }else if (![self.vVerifCode.text isEqual:self.userModel.verificationCode]) {
        [self.utils showErrorMessage:self.vErrorLyt contView:self.vErrorMsg errorLabel:@"Verification code does not match"];
    }else{

        WnPUserDAO *userDAO = [[WnPUserDAO alloc]init];
        @try {
            self.userModel.verificationCode=@"";
            self.userModel = [userDAO updateUser:self.userModel];
            UIStoryboard *stryBrd = [UIStoryboard storyboardWithName:@"MenuController" bundle:nil];
            MenuController *viewCtrl=[stryBrd instantiateViewControllerWithIdentifier:@"MenuController"];
            if(viewCtrl != nil){
                viewCtrl.modalTransitionStyle=UIModalTransitionStyleFlipHorizontal;
                viewCtrl.viewName=@"Home";
                viewCtrl.resetPwd=self.userModel.usingTempPwd;
               // [self presentModalViewController:viewCtrl animated:YES ];
                [self presentViewController:viewCtrl animated:YES completion:nil];
            }
        }
        @catch (NSException *exception) {
            NSLog(@"Caught exception %@", exception);
            //[self.utils showErrorMessage:self.errorLyt contView:self.errorLabel errorLabel:exception.reason];
            self.errorLabel.text=exception.reason;
        }

    }
}

- (void)checkTC:(UITapGestureRecognizer *) rec{
    if(self.rmChecked){
        self.rmChecked=FALSE;
        [self.remmbMe setImage:[UIImage imageNamed:@"checkbox_unsel.png"]];
    }else{
        self.rmChecked=TRUE;
        [self.remmbMe setImage:[UIImage imageNamed:@"checkbox_sel.png"]];
    }
    
}
- (void)hideKeyBoard:(UITapGestureRecognizer *) rec{
     [self.passwordValue resignFirstResponder];
     [self.emailValue resignFirstResponder];
    [self.view endEditing:YES];
}


-(void)editQuantity:(UIGestureRecognizer *)recognizer{
    self.lbl.text=self.vVerifCode.text;
}


- (IBAction)cancelLogin:(id)sender {
    [self.wnpCont setUserId:@-1];
    [self.wnpCont setUserModel:nil];
    UIStoryboard *stryBrd = [UIStoryboard storyboardWithName:@"LoginScreen" bundle:nil];
    UIViewController *viewCtrl=[stryBrd instantiateViewControllerWithIdentifier:@"LoginScreen"];
    if(viewCtrl != nil){
        viewCtrl.modalTransitionStyle=UIModalTransitionStyleFlipHorizontal;
        [self presentViewController:viewCtrl animated:YES completion:nil];
    }
}
@end
