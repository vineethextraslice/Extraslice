//
//  ShowPlansController.m
//  extraSlice
//
//  Created by Administrator on 19/06/16.
//  Copyright © 2016 Extraslice Inc. All rights reserved.
//

#import "SelectPlanController.h"
#import "UserDataController.h"
#import "LoginController.h"
#import "SmartSpaceDAO.h"
#import "AdminAccountModel.h"
#import "OrganizationModel.h"
#import "PlanModel.h"
#import "WnPConstants.h"
#import "ResourceTypeModel.h"
#import "Utilities.h"

double payableAmountVal=0;

@interface SelectPlanController ()
@property(strong,nonatomic) WnPConstants *wnpConst;
@property(strong,nonatomic) SmartSpaceDAO *smartSpaceDAO;
//@property(strong,nonatomic) UIColor *bgColor;
@property(strong,nonatomic) NSMutableArray *selectedPlanResourcse;
@property(strong,nonatomic) UILabel *selectedPyblLbl;
@property(strong,nonatomic)  NSMutableSet *selectedAddonIds;
@property(strong,nonatomic) Utilities *utils;
@end

@implementation SelectPlanController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.selectedAddonIds= [[NSMutableSet alloc] init];
    self.utils = [[Utilities alloc]init];
    //self.bgColor = [UIColor colorWithRed:92.0/255.0 green:172.0/255.0 blue:230.0/255.0 alpha:1.0];
    self.wnpConst = [[WnPConstants alloc]init];
    self.headerView.backgroundColor=[self.wnpConst getThemeBaseColor];
   
    
    self.errorViewHeight.constant = 0;
    self.errorText.text= @"";
    self.errorView.hidden = true;
    self.errorViewTop.constant=0;
    UITapGestureRecognizer *gobackTap = [[UITapGestureRecognizer alloc] initWithTarget:self action: @selector(goBack:)];
    gobackTap.numberOfTapsRequired = 1;
    gobackTap.numberOfTouchesRequired = 1;
    [self.goBack setUserInteractionEnabled:YES];
    [self.goBack addGestureRecognizer:gobackTap];
    
    UITapGestureRecognizer *gobackViewTap = [[UITapGestureRecognizer alloc] initWithTarget:self action: @selector(goBack:)];
    gobackViewTap.numberOfTapsRequired = 1;
    gobackViewTap.numberOfTouchesRequired = 1;
    [self.gobackView setUserInteractionEnabled:YES];
    [self.gobackView addGestureRecognizer:gobackViewTap];
    [self.view bringSubviewToFront:self.gobackView];
    
    @try{
        self.smartSpaceDAO = [[SmartSpaceDAO alloc]init];
        [self.smartSpaceDAO getPlanAndOrgDetl];
        self.orgList = self.smartSpaceDAO.orgArray;
        self.adminAcctModel=[self.smartSpaceDAO getAdminAccount];
        self.planArray = self.smartSpaceDAO.planArray ;
        self.existingMmbrLyt.hidden=false;
    }@catch(NSException *exp){
        self.errorViewHeight.constant = 30;
        self.errorText.text= exp.description;
        self.errorView.hidden = false;
        self.errorViewTop.constant=5;
        self.existingMmbrLyt.hidden=true;
    }
        

   /* CGRect screenRect = [[UIScreen mainScreen] bounds];
    float scrHeight = (100+(self.planArray.count*34));
    self.scrollViewHeight.constant = scrHeight;
    self.bcImageHeight.constant=(screenRect.size.height-scrHeight);*/
    
    UITapGestureRecognizer *regUserTap = [[UITapGestureRecognizer alloc] initWithTarget:self action: @selector(loadRegisteredUserData:)];
    regUserTap.numberOfTapsRequired = 1;
    regUserTap.numberOfTouchesRequired = 1;
    [self.registeredUser setUserInteractionEnabled:YES];
    [self.registeredUser addGestureRecognizer:regUserTap];
    [self collpasePlan];
   
}
-(void) viewDidAppear:(BOOL)animated{
    
}

- (void)collpasePlan{
    
    int index = 0;
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat tableWidth = screenRect.size.width;
    self.bcImage.hidden=false;
    float scrHeight = (self.planArray.count*64)+100;
    float scrHeight1 = screenRect.size.height-scrHeight;
    self.scrollViewHeight.constant = scrHeight;
    self.bcImageHeight.constant=scrHeight1;//();
    for(UIView *sv in self.planContainer.subviews){
        [sv removeFromSuperview];
    }
    self.selectedPlan =nil;
    for(PlanModel *plnModel in self.planArray){
        UIView *topView = [[UIView alloc] initWithFrame:CGRectMake(0, (index*64)+2 , tableWidth, 64)];
        
        
        UIImageView *expandImage = [[UIImageView alloc] initWithFrame:CGRectMake((tableWidth-30), 16 , 30, 30)];
        [expandImage setImage:[UIImage imageNamed:@"arrow_down.png"]];
        [topView addSubview: expandImage];
       
        UILabel *header = [[UILabel alloc] initWithFrame:CGRectMake(5, 0 , (tableWidth-30), 30)];
        [topView setBackgroundColor:[self.wnpConst getThemeColorWithTransparency:0.6]];
        header.text = plnModel.planName;
        header.textColor =[UIColor whiteColor];
        [topView addSubview: header];
        UIFont *txtFont = [header.font fontWithSize:18];
        header.font = txtFont;

        UILabel *desc = [[UILabel alloc] initWithFrame:CGRectMake(5, 32 , (tableWidth-30), 30)];
        desc.text = [NSString stringWithFormat:@"%s%@","Starts from $",plnModel.planPrice];
        desc.textColor =[UIColor whiteColor];
        [topView addSubview: desc];
        UIFont *desctxtFont = [desc.font fontWithSize:15];
        desc.font = desctxtFont;
        
        UITapGestureRecognizer *selectPlnTap = [[UITapGestureRecognizer alloc] initWithTarget:self action: @selector(expandPlan:)];
        selectPlnTap.numberOfTapsRequired = 1;
        selectPlnTap.numberOfTouchesRequired = 1;
        [topView setUserInteractionEnabled:YES];
        [topView addGestureRecognizer:selectPlnTap];
        topView.tag = index;

         UIView *divider = [[UIView alloc] initWithFrame:CGRectMake(0, (index*64)+64 , tableWidth, 2)];
        [divider setBackgroundColor:[UIColor whiteColor]];

        [self.planContainer addSubview:topView];
        [self.planContainer addSubview:divider];
        
        index++;
        
    }
}
- (void)expandPlan:(UITapGestureRecognizer *) rec{
    NSInteger position =  rec.view.tag;
   
    for(UIView *sv in self.planContainer.subviews){
        [sv removeFromSuperview];
    }
    [self.view bringSubviewToFront:self.planContainer];
    int index = 0;
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat tableWidth = screenRect.size.width;
    self.bcImage.hidden=true;
    self.scrollViewHeight.constant = screenRect.size.height-100;
    self.bcImageHeight.constant=0;
    int currY = 0;
    self.selectedAddonIds= [[NSMutableSet alloc] init];
   
    for(PlanModel *plnModel in self.planArray){
        int totalHeight = 34;
        if(position == index){
            self.selectedPlan =plnModel;
            self.selectedPlanResourcse = self.selectedPlan.resourceTypeList;
            totalHeight = screenRect.size.height - 95 - ((self.planArray.count-1)*34);
            payableAmountVal = self.selectedPlan.planPrice.doubleValue;
        }
         UIView *topView = [[UIView alloc] initWithFrame:CGRectMake(0, currY+2 , tableWidth, totalHeight)];
        UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0 , tableWidth, 30)];
        [self.planContainer addSubview:topView];
        [self.planContainer bringSubviewToFront:topView];

        
        
        UIImageView *expandImage = [[UIImageView alloc] initWithFrame:CGRectMake((tableWidth-30), 2 , 30, 30)];
         if(position == index){
             [expandImage setImage:[UIImage imageNamed:@"arrow_up.png"]];
         }else{
               [expandImage setImage:[UIImage imageNamed:@"arrow_down.png"]];
         }
        [header addSubview: expandImage];
        UILabel *headerTV = [[UILabel alloc] initWithFrame:CGRectMake(5, 0 , (tableWidth-60), 30)];
        
       
        
        [header addSubview: headerTV];
        [topView addSubview: header];
        
        header.tag = index;
                [self.planContainer bringSubviewToFront:header];
        NSLog(@"%s%d","here....................",index);
        if(position == index){
            UITapGestureRecognizer *selectPlnTap = [[UITapGestureRecognizer alloc] initWithTarget:self action: @selector(collpasePlan)];
            selectPlnTap.numberOfTapsRequired = 1;
            selectPlnTap.numberOfTouchesRequired = 1;
            [header setUserInteractionEnabled:YES];
            [header addGestureRecognizer:selectPlnTap];
            [header setBackgroundColor:[self.wnpConst getThemeBaseColor]];
            headerTV.text = plnModel.planName;
            headerTV.textColor =[UIColor whiteColor];
            UILabel *planPrice = [[UILabel alloc] initWithFrame:CGRectMake(0, 30 , (tableWidth), 30)];
            NSString *plnPrcDesc = @"Plan price : $";
            if(!plnModel.purchaseOnSpot){
                plnPrcDesc = @"Plan price : Starts from $";
            }
            planPrice.text = [NSString stringWithFormat:@"%@%@",plnPrcDesc,[self.utils getNumberFormatter:plnModel.planPrice.doubleValue]];
            [topView addSubview: planPrice];
            UIScrollView *scrollView  = [[UIScrollView alloc] initWithFrame:CGRectMake(5,69 , (tableWidth), totalHeight-170)];
            scrollView.scrollEnabled=true;
            scrollView.scrollsToTop=true;
            scrollView.contentSize = CGSizeMake(tableWidth, ((plnModel.resourceTypeList.count+1)*41) );
            int subIndex =0;
            float rowHeight=30;
            UIView *prevView = nil;
            UIView *prevNameView = nil;
            for(NSDictionary  *resTypeObj in plnModel.resourceTypeList){
                ResourceTypeModel *resType = [[ResourceTypeModel alloc]init];
                resType = [resType initWithDictionary:resTypeObj];

                UIView *rowView = [[UIView alloc] initWithFrame:CGRectMake(0, 5 , (tableWidth), rowHeight)];
                if(prevView !=nil){
                    CGSize lastRect = [prevNameView sizeThatFits: prevNameView.frame.size];
                    float lastHeight = rowHeight;
                    if(lastRect.height > rowHeight){
                        lastHeight = lastRect.height;
                    }
                    NSLog(@"%s%@%f","frame size",resType.resourceTypeName,lastHeight);
                    rowView = [[UIView alloc] initWithFrame:CGRectMake(0, (prevView.frame.origin.y+lastHeight+5) , (tableWidth), rowHeight)];
                }
               ;
                [rowView sizeToFit];
                                bool isAddOn = false;
                if([resType.allowUsageBy isEqualToString:@"ondemand"]){
                    isAddOn = true;
                }
                UIImageView *selectAddOn = [[UIImageView alloc] initWithFrame:CGRectMake(2, 2 , 25, 25)];
                [selectAddOn setImage:[UIImage imageNamed:@"checkbox_unsel.png"]];
                
               
                [rowView addSubview: selectAddOn];
                
                UILabel *resourceName = [[UILabel alloc] initWithFrame:CGRectMake(32, 2 , ((tableWidth-35)*0.55), rowHeight)];
                resourceName.numberOfLines=0;
                resourceName.lineBreakMode=NSLineBreakByWordWrapping;
                resourceName.text = resType.resourceTypeName;
                [resourceName sizeToFit];
                
                [rowView addSubview: resourceName];
                
                UILabel *limit = [[UILabel alloc] initWithFrame:CGRectMake(34+((tableWidth-35)*0.55), 2, ((tableWidth-35)*0.35), rowHeight)];
                
                limit.numberOfLines=-1;
                [rowView addSubview: limit];
                UILabel *price = [[UILabel alloc] initWithFrame:CGRectMake(36+((tableWidth-35)*0.85), 2, ((tableWidth-35)*0.15), rowHeight)];
                price.text = [NSString stringWithFormat:@"%s%@","$",[self.utils getNumberFormatter:resType.planSplPrice.doubleValue]];
                if(isAddOn){
                    selectAddOn.hidden = false;
                    selectAddOn.tag=resType.resourceTypeId.intValue;
                    UITapGestureRecognizer *selAddOnTap = [[UITapGestureRecognizer alloc] initWithTarget:self action: @selector(addAddOn:)];
                    selAddOnTap.numberOfTapsRequired = 1;
                    selAddOnTap.numberOfTouchesRequired = 1;
                    [selectAddOn setUserInteractionEnabled:YES];
                    [selectAddOn addGestureRecognizer:selAddOnTap];
                    limit.text = @"Add-on";
                }else{
                    if([resType.allowUsageBy isEqualToString:@"free"] || resType.planLimit.intValue == -1){
                        limit.text = @"Unlimited";
                    }else if(resType.planLimit.intValue == 0){
                        limit.text = [NSString stringWithFormat:@"%s%@%s%@","$",resType.planSplPrice,"/",resType.planLimitUnit];
                    }else{
                        limit.text = [NSString stringWithFormat:@"%@%s%@",resType.planLimit," ",resType.planLimitUnit];
                    }
                    
                    selectAddOn.hidden = true;
                }
                
                 [limit sizeToFit];
                [rowView addSubview: price];
                if(isAddOn){
                    price.hidden = false;
                }else{
                    price.hidden = true;
                }
                [scrollView addSubview:rowView];
                prevView=rowView;
                prevNameView=resourceName;
                subIndex++;
            }
            [topView addSubview: scrollView];
            NSString *pyblDesc = @"Payable amount : $";
            if(!plnModel.purchaseOnSpot){
                pyblDesc = @"Payable amount : Starts from $";
            }
            UILabel *payableAmt = [[UILabel alloc] initWithFrame:CGRectMake(5, totalHeight-105 , (tableWidth), 30)];
            payableAmt.text=[NSString stringWithFormat:@"%@%@",pyblDesc,[self.utils getNumberFormatter:plnModel.planPrice.doubleValue]];
            
            self.selectedPyblLbl = payableAmt;
            [topView addSubview: payableAmt];
            UIButton *joinNow = [[UIButton alloc] initWithFrame:CGRectMake(self.view.center.x-125, totalHeight-70 , 250, 30)];
            joinNow.backgroundColor=[self.wnpConst getThemeBaseColor];
            
            [joinNow setTitle: @"Join now" forState: UIControlStateNormal];
            joinNow.userInteractionEnabled=TRUE;
            joinNow.enabled=TRUE;
            [joinNow addTarget:self action:@selector(loadUserData:) forControlEvents: UIControlEventTouchUpInside];
            [topView addSubview: joinNow];
            
            [topView bringSubviewToFront:scrollView];
            [topView bringSubviewToFront:joinNow];
        }else{
            [header setBackgroundColor:[self.wnpConst getThemeColorWithTransparency:0.6]];
            headerTV.text = plnModel.planName;
            headerTV.textColor =[UIColor whiteColor];
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action: @selector(expandPlan:)];
            tap.numberOfTapsRequired = 1;
            tap.numberOfTouchesRequired = 1;
            [header setUserInteractionEnabled:YES];
            [header addGestureRecognizer:tap];
        }
        UIView *divider = [[UIView alloc] initWithFrame:CGRectMake(0, currY+64 , tableWidth, 2)];
        [divider setBackgroundColor:[UIColor whiteColor]];
        [self.planContainer addSubview:divider];
        currY = currY+totalHeight;
        index++;
        
    }

    
    
    //
    
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

- (IBAction)loadUserData:(id)sender {
    UIStoryboard *stryBrd = [UIStoryboard storyboardWithName:@"UserData" bundle:nil];
    UserDataController *viewCtrl=[stryBrd instantiateViewControllerWithIdentifier:@"UserData"];
    viewCtrl.selectedPlan = self.selectedPlan;
    viewCtrl.orgList = self.orgList;
    viewCtrl.adminAcctModel = self.adminAcctModel;
    viewCtrl.planArray= self.planArray;
    viewCtrl.payableAmount = [NSNumber numberWithDouble:payableAmountVal];
    NSMutableArray *addOnAArray = [[NSMutableArray alloc]init];
    ResourceTypeModel *resTypeMdl = [[ResourceTypeModel alloc]init];
    for(NSDictionary *itemsInArray in self.selectedPlanResourcse){
        resTypeMdl = [resTypeMdl initWithDictionary: itemsInArray];
        if([self.selectedAddonIds containsObject:resTypeMdl.resourceTypeId]){
             [addOnAArray addObject:itemsInArray];
        }
    }
    /*for(NSNumber *idNum in self.selectedAddonIds){
        [addOnAArray addObject:[self.selectedPlanResourcse objectAtIndex:idNum.intValue]];
    }*/
    viewCtrl.addOnAArray =addOnAArray;
    [self.utils loadViewControlleWithAnimation:self NextController:viewCtrl];
    
}

- (void)goBack:(UITapGestureRecognizer *) rec{
    UIStoryboard *stryBrd = [UIStoryboard storyboardWithName:@"LoginController" bundle:nil];
    LoginController *viewCtrl=[stryBrd instantiateViewControllerWithIdentifier:@"LoginController"];
    [self.utils loadViewControlleWithAnimation:self NextController:viewCtrl];
    
}
- (void)loadRegisteredUserData:(UITapGestureRecognizer *) rec{
    UIStoryboard *stryBrd = [UIStoryboard storyboardWithName:@"UserData" bundle:nil];
    UserDataController *viewCtrl=[stryBrd instantiateViewControllerWithIdentifier:@"UserData"];
    viewCtrl.selectedPlan = nil;
    viewCtrl.orgList = self.orgList;
    viewCtrl.adminAcctModel = self.adminAcctModel;
    viewCtrl.planArray= self.planArray;
    viewCtrl.addOnAArray =[[NSMutableArray alloc]init];;
    [self.utils loadViewControlleWithAnimation:self NextController:viewCtrl];
    
}

- (void)addAddOn:(UITapGestureRecognizer *) rec{
    int resId = rec.view.tag;
    if(resId >0 ){
        bool found=false;
        ResourceTypeModel *resTypeMdl = [[ResourceTypeModel alloc]init];
        for(NSDictionary *itemsInArray in self.selectedPlanResourcse){
            resTypeMdl = [resTypeMdl initWithDictionary: itemsInArray];
            if(resTypeMdl.resourceTypeId.intValue == resId ){
                found = true;
                break;
                
            }
        }
        if(found){
            
            UIImageView *planImg = (UIImageView *)rec.view;
            NSNumber *currPos = [NSNumber numberWithInt:resId];
            if([self.selectedAddonIds containsObject:currPos]){
                [self.selectedAddonIds removeObject:currPos];
                self.selectedPyblLbl.text=[NSString stringWithFormat:@"%s%@","Payable amount : $",[self.utils getNumberFormatter:(payableAmountVal-resTypeMdl.planSplPrice.doubleValue)]];
                payableAmountVal = payableAmountVal -resTypeMdl.planSplPrice.doubleValue;
                [planImg setImage:[UIImage imageNamed:@"checkbox_unsel.png"]];
                
            }else{
                [self.selectedAddonIds addObject:currPos];
                self.selectedPyblLbl.text=[NSString stringWithFormat:@"%s%@","Payable amount : $",[self.utils getNumberFormatter:(payableAmountVal+resTypeMdl.planSplPrice.doubleValue)]];
                payableAmountVal = payableAmountVal +resTypeMdl.planSplPrice.doubleValue;
                [planImg setImage:[UIImage imageNamed:@"checkbox_sel.png"]];
            }

        }
    }
}
@end
