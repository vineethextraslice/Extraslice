//
//  PlanDetails.m
//  extraSlice
//
//  Created by Administrator on 28/09/16.
//  Copyright © 2016 Extraslice Inc. All rights reserved.
//

#import "PlanDetails.h"
#import "ResourceTypeModel.h"
#import "Utilities.h"
#import "ESliceConstants.h"
#import "SelectPlanController.h"
#import "UserDataController.h"


double totalAmountVal=0;
double addonPrice=0;
double offerPercent=0;
@interface PlanDetails ()
@property(strong,nonatomic) ESliceConstants *wnpConst;
@property(strong,nonatomic) Utilities *utils;
@property(strong,nonatomic) PlanOfferModel *selectedOffer;
@property(strong,nonatomic)  NSMutableSet *selectedAddonIds;
@property(strong,nonatomic) NSMutableDictionary *selectedPlnMap;
@property(strong,nonatomic) NSMutableArray *selectedPlnArray;
@property(strong,nonatomic) UIView *popup;

@end

@implementation PlanDetails

- (void)viewDidLoad {
    [super viewDidLoad];
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    int screenHeight=screenRect.size.height;
    int screenWidth=screenRect.size.width;
    int subIndex =0;
    float rowHeight=30;
    self.utils = [[Utilities alloc]init];
    self.wnpConst = [[ESliceConstants alloc]init];
    self.selectedPlnArray=[[NSMutableArray alloc]init];
    self.selectedAddonIds=[[NSMutableSet alloc]init];
    self.selectedPlnMap =[[NSMutableDictionary alloc]init];
    
  
     self.planNameTV.textColor=[self.utils getThemeLightBlue];
    self.planShortDesc.backgroundColor=[self.utils getThemeLightBlue];
    self.offerHeader.backgroundColor=[self.utils getThemeLightBlue];
    self.addonHeader.backgroundColor=[self.utils getThemeLightBlue];
    self.resourceMainHeader.backgroundColor=[self.utils getThemeLightBlue];
    self.resourceHeader.backgroundColor=[self.utils getLightGray];
    
    self.offerScrView.layer.borderColor = [self.utils getThemeLightBlue].CGColor;
    self.offerScrView.layer.borderWidth = 1.0f;

    self.addonScrView.layer.borderColor = [self.utils getThemeLightBlue].CGColor;
    self.addonScrView.layer.borderWidth = 1.0f;

    
   
    self.addToCartBtn.backgroundColor=[self.utils getThemeLightBlue];

    self.planCost.layer.borderColor=[self.utils getThemeLightBlue].CGColor;
     self.planCost.layer.borderWidth = 1.0f;
    if(!self.selectedPlnModel.purchaseOnSpot){
        [self.addToCartBtn setTitle: @"Check availability" forState: UIControlStateNormal];
    }
    
    UITapGestureRecognizer *goBackTap = [[UITapGestureRecognizer alloc] initWithTarget:self action: @selector(goBackToPlans:)];
    goBackTap.numberOfTapsRequired = 1;
    goBackTap.numberOfTouchesRequired = 1;
    [self.goBack setUserInteractionEnabled:YES];
    [self.goBack addGestureRecognizer:goBackTap];
    
    self.planCost.text=[NSString stringWithFormat:@"%s%@" ,"Plan cost : $",[self.utils getNumberFormatter:self.selectedPlnModel.planPrice.doubleValue]];
    totalAmountVal=self.selectedPlnModel.planPrice.doubleValue;
    UIView *prevView = nil;
    UIView *prevNameView = nil;
    //int screenplanHt=screenHeight-(headerHieght+cartHeight+addonHeight);
    
    self.planNameTV.text=self.selectedPlnModel.planName;
    self.planShortDesc.text = [NSString stringWithFormat:@"%@%s%@%s",self.selectedPlnModel.planName," ($",[self.utils getNumberFormatter:self.selectedPlnModel.planPrice.doubleValue],")"];
    
    
    UILabel *resourceNameHead = [[UILabel alloc] initWithFrame:CGRectMake(0, 0 , ((screenWidth-10)*0.6)+1, 32)];
    resourceNameHead.layer.borderWidth=1;
    resourceNameHead.layer.borderColor=[UIColor whiteColor].CGColor;
    resourceNameHead.text = @" Resource name";
    [self.resourceHeader addSubview: resourceNameHead];
    
    UILabel *limit = [[UILabel alloc] initWithFrame:CGRectMake(((screenWidth-10)*0.6)+1, 0, ((screenWidth-10)*0.4)+1, 32)];
    limit.layer.borderWidth=1;
    limit.layer.borderColor=[UIColor whiteColor].CGColor;
    limit.text = @" Usable limit";
    [self.resourceHeader addSubview: limit];

    int totalLytHeight = (int)(self.selectedPlnModel.resourceTypeList.count)*32;
    int addOnHeight = (int)((self.addonList.count*32)+(self.offerList.count*45)+(65+20+30+20+30+20+30+10+30+10+30+20+30+20));
    if(screenHeight - addOnHeight<totalLytHeight){
        self.planDetlHieght.constant = screenHeight - addOnHeight;
        self.resorceHeaderHeight.constant=0;
        self.planDetlHieght.constant=35;
        self.planDetlScrView.layer.borderColor = [self.utils getThemeLightBlue].CGColor;
        self.planDetlScrView.layer.borderWidth = 1.0;
        self.resourceHeader.hidden=true;
        float centerX = self.view.center.x;
        
        UILabel *showPlanLbl = [[UILabel alloc] initWithFrame:CGRectMake(centerX-60, 2 , 120, 30)];
        [self.planDetlScrView addSubview: showPlanLbl];
        
        NSDictionary *attrs =@{NSFontAttributeName:[UIFont boldSystemFontOfSize:16],NSForegroundColorAttributeName:[UIColor blueColor],NSUnderlineStyleAttributeName : @(NSUnderlineStyleSingle | NSUnderlinePatternSolid),NSUnderlineColorAttributeName:[UIColor blueColor] };
        NSDictionary *subAttrs =@{NSFontAttributeName:[UIFont systemFontOfSize:14],NSUnderlineStyleAttributeName: @(NSUnderlineStyleNone)};
        NSString *str = @"View details";
        NSRange theRange = NSMakeRange(0,str.length);
        NSMutableAttributedString *viewUrl=[[NSMutableAttributedString alloc]initWithString:str attributes:subAttrs];
        [viewUrl setAttributes:attrs range:theRange];
        showPlanLbl.attributedText = viewUrl;
        showPlanLbl.textAlignment=NSTextAlignmentCenter;
        showPlanLbl.numberOfLines=1;
        UITapGestureRecognizer *viewPlanTap = [[UITapGestureRecognizer alloc] initWithTarget:self action: @selector(showPlanDetlPopup)];
        viewPlanTap.numberOfTapsRequired = 1;
        viewPlanTap.numberOfTouchesRequired = 1;
        [showPlanLbl setUserInteractionEnabled:YES];
        [showPlanLbl addGestureRecognizer:viewPlanTap];
    }else{
        totalLytHeight = 0;
        for(NSDictionary  *resTypeObj in self.selectedPlnModel.resourceTypeList){
            ResourceTypeModel *resType = [[ResourceTypeModel alloc]init];
            resType = [resType initWithDictionary:resTypeObj];
            if([resType.allowUsageBy isEqualToString:@"ondemand"]){
                continue;
            }
            UIView *rowView = [[UIView alloc] initWithFrame:CGRectMake(0, 0 , (screenWidth), rowHeight)];
            if(prevView !=nil){
                CGSize lastRect = [prevNameView sizeThatFits: prevNameView.frame.size];
                float lastHeight = rowHeight;
                if(lastRect.height > rowHeight){
                    lastHeight = lastRect.height;
                }
                rowView = [[UIView alloc] initWithFrame:CGRectMake(0, (prevView.frame.origin.y+lastHeight)-1 , (screenWidth), rowHeight)];
            }
            [rowView sizeToFit];
   
            if(resType.resourceDesc || resType.resourceDesc == nil || resType.resourceDesc.length==0){
               // rowHeight =30;
                UILabel *resourceName = [[UILabel alloc] initWithFrame:CGRectMake(0, 0 , ((screenWidth-10)*0.6), rowHeight)];
                resourceName.lineBreakMode=NSLineBreakByWordWrapping;
                resourceName.text = [NSString stringWithFormat:@"%s%@"," ",resType.resourceTypeName];
                resourceName.layer.borderWidth=1;
                resourceName.layer.borderColor=[self.utils getThemeLightBlue].CGColor;
                [rowView addSubview: resourceName];
            
                UILabel *limit = [[UILabel alloc] initWithFrame:CGRectMake(((screenWidth-10)*0.6)-1, 0, ((screenWidth-10)*0.4), rowHeight)];
                limit.numberOfLines=-1;
                limit.layer.borderWidth=1;
                limit.layer.borderColor=[self.utils getThemeLightBlue].CGColor;
                [rowView addSubview: limit];
            
                if([resType.allowUsageBy isEqualToString:@"free"] || resType.planLimit.intValue == -1){
                    limit.text = @" Unlimited";
                }else if(resType.planLimit.intValue == 0){
                    limit.text = [NSString stringWithFormat:@"%s%@%s%@"," $",resType.planSplPrice,"/",resType.planLimitUnit];
                }else{
                    limit.text = [NSString stringWithFormat:@"%s%@%s%@"," ",resType.planLimit," ",resType.planLimitUnit];
                }
                prevNameView=resourceName;
            }else{
                //rowHeight =60;
                UILabel *resourceName = [[UILabel alloc] initWithFrame:CGRectMake(0, 0 , (screenWidth-10), rowHeight)];
                resourceName.numberOfLines=0;
                resourceName.lineBreakMode=NSLineBreakByWordWrapping;
                resourceName.text = [NSString stringWithFormat:@"%s%@"," ",resType.resourceDesc];
                resourceName.layer.borderWidth=1;
                resourceName.layer.borderColor=[self.utils getThemeLightBlue].CGColor;
                resourceName.textAlignment = NSTextAlignmentCenter;
                [rowView addSubview: resourceName];
                prevNameView=resourceName;
            }
            [self.planDetlScrView addSubview:rowView];
            prevView=rowView;
            
            CGSize lastRect = [prevNameView sizeThatFits: prevNameView.frame.size];
            float lastHeight = rowHeight;
            if(lastRect.height > rowHeight){
                lastHeight = lastRect.height;
            }
            
            totalLytHeight = totalLytHeight+lastHeight;
            subIndex++;
        }
        self.planDetlHieght.constant = totalLytHeight;
        self.planDetlScrView.scrollEnabled=false;
    }
    
    self.planDetlScrView.contentSize = CGSizeMake(screenWidth, totalLytHeight);
    [self loadAddons];
    [self loadOffers];
}

- (void)loadOffers{
    int subIndex =0;
    float rowHeight=30;
    UIView *prevView = nil;
    UIView *prevNameView = nil;
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    int screenWidth=screenRect.size.width;
    for(UIView *sv in self.offerScrView.subviews){
        [sv removeFromSuperview];
    }
    offerPercent=0;
    for(PlanOfferModel *offerMdl in self.offerList){
        NSArray *applicableTo = [offerMdl.applicableTo componentsSeparatedByString:@","];
        NSString *plnId=[NSString stringWithFormat:@"%d",self.selectedPlnModel.planId.intValue];
        BOOL found = false;
        for(NSString *appId in applicableTo){
            if([appId isEqualToString:plnId]){
                found= TRUE;
                break;
            }
        }
        if(found==NO){
            continue;
        }
        UIView *rowView = [[UIView alloc] initWithFrame:CGRectMake(0, 5 , (screenWidth), rowHeight)];
        if(prevView !=nil){
            CGSize lastRect = [prevNameView sizeThatFits: prevNameView.frame.size];
            float lastHeight = rowHeight;
            if(lastRect.height > rowHeight){
                lastHeight = lastRect.height;
            }
            rowView = [[UIView alloc] initWithFrame:CGRectMake(0, (prevView.frame.origin.y+lastHeight+5) , (screenWidth), rowHeight)];
        }
        
        [rowView sizeToFit];
        UIImageView *selectAddOn = [[UIImageView alloc] initWithFrame:CGRectMake(2, 2 , 25, 25)];
        [selectAddOn setImage:[UIImage imageNamed:@"checkbox_unsel.png"]];
      
        
        
        if(self.selectedOffer != nil &&  self.selectedOffer.offerId.intValue == offerMdl.offerId.intValue){
            [selectAddOn setImage:[UIImage imageNamed:@"checkbox_sel.png"]];
            offerPercent = offerMdl.offerValue.doubleValue/100.00;
        }else{
            [selectAddOn setImage:[UIImage imageNamed:@"checkbox_unsel.png"]];
        }
        
        [rowView addSubview: selectAddOn];
        
        UILabel *resourceName = [[UILabel alloc] initWithFrame:CGRectMake(32, 2 , ((screenWidth-35)*0.75), rowHeight)];
        resourceName.numberOfLines=0;
        resourceName.lineBreakMode=NSLineBreakByWordWrapping;
        resourceName.text = offerMdl.offerName;
        [resourceName sizeToFit];
        
        [rowView addSubview: resourceName];
        
        
        UILabel *price = [[UILabel alloc] initWithFrame:CGRectMake(36+((screenWidth-35)*0.75), 2, ((screenWidth-35)*0.25), rowHeight)];
        double offerPrice = (self.selectedPlnModel.planPrice.doubleValue)-(offerMdl.offerValue.doubleValue*self.selectedPlnModel.planPrice.doubleValue/100.00);
        price.text = [NSString stringWithFormat:@"%s%@","$",[self.utils getNumberFormatter:offerPrice]];
        selectAddOn.hidden = false;
        selectAddOn.tag=offerMdl.offerId.intValue;;
        UITapGestureRecognizer *selAddOnTap = [[UITapGestureRecognizer alloc] initWithTarget:self action: @selector(addOffer:)];
        selAddOnTap.numberOfTapsRequired = 1;
        selAddOnTap.numberOfTouchesRequired = 1;
        [selectAddOn setUserInteractionEnabled:YES];
        [selectAddOn addGestureRecognizer:selAddOnTap];
        
        [rowView addSubview: price];
        price.hidden = false;
        [self.offerScrView addSubview:rowView];
        prevView=rowView;
        prevNameView=resourceName;
        subIndex++;
        self.offerScrView.scrollEnabled=true;
        self.offerScrView.scrollsToTop=true;
        self.offerScrView.contentSize = CGSizeMake(screenWidth, ((self.offerList.count)*45) );
        self.offerScrHeight.constant=self.offerList.count*45;
    }
    if(subIndex == 0){
        self.offerHeader.hidden=true;
        self.offerHeaderHeight.constant=0;
        self.offerScrHeight.constant=0;
    }
    totalAmountVal=(self.selectedPlnModel.planPrice.doubleValue+addonPrice);
    totalAmountVal = totalAmountVal - (totalAmountVal*offerPercent);

    self.planCost.text=[NSString stringWithFormat:@"%s%@" ,"Plan cost : $",[self.utils getNumberFormatter:totalAmountVal]];
}


- (void)loadAddons{
    int subIndex =0;
    float rowHeight=30;
    UIView *prevView = nil;
    UIView *prevNameView = nil;
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    int screenWidth=screenRect.size.width;
    for(UIView *sv in self.addonScrView.subviews){
        [sv removeFromSuperview];
    }
    NSMutableSet *selectedPlansResIds =[[NSMutableSet alloc]init];
    
    for(NSDictionary  *resTypeObj in self.selectedPlnModel.resourceTypeList){
        ResourceTypeModel *resType = [[ResourceTypeModel alloc]init];
        resType = [resType initWithDictionary:resTypeObj];
        if(![resType.allowUsageBy isEqualToString:@"ondemand"]){
            [selectedPlansResIds addObject:resType.resourceTypeId];
        }
    }
    addonPrice =0;
    for(ResourceTypeModel *resType in self.addonList){
        if([selectedPlansResIds containsObject:resType.resourceTypeId]){
            continue;
        }
        UIView *rowView = [[UIView alloc] initWithFrame:CGRectMake(0, 5 , (screenWidth), rowHeight)];
        if(prevView !=nil){
            CGSize lastRect = [prevNameView sizeThatFits: prevNameView.frame.size];
            float lastHeight = rowHeight;
            if(lastRect.height > rowHeight){
                lastHeight = lastRect.height;
            }
            rowView = [[UIView alloc] initWithFrame:CGRectMake(0, (prevView.frame.origin.y+lastHeight+5) , (screenWidth), rowHeight)];
        }
        
        [rowView sizeToFit];
        UIImageView *selectAddOn = [[UIImageView alloc] initWithFrame:CGRectMake(2, 2 , 25, 25)];
        [selectAddOn setImage:[UIImage imageNamed:@"checkbox_unsel.png"]];
        double currAddonPrice = resType.planSplPrice.doubleValue;
        
        
        if([self.selectedAddonIds containsObject:resType.resourceTypeId]){
            [selectAddOn setImage:[UIImage imageNamed:@"checkbox_sel.png"]];
            addonPrice = addonPrice+currAddonPrice;
        }else{
            [selectAddOn setImage:[UIImage imageNamed:@"checkbox_unsel.png"]];
        }
        
        [rowView addSubview: selectAddOn];
        
        UILabel *resourceName = [[UILabel alloc] initWithFrame:CGRectMake(32, 2 , ((screenWidth-35)*0.75), rowHeight)];
        resourceName.numberOfLines=0;
        resourceName.lineBreakMode=NSLineBreakByWordWrapping;
        resourceName.text = resType.resourceTypeName;
        [resourceName sizeToFit];
        
        [rowView addSubview: resourceName];
        
       
        UILabel *price = [[UILabel alloc] initWithFrame:CGRectMake(36+((screenWidth-35)*0.75), 2, ((screenWidth-35)*0.25), rowHeight)];
        price.text = [NSString stringWithFormat:@"%s%@","$",[self.utils getNumberFormatter:resType.planSplPrice.doubleValue]];
        selectAddOn.hidden = false;
        selectAddOn.tag=resType.resourceTypeId.intValue;;
        UITapGestureRecognizer *selAddOnTap = [[UITapGestureRecognizer alloc] initWithTarget:self action: @selector(addAddOn:)];
        selAddOnTap.numberOfTapsRequired = 1;
        selAddOnTap.numberOfTouchesRequired = 1;
        [selectAddOn setUserInteractionEnabled:YES];
        [selectAddOn addGestureRecognizer:selAddOnTap];
     
        [rowView addSubview: price];
        price.hidden = false;
        [self.addonScrView addSubview:rowView];
        prevView=rowView;
        prevNameView=resourceName;
        subIndex++;
        self.addonScrView.scrollEnabled=true;
        self.addonScrView.scrollsToTop=true;
        self.addonScrView.contentSize = CGSizeMake(screenWidth, ((self.addonList.count)*34) );
        self.addonScrHeight.constant=self.addonList.count*34;
    }
    if(subIndex == 0){
        self.addonHeader.hidden=true;
        self.addonHeaderHeight.constant=0;
        self.addonScrHeight.constant=0;
    }
    totalAmountVal=(self.selectedPlnModel.planPrice.doubleValue+addonPrice);
    totalAmountVal = totalAmountVal - (totalAmountVal*offerPercent);
    self.planCost.text=[NSString stringWithFormat:@"%s%@" ,"Plan cost : $",[self.utils getNumberFormatter:totalAmountVal]];
}

- (void)addAddOn:(UITapGestureRecognizer *) rec{
    int resId = (int)rec.view.tag;
    if(resId >=0 ){
        for(ResourceTypeModel *resTypeMdl in self.addonList){
            if(resTypeMdl.resourceTypeId.intValue == resId){
                if([self.selectedAddonIds containsObject:resTypeMdl.resourceTypeId]){
                    [self.selectedAddonIds removeObject:resTypeMdl.resourceTypeId];
                }else{
                    [self.selectedAddonIds addObject:resTypeMdl.resourceTypeId];
                }
                
                break;
            }
        }
    }
    
    [self loadAddons];
   
}

- (void)addOffer:(UITapGestureRecognizer *) rec{
    int offerId = (int)rec.view.tag;
    
    if(offerId >=0 ){
        for(PlanOfferModel *offerMdl in self.offerList){
            if(offerMdl.offerId.intValue == offerId){
                if(self.selectedOffer !=nil && self.selectedOffer.offerId.intValue==offerMdl.offerId.intValue){
                    self.selectedOffer =nil;
                }else{
                   self.selectedOffer =offerMdl;
                }
                break;
            }
        }
    }
   
    [self loadOffers];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)goBackToPlans:(UITapGestureRecognizer *) rec{
    
    UIStoryboard *stryBrd = [UIStoryboard storyboardWithName:@"SelectPlan" bundle:nil];
    SelectPlanController *viewCtrl=[stryBrd instantiateViewControllerWithIdentifier:@"SelectPlan"];
    viewCtrl.adminAcctModel=self.adminAcctModel;
    viewCtrl.addonList = self.addonList;
    viewCtrl.planArray = self.planArray;
    viewCtrl.offerList=self.offerList;
    viewCtrl.noOfdaystoSubsDate = self.noOfdaystoSubsDate;
    viewCtrl.trialEndsAt = self.trialEndsAt;
    viewCtrl.firstsubDate  = self.firstsubDate;
    viewCtrl.noOFDaysInMoth  = self.noOFDaysInMoth;
    viewCtrl.message = self.message;
    viewCtrl.noOfdaystoNextMonth = self.noOfdaystoNextMonth;
    [self.utils loadViewControlleWithAnimation:self NextController:viewCtrl];

}
-(void) showPlanDetlPopup {
    self.view.backgroundColor=[UIColor grayColor];
    for(UIView *subViews in [self.view subviews]){
        subViews.alpha=0.2;
        subViews.userInteractionEnabled=false;
    }
    float centerY = self.view.center.y;
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    int screenWidth=screenRect.size.width-10;
    int toalHeight =(int)(self.selectedPlnModel.resourceTypeList.count)*30+150;
    self.popup = [[UIView alloc] initWithFrame:CGRectMake(5, centerY-(toalHeight/2) , screenWidth, toalHeight)];
    self.popup.backgroundColor = [UIColor whiteColor];
    [self.view addSubview: self.popup];
    
    UILabel *header = [[UILabel alloc] initWithFrame:CGRectMake(0, 0 , screenWidth, 30)];
    header.text=self.selectedPlnModel.planName;
    header.textAlignment=NSTextAlignmentCenter;
    header.numberOfLines=1;
    header.backgroundColor=[self.utils getThemeLightBlue];
    header.textColor=[UIColor whiteColor];
    [self.popup addSubview: header];
    
    UILabel *resourceNameHead = [[UILabel alloc] initWithFrame:CGRectMake(0, 30 , ((screenWidth)*0.7), 30)];
    resourceNameHead.layer.borderWidth=1;
    resourceNameHead.layer.borderColor=[UIColor whiteColor].CGColor;
    resourceNameHead.textColor =[UIColor whiteColor];
    resourceNameHead.text = @" Resource name";
    resourceNameHead.backgroundColor=[self.utils getLightGray];
    [self.popup addSubview: resourceNameHead];
    
    UILabel *limit = [[UILabel alloc] initWithFrame:CGRectMake(((screenWidth)*0.7), 30, ((screenWidth)*0.3), 30)];
    limit.layer.borderWidth=1;
    limit.layer.borderColor=[UIColor whiteColor].CGColor;
    limit.textColor =[UIColor whiteColor];
    limit.text = @" limit";
    limit.backgroundColor=[self.utils getLightGray];
    [self.popup addSubview: limit];
    UIView *prevView = nil;
    UIView *prevNameView = nil;
    int rowHeight =30;
    for(NSDictionary  *resTypeObj in self.selectedPlnModel.resourceTypeList){
        ResourceTypeModel *resType = [[ResourceTypeModel alloc]init];
        resType = [resType initWithDictionary:resTypeObj];
        if([resType.allowUsageBy isEqualToString:@"ondemand"]){
            continue;
        }
        UIView *rowView = [[UIView alloc] initWithFrame:CGRectMake(0, 60 , (screenWidth), rowHeight)];
        if(prevView !=nil){
            CGSize lastRect = [prevNameView sizeThatFits: prevNameView.frame.size];
            float lastHeight = rowHeight;
            if(lastRect.height > rowHeight){
                lastHeight = lastRect.height;
            }
            rowView = [[UIView alloc] initWithFrame:CGRectMake(0, (prevView.frame.origin.y+lastHeight)-1 , (screenWidth), rowHeight)];
        }
        [rowView sizeToFit];
        if(resType.resourceDesc == (id)[NSNull null] ||resType.resourceDesc == nil || resType.resourceDesc.length==0){
            rowHeight =30;
            UILabel *resourceName = [[UILabel alloc] initWithFrame:CGRectMake(0, 0 , (screenWidth*0.7), rowHeight)];
            resourceName.numberOfLines=1;
            resourceName.lineBreakMode=NSLineBreakByWordWrapping;
            resourceName.text = [NSString stringWithFormat:@"%s%@"," ",resType.resourceTypeName];
            resourceName.layer.borderWidth=1;
            resourceName.layer.borderColor=[self.utils getThemeLightBlue].CGColor;
            [rowView addSubview: resourceName];
        
            UILabel *limit = [[UILabel alloc] initWithFrame:CGRectMake((screenWidth*0.7)-1, 0, (screenWidth*0.3), rowHeight)];
            limit.numberOfLines=-1;
            limit.layer.borderWidth=1;
            limit.layer.borderColor=[self.utils getThemeLightBlue].CGColor;
            [rowView addSubview: limit];
        
            if([resType.allowUsageBy isEqualToString:@"free"] || resType.planLimit.intValue == -1){
                limit.text = @" Unlimited";
            }else if(resType.planLimit.intValue == 0){
                limit.text = [NSString stringWithFormat:@"%s%@%s%@"," $",resType.planSplPrice,"/",resType.planLimitUnit];
            }else{
                limit.text = [NSString stringWithFormat:@"%s%@%s%@"," ",resType.planLimit," ",resType.planLimitUnit];
            }
            prevNameView=resourceName;
        }else{
            rowHeight =60;
            UILabel *resourceName = [[UILabel alloc] initWithFrame:CGRectMake(0, 0 , screenWidth-1, rowHeight)];
            resourceName.numberOfLines=0;
            resourceName.lineBreakMode=NSLineBreakByWordWrapping;
            resourceName.text = [NSString stringWithFormat:@"%s%@"," ",resType.resourceDesc];
            resourceName.textAlignment = NSTextAlignmentCenter;

            resourceName.layer.borderWidth=1;
            resourceName.layer.borderColor=[self.utils getThemeLightBlue].CGColor;
            [rowView addSubview: resourceName];
            prevNameView=resourceName;
        }
        [self.popup addSubview:rowView];
        prevView=rowView;
        CGSize lastRect = [prevNameView sizeThatFits: prevNameView.frame.size];
        float lastHeight = rowHeight;
        if(lastRect.height > rowHeight){
            lastHeight = lastRect.height;
        }
        
    }

    
    UIButton *closeBtn = [[UIButton alloc] initWithFrame:CGRectMake( (screenWidth)/2-50,toalHeight-45 , 100, 30)];
    closeBtn.backgroundColor=[self.utils getThemeLightBlue];
    
    [closeBtn setTitle: @"Close" forState: UIControlStateNormal];
    closeBtn.userInteractionEnabled=TRUE;
    closeBtn.enabled=TRUE;
    [closeBtn addTarget:self action:@selector(closePoup:) forControlEvents: UIControlEventTouchUpInside];
    [self.popup addSubview: closeBtn];
    
    
}
- (IBAction)closePoup:(id)sender {

    
    [self.popup removeFromSuperview];
    self.view.backgroundColor=[UIColor whiteColor];
    for(UIView *subViews in [self.view subviews]){
        subViews.alpha=1.0;
        subViews.userInteractionEnabled=true;
    }
}

- (IBAction)addToCart:(id)sender {
    NSMutableArray *planArray = [[NSMutableArray alloc]init];
    [planArray addObject:self.selectedPlnModel];
    [self.selectedPlnMap setObject:planArray forKey:self.selectedPlnModel.planId];
    
    UIStoryboard *stryBrd = [UIStoryboard storyboardWithName:@"UserData" bundle:nil];
    UserDataController *viewCtrl=[stryBrd instantiateViewControllerWithIdentifier:@"UserData"];
    for(NSNumber *key in self.selectedPlnMap.allKeys){
        NSMutableArray *planArray= [self.selectedPlnMap objectForKey:key];
        for(PlanModel *pln1 in planArray){
            [self.selectedPlnArray addObject:pln1];
        }
    }
    viewCtrl.selectedPlanArray = self.selectedPlnArray;
    viewCtrl.adminAcctModel = self.adminAcctModel;
    viewCtrl.planArray= self.planArray;
    viewCtrl.payableAmount = [NSNumber numberWithDouble:totalAmountVal];
    viewCtrl.addonList = self.addonList;
    viewCtrl.selectedAddonIds = self.selectedAddonIds;
    viewCtrl.selectedPlnMap = self.selectedPlnMap;
    viewCtrl.offerList=self.offerList;
    viewCtrl.selectedOffer=self.selectedOffer;
    viewCtrl.noOfdaystoSubsDate = self.noOfdaystoSubsDate;
    viewCtrl.trialEndsAt = self.trialEndsAt;
    viewCtrl.firstsubDate  = self.firstsubDate;
    viewCtrl.noOFDaysInMoth  = self.noOFDaysInMoth;
    viewCtrl.message = self.message;
    viewCtrl.noOfdaystoNextMonth = self.noOfdaystoNextMonth;
    [self.utils loadViewControlleWithAnimation:self NextController:viewCtrl];
}
@end
