//
//  ProfileScreen.m
//  extraSlice
//
//  Created by Administrator on 06/09/16.
//  Copyright © 2016 Extraslice Inc. All rights reserved.
//

#import "ProfileScreen.h"
#import "SmartSpaceDAO.h"
#import "Utilities.h"
#import "OrganizationModel.h"
#import "PlanModel.h"
#import "ResourceTypeModel.h"
#import "WnpConstants.h"
#import "UserOrgModel.h"
static UIColor *SelectedCellBGColor ;
static UIColor *NotSelectedCellBGColor;
int suscrHeight=0;
int userLytHeight=0;
@interface ProfileScreen () <UITableViewDelegate, UITableViewDataSource,UITextFieldDelegate>

@property(strong,nonatomic) UITableView *pickQty;
@property(strong,nonatomic) OrganizationModel *selectedOrg;
@property(strong,nonatomic) NSMutableArray *orgArray;
@property(strong,nonatomic) NSMutableArray *itemsArray;
@property(strong,nonatomic) NSMutableArray *chArray;
@property(strong,nonatomic) NSMutableArray *userChArray;
@property(strong,nonatomic) NSMutableDictionary *selectedUserMap;
@property(strong,nonatomic)WnPConstants *wnpConst;
@property(strong,nonatomic)SmartSpaceDAO *smDao;
@property(strong,nonatomic)NSNumber *userId;
@property(strong,nonatomic)NSArray *orgUserList;
@property(nonatomic)BOOL cancelMeetings;
@property(strong,nonatomic) UIView *alertView;
@property(strong,nonatomic) UITextField *email;
@property(strong,nonatomic) UILabel *selectedRole;
@property(strong,nonatomic) NSArray *pickerData;
@property(strong,nonatomic) UIView *countView;
@property(strong,nonatomic) UILabel *planCount;
@property(strong,nonatomic) UserOrgModel *selectedUsrOrgMdl;
@property(strong,nonatomic) Utilities *utils;
@end

@implementation ProfileScreen

- (void)viewDidLoad {
    [super viewDidLoad];

self.pickerData = @[@"Admin", @"Member"];
    self.wnpConst = [[WnPConstants alloc]init];
    self.smDao =[[SmartSpaceDAO alloc]init];
     self.utils= [[Utilities alloc]init];
    UserModel *userMdl = [self.utils getLoggedinUser];
    self.userChArray = [[NSMutableArray alloc]init];
    self.selectedUserMap= [[NSMutableDictionary alloc]init];
    //self.orgDropdown.delegate = self;
    //self.orgDropdown.dataSource = self;
    self.userId =userMdl.userId;
    self.cancelMeetings=FALSE;
    SelectedCellBGColor=[UIColor grayColor];
    NotSelectedCellBGColor =[UIColor whiteColor];
    self.orgArray =[[NSMutableArray alloc]init];
    self.itemsArray = [[NSMutableArray alloc]init];
    self.chArray= [[NSMutableArray alloc]init];
    self.header.backgroundColor = [self.wnpConst getThemeColorWithTransparency:0.7];
    self.orgHeader.backgroundColor = [self.wnpConst getThemeColorWithTransparency:0.1];
    for(NSDictionary *orgDic in userMdl.orgList){
        OrganizationModel *orgModel = [[OrganizationModel alloc]init];
        orgModel = [orgModel initWithDictionary:orgDic];
        if(orgModel.orgRoleId.intValue == 1){
            [self.orgArray addObject:orgModel];
        }
    }
    UITapGestureRecognizer *expSubs = [[UITapGestureRecognizer alloc] initWithTarget:self action: @selector(expandSubScLyt:)];
    expSubs.numberOfTapsRequired = 1;
    expSubs.numberOfTouchesRequired = 1;
    [self.expandSubscView setUserInteractionEnabled:YES];
    [self.expandSubscView addGestureRecognizer:expSubs];
    
    UITapGestureRecognizer *expUsr = [[UITapGestureRecognizer alloc] initWithTarget:self action: @selector(expandSubScLyt:)];
    expUsr.numberOfTapsRequired = 1;
    expUsr.numberOfTouchesRequired = 1;
    [self.expandUserView setUserInteractionEnabled:YES];
    [self.expandUserView addGestureRecognizer:expUsr];
    
    
    //OrganizationModel *orgModel = [[OrganizationModel alloc]init];
   // orgModel.orgName=@"test";
    //[self.orgArray addObject:orgModel];
    if(self.orgArray.count ==0){
        self.errorText.text=@"You are not autherized to do this action";
        self.errorLayout.hidden=false;
        self.errorLytHeight.constant=100;
         self.orgLytHeight.constant=0;
        self.orgLyt.hidden=true;
    }else if(self.orgArray.count == 1){
        self.selectedOrg = [self.orgArray objectAtIndex:0];
        self.errorLayout.hidden=true;
        self.orgLyt.hidden=false;
        self.orgName.hidden=false;
        self.orgDropdown.hidden=true;
         self.errorLytHeight.constant=0;
        self.orgName.text=self.selectedOrg.orgName;
    }else{
        self.errorLayout.hidden=true;
        self.errorLytHeight.constant=0;
        self.orgLyt.hidden=false;
        self.orgName.hidden=true;
        self.orgDropdown.hidden=false;
        for(OrganizationModel *model in self.orgArray){
            
        }
    }
    @try{
        NSDictionary *subscData =[self.smDao getSubscriptionData:self.userId OrgId:self.selectedOrg.orgId];
        if(subscData != nil){
            int userLimit = 0;
            NSString *status = [subscData objectForKey:@"STATUS"];
            if([status isEqualToString:@"SUCCESS"]){
                
                BOOL canUnsubscribe =NO;
                @try {
                   NSNumber* canUnsubscribeInt = [subscData objectForKey:@"canUnsubscribe"];
                    if ([canUnsubscribeInt boolValue] == YES){
                        canUnsubscribe =YES;
                    }
                }
                @catch (NSException *exception) {
                    
                }
                
                
                 NSString *userCount = [subscData objectForKey:@"USERCOUNT"];
                userLimit = userCount.intValue;
                NSArray *planList = [subscData objectForKey:@"PlanList"];
                for(NSDictionary *planDic in planList){
                    PlanModel *plnModel = [[PlanModel alloc]init];
                    plnModel = [plnModel initWithDictionary:planDic];
                    NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
                    [dic setValue:@"Plan" forKey:@"Type"];
                    [dic setValue:plnModel.planId forKey:@"Id"];
                    [dic setValue:plnModel.planName forKey:@"Name"];
                    [dic setValue:[NSNumber numberWithBool:false] forKey:@"Selected"];
                    [self.itemsArray addObject:dic];
                }
                NSArray *addonList = [subscData objectForKey:@"AddonArray"];
                for(NSDictionary *addOnDic in addonList){
                    ResourceTypeModel *resModel = [[ResourceTypeModel alloc]init];
                    resModel = [resModel initWithDictionary:addOnDic];
                    NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
                    [dic setValue:@"Addon" forKey:@"Type"];
                    [dic setValue:resModel.resourceTypeId forKey:@"Id"];
                    [dic setValue:resModel.resourceTypeName forKey:@"Name"];
                    [dic setValue:[NSNumber numberWithBool:false] forKey:@"Selected"];
                    [self.itemsArray addObject:dic];
                }
                self.orgUserList = [subscData objectForKey:@"USERLIST"];
                int top=0;
                int scrWidth = self.view.frame.size.width-35;
                int index = 0;
                for(NSDictionary *userDic in self.orgUserList){
                    UserOrgModel *userMdl = [[UserOrgModel alloc]init];
                    userMdl = [userMdl initWithDictionary:userDic];
                   
                    UIImageView *select =[[UIImageView alloc] initWithFrame:CGRectMake(5,top+2,25,25)];
                    [select setImage:[UIImage imageNamed:@"checkbox_unsel.png"]];
                    [self.userScrView addSubview:select];
                    [self.userChArray addObject:select];
                    
                    UILabel *typeLbl =[[UILabel alloc] initWithFrame:CGRectMake(30,top+2,(scrWidth*0.55),30)];
                    typeLbl.text=userMdl.userName;
                    UIFont *txtFont = [typeLbl.font fontWithSize:15];
                    typeLbl.font = txtFont;
                    typeLbl.tag=-1;
                    [self.userScrView addSubview:typeLbl];
                    
                    UILabel *role =[[UILabel alloc] initWithFrame:CGRectMake((scrWidth*0.55)+32,top+2,(scrWidth*0.3),30)];
                    
                    role.text=(userMdl.orgRoleId.intValue == 1 ? @"Admin":@"Member");
                    UIFont *txtFont1 = [role.font fontWithSize:15];
                    role.font = txtFont1;
                    role.tag=index;
                    [self.userScrView addSubview:role];
                    
                    UILabel *status =[[UILabel alloc] initWithFrame:CGRectMake((scrWidth*0.85)+34,top+2,(scrWidth*0.15),30)];
                    status.text=userMdl.userStatus;
                    UIFont *txtFont2 = [status.font fontWithSize:15];
                    status.font = txtFont2;
                    status.tag=-1;
                    [self.userScrView addSubview:status];
                    
                    top = top+30;
                    
                    UITapGestureRecognizer *selectTap = [[UITapGestureRecognizer alloc] initWithTarget:self action: @selector(selectUser:)];
                    selectTap.numberOfTapsRequired = 1;
                    selectTap.numberOfTouchesRequired = 1;
                    [select setUserInteractionEnabled:YES];
                    [select addGestureRecognizer:selectTap];
                    select.tag = index;
                    index++;
                }
                 self.userScrViewHt.constant=top=self.orgUserList.count*32;
                suscrHeight=self.itemsArray.count*32 + 110;
                userLytHeight=(self.orgUserList.count)*32+160;
                
                self.userLytHeight.constant = userLytHeight;
                [self.view bringSubviewToFront:self.userLyt];
               
                float centerX = self.view.center.x;
                if(userLimit > 1){
                    UIButton *removeBtn = [[UIButton alloc] initWithFrame:CGRectMake(centerX-150,top+5,120,30)];
                    removeBtn.backgroundColor=[self.wnpConst getThemeBaseColor];
                    [removeBtn setTitle: @"Remove User" forState: UIControlStateNormal];
                    removeBtn.userInteractionEnabled=TRUE;
                    removeBtn.enabled=TRUE;
                    removeBtn.clipsToBounds=true;
                    [removeBtn addTarget:self action:@selector(removeUserFromOrg:) forControlEvents: UIControlEventTouchUpInside];
                    [self.userLyt addSubview:removeBtn];
                
                [self.userLyt bringSubviewToFront:removeBtn];
                    UIButton *updateBtn = [[UIButton alloc] initWithFrame:CGRectMake(centerX+30,top+5,120,30)];
                    updateBtn.backgroundColor=[self.wnpConst getThemeBaseColor];
                    [updateBtn setTitle: @"Update User" forState: UIControlStateNormal];
                    updateBtn.userInteractionEnabled=TRUE;
                    updateBtn.enabled=TRUE;
                    [updateBtn addTarget:self action:@selector(updateUser:) forControlEvents: UIControlEventTouchUpInside];
                    [self.userLyt addSubview:updateBtn];
                    
                    if(userLimit > self.orgUserList.count){
                        top = top+30;
                        UILabel *addUsertext =[[UILabel alloc] initWithFrame:CGRectMake(0,top+5,(scrWidth*0.55),30)];
                        addUsertext.text=@"Add new user";
                        UIFont *txtFont = [addUsertext.font fontWithSize:15];
                        addUsertext.font = txtFont;
                        [self.userLyt addSubview:addUsertext];
                    
                        top = top+30;
                        self.email =[[UITextField alloc] initWithFrame:CGRectMake(centerX-100,top+15,200,30)];
                        self.email.placeholder=@"Email";
                        UIFont *emailfnt = [self.email.font fontWithSize:15];
                        self.email.font = emailfnt;
                        self.email.delegate=self;
                        UIImage *blueBGImg = [UIImage imageNamed:@"edt_bg_grey.png"];
                        self.email.background = blueBGImg;

                        [self.userLyt addSubview:self.email];
                    
                        top = top+40;
                        UIButton *addNewUsrBtn = [[UIButton alloc] initWithFrame:CGRectMake(centerX-75,top+10,150,30)];
                        addNewUsrBtn.backgroundColor=[self.wnpConst getThemeBaseColor];
                        [addNewUsrBtn setTitle: @"Add User" forState: UIControlStateNormal];
                        addNewUsrBtn.userInteractionEnabled=TRUE;
                        addNewUsrBtn.enabled=TRUE;
                        [addNewUsrBtn addTarget:self action:@selector(addUser:) forControlEvents: UIControlEventTouchUpInside];
                        [self.userLyt addSubview:addNewUsrBtn];
                    }
                }
                
                top=0;
                index = 0;
                self.planScrViewHt.constant=self.itemsArray.count*32;
                self.orgLytHeight.constant=self.itemsArray.count*32 + 110;
                for(NSDictionary *dic in self.itemsArray){
                    UILabel *typeLbl =[[UILabel alloc] initWithFrame:CGRectMake(5,top+2,100,30)];
                    typeLbl.text=[dic objectForKey:@"Type"];
                    UIFont *txtFont = [typeLbl.font fontWithSize:15];
                    typeLbl.font = txtFont;
                    [self.planScrView addSubview:typeLbl];
                
                    UILabel *nameLbl =[[UILabel alloc] initWithFrame:CGRectMake(110,top+2,(scrWidth-top-110),30)];
                    nameLbl.text=[dic objectForKey:@"Name"];
                    UIFont *txtFont1 = [nameLbl.font fontWithSize:15];
                    nameLbl.font = txtFont1;
                    [self.planScrView addSubview:nameLbl];
                
                    UIImageView *select =[[UIImageView alloc] initWithFrame:CGRectMake((scrWidth-30),top+2,25,25)];
                    [select setImage:[UIImage imageNamed:@"checkbox_unsel.png"]];
                    [self.planScrView addSubview:select];
                    [self.chArray addObject:select];
                
                    top = top+30;
                
                    UITapGestureRecognizer *selectTap = [[UITapGestureRecognizer alloc] initWithTarget:self action: @selector(selectItem:)];
                    selectTap.numberOfTapsRequired = 1;
                    selectTap.numberOfTouchesRequired = 1;
                    [select setUserInteractionEnabled:YES];
                    [select addGestureRecognizer:selectTap];
                    select.tag = index;
                    index++;
                
                }
               
                top = self.itemsArray.count*32+30;
                
                if(canUnsubscribe){
                    UIImageView *selMeeting =[[UIImageView alloc] initWithFrame:CGRectMake(centerX-135,top+5,25,25)];
                    [selMeeting setImage:[UIImage imageNamed:@"checkbox_unsel.png"]];
                    
                    UITapGestureRecognizer *selMeetingTap = [[UITapGestureRecognizer alloc] initWithTarget:self action: @selector(selectMeetings:)];
                    selMeetingTap.numberOfTapsRequired = 1;
                    selMeetingTap.numberOfTouchesRequired = 1;
                    [selMeeting setUserInteractionEnabled:YES];
                    [selMeeting addGestureRecognizer:selMeetingTap];
                    [self.orgLyt addSubview:selMeeting];
                    UILabel *selMeetingText =[[UILabel alloc] initWithFrame:CGRectMake(centerX-100,top+5,200,30)];
                    selMeetingText.text=@"Cancel reservations too";
                    UIFont *txtFont1 = [selMeetingText.font fontWithSize:15];
                    selMeetingText.font = txtFont1;
                    [self.orgLyt addSubview:selMeetingText];
                    top = top+30;
                    
                    UIButton *submitBtn = [[UIButton alloc] initWithFrame:CGRectMake(centerX-75,top+5,150,30)];
                    submitBtn.backgroundColor=[self.wnpConst getThemeBaseColor];
                    [submitBtn setTitle: @"Unsubscribe" forState: UIControlStateNormal];
                    submitBtn.userInteractionEnabled=TRUE;
                    submitBtn.enabled=TRUE;
                    [submitBtn addTarget:self action:@selector(submitCancelRequest:) forControlEvents: UIControlEventTouchUpInside];
                    [self.orgLyt addSubview:submitBtn];
                }else{
                     NSString *message =@"";
                    @try {
                        message= [subscData objectForKey:@"UNSUBMESSAGE"];
                    }@catch (NSException *exception) {
                        message =@"";
                    }
                    if(message == nil){
                         message =@"";
                    }
                    
                    UILabel *unsubMessage =[[UILabel alloc] initWithFrame:CGRectMake(5,top+5,scrWidth,30)];
                    unsubMessage.text=message;
                    UIFont *txtFont1 = [unsubMessage.font fontWithSize:15];
                    unsubMessage.font = txtFont1;
                    unsubMessage.numberOfLines=0;
                    unsubMessage.textAlignment=NSTextAlignmentCenter;
                    unsubMessage.textColor = [UIColor blueColor];
                    [unsubMessage sizeToFit];
                    [self.orgLyt addSubview:unsubMessage];
                    top = top+30;

                }
            
                
             


                [self showView];
            }else{
                self.errorText.text=[subscData objectForKey:@"ERRORMESSAGE"];;
                self.errorLayout.hidden=false;
                self.errorLytHeight.constant=100;
                self.orgLytHeight.constant=0;
                self.orgLyt.hidden=true;
            }
        
        }else{
            //self.orgLytHeight.constant = 0;
        }
    }@catch(NSException *exception) {
        self.errorText.text=exception.description;
        self.errorLayout.hidden=false;
        self.errorLytHeight.constant=100;
        self.orgLytHeight.constant=0;
        self.orgLyt.hidden=true;
    }
}



- (IBAction)submitCancelRequest:(id)sender {
    NSMutableArray *plnIdArray = [[NSMutableArray alloc]init];
    NSMutableArray *addOnIdArray = [[NSMutableArray alloc]init];
    
    for(NSDictionary *dic in self.itemsArray){
        NSNumber* selected = [dic objectForKey:@"Selected"];
        if ([selected boolValue] == YES){
            NSString *type =[dic objectForKey:@"Type"];
            NSNumber *id = [dic objectForKey:@"Id"];
            if([type isEqualToString:@"Plan"]){
                [plnIdArray addObject:id];
            }else{
                [addOnIdArray addObject:id];
            }
        }
    }
    if(plnIdArray.count ==0 && addOnIdArray.count ==0){
        [self showPopup:@"Error" Message:@"Please select an item to unsubscribe"];
    }else{
        NSDictionary *subscData =[self.smDao requestCancelSubscription:self.userId OrgId:self.selectedOrg.orgId CancelMeetingsToo:self.cancelMeetings PlanIdList:plnIdArray AddonIds:addOnIdArray];
        NSString *status = [subscData objectForKey:@"STATUS"];
        if([status isEqualToString:@"SUCCESS"]){
            [self showPopup:@"Successful" Message:@"Your request submitted successfully. our community manager contact you soon."];
        }else{
            NSString *erroMsg = [subscData objectForKey:@"ERRORMESSAGE"];
            [self showPopup:@"Error" Message:erroMsg];
        }
    }
   
    

}
- (void)selectUser :(UITapGestureRecognizer *) rec{
    int position = rec.view.tag;
    NSDictionary *userDic =[self.orgUserList objectAtIndex:position];
    self.selectedUsrOrgMdl = [[UserOrgModel alloc]init];
    UIImageView *ch = [self.userChArray objectAtIndex:position];
    self.selectedUsrOrgMdl = [self.selectedUsrOrgMdl initWithDictionary:userDic];
    if([self.selectedUserMap.allKeys containsObject:self.selectedUsrOrgMdl.userName]){
        [self.selectedUserMap removeObjectForKey:self.selectedUsrOrgMdl.userName];
         [ch setImage:[UIImage imageNamed:@"checkbox_unsel.png"]];
        if(self.countView != nil){
            [self.countView removeFromSuperview];
        }
        if(self.pickQty != nil){
            [self.pickQty removeFromSuperview];
        }
        if(self.selectedRole != nil){
            self.selectedRole.hidden=false;
            self.selectedRole.text=self.selectedUsrOrgMdl.orgRoleId.intValue==1?@"Admin":@"Member";
        }
    }else{
        [self.selectedUserMap setObject:self.selectedUsrOrgMdl forKey:self.selectedUsrOrgMdl.userName];
         [ch setImage:[UIImage imageNamed:@"checkbox_sel.png"]];
        for(UIView *sv in self.userScrView.subviews){
            if( [sv isKindOfClass:[UILabel class]] && sv.tag == position){
                self.selectedRole = (UILabel *) sv;
                self.selectedRole.hidden=true;
                int x=self.selectedRole.frame.origin.x;
                int y =self.selectedRole.frame.origin.y;
           
                
                self.countView = [[UIView alloc] initWithFrame:CGRectMake(x, y, self.selectedRole.frame.size.width, self.selectedRole.frame.size.height)];
                self.countView.layer.borderWidth=1;
                self.countView.layer.borderColor=[self.wnpConst getThemeBaseColor].CGColor;
                [self.userScrView addSubview: self.countView];
                
                self.planCount = [[UILabel alloc] initWithFrame:CGRectMake(0, 0 , self.selectedRole.frame.size.width-26, 30)];
                self.planCount.text=self.selectedUsrOrgMdl.orgRoleId.intValue==1?@"Admin":@"Member";
                self.planCount.textAlignment=NSTextAlignmentCenter;
                UIFont *txtFont1 = [self.planCount.font fontWithSize:15];
                self.planCount.font = txtFont1;

                [self.countView addSubview: self.planCount];
               
                
                UIImageView *editup = [[UIImageView alloc] initWithFrame:CGRectMake(self.selectedRole.frame.size.width-26, 4 , 14, 14)];
                self.countView.tag=position;
                [editup setImage:[UIImage imageNamed:@"up.png"]];
                [self.countView addSubview: editup];
                
                UIImageView *editDown = [[UIImageView alloc] initWithFrame:CGRectMake(self.selectedRole.frame.size.width-26, 12 , 14, 14)];
 
                [editDown setImage:[UIImage imageNamed:@"down.png"]];
                [self.countView addSubview: editDown];
                
                UITapGestureRecognizer *editTap = [[UITapGestureRecognizer alloc] initWithTarget:self action: @selector(expandTable:)];
                editTap.numberOfTapsRequired = 1;
                editTap.numberOfTouchesRequired = 1;
                [self.countView setUserInteractionEnabled:YES];
                [self.countView addGestureRecognizer:editTap];
                break;
            }
            
        }


    }
}

- (IBAction)removeUserFromOrg:(id)sender {
    int noOfAdminUsers = 0;
    if(self.selectedUserMap.count == 0){
        [self showPopup:@"Error" Message:@"Please select a user to remove"];
    }else  if(self.selectedUserMap.count == self.orgUserList.count){
        [self showPopup:@"Error" Message:@"An organization should have minimum one admin user"];
    }else{
        for(NSDictionary *userDic in self.orgUserList){
            if([self.selectedUserMap.allKeys containsObject:[userDic objectForKey:@"userName"]]){
                continue;
            }
            UserOrgModel *userMdl = [[UserOrgModel alloc]init];
            userMdl = [userMdl initWithDictionary:userDic];
            if(![userMdl.userStatus isEqualToString:@"Not registred"]){
                if(userMdl.orgRoleId.intValue == 1){
                    noOfAdminUsers++;
                }
            }
        }
        if(noOfAdminUsers == 0){
            [self showPopup:@"Error" Message:@"An organization should have minimum one admin user"];
        }else{
            NSMutableArray *userArray = [[NSMutableArray alloc]init];
            
            for(NSString  *key in self.selectedUserMap.allKeys){
                UserOrgModel *modifiedMdl = [self.selectedUserMap objectForKey:key];
                [userArray addObject:[modifiedMdl dictionaryWithPropertiesOfObject:modifiedMdl]];
            }
            [self.smDao deleteUsersFromOrg:userArray];

        }
    }
    
    
   
}

- (IBAction)updateUser:(id)sender {
    int noOfAdminUsers = 0;
    if(self.selectedUserMap.count == 0){
        [self showPopup:@"Error" Message:@"Please select a user to remove"];
    }else{
        for(NSString *key in self.selectedUserMap.allKeys){
            UserOrgModel *userModel = [self.selectedUserMap objectForKey:key];
            if(![userModel.userStatus isEqualToString:@"Not registred"]){
                if(userModel.orgRoleId.intValue == 1){
                    noOfAdminUsers++;
                }
            }
        }
        for(NSDictionary *userDic in self.orgUserList){
            if([self.selectedUserMap.allKeys containsObject:[userDic objectForKey:@"userName"]]){
                continue;
            }
            UserOrgModel *userMdl = [[UserOrgModel alloc]init];
            userMdl = [userMdl initWithDictionary:userDic];
            if(![userMdl.userStatus isEqualToString:@"Not registred"]){
                if(userMdl.orgRoleId.intValue == 1){
                    noOfAdminUsers++;
                }
            }
        }
        if(noOfAdminUsers == 0){
            [self showPopup:@"Error" Message:@"An organization should have minimum one admin user"];
        }else{
            NSMutableArray *userArray = [[NSMutableArray alloc]init];
            
            for(NSString  *key in self.selectedUserMap.allKeys){
                UserOrgModel *modifiedMdl = [self.selectedUserMap objectForKey:key];
                [userArray addObject:[modifiedMdl dictionaryWithPropertiesOfObject:modifiedMdl]];
            }
            [self.smDao updateOrgUser:userArray];
        }
    }
}

- (IBAction)addUser:(id)sender {
    if(self.email.text.length == 0){
        [self showPopup:@"Error" Message:@"Please enter user email"];
    }else{
       [self.smDao addUserToOrg:self.email.text OrgId:self.selectedOrg.orgId AdminId: [self.utils getLoggedinUser].userId];
    }

}
- (void)expandSubScLyt :(UITapGestureRecognizer *) rec{
    if(self.expandProfile){
        self.expandProfile =FALSE;
    }else{
        self.expandProfile =TRUE;
    }
    [self showView];
}

- (void)selectMeetings :(UITapGestureRecognizer *) rec{
    UIImageView *iv = (UIImageView *)rec.view;
    if (self.cancelMeetings== YES){
        [iv setImage:[UIImage imageNamed:@"checkbox_unsel.png"]];
        self.cancelMeetings=NO;
    }else{
        [iv setImage:[UIImage imageNamed:@"checkbox_sel.png"]];
        self.cancelMeetings = YES;
    }
    
    
}
- (void)selectItem :(UITapGestureRecognizer *) rec{
    UIImageView *iv = (UIImageView *)rec.view;
    int index = iv.tag;
    NSDictionary *dic = [self.itemsArray objectAtIndex:index];
    UIImageView *imv=[self.chArray objectAtIndex:index];
    NSNumber* selected = [dic objectForKey:@"Selected"];
    if ([selected boolValue] == YES){
        [imv setImage:[UIImage imageNamed:@"checkbox_unsel.png"]];
        [dic setValue:[NSNumber numberWithBool:false] forKey:@"Selected"];
    }else{
        [imv setImage:[UIImage imageNamed:@"checkbox_sel.png"]];
        [dic setValue:[NSNumber numberWithBool:true] forKey:@"Selected"];
    }
    
    
}




- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSIndexPath *currentSelectedIndexPath = [tableView indexPathForSelectedRow];
    if (currentSelectedIndexPath != nil)
    {
        [[tableView cellForRowAtIndexPath:currentSelectedIndexPath] setBackgroundColor:NotSelectedCellBGColor];
    }
    
    return indexPath;
}



- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (cell.isSelected == YES)
    {
        [cell setBackgroundColor:SelectedCellBGColor];
    }
    else
    {
        [cell setBackgroundColor:NotSelectedCellBGColor];
    }
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
   // return self.orgArray.count;
     return self.pickerData.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"SimpleTableItem";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    tableView.rowHeight=30;
    cell.textLabel.text = [self.pickerData objectAtIndex:indexPath.row];
    UITapGestureRecognizer *expSubs = [[UITapGestureRecognizer alloc] initWithTarget:self action: @selector(tapRow:)];
    expSubs.numberOfTapsRequired = 1;
    expSubs.numberOfTouchesRequired = 1;
    cell.tag=indexPath.row;
    [cell setUserInteractionEnabled:YES];
    [cell addGestureRecognizer:expSubs];
    return cell;
}
/*-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSString *celId =@"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:celId];
    // if(cell == nil){
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:celId];
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat tableWidth = screenRect.size.width-10;
    
    UILabel *code = [[UILabel alloc] initWithFrame:CGRectMake(0, 2 , (tableWidth), 30)];
    UIFont *txtFont = [code.font fontWithSize:15.0];
    code.font = txtFont;
    [code setUserInteractionEnabled:TRUE];
    [code setEnabled:YES];
    // UITapGestureRecognizer *codeSel=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(setSeletedOrganization:)];
    // [codeSel setNumberOfTapsRequired:1];
    //  [code addGestureRecognizer:codeSel];
    if(indexPath.item > 0){
        OrganizationModel *orgModel=[self.orgArray objectAtIndex:0];
        code.text=[NSString stringWithFormat:@"%s%@", "  ", orgModel.orgName];
        NSLog(@"%@",orgModel.orgName);
        if(self.selectedOrg.orgId.intValue == orgModel.orgId.intValue){
            code.backgroundColor=[UIColor grayColor];
        }else{
            code.backgroundColor=[UIColor whiteColor];
        }
    }else if(indexPath.item ==0){
        code.text=[NSString stringWithFormat:@"%s", "  Select organization"];
    }else if(indexPath.item ==1){
        code.text=[NSString stringWithFormat:@"%s", "  Add organization"];
    }
    [cell addSubview:code];
    [cell bringSubviewToFront:code];
    
    
    UIView *seperator = [[UIView alloc] initWithFrame:CGRectMake(0, 31 , tableWidth, 1)];
    // [seperator setBackgroundColor:[self.wnpCont getThemeHeaderColor]];
    [cell addSubview:seperator];
    //self.storeSelector.rowHeight=35;
    
    //}
    
    
    
    return cell;
}*/


- (void)tapRow:(UITapGestureRecognizer *) rec{

    // [[tableView cellForRowAtIndexPath:indexPath] setBackgroundColor:SelectedCellBGColor];
    int resId = rec.view.tag;
    if(resId==0){
        self.selectedRole.text=@"Admin";
        self.planCount.text=@"Admin";
    }else{
        self.selectedRole.text=@"Member";
        self.planCount.text=@"Member";
    }
    
    UserOrgModel *modifiedMdl = [self.selectedUserMap objectForKey:self.selectedUsrOrgMdl.userName];
    [self.selectedUserMap removeObjectForKey:self.selectedUsrOrgMdl.userName];
    modifiedMdl.orgRoleId=[NSNumber numberWithInt:resId+1];
    [self.selectedUserMap setObject:modifiedMdl forKey:modifiedMdl.userName];
    [self.pickQty removeFromSuperview];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
   // [[tableView cellForRowAtIndexPath:indexPath] setBackgroundColor:SelectedCellBGColor];
    int resId = tableView.tag;
    if(indexPath.row ==0){
        self.selectedRole.text=@"Admin";
    }else{
        self.selectedRole.text=@"Member";
    }
    [self.pickQty removeFromSuperview];
}


-(void) showPopup:(NSString *) title Message:(NSString *) message
{
    self.view.backgroundColor=[UIColor grayColor];
    for(UIView *subViews in [self.view subviews]){
        subViews.alpha=0.2;
        subViews.userInteractionEnabled=false;
    }
    float centerX = self.view.frame.size.width/2;
    float centerY = self.view.frame.size.height/2;
    self.alertView = [[UIView alloc] initWithFrame:CGRectMake(centerX-150, centerY-90 , 300, 180)];
    self.alertView.backgroundColor = [UIColor whiteColor];
    self.alertView.layer.borderColor = [self.wnpConst getThemeBaseColor].CGColor;
    self.alertView.layer.borderWidth = 1.0f;
    [self.view addSubview: self.alertView];
    UILabel *header = [[UILabel alloc] initWithFrame:CGRectMake(0, 0 , 300, 30)];
    header.text=title;//@"Your request processed successfully. Our community manager will contact you soon.";
    header.textAlignment=NSTextAlignmentCenter;
    header.numberOfLines=1;
    header.backgroundColor=[self.wnpConst getThemeBaseColor];;
    header.textColor=[UIColor whiteColor];
    [self.alertView addSubview: header];
    
    
    
    UILabel *messageText = [[UILabel alloc] initWithFrame:CGRectMake(0, 40 , 300, 90)];
    messageText.text=message;
    messageText.textAlignment=NSTextAlignmentCenter;
    messageText.numberOfLines=-1;
    [self.alertView addSubview: messageText];
    UIButton *closeBtn = [[UIButton alloc] initWithFrame:CGRectMake( 115,140 , 70, 30)];
    closeBtn.backgroundColor=[self.wnpConst getThemeBaseColor];
    
    [closeBtn setTitle: @"Ok" forState: UIControlStateNormal];
    closeBtn.userInteractionEnabled=TRUE;
    closeBtn.enabled=TRUE;
    [closeBtn addTarget:self action:@selector(closePopup:) forControlEvents: UIControlEventTouchUpInside];
    
    [self.alertView addSubview: closeBtn];
}
-(void)closePopup:(UITapGestureRecognizer *) rec{
    self.view.backgroundColor=[UIColor whiteColor];
    for(UIView *subViews in [self.view subviews]){
        subViews.alpha=1.0;
        subViews.userInteractionEnabled=true;
    }
    [self.alertView removeFromSuperview];
}
-(void) showView{
    if(self.expandProfile){
        self.userLytHeight.constant=0;
        self.orgLytHeight.constant=suscrHeight;
        self.userLyt.hidden=true;
        self.orgLyt.hidden=false;
        [self.expandSubscView setImage:[UIImage imageNamed:@"arrow_up.png"]];
        [self.expandUserView setImage:[UIImage imageNamed:@"arrow_down.png"]];
        
    }else{
        self.userLytHeight.constant=userLytHeight;
        //self.userScrViewHt.constant=userLytHeight-160;
        self.orgLytHeight.constant=0;
        self.userLyt.hidden=false;
        self.orgLyt.hidden=true;
        [self.expandSubscView setImage:[UIImage imageNamed:@"arrow_down.png"]];
        [self.expandUserView setImage:[UIImage imageNamed:@"arrow_up.png"]];
    }
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

-(void) expandTable:(UITapGestureRecognizer *) rec{
    int position = rec.view.tag;
    for(UIView *sv in self.userScrView.subviews){
        if( [sv isKindOfClass:[UILabel class]] && sv.tag == position){
            self.selectedRole = (UILabel *) sv;
            
            int x=self.selectedRole.frame.origin.x;
            int y =65+self.userScrView.frame.origin.y+self.selectedRole.frame.origin.y;
            if(self.pickQty != nil){
                [self.pickQty removeFromSuperview];
            }

            self.pickQty = [[UITableView alloc] initWithFrame:CGRectMake(x, y, self.selectedRole.frame.size.width, self.selectedRole.frame.size.height*2)];
            self.pickQty.dataSource=self;
            self.pickQty.delegate=self;
            self.pickQty.layer.borderWidth=1;
            
            self.pickQty.layer.borderColor=[self.wnpConst getThemeBaseColor].CGColor;
            self.pickQty.scrollEnabled=false;
            
            
            self.pickQty.tag=position;
            [self.view addSubview:self.pickQty];
            break;
        }
        
    }
    
}
@end
