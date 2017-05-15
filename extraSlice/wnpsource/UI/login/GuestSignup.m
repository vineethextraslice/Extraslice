//
//  GustSignupViewController.m
//  extraSlice
//
//  Created by Administrator on 10/01/17.
//  Copyright © 2017 Extraslice Inc. All rights reserved.
//

#import "GuestSignup.h"
#import "UserModel.h"
#import "UserDAO.h"
#import "Utilities.h"
#import "LoginController.h"
#import "ESliceConstants.h"
#import "AdminAccountModel.h"
#import "SmartSpaceDAO.h"

@interface GuestSignup ()
@property(nonatomic) BOOL tcChecked;
@property(strong,nonatomic) ESliceConstants *wnpCont;
@property(strong,nonatomic)  Utilities *utils ;
@property(strong,nonatomic)  UserDAO *userDao;
@property(strong,nonatomic) UIColor *bgColor;
@property(strong,nonatomic) AdminAccountModel *adminAcctModel;
@property(strong,nonatomic) SmartSpaceDAO *smSpaceDAO;

@end

@implementation GuestSignup

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tcChecked= FALSE;
    self.wnpCont= [[ESliceConstants alloc]init];
    self.utils = [[Utilities alloc]init];
    self.userDao = [[UserDAO alloc]init];
    self.bgColor = [UIColor colorWithRed:92.0/255.0 green:172.0/255.0 blue:230.0/255.0 alpha:1.0];

    NSDictionary *attrs =@{NSFontAttributeName:[UIFont boldSystemFontOfSize:16],NSForegroundColorAttributeName:[self.utils getThemeDarkBlue],NSUnderlineStyleAttributeName : @(NSUnderlineStyleSingle | NSUnderlinePatternSolid),NSUnderlineColorAttributeName:[self.utils getThemeDarkBlue] };
    NSDictionary *subAttrs =@{NSFontAttributeName:[UIFont systemFontOfSize:14],NSUnderlineStyleAttributeName: @(NSUnderlineStyleNone)};
    NSString *str = @"I accept the Terms and Conditions";
    NSRange theRange = NSMakeRange(13,20);
    NSMutableAttributedString *tcurl=[[NSMutableAttributedString alloc]initWithString:str attributes:subAttrs];
    [tcurl setAttributes:attrs range:theRange];
    self.tcText.attributedText = tcurl;
    self.tcText.numberOfLines = 0; //will wrap text in new line
    [self.tcText sizeToFit];
    self.smSpaceDAO = [[SmartSpaceDAO alloc]init];
    @try{
      [self performBackgroundTask];
    }@catch(NSException *exp){
        
    }
    self.signup.backgroundColor =[self.utils getThemeLightBlue];
    self.cancel.backgroundColor =[self.utils getThemeLightBlue];
    self.header.textColor =[self.utils getThemeLightBlue];
    self.tcText.textColor =[self.utils getThemeDarkBlue];
    self.password.delegate =self;
    self.email.delegate =self;
    self.confPassword.delegate =self;

    self.email.autocorrectionType = UITextAutocorrectionTypeNo;

    UITapGestureRecognizer *tcLabelTap = [[UITapGestureRecognizer alloc] initWithTarget:self action: @selector(showTC:)];
    tcLabelTap.numberOfTapsRequired = 1;
    tcLabelTap.numberOfTouchesRequired = 1;
    [self.tcText setUserInteractionEnabled:YES];
    [self.tcText addGestureRecognizer:tcLabelTap];
    
    UITapGestureRecognizer *tcCheckTap = [[UITapGestureRecognizer alloc] initWithTarget:self action: @selector(checkTC:)];
    tcCheckTap.numberOfTapsRequired = 1;
    tcCheckTap.numberOfTouchesRequired = 1;
    [self.tcChBox setUserInteractionEnabled:YES];
    [self.tcChBox addGestureRecognizer:tcCheckTap];
    //self.headerView.backgroundColor=[self.wnpCont getThemeBaseColor];
    
    UITapGestureRecognizer *viewTap = [[UITapGestureRecognizer alloc] initWithTarget:self action: @selector(hideKeyBoard:)];
    viewTap.numberOfTapsRequired = 1;
    viewTap.numberOfTouchesRequired = 1;
    [self.view setUserInteractionEnabled:YES];
    [self.view addGestureRecognizer:viewTap];
    
    UITapGestureRecognizer *goBackTap = [[UITapGestureRecognizer alloc] initWithTarget:self action: @selector(goBack:)];
    goBackTap.numberOfTapsRequired = 1;
    goBackTap.numberOfTouchesRequired = 1;
    [self.back setUserInteractionEnabled:YES];
    [self.back addGestureRecognizer:goBackTap];


}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

- (void) createUser {
    
    UserModel *userModel =[[UserModel alloc] init];
    UserDAO *userDAO = [[UserDAO alloc]init];
    @try {
        userModel.email=self.email.text;
        userModel.userName= self.email.text;
        userModel.password=[self.utils encode:self.password.text];
        userModel = [userDAO addGuestUser:userModel];
        [self showPopup:@"Successful" Message:@"Please use the verification code send to your email for login."];
    }
    @catch (NSException *exception) {
        NSString *errorStr = exception.reason;
        if([errorStr containsString:@"Error while inserting User Details"]){
            errorStr = @"Username already exists";
        }
        [self.utils showErrorMessage:self.errorLyt contView:self.errorText errorLabel:errorStr];
    }
    
}

- (IBAction)signupAsGuest:(id)sender {
    if (self.email.text == nil || self.email.text.length ==0) {
        [self.utils showErrorMessage:self.errorLyt contView:self.errorText errorLabel:@"Please enter a valid email"];
    }else if (![self.utils isValidEmail:self.email.text]) {
        [self.utils showErrorMessage:self.errorLyt contView:self.errorText errorLabel:@"Please enter a valid email"];
    }else if (self.password.text == nil || self.password.text.length ==0) {
       [self.utils showErrorMessage:self.errorLyt contView:self.errorText errorLabel:@"Please enter a valid password"];
    } else if (self.confPassword.text == nil || self.confPassword.text.length ==0) {
        [self.utils showErrorMessage:self.errorLyt contView:self.errorText errorLabel:@"Please confirm your password"];
    }else if (![self.password.text isEqual:self.confPassword.text]) {
        [self.utils showErrorMessage:self.errorLyt contView:self.errorText errorLabel:@"Your password does not match with confirm password"];
    }else if (!self.tcChecked) {
        [self.utils showErrorMessage:self.errorLyt contView:self.errorText errorLabel:@"Please accept terms and conditions"];
    }else{
        [self createUser];
    }

}


- (void)goBack:(UITapGestureRecognizer *)rec {
    UIStoryboard *stryBrd = [UIStoryboard storyboardWithName:@"LoginController" bundle:nil];
    UIViewController *viewCtrl=[stryBrd instantiateViewControllerWithIdentifier:@"LoginController"];
    if(viewCtrl != nil){
        viewCtrl.modalTransitionStyle=UIModalTransitionStyleFlipHorizontal;
        [self presentViewController:viewCtrl animated:YES completion:nil];
    }
    
}
- (IBAction)cancelSignup:(id)sender {
    UIStoryboard *stryBrd = [UIStoryboard storyboardWithName:@"LoginController" bundle:nil];
    UIViewController *viewCtrl=[stryBrd instantiateViewControllerWithIdentifier:@"LoginController"];
    if(viewCtrl != nil){
        viewCtrl.modalTransitionStyle=UIModalTransitionStyleFlipHorizontal;
        [self presentViewController:viewCtrl animated:YES completion:nil];
    }

}


- (void)showTC:(UITapGestureRecognizer *) rec{
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 65, screenRect.size.width, screenRect.size.height)];
    
    webView.tag=55;
    NSURL *url = [NSURL URLWithString:self.adminAcctModel.termsNCondUrl];
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
    [webView loadRequest:requestObj];
    [self.view addSubview:webView];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button addTarget:self
               action:@selector(closeTC:)
     forControlEvents:UIControlEventTouchDown];
    [button setTitle:@"Close" forState:UIControlStateNormal];
    button.frame = CGRectMake(((screenRect.size.width/2)-55), screenRect.size.height-40, 110, 30);
    [button addTarget:self action:@selector(closeTC:) forControlEvents:UIControlEventTouchUpInside];
    button.backgroundColor=[self.wnpCont getThemeBaseColor];
    button.tag=65;
    [self.view addSubview:button];
    [self.view bringSubviewToFront:button];
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
    header.backgroundColor=self.bgColor;
    header.textColor=[UIColor whiteColor];
    [alertView addSubview: header];
    
    
    
    UILabel *messageText = [[UILabel alloc] initWithFrame:CGRectMake(0, 40 , 300, 90)];
    messageText.text=message;
    messageText.textAlignment=NSTextAlignmentCenter;
    messageText.numberOfLines=-1;
    [alertView addSubview: messageText];
    UIButton *closeBtn = [[UIButton alloc] initWithFrame:CGRectMake( 115,140 , 70, 30)];
    closeBtn.backgroundColor=self.bgColor;
    
    [closeBtn setTitle: @"Ok" forState: UIControlStateNormal];
    closeBtn.userInteractionEnabled=TRUE;
    closeBtn.enabled=TRUE;
    [closeBtn addTarget:self action:@selector(cancelSignup:) forControlEvents: UIControlEventTouchUpInside];
    [alertView addSubview: closeBtn];
}
- (void)checkTC:(UITapGestureRecognizer *) rec{
    if(self.tcChecked){
        self.tcChecked=FALSE;
        [self.tcChBox setImage:[UIImage imageNamed:@"checkbox_unsel.png"]];
    }else{
        self.tcChecked=TRUE;
        [self.tcChBox setImage:[UIImage imageNamed:@"checkbox_sel.png"]];
    }
    
}
- (void)closeTC:(UITapGestureRecognizer *) rec{
    
    
    [[self.view viewWithTag:55] removeFromSuperview];
    [[self.view viewWithTag:65] removeFromSuperview];
}
- (void)hideKeyBoard:(UITapGestureRecognizer *) rec{
    [self.view endEditing:YES];
}

- (void)performBackgroundTask
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        
        indicator.frame = CGRectMake(0.0, 0.0, 80.0, 80.0);
        CGAffineTransform transform = CGAffineTransformMakeScale(2.0f, 2.0f);
        indicator.transform = transform;
        indicator.center = self.view.center;
        [self.view addSubview:indicator];
        [indicator bringSubviewToFront:self.view];
        [indicator startAnimating];
        @try{
            self.adminAcctModel=[self.smSpaceDAO getAdminAccount];
        }@catch(NSException *exp){
        }
    
        dispatch_async(dispatch_get_main_queue(), ^{
            [indicator stopAnimating];
        });
    });
}

@end
