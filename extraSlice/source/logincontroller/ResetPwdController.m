//
//  ForgotPwdController.m
//  extraSlice
//
//  Created by Administrator on 19/06/16.
//  Copyright © 2016 Extraslice Inc. All rights reserved.
//

#import "ResetPwdController.h"
#import "UserModel.h"
#import "UserDAO.h"
#import "Utilities.h"
#import "WnPConstants.h"
#import "LoginController.h"

@interface ResetPwdController ()
@property(strong,nonatomic) Utilities *utils;
@property(strong,nonatomic) WnPConstants *wnpConst;
@end

@implementation ResetPwdController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.email.delegate =self;
    self.utils = [[Utilities alloc]init];
    self.wnpConst = [[WnPConstants alloc]init];
    
    UITapGestureRecognizer *gobackTap = [[UITapGestureRecognizer alloc] initWithTarget:self action: @selector(goBack:)];
    gobackTap.numberOfTapsRequired = 1;
    gobackTap.numberOfTouchesRequired = 1;
    [self.goBackView setUserInteractionEnabled:YES];
    [self.goBackView addGestureRecognizer:gobackTap];
    
    UITapGestureRecognizer *gobackViewTap = [[UITapGestureRecognizer alloc] initWithTarget:self action: @selector(goBack:)];
    gobackViewTap.numberOfTapsRequired = 1;
    gobackViewTap.numberOfTouchesRequired = 1;
    [self.goBackImage setUserInteractionEnabled:YES];
    [self.goBackImage addGestureRecognizer:gobackViewTap];
    [self.view bringSubviewToFront:self.goBackView];
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
- (void)goBack:(UITapGestureRecognizer *) rec{
    UIStoryboard *stryBrd = [UIStoryboard storyboardWithName:@"LoginController" bundle:nil];
    LoginController *viewCtrl=[stryBrd instantiateViewControllerWithIdentifier:@"LoginController"];
    
    [self.utils loadViewControlleWithAnimation:self NextController:viewCtrl];
    
}
- (IBAction)backToHome:(id)sender {
    UIStoryboard *stryBrd = [UIStoryboard storyboardWithName:@"LoginController" bundle:nil];
    UIViewController *viewCtrl=[stryBrd instantiateViewControllerWithIdentifier:@"LoginController"];
    [self.utils loadViewControlleWithAnimation:self NextController:viewCtrl];
}

- (IBAction)resetPassword:(id)sender {
    self.errorText.text= @"";
    self.errorLyt.hidden = true;
   
    if (self.email.text == nil || self.email.text.length ==0) {
        self.errorText.text= @"Please enter a valid email";
        self.errorLyt.hidden = false;
        
    }else{
        [self performBackgroundTask];
    }

}
- (void)performBackgroundTask
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *error = nil;
        NSString *status = nil;
        UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        CGAffineTransform transform = CGAffineTransformMakeScale(2.0f, 2.0f);
        indicator.transform = transform;
        indicator.frame = CGRectMake(0.0, 0.0, 80.0, 80.0);
        indicator.center = self.view.center;
        [self.view addSubview:indicator];
        [indicator bringSubviewToFront:self.view];
        NSString *userName=self.email.text;
        UserDAO *userDAO = [[UserDAO alloc]init];
        [indicator startAnimating];
        
        @try{
            
            status= [userDAO resetPassword:userName];
            
        }@catch(NSException *exp){
            error =exp.description;;
            
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [indicator stopAnimating];
            if(error != nil){
                self.errorText.text= error;
                self.errorLyt.hidden = false;
            }else{
                if([status isEqualToString:@"SUCCESS"]){
                    [self showPopup:@"Successfull" Message:@"new password sent to your email"];
                }else{
                    self.errorText.text= status;
                    self.errorLyt.hidden = false;
                }
            }
        });
    });
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}
-(void)textFieldDidBeginEditing:(UITextField *)textField{
    UIImage *blueBGImg = [UIImage imageNamed:@"edt_bg_blue.png"];
    textField.background = blueBGImg;
    
}
-(void) textFieldDidEndEditing:(UITextField *)textField{
    UIImage *blueBGImg = [UIImage imageNamed:@"edt_bg_grey.png"];
    textField.background = blueBGImg;
    
}

-(void) showPopup:(NSString *) title Message:(NSString *) message
{
    self.view.backgroundColor=[UIColor grayColor];
    for(UIView *subViews in [self.view subviews]){
        subViews.alpha=0.2;
        subViews.userInteractionEnabled=false;
    }
    float centerX = self.view.center.x;
    float centerY = self.view.center.y;
    UIView *alertView = [[UIView alloc] initWithFrame:CGRectMake(centerX-150, centerY-80 , 300, 180)];
    alertView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview: alertView];
    UILabel *header = [[UILabel alloc] initWithFrame:CGRectMake(0, 0 , 300, 30)];
    header.text=title;//@"Your request processed successfully. Our community manager will contact you soon.";
    header.textAlignment=NSTextAlignmentCenter;
    header.numberOfLines=1;
    header.backgroundColor=[self.wnpConst getThemeBaseColor];
    header.textColor=[UIColor whiteColor];
    [alertView addSubview: header];
    
    
    
    UILabel *messageText = [[UILabel alloc] initWithFrame:CGRectMake(0, 40 , 300, 90)];
    messageText.text=message;
    messageText.textAlignment=NSTextAlignmentCenter;
    messageText.numberOfLines=-1;
    [alertView addSubview: messageText];
    UIButton *closeBtn = [[UIButton alloc] initWithFrame:CGRectMake( 115,140 , 70, 30)];
    closeBtn.backgroundColor=[self.wnpConst getThemeBaseColor];;
    
    [closeBtn setTitle: @"Ok" forState: UIControlStateNormal];
    closeBtn.userInteractionEnabled=TRUE;
    closeBtn.enabled=TRUE;
    [closeBtn addTarget:self action:@selector(gotoHome:) forControlEvents: UIControlEventTouchUpInside];
    [alertView addSubview: closeBtn];
}

- (IBAction)gotoHome:(id)sender {
    UIStoryboard *stryBrd = [UIStoryboard storyboardWithName:@"LoginController" bundle:nil];
    LoginController *viewCtrl=[stryBrd instantiateViewControllerWithIdentifier:@"LoginController"];
    [self.utils loadViewControlleWithAnimation:self NextController:viewCtrl];
    
}
@end
