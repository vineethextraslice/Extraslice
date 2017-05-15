//
//  UserInfoController.m
//  extraSlice
//
//  Created by Administrator on 19/06/16.
//  Copyright © 2016 Extraslice Inc. All rights reserved.
//

#import "UserDataController.h"
#import "SelectPlanController.h"
#import "OrganizationModel.h"
#import "UserModel.h"
#import "UserRequestModel.h"
#import "UserDAO.h"
#import "Utilities.h"
#import "LoginController.h"
#import "WnPConstants.h"
#import "STPPaymentCardTextField.h"
#import "STPAPIClient.h"
#import "Stripe.h"
#import "StripeDAO.h"
#import "StripePlanModel.h"
#import "SmartSpaceDAO.h"
#import "PlanOfferModel.h"

static UIColor *SelectedCellBGColor ;
static UIColor *NotSelectedCellBGColor;
@interface UserDataController ()<STPPaymentCardTextFieldDelegate>
@property(nonatomic) BOOL alreadyRegistered ;
@property(nonatomic) BOOL makePayment ;
@property(nonatomic) BOOL dedicatedPlan ;
@property(nonatomic) BOOL individual;
@property(nonatomic) BOOL isPaypal;
@property(nonatomic) BOOL tcAccepted;
@property(strong,nonatomic) NSMutableArray *addOnAArray;

@property(strong,nonatomic) UIView *previousRow;
@property(strong,nonatomic) OrganizationModel *selectedOrg;
@property(strong,nonatomic) PlanModel *selectedPlan;
@property(strong,nonatomic) UIColor *bgColor;
@property(strong,nonatomic) UILabel *crtOrgError;
@property(strong,nonatomic) UITextField *crtOrgOrgName ;
@property(strong,nonatomic) UITextField *crtOrgAddress;
@property(strong,nonatomic) UITextField *crtOrgContactNo;
@property(strong,nonatomic) UITextField *crtOrgDesc;
@property(strong,nonatomic) UIView *crtOrgPopup;
@property(strong,nonatomic) WnPConstants *wnpCont;
@property(strong,nonatomic) UIButton *strpSubmitBtn;
@property(strong,nonatomic) UIButton *strpCancelBtn;
@property(strong,nonatomic) STPPaymentCardTextField *strpPymntTf;
@property(strong,nonatomic)  Utilities *utils ;
@property(strong,nonatomic) StripeDAO *strpDAO;
@property(strong,nonatomic)  UserDAO *userDao;
@property(strong,nonatomic) SmartSpaceDAO *smSpaceDAO;
@property(strong,nonatomic) UITextField *orgName;
@property(strong,nonatomic) NSNumber *initilaPaymentAmount;
@property(strong,nonatomic) OrganizationModel *individualOrg;
@property(strong,nonatomic) STPAPIClient *strpClient;
@end
/*var payableAmount = document.getElementById('planamount').value;
var onetimeAmount =(+payableAmount)*((+noOfdaystoNextMonth)/(+noOFDaysInMoth));
document.getElementById('onetimeamount').value =Math.round(+onetimeAmount * 100) / 100;
var message = '<?php echo $message; ?>';
message = message.replace("replace_amount", Math.round(+onetimeAmount * 100) / 100);*/
@implementation UserDataController
UserModel *addedModel = nil;
- (void)viewDidLoad {
    [super viewDidLoad];
    self.tcAccepted= FALSE;
    self.strpDAO = [[StripeDAO alloc]init];
    self.wnpCont= [[WnPConstants alloc]init];
    self.utils = [[Utilities alloc]init];
    self.individualOrg =[[OrganizationModel alloc]init];
    self.smSpaceDAO = [[SmartSpaceDAO alloc]init];
    self.userDao = [[UserDAO alloc]init];
    self.userName.delegate =self;
    self.email.delegate =self;
    self.password.delegate =self;
    self.confPassword.delegate =self;
    self.contactNo.delegate =self;
    self.noOfSeats.delegate =self;
    self.makePayment=true;
    [self.tcView bringSubviewToFront:self.tcChecbox];
    [self.tcChecbox setUserInteractionEnabled:TRUE];
    [self performBackgroundTask:@"INDIVIDUAL"];
    [self performBackgroundTask:@"ALLORG"];
    NSDictionary *attrs =@{NSFontAttributeName:[UIFont boldSystemFontOfSize:16],NSForegroundColorAttributeName:[UIColor blueColor],NSUnderlineStyleAttributeName : @(NSUnderlineStyleSingle | NSUnderlinePatternSolid),NSUnderlineColorAttributeName:[UIColor blueColor] };
    NSDictionary *subAttrs =@{NSFontAttributeName:[UIFont systemFontOfSize:14],NSUnderlineStyleAttributeName: @(NSUnderlineStyleNone)};
    NSString *str = @"I accept the Terms and Conditions";
    NSRange theRange = NSMakeRange(13,20);
    NSMutableAttributedString *tcurl=[[NSMutableAttributedString alloc]initWithString:str attributes:subAttrs];
    [tcurl setAttributes:attrs range:theRange];
     self.tcText.attributedText = tcurl;
    if(self.selectedPlanArray != nil){
        self.selectedPlan = [self.selectedPlanArray objectAtIndex:0];
    }
    self.addOnAArray = [[NSMutableArray alloc]init];
    
     if(self.selectedAddonIds != (id)[NSNull null] && self.selectedAddonIds != nil){
         for(ResourceTypeModel  *resTypeMdl in self.addonList){
             if([self.selectedAddonIds containsObject:resTypeMdl.resourceTypeId]){
                 [self.addOnAArray addObject:[resTypeMdl dictionaryWithPropertiesOfObject:resTypeMdl]];
             }
         }
     }

    double onetimeAmount =(self.payableAmount.doubleValue*self.noOfdaystoNextMonth.doubleValue)/(self.noOFDaysInMoth.doubleValue);
    self.initilaPaymentAmount = [NSNumber numberWithDouble:onetimeAmount];
    NSString *pymntText = [self.message stringByReplacingOccurrencesOfString:@"replace_amount" withString:[self.utils getNumberFormatter:onetimeAmount]];

        self.paydescrText.text=pymntText;
    
    
    
    
   
    
    UITapGestureRecognizer *showTcTap = [[UITapGestureRecognizer alloc] initWithTarget:self action: @selector(showTC:)];
    showTcTap.numberOfTapsRequired = 1;
    showTcTap.numberOfTouchesRequired = 1;
    [self.tcText setUserInteractionEnabled:YES];
    [self.tcText addGestureRecognizer:showTcTap];
   
    UITapGestureRecognizer *tcCheckTap = [[UITapGestureRecognizer alloc] initWithTarget:self action: @selector(checkTC:)];
    tcCheckTap.numberOfTapsRequired = 1;
    tcCheckTap.numberOfTouchesRequired = 1;
    [self.tcChecbox setUserInteractionEnabled:YES];
    [self.tcChecbox addGestureRecognizer:tcCheckTap];
    
    @try{
        self.adminAcctModel=[self.smSpaceDAO getAdminAccount];
    }@catch(NSException *exp){
        
    }


    self.individual=true;
    self.isPaypal =false;
        self.bgColor = [UIColor colorWithRed:92.0/255.0 green:172.0/255.0 blue:230.0/255.0 alpha:1.0];
 
    self.errorLyt.hidden=true;
    self.errorText.text=@"";
    self.errorHieght.constant=0;
    self.errorTop.constant=0;
    [self.errorText clipsToBounds];
    self.orgName = [[UITextField alloc] initWithFrame:CGRectMake(0, 0 , 210, 30)];
    UIImage *grayBGImg = [UIImage imageNamed:@"edt_bg_grey.png"];
    [self.orgName setBackground:grayBGImg];
    self.orgName.placeholder=@"Select/Create Organization";

    
   
    

    self.orgName.delegate=self;
    SelectedCellBGColor=[UIColor grayColor];
    NotSelectedCellBGColor =[UIColor whiteColor];
    UITapGestureRecognizer *gobackTap = [[UITapGestureRecognizer alloc] initWithTarget:self action: @selector(goBack:)];
    gobackTap.numberOfTapsRequired = 1;
    gobackTap.numberOfTouchesRequired = 1;
    [self.goBack setUserInteractionEnabled:YES];
    [self.goBack addGestureRecognizer:gobackTap];
    
    UITapGestureRecognizer *gobackViewTap = [[UITapGestureRecognizer alloc] initWithTarget:self action: @selector(goBack:)];
    gobackViewTap.numberOfTapsRequired = 1;
    gobackViewTap.numberOfTouchesRequired = 1;
    [self.goBackView setUserInteractionEnabled:YES];
    [self.goBackView addGestureRecognizer:gobackViewTap];

    [self.view bringSubviewToFront:self.goBackView];
    UITapGestureRecognizer *selIndTap = [[UITapGestureRecognizer alloc] initWithTarget:self action: @selector(makeIndividual:)];
    selIndTap.numberOfTapsRequired = 1;
    selIndTap.numberOfTouchesRequired = 1;
    [self.selIndividual setUserInteractionEnabled:YES];
    [self.selIndividual addGestureRecognizer:selIndTap];
    
    UITapGestureRecognizer *selOrgTap = [[UITapGestureRecognizer alloc] initWithTarget:self action: @selector(makeIndividual:)];
    selOrgTap.numberOfTapsRequired = 1;
    selOrgTap.numberOfTouchesRequired = 1;
    [self.selOrg setUserInteractionEnabled:YES];
    [self.selOrg addGestureRecognizer:selOrgTap];
    
    /*UITapGestureRecognizer *selPplTap = [[UITapGestureRecognizer alloc] initWithTarget:self action: @selector(    selectPayBy
:)];
    selPplTap.numberOfTapsRequired = 1;
    selPplTap.numberOfTouchesRequired = 1;
    [self.selPaypal setUserInteractionEnabled:YES];
    [self.selPaypal addGestureRecognizer:selPplTap];
    
    UITapGestureRecognizer *selStrpTap = [[UITapGestureRecognizer alloc] initWithTarget:self action: @selector(selectPayBy:)];
    selStrpTap.numberOfTapsRequired = 1;
    selStrpTap.numberOfTouchesRequired = 1;
    [self.selStripe setUserInteractionEnabled:YES];
    [self.selStripe addGestureRecognizer:selStrpTap];*/
    /*for(OrganizationModel *orgMdl in self.orgList){
        if(orgMdl.orgId.intValue == 1){
            self.selectedOrg=orgMdl;
            break;
        }
    }*/
    
    self.selectedOrg.orgRoleId=@1;


       if(self.selectedPlan == nil){
           self.alreadyRegistered = true;
           self.noOfSeats.hidden = true;
           self.seatHieght.constant=0;
           self.seatTop.constant=0;
        
           self.contactNo.hidden=true;
           self.phoneHeight.constant=0;
           self.phoneTop.constant=0;
        
           self.membershipType.hidden=true;
           self.membTypeHeight.constant=0;
           self.membTypeTop.constant=0;

        
           self.userName.hidden=true;
           self.nameHeight.constant=0;
           self.userTop.constant=0;
        
           self.paydescrText.hidden=true;
           self.payDescHeight.constant=0;
           self.payDescTop.constant=0;
           self.dedicatedPlan = false;
        
           self.makePayment=false;

    }else{
        self.contactNo.hidden=false;
        self.alreadyRegistered = false;
        for(PlanModel *pln in self.selectedPlanArray){
            if(!pln.purchaseOnSpot){
                self.dedicatedPlan = true;
                break;
            }
        }
        if(!self.dedicatedPlan){
           
            self.noOfSeats.hidden = true;
            self.makePayment=true;
            
        }else{
            self.tcView.hidden=true;
            self.tcHeight.constant=0;
            [self.joinNowBtn setTitle: @"Check availability" forState: UIControlStateNormal];
            self.makePayment=false;
            self.noOfSeats.hidden = false;
            self.password.hidden=true;
            self.passwordHeight.constant=0;
            self.passwordTop.constant=0;
            self.confPassword.hidden=true;
            self.confPwdHeight.constant=0;
            self.confPwdTop.constant=0;
            self.membershipType.hidden=true;
            self.membTypeHeight.constant=0;
            self.membTypeTop.constant=0;
            self.payDescHeight.constant=0;
            self.payDescTop.constant=0;
            self.paydescrText.hidden=true;
        }
      
    }
    if(self.makePayment){
        self.paydescrText.hidden=false;
    }else{
        self.paydescrText.hidden=true;
        
    }
    
    UITapGestureRecognizer *viewTap = [[UITapGestureRecognizer alloc] initWithTarget:self action: @selector(hideKeyBord)];
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


- (void)goBack:(UITapGestureRecognizer *) rec{
    UIStoryboard *stryBrd = [UIStoryboard storyboardWithName:@"SelectPlan" bundle:nil];
    SelectPlanController *viewCtrl=[stryBrd instantiateViewControllerWithIdentifier:@"SelectPlan"];
   // viewCtrl.selectedPlan = self.selectedPlan;
    viewCtrl.planArray= self.planArray;
    viewCtrl.addonList = self.addonList;
    viewCtrl.adminAcctModel = self.adminAcctModel;
    viewCtrl.planArray= self.planArray;
    viewCtrl.offerList=self.offerList;
    viewCtrl.noOfdaystoSubsDate = self.noOfdaystoSubsDate;
    viewCtrl.trialEndsAt = self.trialEndsAt;
    viewCtrl.firstsubDate  = self.firstsubDate;
    viewCtrl.noOFDaysInMoth  = self.noOFDaysInMoth;
    viewCtrl.message = self.message;
    viewCtrl.noOfdaystoNextMonth = self.noOfdaystoNextMonth;
    [self.utils loadViewControlleWithAnimation:self NextController:viewCtrl];}

- (void)makeIndividual:(UITapGestureRecognizer *) rec{
    [self hideKeyBord];
    if(self.individual){
        self.selectedOrg=nil;
        [self.selIndividual setImage:[UIImage imageNamed:@"rb_blue_unsel.png"]];
        [self.selOrg setImage:[UIImage imageNamed:@"rb_blue_sel.png"]];
        self.paydescrText.hidden=false;
        self.individual = false;
        [self showCreateOrgPopup];
    }else{
        self.selectedOrg=self.individualOrg;
        self.selectedOrg.orgRoleId=@1;
        [self.selOrg setImage:[UIImage imageNamed:@"rb_blue_unsel.png"]];
        [self.selIndividual setImage:[UIImage imageNamed:@"rb_blue_sel.png"]];
       if(!self.dedicatedPlan && !self.alreadyRegistered){
            /*self.payType.hidden=false;
            self.payTypeHeight.constant=30;
            self.payTypeTop.constant=10;
            self.payHeader.hidden=false;
            self.payHeaderHeight.constant=30;
            self.payHeaderTop.constant=10;*/
        }
        
        self.paydescrText.hidden=false;
        self.makePayment=true;
        self.individual = true;
    }
    
}


- (IBAction)setSelected:(id)sender {
    NSLog(@"here....................");
    UIImage *blueBGImg = [UIImage imageNamed:@"edt_bg_blue.png"];
    UITextField *tf = (UITextField *)sender;
    tf.background = blueBGImg;
}

- (IBAction)setUnselected:(id)sender {
    UIImage *blueBGImg = [UIImage imageNamed:@"edt_bg_grey.png"];
    UITextField *tf = (UITextField *)sender;
    tf.background = blueBGImg;

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
- (IBAction)gotoHome:(id)sender {
    UIStoryboard *stryBrd = [UIStoryboard storyboardWithName:@"LoginController" bundle:nil];
    LoginController *viewCtrl=[stryBrd instantiateViewControllerWithIdentifier:@"LoginController"];
    [self.utils loadViewControlleWithAnimation:self NextController:viewCtrl];

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
    [closeBtn addTarget:self action:@selector(gotoHome:) forControlEvents: UIControlEventTouchUpInside];
    [alertView addSubview: closeBtn];
}

-(void) showCreateOrgPopup
{
    self.crtOrgError.text=@"";
    self.crtOrgError.hidden=true;
    self.selectedOrg = nil;
    self.view.backgroundColor=[UIColor grayColor];
    for(UIView *subViews in [self.view subviews]){
        subViews.alpha=0.2;
        subViews.userInteractionEnabled=false;
    }
    float centerX = self.view.center.x;
    float centerY = self.view.center.y;
    self.crtOrgPopup = [[UIView alloc] initWithFrame:CGRectMake(centerX-150, centerY-145 , 300, 290)];
    self.crtOrgPopup.backgroundColor = [UIColor whiteColor];
    [self.view addSubview: self.crtOrgPopup];
    
    UILabel *header = [[UILabel alloc] initWithFrame:CGRectMake(0, 0 , 300, 30)];
    header.text=@"Add Organization";
    header.textAlignment=NSTextAlignmentCenter;
    header.numberOfLines=1;
    header.backgroundColor=self.bgColor;
    header.textColor=[UIColor whiteColor];
    [self.crtOrgPopup addSubview: header];
    
    self.crtOrgError = [[UILabel alloc] initWithFrame:CGRectMake(25, 40 , 250, 30)];
    self.crtOrgError.hidden=true;
    self.crtOrgError.textColor=[UIColor redColor];
    [self.crtOrgPopup addSubview: self.crtOrgError];
    
    self.crtOrgOrgName = [[UITextField alloc] initWithFrame:CGRectMake(25, 80 , 250, 30)];
    self.crtOrgOrgName.placeholder=@"Name";
     self.crtOrgOrgName.textAlignment=NSTextAlignmentCenter;
     UIImage *greyBGImg = [UIImage imageNamed:@"edt_bg_grey.png"];
    self.crtOrgOrgName.background = greyBGImg;
    self.crtOrgOrgName.delegate =self;
    [self.crtOrgPopup addSubview: self.crtOrgOrgName];
     self.crtOrgOrgName.text=self.orgName.text;
    
    
    self.crtOrgAddress = [[UITextField alloc] initWithFrame:CGRectMake(25, 120 , 250, 30)];
    self.crtOrgAddress.placeholder=@"Address";
    self.crtOrgAddress.textAlignment=NSTextAlignmentCenter;
    self.crtOrgAddress.background = greyBGImg;
    self.crtOrgAddress.delegate =self;
    [self.crtOrgPopup addSubview: self.crtOrgAddress];
    
    self.crtOrgContactNo = [[UITextField alloc] initWithFrame:CGRectMake(25, 160 , 250, 30)];
    self.crtOrgContactNo.placeholder=@"Contact no";
    self.crtOrgContactNo.textAlignment=NSTextAlignmentCenter;
    self.crtOrgContactNo.background = greyBGImg;
    self.crtOrgContactNo.delegate =self;
    [self.crtOrgPopup addSubview: self.crtOrgContactNo];
    
    self.crtOrgDesc = [[UITextField alloc] initWithFrame:CGRectMake(25, 200 , 250, 30)];
    self.crtOrgDesc.placeholder=@"Description";
    self.crtOrgDesc.textAlignment=NSTextAlignmentCenter;
    self.crtOrgDesc.background = greyBGImg;
    self.crtOrgDesc.delegate =self;
    [self.crtOrgPopup addSubview: self.crtOrgDesc];
    
    UIButton *addBtn = [[UIButton alloc] initWithFrame:CGRectMake( 30,240 , 105, 30)];
    addBtn.backgroundColor=self.bgColor;
    
    [addBtn setTitle: @"Add" forState: UIControlStateNormal];
    addBtn.userInteractionEnabled=TRUE;
    addBtn.enabled=TRUE;
    [addBtn addTarget:self action:@selector(addOrganization:) forControlEvents: UIControlEventTouchUpInside];
    [self.crtOrgPopup addSubview: addBtn];
    
    UIButton *cancelBtn = [[UIButton alloc] initWithFrame:CGRectMake( 165,240 , 105, 30)];
    cancelBtn.backgroundColor=self.bgColor;
    
    [cancelBtn setTitle: @"Cancel" forState: UIControlStateNormal];
    cancelBtn.userInteractionEnabled=TRUE;
    cancelBtn.enabled=TRUE;
    [cancelBtn addTarget:self action:@selector(closeOrgPopup:) forControlEvents: UIControlEventTouchUpInside];
    [self.crtOrgPopup addSubview: cancelBtn];
}

-(void) showStripePopup
{
 
    for(UIView *subViews in [self.view subviews]){
        subViews.alpha=0.2;
        subViews.userInteractionEnabled=false;
    }
    float centerX = self.view.center.x;
    float centerY = self.view.center.y;
    
    self.view.userInteractionEnabled=false;
    self.crtOrgPopup=[[UIView alloc] initWithFrame:CGRectMake(centerX-135,centerY-95,270,220)];
     self.crtOrgPopup.backgroundColor = [UIColor whiteColor];
    self.crtOrgPopup.layer.borderColor = [self.wnpCont getThemeBaseColor].CGColor;
    self.crtOrgPopup.layer.borderWidth = 1.0f;
    self.crtOrgPopup.alpha=1.0;
  //  [self.view addSubview:self.crtOrgPopup];
    [[UIApplication sharedApplication].keyWindow addSubview:self.crtOrgPopup];
    
    UILabel *headerLbl =[[UILabel alloc] initWithFrame:CGRectMake(0,0,270,35)];
    headerLbl.text=@"Stripe payment gateway";
    headerLbl.textAlignment=NSTextAlignmentCenter;
    UIFont *txtFont = [headerLbl.font fontWithSize:fontSize];
    headerLbl.font = txtFont;
    headerLbl.textColor=[UIColor whiteColor];
    headerLbl.backgroundColor=[self.wnpCont getThemeBaseColor];
    [self.crtOrgPopup addSubview:headerLbl];
    
    self.crtOrgError = [[UILabel alloc] initWithFrame:CGRectMake(10, 40 , 250, 30)];
    self.crtOrgError.hidden=true;
    self.crtOrgError.textColor=[UIColor redColor];
    [self.crtOrgPopup addSubview: self.crtOrgError];
    if(self.initilaPaymentAmount.doubleValue > 0){
        UILabel *descLabel =[[UILabel alloc] initWithFrame:CGRectMake(10,75,195,30)];
        descLabel.text=@"Onetime Payment for plan ";
        descLabel.textAlignment=NSTextAlignmentLeft;
        // UIFont *txtFont = [headerLbl.font fontWithSize:fontSize];
        descLabel.font = txtFont;
        descLabel.textColor=[UIColor blackColor];
        // headerLbl.backgroundColor=[self.wnpCont getThemeBaseColor];
        [self.crtOrgPopup addSubview:descLabel];
        
        UILabel *amtLbl =[[UILabel alloc] initWithFrame:CGRectMake(210,75,50,30)];
        amtLbl.text=[NSString stringWithFormat:@"%s%@","$",[self.utils getNumberFormatter:self.initilaPaymentAmount.doubleValue]];
        amtLbl.textAlignment=NSTextAlignmentLeft;
        // UIFont *txtFont = [headerLbl.font fontWithSize:fontSize];
        amtLbl.font = txtFont;
        amtLbl.textColor=[UIColor blackColor];
        // headerLbl.backgroundColor=[self.wnpCont getThemeBaseColor];
        [self.crtOrgPopup addSubview:amtLbl];
    }
    
    
    
    
    UILabel *subDescLabel =[[UILabel alloc] initWithFrame:CGRectMake(10,110,195,30)];
    subDescLabel.text=@"Subscription for plan ";
    subDescLabel.textAlignment=NSTextAlignmentLeft;
    // UIFont *txtFont = [headerLbl.font fontWithSize:fontSize];
    subDescLabel.font = txtFont;
    subDescLabel.textColor=[UIColor blackColor];
    // headerLbl.backgroundColor=[self.wnpCont getThemeBaseColor];
    [self.crtOrgPopup addSubview:subDescLabel];
    
    UILabel *subAmtLbl =[[UILabel alloc] initWithFrame:CGRectMake(210,110,50,30)];
    subAmtLbl.text=[NSString stringWithFormat:@"%s%@","$",[self.utils getNumberFormatter:self.payableAmount.doubleValue]];
    subAmtLbl.textAlignment=NSTextAlignmentLeft;
    // UIFont *txtFont = [headerLbl.font fontWithSize:fontSize];
    subAmtLbl.font = txtFont;
    subAmtLbl.textColor=[UIColor blackColor];
    // headerLbl.backgroundColor=[self.wnpCont getThemeBaseColor];
    [self.crtOrgPopup addSubview:subAmtLbl];
    
    self.strpPymntTf = [[STPPaymentCardTextField alloc] initWithFrame:CGRectMake(10,145,250,30)];
    self.strpPymntTf.delegate=self;
    [self.crtOrgPopup addSubview:self.strpPymntTf];
    
    self.strpSubmitBtn = [[UIButton alloc] initWithFrame:CGRectMake(20,185,100,30)];
    self.strpSubmitBtn.backgroundColor=[UIColor grayColor];
    [self.strpSubmitBtn setTitle: @"Submit" forState: UIControlStateNormal];
    self.strpSubmitBtn.userInteractionEnabled=TRUE;
    self.strpSubmitBtn.enabled=FALSE;
    [self.strpSubmitBtn addTarget:self action:@selector(submitStripePayment:) forControlEvents: UIControlEventTouchUpInside];
    self.strpSubmitBtn.backgroundColor=[UIColor grayColor];

    [self.crtOrgPopup addSubview:self.strpSubmitBtn];
    
    self.strpCancelBtn = [[UIButton alloc] initWithFrame:CGRectMake(150,185,100,30)];
    self.strpCancelBtn.backgroundColor=[self.wnpCont getThemeBaseColor];
   // self.strpCancelBtn.backgroundColor=[UIColor grayColor];
    
    self.strpCancelBtn.userInteractionEnabled=TRUE;
    self.strpCancelBtn.enabled=TRUE;
    [self.strpCancelBtn setTitle: @"Cancel" forState: UIControlStateNormal];
    [self.strpCancelBtn addTarget:self action:@selector(cancelStripePayment:) forControlEvents: UIControlEventTouchUpInside];
    [self.crtOrgPopup addSubview:self.strpCancelBtn];

    UITapGestureRecognizer *viewTap = [[UITapGestureRecognizer alloc] initWithTarget:self action: @selector(hideKeyBord)];
    viewTap.numberOfTapsRequired = 1;
    viewTap.numberOfTouchesRequired = 1;
    [self.self.crtOrgPopup setUserInteractionEnabled:YES];
    [self.self.crtOrgPopup addGestureRecognizer:viewTap];
}

- (IBAction)closeOrgPopup:(id)sender {
    self.crtOrgError.text=@"";
    self.crtOrgError.hidden=true;

    [self.crtOrgPopup removeFromSuperview];
    self.view.backgroundColor=[UIColor whiteColor];
    for(UIView *subViews in [self.view subviews]){
        subViews.alpha=1.0;
        subViews.userInteractionEnabled=true;
    }
}
- (IBAction)addOrganization:(id)sender {
    self.crtOrgError.text=@"";
    self.crtOrgError.hidden=true;
    if(self.crtOrgOrgName.text == nil || self.crtOrgOrgName.text.length == 0){
        self.crtOrgError.text=@"Please enter organization name";
        self.crtOrgError.hidden=false;
    }else if([self.orgList containsObject:self.crtOrgOrgName.text]){
        self.crtOrgError.text=@"Organization name already exists";
        self.crtOrgError.hidden=false;
    }else{
        self.selectedOrg = [[OrganizationModel alloc]init];
        self.selectedOrg.orgName=self.crtOrgOrgName.text;
        self.selectedOrg.orgRoleId=@1;
        self.selectedOrg.address=self.crtOrgAddress.text;
        self.selectedOrg.contactNo=self.crtOrgContactNo.text;
        self.selectedOrg.keyWords=self.crtOrgDesc.text;
        self.orgName.text = self.crtOrgOrgName.text;
        self.orgName.text=self.crtOrgOrgName.text;
        [self closeOrgPopup:sender];
    }
}
- (IBAction)registerThisUser:(id)sender {
  
    self.errorText.text=@"";
    self.errorLyt.hidden=true;
    self.errorHieght.constant=0;
    self.errorTop.constant=0;
    NSString *errorMsg = [self validateUserData];
    
   
    if(errorMsg == nil){
        if(self.dedicatedPlan){
            
            [self addDedicatedMembershipRequest];
        }else{
            if(self.makePayment){
                [self showStripePopup];
            }else{
                [self addUser:nil];
            }
            
            
        }
    }else{
        self.errorText.text=errorMsg;
        self.errorLyt.hidden=false;
        self.errorHieght.constant=30;
        self.errorTop.constant=10;

    }
    
}
-(NSString *) validateUserData{
    NSString *error=nil;
    if(!self.dedicatedPlan){
        if(!self.tcAccepted){
            return @"Please accept terms and conditions";
        }
    }
    if(self.email.text == nil || self.email.text.length == 0){
        return @"Please enter a valid email";
    }
    if(self.dedicatedPlan){
        if(self.noOfSeats.text == nil || self.noOfSeats.text.length == 0){
            return @"Please enter required no of seats";
        }
        
        if(self.contactNo.text == nil || self.contactNo.text.length == 0){
            return @"Please enter contact no";
        }
    }else{
        if(self.password.text == nil || self.password.text.length == 0){
            return @"Please enter a valid password";
        }
        if(self.confPassword.text == nil || self.confPassword.text.length == 0){
            return @"Please confirm password";
        }
        if(![self.confPassword.text isEqualToString:self.password.text]){
            return @"Password and confirm password does not match";
        }
        if(!self.individual && self.selectedOrg == nil){
            return @"Please select/create organization";
        }
    }
    
    
    
    return error;
}
- (IBAction)submitStripePayment:(id)sender {


    self.crtOrgError.text= @"";
    self.crtOrgError.hidden=true;
    self.strpSubmitBtn.backgroundColor=[UIColor grayColor];
    self.strpSubmitBtn.userInteractionEnabled=FALSE;
    self.strpSubmitBtn.enabled=FALSE;
    
    self.strpCancelBtn.backgroundColor=[UIColor grayColor];
    self.strpCancelBtn.userInteractionEnabled=FALSE;
    self.strpCancelBtn.enabled=FALSE;
   if(self.adminAcctModel.strpPubKey == (id)[NSNull null] || self.adminAcctModel.strpPubKey == nil){
       self.crtOrgError.text= @"Invalid Stripe  account";
       self.crtOrgError.hidden=false;
        //[self.delegate stripePaymentViewController:self didFinish:error];
       /* for(UIView *subViews in [self.crtOrgPopup subviews]){
            [subViews removeFromSuperview];
        }
        for(UIView *subViews in [[UIApplication sharedApplication].keyWindow subviews]){
            subViews.alpha=1.0;
            subViews.userInteractionEnabled=TRUE;
        }
        [self.crtOrgPopup removeFromSuperview];
        self.view.alpha=1.0;
        self.view.userInteractionEnabled=TRUE;*/
        
        return;
    }
    NSString *publicKey=[self.utils decode:self.adminAcctModel.strpPubKey];
    @try{
        NSLog(@"%@",publicKey);
        self.strpClient = [[STPAPIClient alloc] initWithPublishableKey:publicKey];
        [Stripe setDefaultPublishableKey:publicKey];
        NSLog(@"%@",self.strpClient.publishableKey);
        if (![self.strpPymntTf isValid]) {
            self.crtOrgError.text= @"Invalid Card";
            self.crtOrgError.hidden=false;
            self.strpCancelBtn.backgroundColor=[self.wnpCont getThemeBaseColor];
            // self.strpCancelBtn.backgroundColor=[UIColor grayColor];
            
            self.strpCancelBtn.userInteractionEnabled=TRUE;
            self.strpCancelBtn.enabled=TRUE;
            return;
        }
        if (![Stripe defaultPublishableKey]) {

            self.crtOrgError.text= @"Invalid key";
            self.crtOrgError.hidden=false;
            self.strpCancelBtn.backgroundColor=[self.wnpCont getThemeBaseColor];
            // self.strpCancelBtn.backgroundColor=[UIColor grayColor];
            
            self.strpCancelBtn.userInteractionEnabled=TRUE;
            self.strpCancelBtn.enabled=TRUE;
            return;
        }
        
        [self.strpClient createTokenWithCard:self.strpPymntTf.card completion:^(STPToken *token, NSError *error) {
            if (error) {
                self.crtOrgError.text= error.description;
                self.crtOrgError.hidden=false;
                self.strpCancelBtn.backgroundColor=[self.wnpCont getThemeBaseColor];
                // self.strpCancelBtn.backgroundColor=[UIColor grayColor];
                
                self.strpCancelBtn.userInteractionEnabled=TRUE;
                self.strpCancelBtn.enabled=TRUE;
                return;
            }else{
                [self addUser:token.tokenId];
            }
        }];
        
        
        
       
        
    }@catch(NSException *exception) {
        self.crtOrgError.text= exception.description;
        self.crtOrgError.hidden=false;
        self.strpCancelBtn.backgroundColor=[self.wnpCont getThemeBaseColor];
        // self.strpCancelBtn.backgroundColor=[UIColor grayColor];
        
        self.strpCancelBtn.userInteractionEnabled=TRUE;
        self.strpCancelBtn.enabled=TRUE;
        return;

    }

    
    
}

- (IBAction)cancelStripePayment:(id)sender {
    [self.crtOrgPopup removeFromSuperview];
    for(UIView *subViews in self.view.subviews){
        subViews.alpha=1.0;
        subViews.userInteractionEnabled=TRUE;
    }
    self.view.alpha=1.0;
    self.view.userInteractionEnabled=TRUE;
}
- (void)paymentCardTextFieldDidChange:(nonnull STPPaymentCardTextField *)textField {
    self.strpSubmitBtn.enabled = textField.isValid;
    if(textField.isValid){
        [self hideKeyBord];
        self.strpSubmitBtn.backgroundColor=[self.wnpCont getThemeBaseColor];
    }
    
}
- (void)checkTC:(UITapGestureRecognizer *) rec{
   
    if(self.tcAccepted){
        self.tcAccepted=FALSE;
        [self.tcChecbox setImage:[UIImage imageNamed:@"checkbox_unsel.png"]];
    }else{
        self.tcAccepted=TRUE;
        [self.tcChecbox setImage:[UIImage imageNamed:@"checkbox_sel.png"]];
    }
     [self hideKeyBord];
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

- (void)closeTC:(UITapGestureRecognizer *) rec{
    
    [[self.view viewWithTag:55] removeFromSuperview];
    [[self.view viewWithTag:65] removeFromSuperview];
}
-(void) hideKeyBord{
    [self.strpPymntTf resignFirstResponder];
    [self.view endEditing:YES];
}
- (void)performBackgroundTask:(NSString *)purpose
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        if([purpose isEqualToString:@"INDIVIDUAL"]){
            
            indicator.frame = CGRectMake(0.0, 0.0, 80.0, 80.0);
            CGAffineTransform transform = CGAffineTransformMakeScale(2.0f, 2.0f);
            indicator.transform = transform;
            indicator.center = self.view.center;
            [self.view addSubview:indicator];
            [indicator bringSubviewToFront:self.view];
            [indicator startAnimating];
            @try{
                self.individualOrg= [self.smSpaceDAO getIndividualOrg];
            }@catch(NSException *exp){
                
            }
        }else{
            @try{
                self.orgList =[self.smSpaceDAO getAllOrganizationNames];
                
            }@catch(NSException *exp){
                
            }
        }
    
       
        dispatch_async(dispatch_get_main_queue(), ^{
            if([purpose isEqualToString:@"INDIVIDUAL"]){
               [indicator stopAnimating];
                self.selectedOrg=self.individualOrg;
            }else{
               
            }
            
            
            
        });
    });
}
-(void )addDedicatedMembershipRequest{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *error = nil;
        NSString *status = nil;
        UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        
            
            indicator.frame = CGRectMake(0.0, 0.0, 80.0, 80.0);
            CGAffineTransform transform = CGAffineTransformMakeScale(2.0f, 2.0f);
            indicator.transform = transform;
            indicator.center = self.view.center;
            [self.view addSubview:indicator];
            [indicator bringSubviewToFront:self.view];
            [indicator startAnimating];
            @try{
                UserRequestModel *userReqModel = [[UserRequestModel alloc]init];
                userReqModel.email=self.email.text;
                userReqModel.name =self.userName.text;
                userReqModel.noOfSeats=[NSNumber numberWithInt:self.noOfSeats.text.intValue];
                userReqModel.contactNo=self.contactNo.text;
                userReqModel.planName=self.selectedPlan.planName;
                status = [self.userDao addDedicatedMembershipRequest:userReqModel OfferModel: self.selectedOffer AddOnList:self.addOnAArray];
                

            }@catch(NSException *exp){
                error = exp.description;
            }
       
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [indicator stopAnimating];
            if(error != nil){
                self.errorText.text=error;
                self.errorLyt.hidden=false;
                self.errorHieght.constant=30;
                self.errorTop.constant=10;
            }else if(status != nil && [status isEqualToString:@"SUCCESS"]){
                [self showPopup:@"Thank you" Message:@"Your request processed successfully. Our community manager will contact you soon."];
            }else{
                self.errorText.text=status;
                self.errorLyt.hidden=false;
                self.errorHieght.constant=30;
                self.errorTop.constant=10;
            }
            
            
        });
    });

}

-(void )addUser:(NSString *)tokenId{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *error = nil;
        NSString *status = nil;
        UserModel *addedModel = nil;
         NSMutableArray *plnIdArray = [[NSMutableArray alloc]init];
        UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        
        
        indicator.frame = CGRectMake(0.0, 0.0, 80.0, 80.0);
        CGAffineTransform transform = CGAffineTransformMakeScale(2.0f, 2.0f);
        indicator.transform = transform;
        indicator.center = self.view.center;
      //  if(tokenId == nil){
            [self.view addSubview:indicator];
            [indicator bringSubviewToFront:self.view];
       // }else{
           // [self.crtOrgPopup addSubview:indicator];
           // [indicator bringSubviewToFront:self.crtOrgPopup];
       // }
        
        [indicator startAnimating];
        @try{
            UserModel *userModel = [[UserModel alloc]init];
            userModel.userName=self.email.text;
            userModel.email=self.email.text;
            userModel.password =[self.utils encode:self.password.text];
            userModel.userId = [NSNumber numberWithInt:0];
            userModel.roleId = [NSNumber numberWithInt:0];
            userModel.firstName = self.userName.text;
            NSMutableArray *orgArray = [[NSMutableArray alloc]init];
            if(self.selectedOrg != nil){
                [orgArray addObject:[self.selectedOrg dictionaryWithPropertiesOfObject:self.selectedOrg]];
            }
            userModel.orgList=orgArray;
            
            NSString *userCode = nil;
            if(self.alreadyRegistered){
                userCode = @"Existing";
            }
            for(PlanModel *pln in self.selectedPlanArray){
                [plnIdArray addObject:pln.planId];
            }
            addedModel = [self.userDao createUser:userModel OfferModel: self.selectedOffer AddOnList:self.addOnAArray UserRegCode:userCode CardToken:tokenId PlanIds:plnIdArray TrialEndsAt:self.trialEndsAt TrailDays:self.noOfdaystoSubsDate Gateway:@"STRIPE"] ;

            
        }@catch(NSException *exp){
            error = exp.description;
        }
        
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if(error != nil){
                [indicator stopAnimating];
                //self.errorText.text=error;
               // self.errorLyt.hidden=false;
                self.crtOrgError.text= error;
                self.crtOrgError.hidden=false;
                //self.errorHieght.constant=30;
               // self.errorTop.constant=10;
                self.strpCancelBtn.backgroundColor=[self.wnpCont getThemeBaseColor];
                self.strpCancelBtn.userInteractionEnabled=TRUE;
                self.strpCancelBtn.enabled=TRUE;
                self.errorText.text=error;
                self.errorLyt.hidden=false;
                self.errorHieght.constant=30;
                self.errorTop.constant=10;
                self.strpCancelBtn.backgroundColor=[self.wnpCont getThemeBaseColor];
                self.strpCancelBtn.userInteractionEnabled=TRUE;
                self.strpCancelBtn.enabled=TRUE;
                NSLog(error);

            }else{
                if(addedModel != nil){
                    if(tokenId == nil){
                        [indicator stopAnimating];
                       [self showPopup:@"Successful" Message:@"Please use the verification code send to your email for login."];
                    }else{
                        NSLog(@"taking one time payment");
                        if(self.initilaPaymentAmount.doubleValue > 0){
                            [self.strpClient createTokenWithCard:self.strpPymntTf.card completion:^(STPToken *token, NSError *error) {
                                if (error) {
                                    self.crtOrgError.text= error.description;
                                    self.crtOrgError.hidden=false;
                                    self.strpCancelBtn.backgroundColor=[self.wnpCont getThemeBaseColor];
                                    // self.strpCancelBtn.backgroundColor=[UIColor grayColor];
                                    
                                    self.strpCancelBtn.userInteractionEnabled=TRUE;
                                    self.strpCancelBtn.enabled=TRUE;
                                    return;
                                }else{
                                   
                                   
                                    self.strpDAO = [[StripeDAO alloc]init];
                                    @try{
                                        NSString *status= [self.strpDAO doStripePayment:[NSNumber numberWithDouble:self.initilaPaymentAmount.doubleValue] ID:addedModel.userId CardToken:token.tokenId Currency:@"USD" Description:[NSString stringWithFormat:@"%s%@","One time payment for registering",self.email.text] IsDealerAccount:FALSE];
                                        NSLog(@"status one time payment");
                                         NSLog(@"%@",status);
                                        NSMutableDictionary *orgDic = [addedModel.orgList objectAtIndex:0];
                                        OrganizationModel *org = [[OrganizationModel alloc]init];
                                        org = [org initWithDictionary:orgDic];
                                        NSDate *startDate = [NSDate date];
                                        
                                        NSNumber *plnStart = [NSNumber numberWithLongLong:[startDate timeIntervalSince1970]*1000];
                                      
                                        for(PlanModel *pln in self.selectedPlanArray){
                                            [plnIdArray addObject:pln.planId];
                                        }
                                        [self.smSpaceDAO updatePlanForOrg:addedModel.userId OrgId:org.orgId PlanIds:plnIdArray CustomerId:@"Onetime payment" SubscriptionId:status PlanStartDate:plnStart PlanEndDate:self.firstsubDate PymntGateway:@"Stripe" EventType:@"onetimepayment" EventId:status];
                                        
                                        
                                        [self.crtOrgPopup removeFromSuperview];
                                        for(UIView *subViews in self.view.subviews){
                                            subViews.alpha=1.0;
                                            subViews.userInteractionEnabled=TRUE;
                                        }
                                        self.view.alpha=1.0;
                                        self.view.userInteractionEnabled=TRUE;
                                        [self showPopup:@"Successful" Message:@"Please use the verification code send to your email for login."];
                                    }@catch(NSException *exp){
                                        self.errorText.text=exp.description;
                                        self.errorLyt.hidden=false;
                                        self.strpCancelBtn.backgroundColor=[self.wnpCont getThemeBaseColor];
                                        // self.strpCancelBtn.backgroundColor=[UIColor grayColor];
                                        self.errorHieght.constant=30;
                                        self.errorTop.constant=10;
                                        self.strpCancelBtn.userInteractionEnabled=TRUE;
                                        self.strpCancelBtn.enabled=TRUE;
                                    }
                                }
                            }];
                        }else{
                            [indicator stopAnimating];
                            [self.crtOrgPopup removeFromSuperview];
                            for(UIView *subViews in self.view.subviews){
                                subViews.alpha=1.0;
                                subViews.userInteractionEnabled=TRUE;
                            }
                            self.view.alpha=1.0;
                            self.view.userInteractionEnabled=TRUE;
                            [self showPopup:@"Successful" Message:@"Please use the verification code send to your email for login."];
                        }

                    }
                    
                }else{
                    [indicator stopAnimating];
                    self.errorText.text=@"Failed to add user";
                    self.errorLyt.hidden=false;
                    self.errorHieght.constant=30;
                    self.errorTop.constant=10;
                    self.strpCancelBtn.backgroundColor=[self.wnpCont getThemeBaseColor];
                    self.strpCancelBtn.userInteractionEnabled=TRUE;
                    self.strpCancelBtn.enabled=TRUE;
                    self.errorText.text=@"Failed to add user";
                    self.errorLyt.hidden=false;
                    self.errorHieght.constant=30;
                    self.errorTop.constant=10;
                    self.strpCancelBtn.backgroundColor=[self.wnpCont getThemeBaseColor];
                    self.strpCancelBtn.userInteractionEnabled=TRUE;
                    self.strpCancelBtn.enabled=TRUE;
                }
            }
        });
    });
    
}
@end
