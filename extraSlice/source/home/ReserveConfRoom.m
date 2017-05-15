//
//  ReserveConfRoom.m
//  extraSlice
//
//  Created by Administrator on 27/06/16.
//  Copyright © 2016 Extraslice Inc. All rights reserved.
//

#import "ReserveConfRoom.h"
#import "SmartSpaceDAO.h"
#import "SmartSpaceModel.h"
#import "ESliceConstants.h"
#import "OrganizationModel.h"
#import "ResourceModel.h"
#import "Utilities.h"
#import "ReservationModel.h"
#import "MenuController.h"
#import "STPPaymentCardTextField.h"
#import "STPAPIClient.h"
#import "Stripe.h"
#import "StripeDAO.h"
#import "StripePlanModel.h"
#define degreesToRadians(degrees) (M_PI * degrees / 180.0)
static UIColor *SelectedCellBGColor ;
static UIColor *NotSelectedCellBGColor;
@interface ReserveConfRoom ()<STPPaymentCardTextFieldDelegate>
@property(strong,nonatomic) UIView *datepickerView;
@property(strong,nonatomic) UIView *alertView;
@property(strong,nonatomic) UILabel *selectedTimeLabel;
@property(strong,nonatomic) ESliceConstants *wnpConst;
@property(strong,nonatomic) UIDatePicker *datepicker;
@property(strong,nonatomic) NSNumber *duration;
@property(strong,nonatomic) NSMutableArray *resourceList;
@property(strong,nonatomic) NSMutableArray *orgList;
@property(strong,nonatomic) SmartSpaceModel *smModel ;
@property(strong,nonatomic) ReservationModel *resrvModel ;
@property(strong,nonatomic) OrganizationModel *orgModel ;
@property(strong,nonatomic) ResourceModel *resModel ;
@property(strong,nonatomic) Utilities *utils;
@property(strong,nonatomic) SmartSpaceDAO *smSpDao;
//@property(strong,nonatomic) NSMutableArray *resTypeList;
@property(strong,nonatomic)NSMutableArray *currSchedules;
@property(strong,nonatomic)NSMutableDictionary *dailySchedules;
//@property(strong,nonatomic) NSNumber *currBalance;
//@property(strong,nonatomic) NSNumber *resPrice;
@property(strong,nonatomic) UIView *popup;
@property(strong,nonatomic) UILabel *popupError;
@property(strong,nonatomic) UIButton *strpSubmitBtn;
@property(strong,nonatomic) UIButton *strpCancelBtn;
@property(strong,nonatomic) STPPaymentCardTextField *strpPymntTf;
@property(strong,nonatomic) NSNumber *payableAmount;
@property(strong,nonatomic) StripeDAO *strpDAO;
@property(nonatomic) BOOL isExpanded;
@property(strong,nonatomic) NSDateFormatter *hmAmPmFormatter;
@property(strong,nonatomic) NSDateFormatter *y_m_dhmFormatter;
@property(strong,nonatomic) NSDateFormatter *mdyFormatter;
@property(strong,nonatomic) NSDateFormatter *hmFormatter;
@property(strong,nonatomic) NSDateFormatter *mdyhmFormatter;
@property(strong,nonatomic) NSDateFormatter *ymdhmFormatter;
@property(strong,nonatomic) NSDate *neStartDateSelection;
@property(strong,nonatomic) NSMutableArray *halfHoursForDay;
@property(strong,nonatomic) NSDictionary *jSonResult;

@end

@implementation ReserveConfRoom

- (void)viewDidLoad {
    [super viewDidLoad];
    self.isExpanded = false;
    if(self.selectedDate == (id)[NSNull null] || self.selectedDate == nil){
        self.selectedDate = [self getCurrentLocalTime];
    }

    NSMutableArray *halfHours = [[NSMutableArray alloc]init];
    self.halfHoursForDay = [[NSMutableArray alloc]init];
    [halfHours addObject:@"00"];
    [halfHours addObject:@"30"];
    for(int hour=0;hour<24;hour++){
        for(NSString *hhr in halfHours){
            if(hour <=9){
                [self.halfHoursForDay addObject:[NSString stringWithFormat:@"%s%d%s%@","0",hour,":",hhr]];
            }else{
               [self.halfHoursForDay addObject:[NSString stringWithFormat:@"%d%s%@",hour,":",hhr]];
            }
            
        }
    }
    self.mdyFormatter = [[NSDateFormatter alloc] init];
    self.hmFormatter = [[NSDateFormatter alloc] init];
    self.hmAmPmFormatter = [[NSDateFormatter alloc] init];
    self.smSpDao = [[SmartSpaceDAO alloc]init];
    [self.mdyFormatter setDateFormat:@"MM/dd/yyyy"];
    [self.hmFormatter setDateFormat:@"HH:mm"];
    [self.hmAmPmFormatter setDateFormat:@"hh:mm a"];
    self.mdyhmFormatter = [[NSDateFormatter alloc] init];
    [self.mdyhmFormatter setDateFormat:@"MM/dd/yyyy hh:mm a"];
    self.ymdhmFormatter = [[NSDateFormatter alloc] init];
    [self.ymdhmFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
    
    self.y_m_dhmFormatter = [[NSDateFormatter alloc] init];
    [self.y_m_dhmFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    NSTimeZone *timeZone = [NSTimeZone localTimeZone];
    NSString *tzName = [timeZone name];
    NSLog(@"%@",tzName);
    NSLog(@"%@",[NSDate date]);
    
    [self.ymdhmFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    [self.mdyhmFormatter setTimeZone:[NSTimeZone localTimeZone]];
    
    //[self.hmFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT"]];
   // [self.hmAmPmFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT"]];
   // [self.mdyFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT"]];
   
    
    

    self.meetingName.delegate=self;
    self.orgTable.delegate = self;
    self.orgTable.dataSource = self;
    SelectedCellBGColor=[UIColor grayColor];
    NotSelectedCellBGColor =[UIColor whiteColor];
    
    self.wnpConst = [[ESliceConstants alloc]init];
    self.utils = [[Utilities alloc]init];
    self.selectedStartDate=[self getCurrentLocalTime];
    self.selectedEndDate = [self.selectedStartDate dateByAddingTimeInterval:1800];
    self.neStartDateSelection = self.selectedStartDate;
    self.endTime.text= [self.hmAmPmFormatter stringFromDate:self.selectedEndDate];
    self.duration = [NSNumber numberWithInt:30];
    self.startDate.text= [self.mdyFormatter stringFromDate:self.selectedStartDate];
    self.startTime.text= [self.hmAmPmFormatter stringFromDate:self.selectedStartDate];
    self.orgList = [[NSMutableArray alloc]init];
    
    self.startTime.layer.borderColor = [self.wnpConst getThemeBaseColor].CGColor;
    self.startTime.layer.borderWidth = 1.0f;
    
    self.endTime.layer.borderColor = [self.wnpConst getThemeBaseColor].CGColor;
    self.endTime.layer.borderWidth = 1.0f;
    [self.endTime sizeToFit];
    [self.startTime sizeToFit];
    
    /*for(int i=0;i<=3;i++){
        OrganizationModel *org = [[OrganizationModel alloc]init];
        org.orgId=[NSNumber numberWithInt:(i+1)];
        org.orgName=@"Organization ";
        [self.orgList addObject:[org dictionaryWithPropertiesOfObject:org]];
        
    }
    [self.utils getLoggedinUser].orgList = self.orgList;*/
   // NSMutableArray *orgIdArray = [[NSMutableArray alloc]init];
    if([self.utils getLoggedinUser].orgList != nil && [self.utils getLoggedinUser].orgList.count ==1){
        OrganizationModel *orgModel =[[OrganizationModel alloc]init];
        orgModel =[orgModel initWithDictionary:[[self.utils getLoggedinUser].orgList objectAtIndex:0]];
        if(orgModel.approved){
            self.orgModel = orgModel;
            [self.orgList addObject:self.orgModel];
         //   [orgIdArray addObject:self.orgModel.orgId];
            self.orgTableHeight.constant=0;
            self.orgTableTop.constant=0;
        }
    }else if([self.utils getLoggedinUser].orgList != nil && [self.utils getLoggedinUser].orgList.count >1){
        
        for(NSDictionary *dic in [self.utils getLoggedinUser].orgList){
            OrganizationModel *orgModel =[[OrganizationModel alloc]init];
            orgModel = [self.orgModel initWithDictionary:dic];
            if(orgModel.approved){
           //     [orgIdArray addObject:orgModel.orgId];
                [self.orgList addObject:orgModel];
            }
        }
    }
    @try{
        NSCalendar *gregorian = [NSCalendar currentCalendar];
        NSDateComponents *comp = [gregorian components: NSCalendarUnitYear | NSCalendarUnitMonth fromDate:self.selectedDate];
        [comp setDay:1];
        NSDate *firstDayOfMonthDate = [gregorian dateFromComponents:comp];
        comp = [gregorian components:NSCalendarUnitWeekday fromDate:firstDayOfMonthDate];
        int weekday = (int)[comp weekday];
        NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
        [dateComponents setDay:(-weekday+1)];
         NSDate *calStartDate = [gregorian dateByAddingComponents:dateComponents toDate:firstDayOfMonthDate options:0];
        
        dateComponents = [[NSDateComponents alloc] init];
        [dateComponents setDay:(48)];
        NSDate *calEndDate = [gregorian dateByAddingComponents:dateComponents toDate:calStartDate options:0];
        
        self.currSchedules = [self.smSpDao getCurrentSchedulesForPeriod:[self.y_m_dhmFormatter stringFromDate:calStartDate] EndTime:[self.y_m_dhmFormatter stringFromDate:calEndDate]];
    }@catch (NSException *exception) {
        NSLog(@"%@",exception.description);
        
    }
    if(self.currSchedules != (id)[NSNull null] && self.currSchedules != nil){
        self.dailySchedules = [[NSMutableDictionary alloc]init];
        for(ReservationModel *resModel in self.currSchedules){
            
            NSDate *dte = [NSDate dateWithTimeIntervalSince1970:resModel.startDate.doubleValue/1000];
            NSString *day = [self.mdyFormatter stringFromDate:dte];
            NSMutableArray *dayArray = [[NSMutableArray alloc]init];
            if([self.dailySchedules valueForKey:day] == (id)[NSNull null] || [self.dailySchedules valueForKey:day] == nil){
                
                [self.dailySchedules setObject:dayArray forKey:day];
            }else{
                dayArray = [self.dailySchedules objectForKey:day];
            }
            [dayArray addObject:resModel];
        }
    }
    NSMutableArray *smList  = [[NSMutableArray alloc]init];
    @try{
        smList = [self.smSpDao getAllSmartSpace];
    }@catch (NSException *exception) {
        
    }
    self.adminAcctModel = [self.smSpDao getAdminAccount];
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat tableWidth = screenRect.size.width;
    if(smList != nil && smList.count > 0){
        self.smModel = [[SmartSpaceModel alloc]init];
        self.smModel = [smList objectAtIndex:0];
        UILabel *smspceName = [[UILabel alloc] initWithFrame:CGRectMake(0, 0 ,tableWidth, 30)];
        smspceName.textAlignment = NSTextAlignmentCenter;
        smspceName.text=self.smModel.smSapceName;
        [self.smarspaceSpinner addSubview:smspceName];
        if(smList.count == 1){
            self.smSpaceLytHt.constant =0;
        }else{
            self.smSpaceLytHt.constant =30;
        }
        
         self.confRoomLyt.scrollEnabled=true;
         self.confRoomLyt.contentSize = CGSizeMake(tableWidth, 160*self.smModel.resourceList.count);
        
    }
    
    UITapGestureRecognizer *showOrgPopup = [[UITapGestureRecognizer alloc] initWithTarget:self action: @selector(ShowDropDown:)];
    showOrgPopup.numberOfTapsRequired = 1;
    showOrgPopup.numberOfTouchesRequired = 1;
    [self.orgTable setUserInteractionEnabled:YES];
    [self.orgTable addGestureRecognizer:showOrgPopup];
    
    UITapGestureRecognizer *pickDateTap = [[UITapGestureRecognizer alloc] initWithTarget:self action: @selector(changeDate:)];
    pickDateTap.numberOfTapsRequired = 1;
    pickDateTap.numberOfTouchesRequired = 1;
    [self.startDate setUserInteractionEnabled:YES];
    [self.startDate addGestureRecognizer:pickDateTap];
    

    UITapGestureRecognizer *startTimeTap = [[UITapGestureRecognizer alloc] initWithTarget:self action: @selector(changeDate:)];
    startTimeTap.numberOfTapsRequired = 1;
    startTimeTap.numberOfTouchesRequired = 1;
    [self.startTime setUserInteractionEnabled:YES];
    [self.startTime addGestureRecognizer:startTimeTap];
    
    UITapGestureRecognizer *endTimeTap = [[UITapGestureRecognizer alloc] initWithTarget:self action: @selector(changeDate:)];
    endTimeTap.numberOfTapsRequired = 1;
    endTimeTap.numberOfTouchesRequired = 1;
    [self.endTime setUserInteractionEnabled:YES];
    [self.endTime addGestureRecognizer:endTimeTap];
    [self setSelectedDat:@"Today"];
    
   
}
-(void) viewDidAppear:(BOOL)animated{
    [self loadConferenceRoom ];
}
-(void ) setSelectedDat:(NSString *)dateStr{
    for(UIView *sv in self.dayHeader.subviews){
        [sv removeFromSuperview];
    }

   float scrWidth = self.view.frame.size.width;
    float wid = (scrWidth)/3;
    UIView *todayBottom= [[UIView alloc] initWithFrame:CGRectMake(0 ,28, wid, 2)];
    UILabel *today = [[UILabel alloc] initWithFrame:CGRectMake(0 ,0, wid, 28)];
    today.text=@"Today";
    today.textAlignment = NSTextAlignmentCenter;
    
    UIView *tomorrowBottom= [[UIView alloc] initWithFrame:CGRectMake(wid ,28, wid, 2)];
    UILabel *tomorrow = [[UILabel alloc] initWithFrame:CGRectMake(wid ,0, wid, 28)];
    tomorrow.text=@"Tomorrow";
    tomorrow.textAlignment = NSTextAlignmentCenter;
    
    UIView *pickBottom= [[UIView alloc] initWithFrame:CGRectMake(2*(wid) ,28, wid, 2)];
    UILabel *pick = [[UILabel alloc] initWithFrame:CGRectMake(2*(wid) ,0, wid, 28)];
    pick.text=@"Select Day";
    pick.textAlignment = NSTextAlignmentCenter;
    
    [self.dayHeader addSubview:today];
    [self.dayHeader addSubview:todayBottom];
    [self.dayHeader addSubview:tomorrowBottom];
    [self.dayHeader addSubview:tomorrow];
    [self.dayHeader addSubview:pickBottom];
    [self.dayHeader addSubview:pick];
    /*today.backgroundColor = [self.wnpConst getThemeHeaderColor];
    todayBottom.backgroundColor = [self.wnpConst getThemeHeaderColor];
    tomorrowBottom.backgroundColor = [self.wnpConst getThemeHeaderColor];
    tomorrow.backgroundColor = [self.wnpConst getThemeHeaderColor];
    pickBottom.backgroundColor = [self.wnpConst getThemeHeaderColor];
     pick.backgroundColor = [self.wnpConst getThemeHeaderColor];
    tomorrow.textColor=[UIColor grayColor];
    today.textColor=[UIColor grayColor];
    pick.textColor=[UIColor grayColor];*/
    //today.backgroundColor = [self.wnpConst getThemeColorWithTransparency:0.2];
    //todayBottom.backgroundColor = [self.wnpConst getThemeColorWithTransparency:0.2];
    //tomorrowBottom.backgroundColor = [self.wnpConst getThemeColorWithTransparency:0.2];
   // tomorrow.backgroundColor = [self.wnpConst getThemeColorWithTransparency:0.2];
   // pickBottom.backgroundColor = [self.wnpConst getThemeColorWithTransparency:0.2];
   // pick.backgroundColor = [self.wnpConst getThemeColorWithTransparency:0.2];
    tomorrow.textColor=[UIColor blackColor];
    today.textColor=[UIColor blackColor];
    pick.textColor=[UIColor blackColor];
   
    if([dateStr isEqualToString:@"Today"]){
        todayBottom.backgroundColor = [self.wnpConst getThemeBaseColor];
        //today.backgroundColor = [self.wnpConst getThemeBaseColor];
        //today.textColor=[UIColor whiteColor];
        self.selectedStartDate =[[self getCurrentLocalTime] dateByAddingTimeInterval:300];
        self.neStartDateSelection = self.selectedStartDate;
        self.startDate.text=[self.mdyFormatter stringFromDate:self.selectedStartDate];
        self.startTime.text= [self.hmAmPmFormatter stringFromDate:self.selectedStartDate];
        self.selectedEndDate =[self.selectedStartDate dateByAddingTimeInterval:1800];
        self.endTime.text= [self.hmAmPmFormatter stringFromDate:self.selectedEndDate];
        self.duration=[NSNumber numberWithInt:30];
        [self.endTime sizeToFit];
        [self.startTime sizeToFit];
    }else if(([dateStr isEqualToString:@"Tomorrow"])){
        tomorrowBottom.backgroundColor = [self.wnpConst getThemeBaseColor];
        //tomorrow.backgroundColor = [self.wnpConst getThemeBaseColor];
       // tomorrow.textColor=[UIColor whiteColor];
        NSCalendar *gregorian = [NSCalendar currentCalendar];
        NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
        [dateComponents setDay:(1)];
        self.selectedStartDate= [gregorian dateByAddingComponents:dateComponents toDate:[self getCurrentLocalTime] options:0];
        NSString *datStr =[NSString stringWithFormat:@"%@%s%s",[self.mdyFormatter stringFromDate:self.selectedStartDate]," ","09:00 am"];
        self.selectedStartDate = [self.mdyhmFormatter dateFromString:datStr];
        self.neStartDateSelection = self.selectedStartDate;
        self.startDate.text=[self.mdyFormatter stringFromDate:self.selectedStartDate];
        self.startTime.text= [self.hmAmPmFormatter stringFromDate:self.selectedStartDate];
        self.selectedEndDate =[self.selectedStartDate dateByAddingTimeInterval:1800];
        self.endTime.text= [self.hmAmPmFormatter stringFromDate:self.selectedEndDate];
        self.duration=[NSNumber numberWithInt:30];
        [self.endTime sizeToFit];
        [self.startTime sizeToFit];
    }else{
        pickBottom.backgroundColor = [self.wnpConst getThemeBaseColor];
        //pick.backgroundColor = [self.wnpConst getThemeBaseColor];
        //pick.textColor=[UIColor whiteColor];
        [self changeDate];
    }
    
    UITapGestureRecognizer *todayTap = [[UITapGestureRecognizer alloc] initWithTarget:self action: @selector(setSelectedDateTap:)];
    todayTap.numberOfTapsRequired = 1;
    todayTap.numberOfTouchesRequired = 1;
    [today setUserInteractionEnabled:YES];
    [today addGestureRecognizer:todayTap];
    
    UITapGestureRecognizer *tomorrowTap = [[UITapGestureRecognizer alloc] initWithTarget:self action: @selector(setSelectedDateTap:)];
    tomorrowTap.numberOfTapsRequired = 1;
    tomorrowTap.numberOfTouchesRequired = 1;
    [tomorrow setUserInteractionEnabled:YES];
    [tomorrow addGestureRecognizer:tomorrowTap];
    
    UITapGestureRecognizer *pickTap = [[UITapGestureRecognizer alloc] initWithTarget:self action: @selector(setSelectedDateTap:)];
    pickTap.numberOfTapsRequired = 1;
    pickTap.numberOfTouchesRequired = 1;
    [pick setUserInteractionEnabled:YES];
    [pick addGestureRecognizer:pickTap];
    [self loadConferenceRoom ];
}

-(void) ShowDropDown:(UITapGestureRecognizer *) rec{
    if(self.isExpanded){
        self.orgTableHeight.constant=150;
        self.orgTableBottom.constant=-100;
        self.isExpanded =false;
    }else{
        self.orgTableHeight.constant=35;
        self.isExpanded =true;
        self.orgTableBottom.constant=13;
    }
    
}
-(void) setSelectedDateTap:(UITapGestureRecognizer *) rec{
    UILabel *lbl = (UILabel *)rec.view;
    [self setSelectedDat:lbl.text];
}

-(void) bookNow:(id)sender{
    UIButton *btn = (UIButton *)sender;
    int tag = (int)btn.tag;
    self.resModel = [[ResourceModel alloc] init];
    self.resModel = [self.resModel initWithDictionary:[self.resourceList objectAtIndex:tag]];
    if(self.meetingName.text == nil || [self.meetingName.text isEqualToString:@""] ){
        [self showPopup:@"Error" Message:@"Please enter meeting name" CloseThis:YES];
    }else{
        [self addReservation:NULL];
    }
    
    
        
}
-(void) loadConferenceRoom{
    int index = 0;
    self.resourceList =self.smModel.resourceList;
    float scrWidth = self.view.frame.size.width;
    for(UIView *sbvs in self.confRoomLyt.subviews){
        [sbvs removeFromSuperview];
    }
    for(NSDictionary *resDic in self.smModel.resourceList){
         NSString *resourceType = [resDic objectForKey:@"resourceType"];
        if(![resourceType.uppercaseString isEqualToString:@"CONFERENCE ROOM"]){
            continue;
        }
        UIView *topView= [[UIView alloc] initWithFrame:CGRectMake(0 ,(index*160), scrWidth, 140)];
        UIView *headerView= [[UIView alloc] initWithFrame:CGRectMake(0 ,0, scrWidth, 38)];
        UILabel *meetingRoom = [[UILabel alloc] initWithFrame:CGRectMake(0 ,4, scrWidth-150, 30)];
       headerView.backgroundColor=[self.utils getThemeLightBlue];
        meetingRoom.text = [resDic objectForKey:@"resourceName"];
       
        
        UIButton *bookNow = [[UIButton alloc] initWithFrame:CGRectMake(scrWidth-140 ,4,130 , 30)];

        
        
        [topView addSubview: bookNow];
        
        
        NSString *datStr =[NSString stringWithFormat:@"%@%s%@",self.startDate.text," ",self.startTime.text];
        NSDate *strtTm = [self.mdyhmFormatter dateFromString:datStr];
        NSDate *endTm = [strtTm dateByAddingTimeInterval:self.duration.intValue*60];
        NSString *tod = [self.mdyFormatter stringFromDate:strtTm];
        NSMutableArray *dailyArray = [self.dailySchedules objectForKey:tod];
        BOOL isAvl =true;
        
        ResourceModel *currResModel = [[ResourceModel alloc]init];
        currResModel = [currResModel initWithDictionary:resDic];
        UIScrollView *hourScrView = [[UIScrollView alloc] initWithFrame:CGRectMake(0 ,68, scrWidth, 81)];
        UIImageView *leftArrow = [[UIImageView alloc] initWithFrame:CGRectMake(5 ,108, 20, 20)];
        [leftArrow setImage:[UIImage imageNamed:@"swiperight.png"]];
        
        UIImageView *rightArrow = [[UIImageView alloc] initWithFrame:CGRectMake(scrWidth-25 ,108, 20, 20)];
        [rightArrow setImage:[UIImage imageNamed:@"swipeleft.png"]];
        
        [topView addSubview: leftArrow];
        [topView addSubview: rightArrow];
        UIView *topBorder = [[UIScrollView alloc] initWithFrame:CGRectMake(0 ,21, 1440, 1)];
        topBorder.backgroundColor = [self.wnpConst getThemeColorWithTransparency:0.3];
        
        UIView *bottomBorder = [[UIScrollView alloc] initWithFrame:CGRectMake(0 ,80, 1440, 1)];
        bottomBorder.backgroundColor = [self.wnpConst getThemeColorWithTransparency:0.3];
        
         [hourScrView addSubview: topBorder];
        
         [hourScrView addSubview: bottomBorder];
        for(int i=0;i<48;i++){
            UIView *hourView = [[UIScrollView alloc] initWithFrame:CGRectMake((i*30) ,21, 30, 60)];
            [hourScrView addSubview: hourView];
            UITapGestureRecognizer *hhrTap = [[UITapGestureRecognizer alloc] initWithTarget:self action: @selector(setDateFromHorzBar:)];
            hhrTap.numberOfTapsRequired = 1;
            hhrTap.numberOfTouchesRequired = 1;
            hourView.tag=i;
            [hourView setUserInteractionEnabled:YES];
            [hourView addGestureRecognizer:hhrTap];
        }
        for(int i=0;i<=24;i++){
            UILabel *hourText = [[UILabel alloc] initWithFrame:CGRectMake((i*60) ,0, 60, 20)];
            if(i==0 || i==24){
                hourText.text =@"12a";
            }
            else if(i<12){
                hourText.text =[NSString stringWithFormat:@"%d%s",i,"a"];
            }else if(i==12){
                hourText.text =[NSString stringWithFormat:@"%d%s",12,"p"];
            }else{
                hourText.text =[NSString stringWithFormat:@"%d%s",(i-12),"p"];
            }
            hourText.textAlignment=NSTextAlignmentLeft;
            UIView *hourView = [[UIScrollView alloc] initWithFrame:CGRectMake((i*60) ,21, 1, 60)];
            hourView.backgroundColor = [self.utils getLightGray];
            [hourScrView addSubview: hourView];
            [hourScrView addSubview: hourText];
        }
        NSString *currHour = [self.hmFormatter stringFromDate:[self.hmAmPmFormatter dateFromString:self.startTime.text]];
        NSArray* timeArray = [currHour componentsSeparatedByString: @":"];
        NSString* hourStr = [timeArray objectAtIndex: 0];
        NSString* minStr = [timeArray objectAtIndex: 1];
        int startMin = (hourStr.intValue*60+minStr.intValue);
       
        
        
        hourScrView.contentOffset = CGPointMake(startMin, 0);
        hourScrView.scrollEnabled=true;
        hourScrView.contentSize = CGSizeMake(1440, 60);
        UILabel *roomDesc = [[UILabel alloc] initWithFrame:CGRectMake(0 ,38, scrWidth, 30)];
        if(currResModel.resourceDesc != (id)[NSNull null] && currResModel.resourceDesc != nil){
            roomDesc.text =currResModel.resourceDesc; //@"4 Seats | TV | White board | Monitor";
        }else{
            roomDesc.text =@"Resource details not updated";
        }
        
        roomDesc.backgroundColor=[self.utils getLightGray];
        //roomDesc.backgroundColor=[self.wnpConst getThemeHeaderColor];
        roomDesc.textColor=[UIColor blackColor];
        roomDesc.textAlignment=NSTextAlignmentCenter;
        if(dailyArray != (id)[NSNull null] && dailyArray != nil){
            for(ReservationModel *resrvModel in dailyArray){
                
                if(currResModel.resourceId.intValue != resrvModel.resourceId.intValue){
                    continue;
                }
                NSDate *rsrvStart = [NSDate dateWithTimeIntervalSince1970:resrvModel.startDate.doubleValue/1000];
               // [self.mdyhmFormatter setTimeZone:[NSTimeZone localTimeZone]];
                NSString *localStartTime = [self.mdyhmFormatter stringFromDate:rsrvStart];
                rsrvStart = [self.mdyhmFormatter dateFromString:localStartTime];
                NSDate *rsrvEnd =[rsrvStart dateByAddingTimeInterval:resrvModel.duration.intValue*60];
                NSArray* timeArray = [[self.hmFormatter stringFromDate:rsrvStart] componentsSeparatedByString: @":"];
                NSString* hourStr = [timeArray objectAtIndex: 0];
                NSString* minStr = [timeArray objectAtIndex: 1];
                int startMin = (hourStr.intValue*60+minStr.intValue);
                UIView *bookedView = [[UIScrollView alloc] initWithFrame:CGRectMake(startMin ,21, resrvModel.duration.intValue, 60)];
                bookedView.layer.borderColor = [UIColor redColor].CGColor;
                bookedView.layer.borderWidth = 1.0f;
                bookedView.tag = resrvModel.reservationId.intValue;
                UITapGestureRecognizer *meetTap = [[UITapGestureRecognizer alloc] initWithTarget:self action: @selector(showMeetingReco:)];
                meetTap.numberOfTapsRequired = 1;
                meetTap.numberOfTouchesRequired = 1;
                [bookedView setUserInteractionEnabled:YES];
                [bookedView addGestureRecognizer:meetTap];
                [hourScrView addSubview: bookedView];
                for(int i=-10;i<(resrvModel.duration.intValue+10);i++){
                    UIView *hourView = [[UIScrollView alloc] initWithFrame:CGRectMake(i ,0, 1, 60)];
                    hourView.transform = CGAffineTransformMakeRotation(degreesToRadians(10));
                    if(i%2 ==0){
                        hourView.backgroundColor = [UIColor redColor];
                    }else{
                        hourView.backgroundColor = [UIColor whiteColor];
                    }
                    
                    [bookedView addSubview: hourView];
                }
                
                
                
                
                if(([self.utils isAfter:strtTm CompareTo:rsrvStart] && [self.utils isBefore:strtTm CompareTo:rsrvEnd]) ||
                   ([self.utils isBefore:endTm CompareTo:rsrvEnd] && [self.utils isAfter:endTm CompareTo:rsrvStart]) ||
                   ([self.utils isAfter:rsrvStart CompareTo:strtTm] && [self.utils isBefore:rsrvStart CompareTo:endTm]) ||
                   ([self.utils isBefore:rsrvEnd CompareTo:endTm] && [self.utils isAfter:rsrvEnd CompareTo:strtTm])
                   ){
                    isAvl = false;
                }
                
            }
        }
        if(isAvl){
            bookNow.backgroundColor=[self.utils getThemeDarkBlue];
            bookNow.userInteractionEnabled=TRUE;
            bookNow.enabled=TRUE;
            [bookNow addTarget:self action:@selector(bookNow:) forControlEvents: UIControlEventTouchUpInside];
            bookNow.tag=index;
            [bookNow setTitle: @"Book now" forState: UIControlStateNormal];
            [bookNow setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [bookNow setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
           
        }else{
            [bookNow setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
            [bookNow setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
            [bookNow setTitle: @"Not available" forState: UIControlStateNormal];
            bookNow.backgroundColor=[self.utils getThemeDarkBlue];
            bookNow.userInteractionEnabled=FALSE;
            bookNow.enabled=FALSE;
           
        }
        //topView.backgroundColor=[self.wnpConst getThemeHeaderColor];
        [headerView addSubview: meetingRoom];
        [headerView addSubview: bookNow];
        [topView addSubview: headerView];
        //UIImageView *planImg = [[UIImageView alloc] initWithFrame:CGRectMake(0 ,30, scrWidth, 120)];
        //NSString *imgName = [NSString stringWithFormat:@"%s%d%s","conf_room_00",(index+1),".png"];
        //[planImg setImage:[UIImage imageNamed:imgName]];
        
        //
       [topView addSubview: roomDesc];
       [topView addSubview: hourScrView];
       [topView bringSubviewToFront:roomDesc];
       [self.confRoomLyt addSubview:topView];
       index++;
        [self startFade:leftArrow];
        [self startFade:rightArrow];
    }

}
-(void) addReservation:(NSString *)pymntRefKey{
    
    NSString *datStr =[NSString stringWithFormat:@"%@%s%@",self.startDate.text," ",self.startTime.text];
    NSDate *strtTm = [self.mdyhmFormatter dateFromString:datStr];
    strtTm = [self.mdyhmFormatter dateFromString:datStr];
    NSDate *endTm = [strtTm dateByAddingTimeInterval:self.duration.intValue*60];
    NSMutableArray *dailyArray = [self.dailySchedules objectForKey:[self.mdyFormatter stringFromDate:strtTm]];
    BOOL isAvl =true;
    if(dailyArray != (id)[NSNull null] && dailyArray != nil){
        for(ReservationModel *resrvModel in dailyArray){
            if(self.resModel.resourceId.intValue != resrvModel.resourceId.intValue){
                continue;
            }
            NSDate *rsrvStart = [NSDate dateWithTimeIntervalSince1970:resrvModel.startDate.doubleValue/1000];
            NSString *localDateStr = [self.mdyhmFormatter stringFromDate:rsrvStart];
            rsrvStart = [self.mdyhmFormatter dateFromString:localDateStr];
            
            NSDate *rsrvEnd =[rsrvStart dateByAddingTimeInterval:resrvModel.duration.intValue*60];
            localDateStr = [self.mdyhmFormatter stringFromDate:rsrvStart];
           rsrvEnd= [self.mdyhmFormatter dateFromString:localDateStr];
            //
            if(([self.utils isAfter:strtTm CompareTo:rsrvStart] && [self.utils isBefore:strtTm CompareTo:rsrvEnd]) ||
               ([self.utils isBefore:endTm CompareTo:rsrvEnd] && [self.utils isAfter:endTm CompareTo:rsrvStart]) ||
               ([self.utils isAfter:rsrvStart CompareTo:strtTm] && [self.utils isBefore:rsrvStart CompareTo:endTm]) ||
               ([self.utils isBefore:rsrvEnd CompareTo:endTm] && [self.utils isAfter:rsrvEnd CompareTo:strtTm])
               ){
                isAvl = false;
                break;
            }
            
        }
    }
    if(!isAvl){
        [self showPopup:@"Error" Message:@"This slot is not available organization" CloseThis:YES];
      
    }else if(self.orgModel == (id)[NSNull null] || self.orgModel == nil){
         [self showPopup:@"Error" Message:@"Please select an organization" CloseThis:YES];
    }else {
        self.resrvModel = [[ReservationModel alloc]init];
        self.resrvModel.reservedByUser=[self.utils getLoggedinUser].userId;
        self.resrvModel.reservedByOrg = self.orgModel.orgId;
        self.resrvModel.reservedByOrgName=self.orgModel.orgName;
        
        self.resrvModel.startDate=[self.ymdhmFormatter stringFromDate:strtTm];
        self.resrvModel.endTime=[self.ymdhmFormatter stringFromDate:endTm];
        self.resrvModel.description=@"" ;
        self.resrvModel.duration =self.duration;
        self.resrvModel.resourceType=self.resModel.resourceType;
        self.resrvModel.resourceId=self.resModel.resourceId;
        self.resrvModel.resourceName=self.resModel.resourceName;
        self.resrvModel.smSpaceId=self.smModel.smSpaceId;
        self.resrvModel.smSpaceName=self.smModel.smSapceName;
        self.resrvModel.reservationId=@-1;
        self.resrvModel.reservedByUserName=[self.utils getLoggedinUser].userName;
        self.resrvModel.reservationName=self.meetingName.text;
        
        @try{
            NSDictionary *result= [self.smSpDao addReservation:self.resrvModel PaymentRefKey:pymntRefKey];
            NSString *statusStr = [result objectForKey:@"STATUS"]    ;
            NSLog(@"%@",statusStr);
            if(statusStr != nil && [statusStr isEqual:@"SUCCESS"]){
                
                NSNumber* makePayment = [result objectForKey:@"makePayment"];
                if ([makePayment boolValue] == YES){
                    self.jSonResult = result;
                    NSString *paymentDesc = [result objectForKey:@"paymentDescription"];
                    NSNumber *payableAmount = [result objectForKey:@"payableAmount"];
                    NSNumber* haveAccount = [result objectForKey:@"haveAccount"];
                    if ([haveAccount boolValue] == YES){
                        [self showUpdatePopup:@"Payment" Message:paymentDesc CloseThis:NO];
                    }else{
                        [self showStripePopup: payableAmount.doubleValue Message:paymentDesc];
                    }
                    
                }else{
                     [self showPopup:@"Successful" Message:@"Reserved successfully."  CloseThis:NO];
                }
               
                
                
                
                
            }else{
                NSLog(@"%@",[result objectForKey:@"ERRORMESSAGE"] );
                NSException *e = [NSException exceptionWithName:@"UserException" reason:[result objectForKey:@"ERRORMESSAGE"] userInfo:nil];
                @throw e;
            }

        }@catch(NSException *exp){
            [self showPopup:@"Failed" Message:exp.description CloseThis:YES];
        }
        
    }
}
- (void)changeDate:(UITapGestureRecognizer *) rec{
    float centerX = self.view.center.x;
    float centerY = self.view.center.y;
    float scrWidth = self.view.frame.size.width;
    self.datepickerView = [[UIView alloc] initWithFrame:CGRectMake(0 ,centerY-125, scrWidth, 250)];
    self.datepicker=[[UIDatePicker alloc] initWithFrame:CGRectMake(5, 5, scrWidth, 200)];
   // self.datepicker.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
    self.datepicker.backgroundColor=[UIColor whiteColor];
    
    self.datepicker.hidden = NO;

    if(rec.view == self.endTime){
       self.datepicker.date =self.selectedEndDate;
        self.datepicker.datePickerMode = UIDatePickerModeTime;
        self.selectedTimeLabel = self.endTime;
    }else if(rec.view == self.startDate){
       self.datepicker.date =self.neStartDateSelection;
        self.datepicker.datePickerMode = UIDatePickerModeDate;
        self.selectedTimeLabel = self.startDate;
    }else{
        self.datepicker.date =self.neStartDateSelection;
        self.datepicker.datePickerMode = UIDatePickerModeTime;
        self.selectedTimeLabel = self.startTime;
    }
    self.view.backgroundColor=[UIColor grayColor];
    for(UIView *subViews in [self.view subviews]){
        subViews.alpha=0.2;
        subViews.userInteractionEnabled=false;
    }
    self.datepickerView.backgroundColor=[UIColor whiteColor];
    [self.datepickerView addSubview:self.datepicker];
    UIButton *okBtn = [[UIButton alloc] initWithFrame:CGRectMake(centerX-100,210,75,30)];
    okBtn.backgroundColor=[UIColor grayColor];
    [okBtn setTitle: @"Set" forState: UIControlStateNormal];
    okBtn.userInteractionEnabled=TRUE;
    okBtn.backgroundColor=[self.wnpConst getThemeBaseColor];
    [okBtn addTarget:self action:@selector(LabelChange:) forControlEvents: UIControlEventTouchUpInside];
    UIButton *cancelBtn = [[UIButton alloc] initWithFrame:CGRectMake(centerX+25,210,75,30)];
    cancelBtn.backgroundColor=[UIColor grayColor];
    [cancelBtn setTitle: @"Cancel" forState: UIControlStateNormal];
    cancelBtn.userInteractionEnabled=TRUE;
    [cancelBtn addTarget:self action:@selector(LabelChangeCancel:) forControlEvents: UIControlEventTouchUpInside];
    cancelBtn.backgroundColor=[self.wnpConst getThemeBaseColor];
     [self.datepickerView addSubview:okBtn];
     [self.datepickerView addSubview:cancelBtn];
    [self.view addSubview:self.datepickerView];
    
}

-(void)setDateFromHorzBar:(UITapGestureRecognizer *)hhrTap{
    int tag = (int)hhrTap.view.tag;
    NSDateFormatter *mdyhmFormatter = [[NSDateFormatter alloc] init];
    [mdyhmFormatter setDateFormat:@"MM/dd/yyyy HH:mm"];
    NSString *datStr =[NSString stringWithFormat:@"%@%s%@",self.startDate.text," ",[self.halfHoursForDay objectAtIndex:tag]];
    self.neStartDateSelection = [mdyhmFormatter dateFromString:datStr];
    [self changeDate:hhrTap];
}
- (void)changeDate{
    float centerX = self.view.center.x;
    float centerY = self.view.center.y;
    float scrWidth = self.view.frame.size.width;
    self.datepickerView = [[UIView alloc] initWithFrame:CGRectMake(0 ,centerY-125, scrWidth, 250)];
    self.datepicker=[[UIDatePicker alloc] initWithFrame:CGRectMake(5, 5, scrWidth, 200)];
    self.datepicker.backgroundColor=[UIColor whiteColor];
    self.datepicker.hidden = NO;
    self.datepicker.date =self.selectedStartDate;
    self.datepicker.datePickerMode = UIDatePickerModeDate;
    self.selectedTimeLabel = self.startDate;
    self.view.backgroundColor=[UIColor grayColor];
    for(UIView *subViews in [self.view subviews]){
        subViews.alpha=0.2;
        subViews.userInteractionEnabled=false;
    }
    self.datepickerView.backgroundColor=[UIColor whiteColor];
    [self.datepickerView addSubview:self.datepicker];
    UIButton *okBtn = [[UIButton alloc] initWithFrame:CGRectMake(centerX-100,210,75,30)];
    okBtn.backgroundColor=[UIColor grayColor];
    [okBtn setTitle: @"Set" forState: UIControlStateNormal];
    okBtn.userInteractionEnabled=TRUE;
    okBtn.backgroundColor=[self.wnpConst getThemeBaseColor];
    [okBtn addTarget:self action:@selector(LabelChange:) forControlEvents: UIControlEventTouchUpInside];
    UIButton *cancelBtn = [[UIButton alloc] initWithFrame:CGRectMake(centerX+25,210,75,30)];
    cancelBtn.backgroundColor=[UIColor grayColor];
    [cancelBtn setTitle: @"Cancel" forState: UIControlStateNormal];
    cancelBtn.userInteractionEnabled=TRUE;
    [cancelBtn addTarget:self action:@selector(LabelChangeCancel:) forControlEvents: UIControlEventTouchUpInside];
    cancelBtn.backgroundColor=[self.wnpConst getThemeBaseColor];
    [self.datepickerView addSubview:okBtn];
    [self.datepickerView addSubview:cancelBtn];
    [self.view addSubview:self.datepickerView];
    
}
- (void)LabelChange:(id)sender{
    self.view.backgroundColor=[UIColor whiteColor];
    for(UIView *subViews in [self.view subviews]){
        subViews.alpha=1.0;
        subViews.userInteractionEnabled=true;
    }
    NSString *dat=nil;
    NSDate *selDate = nil;
    if(self.selectedTimeLabel == self.startTime){
         dat =[NSString stringWithFormat:@"%@%s%@",self.startDate.text," ",[self.hmAmPmFormatter stringFromDate:self.datepicker.date]];
        selDate = [self.mdyhmFormatter dateFromString:dat];
    }else if(self.selectedTimeLabel == self.endTime){
       dat =[NSString stringWithFormat:@"%@%s%@",self.startDate.text," ",[self.hmAmPmFormatter stringFromDate:self.datepicker.date]];
         selDate = [self.mdyhmFormatter dateFromString:dat];
    }else if(self.selectedTimeLabel== self.startDate){
        selDate = self.datepicker.date;
        if([[self.mdyFormatter stringFromDate:self.datepicker.date] isEqualToString:[self.mdyFormatter stringFromDate:[self getCurrentLocalTime]]]){
            selDate =[[self getCurrentLocalTime] dateByAddingTimeInterval:300];
        }else{
            NSString *datStr =[NSString stringWithFormat:@"%@%s%s",[self.mdyFormatter stringFromDate:self.datepicker.date]," ","09:00 am"];
            selDate = [self.mdyhmFormatter dateFromString:datStr];
        }
    }
    
    if([self.utils isBefore:selDate CompareTo:[self getCurrentLocalTime]]){
        [self showPopup:@"Error" Message:@"Past Date/time not allowed" CloseThis:YES];
       
    }else if(self.selectedTimeLabel == self.startTime){
        self.startTime.text=[self.hmAmPmFormatter stringFromDate:selDate];
        self.duration = [NSNumber numberWithInt:30];
        self.selectedStartDate=selDate;
        self.neStartDateSelection = self.selectedStartDate;
        self.selectedEndDate = [self.selectedStartDate dateByAddingTimeInterval:1800];
        self.endTime.text= [self.hmAmPmFormatter stringFromDate:self.selectedEndDate];
        [self.endTime sizeToFit];
        [self.startTime sizeToFit];

    }else if(self.selectedTimeLabel == self.endTime){
        NSTimeInterval distanceBetweenDates = [self.datepicker.date timeIntervalSinceDate:self.selectedStartDate];
        
        if (distanceBetweenDates <= 0){
            [self showPopup:@"Error" Message:@"End time should be after start time" CloseThis:YES];
        }else{
             self.selectedEndDate = self.datepicker.date;
            self.endTime.text=[self.hmAmPmFormatter stringFromDate:self.datepicker.date];
            self.duration = [NSNumber numberWithInt:(distanceBetweenDates/60)];
        }
        
    }else if(self.selectedTimeLabel== self.startDate){
        self.duration = [NSNumber numberWithInt:30];
        self.selectedStartDate=selDate;
        self.neStartDateSelection = self.selectedStartDate;
        self.startTime.text= [self.hmAmPmFormatter stringFromDate:self.selectedStartDate];
        self.selectedEndDate = [self.selectedStartDate dateByAddingTimeInterval:1800];
        self.endTime.text= [self.hmAmPmFormatter stringFromDate:self.selectedEndDate];
        self.startDate.text=[self.mdyFormatter stringFromDate:self.selectedStartDate];
        [self.endTime sizeToFit];
        [self.startTime sizeToFit];
    }
    [self.datepickerView removeFromSuperview];
    [self.datepicker removeFromSuperview];
    [self loadConferenceRoom ];
}
- (void)LabelChangeCancel:(id)sender{
    self.view.backgroundColor=[UIColor whiteColor];
    for(UIView *subViews in [self.view subviews]){
        subViews.alpha=1.0;
        subViews.userInteractionEnabled=true;
    }

    [self.datepicker removeFromSuperview];
    [self.datepickerView removeFromSuperview];

}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) showStripePopup:(double) payable Message:(NSString *) message
{
    //self.popupError.text=@"";
    //self.popupError.hidden=true;
    
    // self.view.backgroundColor=[UIColor grayColor];
    for(UIView *subViews in [self.view subviews]){
        subViews.alpha=0.2;
        subViews.userInteractionEnabled=false;
    }
    float centerX = self.view.center.x;
    float centerY = self.view.center.y;
    
    self.view.userInteractionEnabled=false;
    self.popup=[[UIView alloc] initWithFrame:CGRectMake(centerX-135,centerY-125,270,250)];
    self.popup.backgroundColor = [UIColor whiteColor];
    self.popup.layer.borderColor = [self.wnpConst getThemeBaseColor].CGColor;
    self.popup.layer.borderWidth = 1.0f;
    self.popup.alpha=1.0;
    //  [self.view addSubview:self.popup];
    [[UIApplication sharedApplication].keyWindow addSubview:self.popup];
    
    UILabel *headerLbl =[[UILabel alloc] initWithFrame:CGRectMake(0,0,270,35)];
    headerLbl.text=@"Stripe payment gateway";
    headerLbl.textAlignment=NSTextAlignmentCenter;
    UIFont *txtFont = [headerLbl.font fontWithSize:fontSize];
    headerLbl.font = txtFont;
    headerLbl.textColor=[UIColor whiteColor];
    headerLbl.backgroundColor=[self.wnpConst getThemeBaseColor];
    [self.popup addSubview:headerLbl];
    
    self.popupError = [[UILabel alloc] initWithFrame:CGRectMake(10, 40 , 250, 30)];
    self.popupError.hidden=true;
    self.popupError.textColor=[UIColor redColor];
    [self.popup addSubview: self.popupError];
    
    UILabel *descLabel =[[UILabel alloc] initWithFrame:CGRectMake(10,75,250,90)];
    descLabel.text=message;
    descLabel.textAlignment=NSTextAlignmentCenter;
    descLabel.numberOfLines=-1;
    // UIFont *txtFont = [headerLbl.font fontWithSize:fontSize];
    descLabel.font = txtFont;
    descLabel.textColor=[UIColor blackColor];
    // headerLbl.backgroundColor=[self.wnpConst getThemeBaseColor];
    [self.popup addSubview:descLabel];
    
   /* UILabel *amtLbl =[[UILabel alloc] initWithFrame:CGRectMake(210,75,50,30)];
    amtLbl.text=[NSString stringWithFormat:@"%s%@","$",[self.utils getNumberFormatter:payable]];
    amtLbl.textAlignment=NSTextAlignmentLeft;
    // UIFont *txtFont = [headerLbl.font fontWithSize:fontSize];
    amtLbl.font = txtFont;
    amtLbl.textColor=[UIColor blackColor];
    // headerLbl.backgroundColor=[self.wnpConst getThemeBaseColor];
    [self.popup addSubview:amtLbl];*/
    
    
    self.payableAmount = [NSNumber numberWithDouble:payable] ;
    self.strpPymntTf = [[STPPaymentCardTextField alloc] initWithFrame:CGRectMake(10,170,250,30)];
    self.strpPymntTf.delegate=self;
    [self.popup addSubview:self.strpPymntTf];
    
    self.strpSubmitBtn = [[UIButton alloc] initWithFrame:CGRectMake(20,210,100,30)];
    self.strpSubmitBtn.backgroundColor=[UIColor grayColor];
    [self.strpSubmitBtn setTitle: @"Submit" forState: UIControlStateNormal];
    self.strpSubmitBtn.userInteractionEnabled=TRUE;
    self.strpSubmitBtn.enabled=FALSE;
    [self.strpSubmitBtn addTarget:self action:@selector(submitStripePayment:) forControlEvents: UIControlEventTouchUpInside];
    self.strpSubmitBtn.backgroundColor=[UIColor grayColor];
    
    [self.popup addSubview:self.strpSubmitBtn];
    
    self.strpCancelBtn = [[UIButton alloc] initWithFrame:CGRectMake(150,210,100,30)];
    self.strpCancelBtn.backgroundColor=[self.wnpConst getThemeBaseColor];
    // self.strpCancelBtn.backgroundColor=[UIColor grayColor];
    
    self.strpCancelBtn.userInteractionEnabled=TRUE;
    self.strpCancelBtn.enabled=TRUE;
    [self.strpCancelBtn setTitle: @"Cancel" forState: UIControlStateNormal];
    [self.strpCancelBtn addTarget:self action:@selector(cancelStripePayment:) forControlEvents: UIControlEventTouchUpInside];
    [self.popup addSubview:self.strpCancelBtn];
    
    UITapGestureRecognizer *viewTap = [[UITapGestureRecognizer alloc] initWithTarget:self action: @selector(hideKeyBord)];
    viewTap.numberOfTapsRequired = 1;
    viewTap.numberOfTouchesRequired = 1;
    [self.self.popup setUserInteractionEnabled:YES];
    [self.self.popup addGestureRecognizer:viewTap];
}

- (IBAction)loadMyReservations:(id)sender {
    UIStoryboard *stryBrd = [UIStoryboard storyboardWithName:@"MenuController" bundle:nil];
    MenuController *viewCtrl=[stryBrd instantiateViewControllerWithIdentifier:@"MenuController"];
    if(viewCtrl != nil){
        viewCtrl.modalTransitionStyle=UIModalTransitionStyleFlipHorizontal;
        viewCtrl.viewName=@"MyConfBookings";
        viewCtrl.selectedDate= self.selectedStartDate;
        viewCtrl.currSchedules=self.currSchedules;
        viewCtrl.selectedDayType=@"Day";
        [self presentViewController:viewCtrl animated:YES completion:nil];
    }
}
- (IBAction)submitStripePayment:(id)sender {
    self.popupError.text= @"";
    self.popupError.hidden=true;
    self.strpSubmitBtn.backgroundColor=[UIColor grayColor];
    self.strpSubmitBtn.userInteractionEnabled=FALSE;
    self.strpSubmitBtn.enabled=FALSE;
    
    self.strpCancelBtn.backgroundColor=[UIColor grayColor];
    self.strpCancelBtn.userInteractionEnabled=FALSE;
    self.strpCancelBtn.enabled=FALSE;
    if(self.adminAcctModel.strpPubKey == (id)[NSNull null] || self.adminAcctModel.strpPubKey == nil){
        self.popupError.text= @"Invalid Stripe  account";
        self.popupError.hidden=false;
        return;
    }
    NSLog(@"%@",self.adminAcctModel.strpPubKey);
    NSLog(@"%@",self.adminAcctModel.strpSecKey);
    NSString *publicKey=[self.utils decode:self.adminAcctModel.strpPubKey];
    @try{
        NSLog(@"%@",publicKey);
        STPAPIClient *strpClient = [[STPAPIClient alloc] initWithPublishableKey:publicKey];
        [Stripe setDefaultPublishableKey:publicKey];
        NSLog(@"%@",strpClient.publishableKey);
        if (![self.strpPymntTf isValid]) {
            self.popupError.text= @"Invalid Card";
            self.popupError.hidden=false;
            self.strpCancelBtn.backgroundColor=[self.wnpConst getThemeBaseColor];
            // self.strpCancelBtn.backgroundColor=[UIColor grayColor];
            
            self.strpCancelBtn.userInteractionEnabled=TRUE;
            self.strpCancelBtn.enabled=TRUE;
            return;
        }
        if (![Stripe defaultPublishableKey]) {
           
            self.popupError.text= @"Invalid key";
            self.popupError.hidden=false;
            self.strpCancelBtn.backgroundColor=[self.wnpConst getThemeBaseColor];
            // self.strpCancelBtn.backgroundColor=[UIColor grayColor];
            
            self.strpCancelBtn.userInteractionEnabled=TRUE;
            self.strpCancelBtn.enabled=TRUE;
            return;
        }
        
        [strpClient createTokenWithCard:self.strpPymntTf.card completion:^(STPToken *token, NSError *error) {
            if (error) {
                self.popupError.text= error.description;
                self.popupError.hidden=false;
                self.strpCancelBtn.backgroundColor=[self.wnpConst getThemeBaseColor];
                // self.strpCancelBtn.backgroundColor=[UIColor grayColor];
                
                self.strpCancelBtn.userInteractionEnabled=TRUE;
                self.strpCancelBtn.enabled=TRUE;
                return;
            }else{
                @try{
                    NSNumber *payableAmount = [self.jSonResult objectForKey:@"payableAmount"];
                    NSDictionary *i =[self.jSonResult objectForKey:@"ReservationModel"];
                    ReservationModel *resModel = [[ReservationModel alloc]init];
                    resModel = [resModel initWithDictionary:i];
                    NSDate *startDate = [NSDate date];
                    NSNumber *plnStart = [NSNumber numberWithLong:[startDate timeIntervalSince1970]];
                    NSDate *plnEndDate  = [NSDate dateWithTimeIntervalSince1970:resModel.startDate.doubleValue/1000];
                    NSNumber *plnEnd = [NSNumber numberWithLong:[plnEndDate timeIntervalSince1970]];
                    long duaration = (plnEnd.longValue - plnStart.longValue)/(1000*60*60*24);
                    NSNumber *trialPeriod =[NSNumber numberWithLong:duaration];
                    NSDictionary *result= [self.smSpDao updateReservationStatus:resModel CardId:token.tokenId TrialPeriod:trialPeriod Amount:payableAmount Gateway:@"STRIPE"];
                    
                    
                    NSString *statusStr = [result objectForKey:@"STATUS"]    ;
                    NSLog(@"%@",statusStr);
                    [self.popup removeFromSuperview];
                    for(UIView *subViews in self.view.subviews){
                        subViews.alpha=1.0;
                        subViews.userInteractionEnabled=TRUE;
                    }
                    self.view.alpha=1.0;
                    self.view.userInteractionEnabled=TRUE;
                    if(statusStr != nil && [statusStr isEqual:@"SUCCESS"]){
                        [self showPopup:@"Successful" Message:@"Reserved successfully."  CloseThis:NO];
                    }else{
                        [self showPopup:@"Failed" Message:[result objectForKey:@"ERRORMESSAGE"] CloseThis:YES];
                    }
                   
                }
                @catch (NSException *exception) {
                    self.popupError.text= exception.description;
                    self.popupError.hidden=false;
                    self.strpCancelBtn.backgroundColor=[self.wnpConst getThemeBaseColor];
                    // self.strpCancelBtn.backgroundColor=[UIColor grayColor];
                    
                    self.strpCancelBtn.userInteractionEnabled=TRUE;
                    self.strpCancelBtn.enabled=TRUE;
                   
                    self.strpCancelBtn.userInteractionEnabled=TRUE;
                    self.strpCancelBtn.enabled=TRUE;
                }
            }
        }];
    }@catch(NSException *exception) {
        self.popupError.text= exception.description;
        self.popupError.hidden=false;
        self.strpCancelBtn.backgroundColor=[self.wnpConst getThemeBaseColor];
        // self.strpCancelBtn.backgroundColor=[UIColor grayColor];
        
        self.strpCancelBtn.userInteractionEnabled=TRUE;
        self.strpCancelBtn.enabled=TRUE;
        return;
        
    }
    
    
    
}

- (IBAction)cancelStripePayment:(id)sender {
    [self cancelMeeting:sender];
    [self.popup removeFromSuperview];
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
        self.strpSubmitBtn.backgroundColor=[self.wnpConst getThemeBaseColor];
    }
    
}
-(void) hideKeyBord{
    [self.strpPymntTf resignFirstResponder];
    [self.view endEditing:YES];
}
- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.orgList.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
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
        OrganizationModel *orgModel =[[OrganizationModel alloc]init];
        orgModel =[orgModel initWithDictionary:[self.orgList objectAtIndex:0]];
        code.text=[NSString stringWithFormat:@"%s%@", "  ", orgModel.orgName];
        NSLog(@"%@",orgModel.orgName);
        if(self.orgModel.orgId.intValue == orgModel.orgId.intValue){
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [[tableView cellForRowAtIndexPath:indexPath] setBackgroundColor:SelectedCellBGColor];
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
-(NSDate *) getCurrentLocalTime{
    NSDateFormatter *frmt = [[NSDateFormatter alloc] init];
    [frmt setDateFormat:@"dd-MMM-yyyy hh:mm:ss a"];
    //[frmt setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT"]];
    return [self getCurrentLocalTime:frmt];

}
-(NSDate *) getCurrentLocalTime:(NSDateFormatter *)formatter{
   // NSString *localDate = [NSDateFormatter localizedStringFromDate:[NSDate date] dateStyle:NSDateFormatterMediumStyle timeStyle:NSDateFormatterMediumStyle];
   // NSDate *dte =[formatter dateFromString:localDate];
    return [NSDate date];
    
}
-(IBAction)startFade:(id)sender{
    UIImageView *senderImg = (UIImageView *) sender;
    [senderImg setAlpha:0.0f];
    
    //fade in
    [UIView animateWithDuration:2.0f animations:^{
        
        [senderImg setAlpha:1.0f];
        
    } completion:^(BOOL finished) {
        
        //fade out
        [UIView animateWithDuration:5.0f animations:^{
            
            [senderImg setAlpha:0.0f];
            
            
        } completion:nil];
        
    }];
}
-(void)showMeetingReco:(UITapGestureRecognizer *) rec{
    int tag = (int)rec.view.tag;
    ReservationModel *selResModel = nil;
    for(ReservationModel *resModel in self.currSchedules){
        if(resModel.reservationId.intValue == tag){
            selResModel = resModel;
            break;
        }
    }
    [self showMeeting:selResModel];
}
-(void)closePopup:(UITapGestureRecognizer *) rec{
    self.view.backgroundColor=[UIColor whiteColor];
    for(UIView *subViews in [self.view subviews]){
        subViews.alpha=1.0;
        subViews.userInteractionEnabled=true;
    }
    [self.alertView removeFromSuperview];
}
-(void) showMeeting:(ReservationModel *) resModel
{
    self.view.backgroundColor=[UIColor grayColor];
    for(UIView *subViews in [self.view subviews]){
        subViews.alpha=0.2;
        subViews.userInteractionEnabled=false;
    }
    
    float centerX = self.view.center.x;
    float centerY = self.view.center.y;
    self.alertView = [[UIView alloc] initWithFrame:CGRectMake(centerX-150, centerY-80 , 300, 180)];
    self.alertView.backgroundColor = [UIColor whiteColor];
    self.alertView.layer.borderColor = [self.wnpConst getThemeBaseColor].CGColor;
    self.alertView.layer.borderWidth = 1.0f;
    
    [self.view addSubview: self.alertView];
    UILabel *header = [[UILabel alloc] initWithFrame:CGRectMake(0, 0 , 300, 30)];
    header.text=@"Reservation details";//@"Your request processed successfully. Our community manager will contact you soon.";
    header.textAlignment=NSTextAlignmentCenter;
    header.numberOfLines=1;
    header.backgroundColor=[self.wnpConst getThemeBaseColor];;
    header.textColor=[UIColor whiteColor];
    [self.alertView addSubview: header];
    
    
    

    
    UILabel *name = [[UILabel alloc] initWithFrame:CGRectMake(0, 40 , 100, 30)];
    name.text=@"Name";
    //messageText.textAlignment=NSTextAlignmentCenter;

    [self.alertView addSubview: name];
    
    UILabel *nameVal = [[UILabel alloc] initWithFrame:CGRectMake(105, 40 , 190, 30)];
    nameVal.text=resModel.reservationName;
    //messageText.textAlignment=NSTextAlignmentCenter;

    [self.alertView addSubview: nameVal];
    

    
    UILabel *reserved = [[UILabel alloc] initWithFrame:CGRectMake(0, 75 , 100, 30)];
    reserved.text=@"Reserved by";
    //messageText.textAlignment=NSTextAlignmentCenter;
    reserved.numberOfLines=-1;
    [self.alertView addSubview: reserved];
    
    UILabel *reservedVal = [[UILabel alloc] initWithFrame:CGRectMake(105, 75 , 190, 30)];
    NSString *reservedBy = resModel.reservedByOrgName;
    if([resModel.reservedByOrgName.uppercaseString isEqualToString:@"INDIVIDUAL"]){
        reservedBy = resModel.reservedByUserName;
    }
    reservedVal.text=reservedBy;
    //messageText.textAlignment=NSTextAlignmentCenter;

    [self.alertView addSubview: reservedVal];
    
    UILabel *time = [[UILabel alloc] initWithFrame:CGRectMake(0, 110 , 100, 30)];
    time.text=@"Time";
    //messageText.textAlignment=NSTextAlignmentCenter;

    [self.alertView addSubview: time];
    
    UILabel *timeVal = [[UILabel alloc] initWithFrame:CGRectMake(105, 110 , 190, 30)];
    NSDate *rsrvStart = [NSDate dateWithTimeIntervalSince1970:resModel.startDate.doubleValue/1000];
    // [self.mdyhmFormatter setTimeZone:[NSTimeZone localTimeZone]];
    //NSString *localStartTime = [self.mdyhmFormatter stringFromDate:rsrvStart];
   // rsrvStart = [self.mdyhmFormatter dateFromString:localStartTime];
    NSDate *rsrvEnd =[rsrvStart dateByAddingTimeInterval:resModel.duration.intValue*60];

    timeVal.text=[NSString stringWithFormat:@"%@%s%@",[self.hmAmPmFormatter stringFromDate:rsrvStart]," To ",[self.hmAmPmFormatter stringFromDate:rsrvEnd]];
    //messageText.textAlignment=NSTextAlignmentCenter;

    [self.alertView addSubview: timeVal];

    

    
    UIButton *closeBtn = [[UIButton alloc] initWithFrame:CGRectMake( 115,145 , 70, 30)];
    closeBtn.backgroundColor=[self.wnpConst getThemeBaseColor];
    
    [closeBtn setTitle: @"Ok" forState: UIControlStateNormal];
    closeBtn.userInteractionEnabled=TRUE;
    closeBtn.enabled=TRUE;
    [closeBtn addTarget:self action:@selector(closePopup:) forControlEvents: UIControlEventTouchUpInside];
    [self.alertView addSubview: closeBtn];
}
-(void) showPopup:(NSString *) title Message:(NSString *) message CloseThis :(BOOL)closeThis
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
    if(closeThis){
        [closeBtn addTarget:self action:@selector(closePopup:) forControlEvents: UIControlEventTouchUpInside];
    }else{
        [closeBtn addTarget:self action:@selector(loadMyReservations:) forControlEvents: UIControlEventTouchUpInside];
    }
    
    [self.alertView addSubview: closeBtn];
}

-(void) showUpdatePopup:(NSString *) title Message:(NSString *) message CloseThis :(BOOL)closeThis
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
    UIButton *okBtn = [[UIButton alloc] initWithFrame:CGRectMake( 50,140 , 75, 30)];
    okBtn.backgroundColor=[self.wnpConst getThemeBaseColor];
    
    [okBtn setTitle: @"Ok" forState: UIControlStateNormal];
    okBtn.userInteractionEnabled=TRUE;
    okBtn.enabled=TRUE;
    [okBtn addTarget:self action:@selector(updateMeetingStatus:) forControlEvents: UIControlEventTouchUpInside];
    [self.alertView addSubview: okBtn];
    
    UIButton *cancelButton = [[UIButton alloc] initWithFrame:CGRectMake( 175,140 , 75, 30)];
    cancelButton.backgroundColor=[self.wnpConst getThemeBaseColor];
    
    [cancelButton setTitle: @"Cancel" forState: UIControlStateNormal];
    cancelButton.userInteractionEnabled=TRUE;
    cancelButton.enabled=TRUE;
    [cancelButton addTarget:self action:@selector(cancelMeeting:) forControlEvents: UIControlEventTouchUpInside];
    

    [self.alertView addSubview: cancelButton];
}
- (IBAction)updateMeetingStatus:(id)sender {
    @try{
        NSNumber *payableAmount = [self.jSonResult objectForKey:@"payableAmount"];
        NSDictionary *i =[self.jSonResult objectForKey:@"ReservationModel"];
        ReservationModel *resModel = [[ReservationModel alloc]init];
        resModel = [resModel initWithDictionary:i];
        NSDate *startDate = [NSDate date];
        NSNumber *plnStart = [NSNumber numberWithLong:[startDate timeIntervalSince1970]];
        NSDate *plnEndDate  = [NSDate dateWithTimeIntervalSince1970:resModel.startDate.doubleValue/1000];
        NSNumber *plnEnd = [NSNumber numberWithLong:[plnEndDate timeIntervalSince1970]];
        long duaration = (plnEnd.longValue - plnStart.longValue)/(1000*60*60*24);
        NSNumber *trialPeriod = [NSNumber numberWithLong:duaration];
     
        NSDictionary *result= [self.smSpDao updateReservationStatus:resModel CardId:nil TrialPeriod:trialPeriod Amount:payableAmount Gateway:@"STRIPE"];
        
       // NSDictionary *result= [self.smSpDao updateReservationStatus:resModel CardId:@"" TrialPeriod:trialPeriod Amount:payableAmount Gateway:@"STRIPE"];
        NSString *statusStr = [result objectForKey:@"STATUS"]    ;
        NSLog(@"%@",statusStr);
        if(statusStr != nil && [statusStr isEqual:@"SUCCESS"]){
           [self showPopup:@"Successful" Message:@"Reserved successfully."  CloseThis:NO];
        }else{
            [self showPopup:@"Failed" Message:[result objectForKey:@"ERRORMESSAGE"] CloseThis:YES];
        }
        
    }@catch(NSException *exp){
        [self showPopup:@"Failed" Message:exp.description CloseThis:YES];
    }
}
- (IBAction)cancelMeeting:(id)sender {
    @try{
        NSDictionary *i =[self.jSonResult objectForKey:@"ReservationModel"];
        ReservationModel *resModel = [[ReservationModel alloc]init];
        resModel = [resModel initWithDictionary:i];
        NSString *statusStr= [self.smSpDao deleteReservation:resModel];
        
        
        if(statusStr != nil && [statusStr isEqual:@"SUCCESS"]){
            [self showPopup:@"Successful" Message:@"Cancelled successfully."  CloseThis:NO];
        }
        
    }@catch(NSException *exp){
        [self showPopup:@"Failed" Message:exp.description CloseThis:YES];
    }
}
@end
