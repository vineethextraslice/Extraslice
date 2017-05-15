//
//  MyConfRoomReservations.m
//  extraSlice
//
//  Created by Administrator on 28/06/16.
//  Copyright © 2016 Extraslice Inc. All rights reserved.
//

#import "MyConfRoomReservations.h"
#import "WnpConstants.h"
#import "SmartSpaceDAO.h"
#import "Utilities.h"
#import "ReservationModel.h"
#import "STPPaymentCardTextField.h"
#import "STPAPIClient.h"
#import "Stripe.h"
#import "StripeDAO.h"
#import "StripePlanModel.h"
#import "OrganizationModel.h"
#import "ResourceModel.h"
#import "AdminAccountModel.h"
#import "SmartSpaceModel.h"
#import "MenuController.h"
static UIColor *SelectedCellBGColor ;
static UIColor *NotSelectedCellBGColor;
@interface MyConfRoomReservations ()<STPPaymentCardTextFieldDelegate>
@property(strong,nonatomic)WnPConstants *wnpConst;
@property(nonatomic)BOOL overLimit;
@property(strong,nonatomic)UIScrollView *dayScrView;
@property(strong,nonatomic) NSNumber *duration;
@property(strong,nonatomic) NSDate *selectedStartDate;
@property(strong,nonatomic) NSDate *selectedEndDate;
@property(strong,nonatomic)NSMutableDictionary *dailySchedules;
@property(strong,nonatomic) NSDateFormatter *mdyFormatter;
@property(strong,nonatomic) NSMutableArray *orgList;
@property(strong,nonatomic) NSDateFormatter *hmFormatter;
@property(strong,nonatomic) NSDateFormatter *mdyhmFormatter;
@property(strong,nonatomic) NSDateFormatter *ymdhmFormatter;
@property(strong,nonatomic) NSDateFormatter *y_m_dhmFormatter;
@property(strong,nonatomic) UIView *previousRow;
@property(strong,nonatomic) UIView *previousOrgRow;
@property(strong,nonatomic) NSDateFormatter *ddMMMFormat;
@property(strong,nonatomic) NSDateFormatter *MMM_yyyyFormat;
@property(strong,nonatomic) NSMutableArray *resTypeList;
@property(strong,nonatomic)UIView *dayNameStrs;
@property(strong,nonatomic) Utilities *utils;
@property(strong,nonatomic) UIView *strpPopup;
@property(strong,nonatomic) UIView *popup;
@property(strong,nonatomic) UIView *alertView;
@property(strong,nonatomic) UILabel *popupError;
@property(strong,nonatomic) UIButton *popSubmitBtn;
@property(strong,nonatomic) UIButton *popCancelBtn;
@property(strong,nonatomic) UIButton *strpSubmitBtn;
@property(strong,nonatomic) UIButton *strpCancelBtn;
@property(strong,nonatomic) STPPaymentCardTextField *strpPymntTf;
@property(strong,nonatomic) NSNumber *payableAmount;
@property(strong,nonatomic) StripeDAO *strpDAO;
@property(strong,nonatomic) NSString *pymntRefkey;
@property(strong,nonatomic) UILabel *datVal;
@property(strong,nonatomic) UILabel *startTimeVal ;
@property(strong,nonatomic) UILabel *endTimeVal;
@property(strong,nonatomic) UITextField *meetingName;
@property(strong,nonatomic) UITableView *confRoomVal;
@property(strong,nonatomic) UILabel *confRoomName;
@property(strong,nonatomic) UITableView *orgVal;
@property(nonatomic) BOOL isShowMeeting;

@property(strong,nonatomic) UIView *datepickerView;
@property(strong,nonatomic) UILabel *selectedTimeLabel;
@property(strong,nonatomic) UIDatePicker *datepicker;
@property(strong,nonatomic) ReservationModel *selResrvationModel;
@property(strong,nonatomic) SmartSpaceDAO *smSpaceDAO;
@property(strong,nonatomic) ResourceModel *selResource;
@property(strong,nonatomic) OrganizationModel *selOrg;
@property(strong,nonatomic) SmartSpaceModel *selSmartSpace;
@property(strong,nonatomic) AdminAccountModel *adminAcct;
@property(strong,nonatomic) NSLayoutConstraint *confTableHeight;
@property(nonatomic) BOOL isExpanded;
@property(strong,nonatomic) NSMutableArray *daysInMonthArray;
@property(strong,nonatomic) NSString *selectedDayType;
@property(strong,nonatomic) NSDictionary *jSonResult;
@end

@implementation MyConfRoomReservations

- (void)viewDidLoad {
    [super viewDidLoad];
    if(self.selectedDate == (id)[NSNull null] || self.selectedDate == nil){
        self.selectedDate = [NSDate date];
    }
    self.overLimit=false;
    self.previousRow=nil;
    self.previousOrgRow = nil;
    SelectedCellBGColor=[UIColor grayColor];
    NotSelectedCellBGColor =[UIColor whiteColor];
    self.wnpConst = [[WnPConstants alloc]init];
    self.smSpaceDAO = [[SmartSpaceDAO alloc]init];
    self.mdyFormatter = [[NSDateFormatter alloc] init];
    self.hmFormatter = [[NSDateFormatter alloc] init];
    self.dailySchedules = [[NSMutableDictionary alloc]init];
    self.utils = [[Utilities alloc]init];
    self.MMM_yyyyFormat = [[NSDateFormatter alloc]init];
    [self.MMM_yyyyFormat setDateFormat:@"MMM-yyyy"];
    self.ddMMMFormat = [[NSDateFormatter alloc]init];
    [self.ddMMMFormat setDateFormat:@"dd-MMM"];
    [self.mdyFormatter setDateFormat:@"MM/dd/yyyy"];
    [self.hmFormatter setDateFormat:@"hh:mm a"];
    self.mdyhmFormatter = [[NSDateFormatter alloc] init];
    [self.mdyhmFormatter setDateFormat:@"MM/dd/yyyy hh:mm a"];
    self.ymdhmFormatter = [[NSDateFormatter alloc] init];
    [self.ymdhmFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZ"];
    self.y_m_dhmFormatter = [[NSDateFormatter alloc] init];
    [self.y_m_dhmFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    [self.ymdhmFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    [self.mdyhmFormatter setTimeZone:[NSTimeZone localTimeZone]];
    
    NSMutableArray *smList  = [[NSMutableArray alloc]init];
    @try{
        smList = [self.smSpaceDAO getAllSmartSpace];
    }@catch (NSException *exception) {
      
        
    }
    self.adminAcct = [self.smSpaceDAO getAdminAccount];
    self.selSmartSpace = [smList objectAtIndex:0];
    //if(self.currSchedules == (id)[NSNull null] || self.currSchedules == nil){
        [self loadCurrentSchedule];
   // }
    
   
    if([self.utils getLoggedinUser].orgList != nil && [self.utils getLoggedinUser].orgList.count ==1){
        OrganizationModel *orgModel =[[OrganizationModel alloc]init];
        orgModel =[orgModel initWithDictionary:[[self.utils getLoggedinUser].orgList objectAtIndex:0]];
        if(orgModel.approved){
            self.selOrg = orgModel;
            [self.orgList addObject:self.selOrg];
        }
    }else if([self.utils getLoggedinUser].orgList != nil && [self.utils getLoggedinUser].orgList.count >1){

        for(NSDictionary *dic in [self.utils getLoggedinUser].orgList){
            OrganizationModel *orgModel =[[OrganizationModel alloc]init];
            orgModel = [self.selOrg initWithDictionary:dic];
            if(orgModel.approved){
                [self.orgList addObject:orgModel];
            }
        }
    }
    
    [self setSelectedDat:@"Day" SelectedDate:[NSDate date]];
    UISwipeGestureRecognizer * swipeleft=[[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipeleft:)];
    swipeleft.direction=UISwipeGestureRecognizerDirectionLeft;
    [self.view addGestureRecognizer:swipeleft];
    
    UISwipeGestureRecognizer * swiperight=[[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swiperight:)];
    swiperight.direction=UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:swiperight];
}
-(IBAction)startFade:(id)sender{
    UIImageView *senderImg = (UIImageView *) sender;
    [senderImg setAlpha:0.0f];
    
    //fade in
    [UIView animateWithDuration:2.0f animations:^{
        
        [senderImg setAlpha:1.0f];
        
    } completion:^(BOOL finished) {
        
        //fade out
        [UIView animateWithDuration:2.0f animations:^{
            
            [senderImg setAlpha:0.0f];
            
            
        } completion:nil];
        
    }];
}
-(void) loadCurrentSchedule{
    @try{
        NSCalendar *gregorian = [NSCalendar currentCalendar];
        NSDateComponents *comp = [gregorian components: NSCalendarUnitYear | NSCalendarUnitMonth fromDate:self.selectedDate];
        [comp setDay:1];
        NSDate *firstDayOfMonthDate = [gregorian dateFromComponents:comp];
        comp = [gregorian components:NSCalendarUnitWeekday fromDate:firstDayOfMonthDate];
        int weekday = [comp weekday];
        NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
        [dateComponents setDay:(-weekday+1)];
        NSDate *calStartDate = [gregorian dateByAddingComponents:dateComponents toDate:firstDayOfMonthDate options:0];
        
        dateComponents = [[NSDateComponents alloc] init];
        [dateComponents setDay:(48)];
        NSDate *calEndDate = [gregorian dateByAddingComponents:dateComponents toDate:calStartDate options:0];
        
        self.currSchedules = [self.smSpaceDAO getCurrentSchedulesForPeriod:[self.y_m_dhmFormatter stringFromDate:calStartDate] EndTime:[self.y_m_dhmFormatter stringFromDate:calEndDate]];
        if(self.currSchedules != (id)[NSNull null] && self.currSchedules != nil){
            for(ReservationModel *resModel in self.currSchedules){
                NSDate *dte =  [NSDate dateWithTimeIntervalSince1970:resModel.startDate.doubleValue/1000];
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
        self.daysInMonthArray=[[NSMutableArray alloc]init];
        [self.daysInMonthArray addObject:[self.mdyFormatter stringFromDate:calStartDate]];
        for(int i=0;i<48;i++){
            dateComponents = [[NSDateComponents alloc] init];
            [dateComponents setDay:(1)];
            calStartDate = [gregorian dateByAddingComponents:dateComponents toDate:calStartDate options:0];
            [self.daysInMonthArray addObject:[self.mdyFormatter stringFromDate:calStartDate]];
        }
    }@catch (NSException *exception) {
        
        
    }
}
-(void)swipeleft:(UISwipeGestureRecognizer*)gestureRecognizer
{
    if([self.selectedDayType.uppercaseString isEqualToString:@"DAY"]){
        NSCalendar *gregorian = [NSCalendar currentCalendar];
        NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
        [dateComponents setDay:(1)];
        self.selectedDate = [gregorian dateByAddingComponents:dateComponents toDate:self.selectedDate options:0];
        
        if([self.daysInMonthArray containsObject:[self.mdyFormatter stringFromDate:self.selectedDate]]){
            [self setSelectedDat:@"Day" SelectedDate:self.selectedDate];
        }else{
            [self loadCurrentSchedule];
            [self setSelectedDat:@"Day" SelectedDate:self.selectedDate];
        }
    }else if([self.selectedDayType.uppercaseString isEqualToString:@"WEEK"]){
            NSCalendar *gregorian = [NSCalendar currentCalendar];
            NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
            [dateComponents setDay:(7)];
            self.selectedDate = [gregorian dateByAddingComponents:dateComponents toDate:self.selectedDate options:0];
            NSDateComponents *comps = [gregorian components:NSCalendarUnitWeekday fromDate:self.selectedDate];
            int weekday = [comps weekday];
            dateComponents = [[NSDateComponents alloc] init];
            [dateComponents setDay:((-weekday+1)+7)];
            NSDate *newDate = [gregorian dateByAddingComponents:dateComponents toDate:self.selectedDate options:0];
            
            if([self.daysInMonthArray containsObject:[self.mdyFormatter stringFromDate:newDate]]){
                [self setSelectedDat:@"Week" SelectedDate:self.selectedDate];
            }else{
                [self loadCurrentSchedule];
                [self setSelectedDat:@"Week" SelectedDate:self.selectedDate];
            }
    }else if([self.selectedDayType.uppercaseString isEqualToString:@"MONTH"]){
        NSCalendar *gregorian = [NSCalendar currentCalendar];
        NSDateComponents *comp = [[NSDateComponents alloc] init];
        [comp setMonth:1];
         self.selectedDate = [gregorian dateByAddingComponents:comp toDate:self.selectedDate options:0];
        [self setSelectedDat:@"Month" SelectedDate:self.selectedDate];
    }
}

-(void)swiperight:(UISwipeGestureRecognizer*)gestureRecognizer
{
    if([self.selectedDayType.uppercaseString isEqualToString:@"DAY"]){
        NSCalendar *gregorian = [NSCalendar currentCalendar];
        NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
        [dateComponents setDay:(-1)];
        self.selectedDate = [gregorian dateByAddingComponents:dateComponents toDate:self.selectedDate options:0];
        
        if([self.daysInMonthArray containsObject:[self.mdyFormatter stringFromDate:self.selectedDate]]){
            [self setSelectedDat:@"Day" SelectedDate:self.selectedDate];
        }else{
            [self loadCurrentSchedule];
            [self setSelectedDat:@"Day" SelectedDate:self.selectedDate];
        }
    }else if([self.selectedDayType.uppercaseString isEqualToString:@"WEEK"]){
        NSCalendar *gregorian = [NSCalendar currentCalendar];
        NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
        [dateComponents setDay:(-7)];
        self.selectedDate = [gregorian dateByAddingComponents:dateComponents toDate:self.selectedDate options:0];
        NSDateComponents *comps = [gregorian components:NSCalendarUnitWeekday fromDate:self.selectedDate];
        int weekday = [comps weekday];
        dateComponents = [[NSDateComponents alloc] init];
        [dateComponents setDay:((-weekday+1)+7)];
        NSDate *newDate = [gregorian dateByAddingComponents:dateComponents toDate:self.selectedDate options:0];
        
        if([self.daysInMonthArray containsObject:[self.mdyFormatter stringFromDate:newDate]]){
            [self setSelectedDat:@"Week" SelectedDate:self.selectedDate];
        }else{
            [self loadCurrentSchedule];
            [self setSelectedDat:@"Week" SelectedDate:self.selectedDate];
        }
    }else if([self.selectedDayType.uppercaseString isEqualToString:@"MONTH"]){
        NSCalendar *gregorian = [NSCalendar currentCalendar];
        NSDateComponents *comp = [[NSDateComponents alloc] init];
        [comp setMonth:-1];
        self.selectedDate = [gregorian dateByAddingComponents:comp toDate:self.selectedDate options:0];
        [self setSelectedDat:@"Month" SelectedDate:self.selectedDate];
    }
}
-(void) setSelectedDateTap:(UITapGestureRecognizer *) rec{
    UILabel *lbl = (UILabel *)rec.view;
    [self setSelectedDat:lbl.text SelectedDate:[NSDate date]];
}
-(void ) setSelectedDat:(NSString *)dateStr SelectedDate:(NSDate *) selDate{
    [self startFade:self.nextImage];
    [self startFade:self.previousImage];
    /*self.nextImage.hidden = NO;
    self.nextImage.alpha = 1.0f;
    self.previousImage.hidden = NO;
    self.previousImage.alpha = 1.0f;
    // Then fades it away after 2 seconds (the cross-fade animation will take 0.5s)
    [UIView animateWithDuration:0.5 delay:2.0 options:0 animations:^{
        // Animate the alpha value of your imageView from 1.0 to 0.0 here
        self.nextImage.alpha = 0.0f;
         self.previousImage.alpha = 0.0f;
    } completion:^(BOOL finished) {
        // Once the animation is completed and the alpha has gone to 0.0, hide the view for good
        self.nextImage.hidden = YES;
         self.previousImage.hidden = YES;
    }];*/
    for(UIView *sv in self.dayTypeHeader.subviews){
        [sv removeFromSuperview];
    }
    self.selectedDayType=dateStr;
    float scrWidth = self.view.frame.size.width;
    float wid = (scrWidth)/3;
    UIView *todayBottom= [[UIView alloc] initWithFrame:CGRectMake(0 ,28, wid, 2)];
    UILabel *today = [[UILabel alloc] initWithFrame:CGRectMake(0 ,0, wid, 28)];
    today.text=@"Day";
    today.textAlignment = NSTextAlignmentCenter;
    
    UIView *tomorrowBottom= [[UIView alloc] initWithFrame:CGRectMake(wid ,28, wid, 2)];
    UILabel *tomorrow = [[UILabel alloc] initWithFrame:CGRectMake(wid ,0, wid, 28)];
    tomorrow.text=@"Week";
    tomorrow.textAlignment = NSTextAlignmentCenter;
    
    UIView *pickBottom= [[UIView alloc] initWithFrame:CGRectMake(2*wid ,28, wid, 2)];
    UILabel *pick = [[UILabel alloc] initWithFrame:CGRectMake(2*wid ,0, wid, 28)];
    pick.text=@"Month";
    pick.textAlignment = NSTextAlignmentCenter;
    
    [self.dayTypeHeader addSubview:today];
    [self.dayTypeHeader addSubview:todayBottom];
    [self.dayTypeHeader addSubview:tomorrowBottom];
    [self.dayTypeHeader addSubview:tomorrow];
    [self.dayTypeHeader addSubview:pickBottom];
    [self.dayTypeHeader addSubview:pick];

    today.backgroundColor = [self.wnpConst getThemeColorWithTransparency:0.2];
    todayBottom.backgroundColor = [self.wnpConst getThemeColorWithTransparency:0.2];
    tomorrowBottom.backgroundColor = [self.wnpConst getThemeColorWithTransparency:0.2];
    tomorrow.backgroundColor = [self.wnpConst getThemeColorWithTransparency:0.2];
    pickBottom.backgroundColor = [self.wnpConst getThemeColorWithTransparency:0.2];
    pick.backgroundColor = [self.wnpConst getThemeColorWithTransparency:0.2];
    tomorrow.textColor=[UIColor blackColor];
    today.textColor=[UIColor blackColor];
    pick.textColor=[UIColor blackColor];
    
    if([dateStr isEqualToString:@"Day"]){
        todayBottom.backgroundColor = [self.wnpConst getThemeBaseColor];
        [self loadDailyData:selDate];
    }else if(([dateStr isEqualToString:@"Week"])){
        tomorrowBottom.backgroundColor = [self.wnpConst getThemeBaseColor];
        [self loadWeeklyData:selDate];
    }else{
        pickBottom.backgroundColor = [self.wnpConst getThemeBaseColor];
       // pick.backgroundColor = [self.wnpConst getThemeBaseColor];
        //pick.textColor=[UIColor whiteColor];
          [self loadMonthlyData:selDate];
        
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
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}
-(void) loadDailyData:(NSDate *) selDate{
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat tableWidth = screenRect.size.width;
    for(UIView *subV in self.dayScrView.subviews){
        [subV removeFromSuperview];
    }
    for(UIView *subV in self.dayNameStrs.subviews){
        [subV removeFromSuperview];
    }
    //[self.dayScrView removeFromSuperview];
    self.dayScrView =[[UIScrollView alloc] initWithFrame:CGRectMake(0, 63 ,tableWidth, screenRect.size.height-63)];
    self.dayScrView.contentSize = CGSizeMake(tableWidth, 1560);
    self.dayScrView.scrollEnabled=true;
    [self.view addSubview:self.dayScrView];
    self.dayDescription.backgroundColor = [self.wnpConst getThemeHeaderColor];
    NSString *dateString = [self.mdyhmFormatter stringFromDate:selDate];
    self.dayDescription.text=[self.ddMMMFormat stringFromDate:[self.mdyhmFormatter dateFromString:dateString]];
    for(int i=0;i<24;i++){
        UILabel *hourValView= [[UILabel alloc] initWithFrame:CGRectMake(0, (i*60) ,30, 20)];
        [self.dayScrView addSubview:hourValView];
       // hourValView.text=[NSString stringWithFormat:@"%i",i];
        if(i==0){
            hourValView.text =@"12a";
        }
        else if(i<12){
            hourValView.text =[NSString stringWithFormat:@"%d%s",i,"a"];
        }else if(i==12){
            hourValView.text =[NSString stringWithFormat:@"%d%s",12,"p"];
        }else{
            hourValView.text =[NSString stringWithFormat:@"%d%s",(i-12),"p"];
        }
        
        UIView *hourView = [[UIView alloc] initWithFrame:CGRectMake(30, (i*60) ,tableWidth-30, 60)];
        hourView.layer.borderColor = [self.wnpConst getThemeHeaderColor].CGColor;
        hourView.layer.borderWidth = 1.0f;
        [self.dayScrView addSubview:hourView];
    }
    
    self.dayScrView.contentOffset = CGPointMake(0, 540);
    NSDateFormatter *hourFormatter = [[NSDateFormatter alloc] init];
   [hourFormatter setDateFormat:@"HH"];
    
    NSDateFormatter *minFormatter = [[NSDateFormatter alloc] init];
    [minFormatter setDateFormat:@"mm"];
   
    NSString *day = [self.mdyFormatter stringFromDate:selDate];
    NSMutableArray *dayArray = [self.dailySchedules objectForKey:day];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"startDate" ascending:TRUE];
    [dayArray sortUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
   
    
    if( dayArray != (id)[NSNull null] && dayArray != nil){
        NSMutableDictionary *idMap = [[NSMutableDictionary alloc]init];
        for(int topInd=0;topInd  < dayArray.count ; topInd++){
            ReservationModel *resModel = [dayArray objectAtIndex:topInd];
            if(resModel.reservedByUser.intValue != [self.utils getLoggedinUser].userId.intValue){
                continue;
            }
            NSMutableArray *val = [[NSMutableArray alloc]init];
            [val addObject:resModel.reservationId];
            if([idMap objectForKey:resModel.reservationId] != (id)[NSNull null] && [idMap objectForKey:resModel.reservationId] != nil){
                val = [idMap objectForKey:resModel.reservationId];
            }
            
            
            [idMap setObject:val forKey:resModel.reservationId];
            NSDate *rsrvStart = [NSDate dateWithTimeIntervalSince1970:resModel.startDate.doubleValue/1000];
            NSDate *rsrvEnd = [NSDate dateWithTimeIntervalSince1970:resModel.endTime.doubleValue/1000];
            for(int compInd=(topInd+1);compInd  < dayArray.count ; compInd++){
                ReservationModel *compModel = [dayArray objectAtIndex:compInd];
                if(compModel.reservedByUser.intValue != [self.utils getLoggedinUser].userId.intValue){
                    continue;
                }
               val = [idMap objectForKey:resModel.reservationId];
                
                NSDate *newRsrvStart = [NSDate dateWithTimeIntervalSince1970:compModel.startDate.doubleValue/1000];
                
                if([self isAfter:rsrvStart CompareTo:newRsrvStart] && [self isBefore:rsrvEnd CompareTo:newRsrvStart]){
                    [val addObject:compModel.reservationId];
                    [idMap setObject:val forKey:resModel.reservationId];
                    [idMap setObject:val forKey:compModel.reservationId];
                }
            
            }
        }
        for(ReservationModel *resModel in dayArray){
            if(resModel.reservedByUser.intValue != [self.utils getLoggedinUser].userId.intValue){
                continue;
            }
            NSDate *dte =  [NSDate dateWithTimeIntervalSince1970:resModel.startDate.doubleValue/1000];
            NSMutableArray *val = [idMap objectForKey:resModel.reservationId];

            
            
            int top=([hourFormatter stringFromDate:dte].intValue)*60;
            top = top +[minFormatter stringFromDate:dte].intValue;
            int start = -1;
            for(NSNumber *num in val){
                start++;
                if(num.intValue != resModel.reservationId.intValue){
                    break;
                }
            }
            float meetingWidth = (tableWidth-35)/val.count;
            UILabel *meeting= [[UILabel alloc] initWithFrame:CGRectMake(30+(start*meetingWidth)+5, top ,meetingWidth, resModel.duration.intValue)];
            [self.dayScrView addSubview:meeting];
           
            meeting.text=resModel.reservationName;
            meeting.backgroundColor=[self.wnpConst getThemeHeaderColor];
            meeting.layer.borderColor = [self.wnpConst getThemeBaseColor].CGColor;
            meeting.layer.borderWidth = 1.0f;
            

            UITapGestureRecognizer *showMeetingTap = [[UITapGestureRecognizer alloc] initWithTarget:self action: @selector(showMeetingPopup:)];
            showMeetingTap.numberOfTapsRequired = 1;
            showMeetingTap.numberOfTouchesRequired = 1;
            [meeting setUserInteractionEnabled:YES];
            [meeting addGestureRecognizer:showMeetingTap];
            meeting.tag=resModel.reservationId.intValue;
        }
    }

    
}
-(void) loadWeeklyData:(NSDate *) selDate{
    for(UIView *subV in self.dayScrView.subviews){
        [subV removeFromSuperview];
    }
    for(UIView *subV in self.dayNameStrs.subviews){
        [subV removeFromSuperview];
    }
    [self.dayScrView removeFromSuperview];
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat tableWidth = screenRect.size.width;
     self.dayNameStrs =[[UIScrollView alloc] initWithFrame:CGRectMake(0, 63 ,tableWidth, 30)];
    self.dayScrView =[[UIScrollView alloc] initWithFrame:CGRectMake(0, 93 ,tableWidth, screenRect.size.height-93)];
    self.dayScrView.contentSize = CGSizeMake(tableWidth, 1560);
    self.dayScrView.scrollEnabled=true;
    [self.view addSubview:self.dayScrView];

    NSCalendar *gregorian = [NSCalendar currentCalendar];
    NSDateComponents *comps = [gregorian components:NSCalendarUnitWeekday fromDate:selDate];
    int weekday = [comps weekday];
    
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    [dateComponents setDay:(-weekday+1)];

    // Retrieve date with increased days count
    NSDate *newDate = [gregorian dateByAddingComponents:dateComponents toDate:selDate options:0];
    NSString *weekDes=[self.ddMMMFormat stringFromDate:newDate];
    [dateComponents setDay:7];
    newDate = [gregorian dateByAddingComponents:dateComponents toDate:newDate options:0];
    [self.view addSubview:self.dayNameStrs];
    weekDes= [NSString stringWithFormat:@"%@%s%@",weekDes," - ",[self.ddMMMFormat stringFromDate:newDate]];
    self.dayDescription.backgroundColor = [self.wnpConst getThemeHeaderColor];
    self.dayDescription.text=weekDes;
    [dateComponents setDay:-7];
    newDate = [gregorian dateByAddingComponents:dateComponents toDate:newDate options:0];
    self.dayScrView.scrollEnabled=true;
     double hourWidth = ((tableWidth-30)/7);
    for(int i=0;i<24;i++){
        UILabel *hourValView= [[UILabel alloc] initWithFrame:CGRectMake(0, (i*60) ,30, 20)];
        [self.dayScrView addSubview:hourValView];
        if(i==0){
            hourValView.text =@"12a";
        }
        else if(i<12){
            hourValView.text =[NSString stringWithFormat:@"%d%s",i,"a"];
        }else if(i==12){
            hourValView.text =[NSString stringWithFormat:@"%d%s",12,"p"];
        }else{
            hourValView.text =[NSString stringWithFormat:@"%d%s",(i-12),"p"];
        }
       
        for(int day = 0;day<=6;day++){
            UIView *hourView = [[UIView alloc] initWithFrame:CGRectMake(30+(day*hourWidth), (i*60) ,hourWidth, 60)];
            hourView.layer.borderColor = [self.wnpConst getThemeBaseColor].CGColor;
            hourView.layer.borderWidth = 1.0f;
            [self.dayScrView addSubview:hourView];
        }
    }

    for(int day = 0;day<=6;day++){
        UILabel *headerView = [[UILabel alloc] initWithFrame:CGRectMake(30+(day*hourWidth), 0 ,hourWidth, 30)];
        //headerView.layer.borderColor = [self.wnpConst getThemeHeaderColor].CGColor;
        //hourView.layer.borderWidth = 1.0f;
        [self.dayNameStrs addSubview:headerView];
        headerView.text=[self.ddMMMFormat stringFromDate:newDate];
        UIFont *txtFont = [headerView.font fontWithSize:12.0];
        headerView.font = txtFont;

          [dateComponents setDay:1];
       
        NSDateFormatter *hourFormatter = [[NSDateFormatter alloc] init];
        [hourFormatter setDateFormat:@"HH"];
        
        NSDateFormatter *minFormatter = [[NSDateFormatter alloc] init];
        [minFormatter setDateFormat:@"mm"];
        
        NSString *dayStr = [self.mdyFormatter stringFromDate:newDate];
        NSMutableArray *dayArray = [self.dailySchedules objectForKey:dayStr];

        if( dayArray != (id)[NSNull null] && dayArray != nil){
            
            NSMutableDictionary *idMap = [[NSMutableDictionary alloc]init];
            for(int topInd=0;topInd  < dayArray.count ; topInd++){
                ReservationModel *resModel = [dayArray objectAtIndex:topInd];
                if(resModel.reservedByUser.intValue != [self.utils getLoggedinUser].userId.intValue){
                    continue;
                }
                NSMutableArray *val = [[NSMutableArray alloc]init];
                [val addObject:resModel.reservationId];
                if([idMap objectForKey:resModel.reservationId] != (id)[NSNull null] && [idMap objectForKey:resModel.reservationId] != nil){
                    val = [idMap objectForKey:resModel.reservationId];
                }
                
                
                [idMap setObject:val forKey:resModel.reservationId];
                NSDate *rsrvStart = [NSDate dateWithTimeIntervalSince1970:resModel.startDate.doubleValue/1000];
                NSDate *rsrvEnd = [NSDate dateWithTimeIntervalSince1970:resModel.endTime.doubleValue/1000];
                for(int compInd=(topInd+1);compInd  < dayArray.count ; compInd++){
                    ReservationModel *compModel = [dayArray objectAtIndex:compInd];
                    if(compModel.reservedByUser.intValue != [self.utils getLoggedinUser].userId.intValue){
                        continue;
                    }
                    val = [idMap objectForKey:resModel.reservationId];
                    
                    NSDate *newRsrvStart = [NSDate dateWithTimeIntervalSince1970:compModel.startDate.doubleValue/1000];
                    
                    if([self isAfter:rsrvStart CompareTo:newRsrvStart] && [self isBefore:rsrvEnd CompareTo:newRsrvStart]){
                        [val addObject:compModel.reservationId];
                        [idMap setObject:val forKey:resModel.reservationId];
                        [idMap setObject:val forKey:compModel.reservationId];
                    }
                    
                }
            }

            for(ReservationModel *resModel in dayArray){
                if(resModel.reservedByUser.intValue != [self.utils getLoggedinUser].userId.intValue){
                    continue;
                }
                NSDate *dte =  [NSDate dateWithTimeIntervalSince1970:resModel.startDate.doubleValue/1000];
                int top=([hourFormatter stringFromDate:dte].intValue)*60;
                top = top +[minFormatter stringFromDate:dte].intValue;
                 NSMutableArray *val = [idMap objectForKey:resModel.reservationId];
                int start = -1;
                for(NSNumber *num in val){
                    start++;
                    if(num.intValue != resModel.reservationId.intValue){
                        break;
                    }
                }
                float meetingWidth = (hourWidth-4)/val.count;
                //UILabel *meeting= [[UILabel alloc] initWithFrame:CGRectMake(30+(start*meetingWidth)+5, top ,meetingWidth, resModel.duration.intValue)];
                UILabel *meeting= [[UILabel alloc] initWithFrame:CGRectMake(30+((start*meetingWidth)+day*hourWidth+2), top ,meetingWidth, resModel.duration.intValue)];
                NSString *resrvedBy = resModel.reservedByOrgName;
                if([resrvedBy.uppercaseString isEqualToString:@"INDIVIDUAL"] ){
                    resrvedBy = resModel.reservedByUserName;
                }
               meeting.text=resModel.reservationName;
               
                meeting.backgroundColor=[self.wnpConst getThemeHeaderColor];
                meeting.layer.borderColor = [self.wnpConst getThemeBaseColor].CGColor;
                meeting.layer.borderWidth = 1.0f;
                //meeting.clipsToBounds=true;
                
                UITapGestureRecognizer *showMeetingTap = [[UITapGestureRecognizer alloc] initWithTarget:self action: @selector(showMeetingPopup:)];
                showMeetingTap.numberOfTapsRequired = 1;
                showMeetingTap.numberOfTouchesRequired = 1;
                [meeting setUserInteractionEnabled:YES];
                [self.dayScrView setUserInteractionEnabled:YES];
                [meeting addGestureRecognizer:showMeetingTap];
                meeting.tag=resModel.reservationId.intValue;
                
                [self.dayScrView addSubview:meeting];
                [self.dayScrView bringSubviewToFront:meeting];
                 [self.view bringSubviewToFront:meeting];
                
            }
        }
        
        newDate = [gregorian dateByAddingComponents:dateComponents toDate:newDate options:0];
    }
    self.dayScrView.contentOffset = CGPointMake(0, 540);
    
}
-(void) loadMonthlyData:(NSDate *)selDate{

    for(UIView *subV in self.dayScrView.subviews){
        [subV removeFromSuperview];
    }
    for(UIView *subV in self.dayNameStrs.subviews){
        [subV removeFromSuperview];
    }
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat tableWidth = screenRect.size.width;
    
    self.dayNameStrs =[[UIScrollView alloc] initWithFrame:CGRectMake(0, 63 ,tableWidth, 30)];
    NSCalendar *gregorian = [NSCalendar currentCalendar];
    
    NSDateComponents *comp = [gregorian components: NSCalendarUnitYear | NSCalendarUnitMonth fromDate:selDate];
    [comp setDay:1];
    NSDate *firstDayOfMonthDate = [gregorian dateFromComponents:comp];
    comp = [gregorian components:NSCalendarUnitWeekday fromDate:firstDayOfMonthDate];
    int weekday = [comp weekday];
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    [dateComponents setDay:(-weekday+1)];

    // Retrieve date with increased days count
    NSDate *calStartDate = [gregorian dateByAddingComponents:dateComponents toDate:firstDayOfMonthDate options:0];

    
    
    
    NSMutableArray *daysInWeek = [[NSMutableArray alloc]init];
    [daysInWeek addObject:@"Sun"];
    [daysInWeek addObject:@"Mon"];
    [daysInWeek addObject:@"Tue"];
    [daysInWeek addObject:@"Wed"];
    [daysInWeek addObject:@"Thu"];
    [daysInWeek addObject:@"Fri"];
    [daysInWeek addObject:@"Sat"];
    
    for(int day = 0;day<7;day++){
        UILabel *dayDesc= [[UILabel alloc] initWithFrame:CGRectMake((day*(tableWidth/7)), 0 ,(tableWidth/7), 30)];
        [self.dayNameStrs addSubview:dayDesc];
        dayDesc.text=[daysInWeek objectAtIndex:day];
        UIFont *txtFont = [dayDesc.font fontWithSize:12.0];
        dayDesc.font = txtFont;
        
    }
    [self.view addSubview:self.dayNameStrs];
    
    self.dayDescription.backgroundColor = [self.wnpConst getThemeHeaderColor];
    self.dayDescription.text=[self.MMM_yyyyFormat stringFromDate:selDate];
    double cellHeight = (screenRect.size.height-158)/6;
    self.dayScrView =[[UIScrollView alloc] initWithFrame:CGRectMake(0, 93 ,tableWidth, screenRect.size.height-93)];
    /*self.dayScrView.contentSize = CGSizeMake(tableWidth, 1440);
    self.dayScrView.scrollEnabled=true;*/
    [self.view addSubview:self.dayScrView];
    NSDateFormatter *dayFormatter = [[NSDateFormatter alloc] init];
    [dayFormatter setDateFormat:@"d"];
    int dayInMonth =0;
    for(int week=0;week<6;week++){
        for(int day = 0;day<7;day++){
            UIScrollView *dayView = [[UIScrollView alloc] initWithFrame:CGRectMake((day*(tableWidth/7)), (week*cellHeight) ,(tableWidth/7), cellHeight)];
            dayView.layer.borderColor = [self.wnpConst getThemeBaseColor].CGColor;
            dayView.layer.borderWidth = 1.0f;
            [self.dayScrView addSubview:dayView];
            dayView.tag=dayInMonth;
            
            UITapGestureRecognizer *showMeetingTap = [[UITapGestureRecognizer alloc] initWithTarget:self action: @selector(showSelectedDayData:)];
            showMeetingTap.numberOfTapsRequired = 1;
            showMeetingTap.numberOfTouchesRequired = 1;
            [dayView setUserInteractionEnabled:YES];
            [dayView addGestureRecognizer:showMeetingTap];
            [self.dayScrView bringSubviewToFront:dayView];
            
            
            
            UILabel *dateDesc= [[UILabel alloc] initWithFrame:CGRectMake((day*(tableWidth/7)), (week*cellHeight) ,(tableWidth/7), 20)];
            dateDesc.textAlignment=NSTextAlignmentLeft;
            dateDesc.text=[dayFormatter stringFromDate:calStartDate];
            [self.dayScrView addSubview:dateDesc];
            NSString *dayStr = [self.mdyFormatter stringFromDate:calStartDate];
            NSMutableArray *dayArray = [self.dailySchedules objectForKey:dayStr];
           
            if( dayArray != (id)[NSNull null] && dayArray != nil){
                int index=0;
                dayView.contentSize = CGSizeMake((tableWidth/7), dayArray.count*20);
                dayView.scrollEnabled=true;
                for(ReservationModel *resModel in dayArray){
                    if(resModel.reservedByUser.intValue != [self.utils getLoggedinUser].userId.intValue){
                        continue;
                    }
                     NSLog(@"%d%s%@%s%@",day,"  ",dayStr,"  ",[dayFormatter stringFromDate:calStartDate]);
                   UILabel *meeting= [[UILabel alloc] initWithFrame:CGRectMake(2, 20+index*22 ,((tableWidth-20)/7)-4, 20)];
                    NSString *resrvedBy = resModel.reservedByOrgName;
                    if([resrvedBy.uppercaseString isEqualToString:@"INDIVIDUAL"] ){
                        resrvedBy = resModel.reservedByUserName;
                    }
                    meeting.text=resModel.reservationName;
                    
                    meeting.backgroundColor=[self.wnpConst getThemeHeaderColor];
                    meeting.layer.borderColor = [self.wnpConst getThemeBaseColor].CGColor;
                    meeting.layer.borderWidth = 1.0f;
                    meeting.clipsToBounds=true;
                    //dayView.clipsToBounds=true;
                    [dayView addSubview:meeting];
                    index++;
                    
                    UITapGestureRecognizer *viewTap = [[UITapGestureRecognizer alloc] initWithTarget:self action: @selector(hideKeyBord)];
                    viewTap.numberOfTapsRequired = 1;
                    viewTap.numberOfTouchesRequired = 1;
                    [self.popup setUserInteractionEnabled:YES];
                    [self.popup addGestureRecognizer:viewTap];
                    //[dayView bringSubviewToFront:meeting];
                }
            }
            [dateComponents setDay:1];
            calStartDate = [gregorian dateByAddingComponents:dateComponents toDate:calStartDate options:0];
            dayInMonth++;
        }
    }
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
    self.strpPopup=[[UIView alloc] initWithFrame:CGRectMake(centerX-135,centerY-95,270,190)];
    self.strpPopup.backgroundColor = [UIColor whiteColor];
    self.strpPopup.layer.borderColor = [self.wnpConst getThemeBaseColor].CGColor;
    self.strpPopup.layer.borderWidth = 1.0f;
    self.strpPopup.alpha=1.0;
    //  [self.view addSubview:self.popup];
    [[UIApplication sharedApplication].keyWindow addSubview:self.strpPopup];
    
    UILabel *headerLbl =[[UILabel alloc] initWithFrame:CGRectMake(0,0,270,35)];
    headerLbl.text=@"Stripe payment gateway";
    headerLbl.textAlignment=NSTextAlignmentCenter;
    UIFont *txtFont = [headerLbl.font fontWithSize:fontSize];
    headerLbl.font = txtFont;
    headerLbl.textColor=[UIColor whiteColor];
    headerLbl.backgroundColor=[self.wnpConst getThemeBaseColor];
    [self.strpPopup addSubview:headerLbl];
    
    self.popupError = [[UILabel alloc] initWithFrame:CGRectMake(10, 40 , 250, 30)];
    self.popupError.hidden=true;
    self.popupError.textColor=[UIColor redColor];
    [self.strpPopup addSubview: self.popupError];
    
    UILabel *descLabel =[[UILabel alloc] initWithFrame:CGRectMake(10,75,195,30)];
    descLabel.text=message;
    descLabel.textAlignment=NSTextAlignmentLeft;
    // UIFont *txtFont = [headerLbl.font fontWithSize:fontSize];
    descLabel.font = txtFont;
    descLabel.textColor=[UIColor blackColor];
    // headerLbl.backgroundColor=[self.wnpConst getThemeBaseColor];
    [self.strpPopup addSubview:descLabel];
    
    UILabel *amtLbl =[[UILabel alloc] initWithFrame:CGRectMake(210,75,50,30)];
    amtLbl.text=[NSString stringWithFormat:@"%s%@","$",[self.utils getNumberFormatter:payable]];
    amtLbl.textAlignment=NSTextAlignmentLeft;
    // UIFont *txtFont = [headerLbl.font fontWithSize:fontSize];
    amtLbl.font = txtFont;
    amtLbl.textColor=[UIColor blackColor];
    // headerLbl.backgroundColor=[self.wnpConst getThemeBaseColor];
    [self.strpPopup addSubview:amtLbl];
    
    
    self.payableAmount = [NSNumber numberWithDouble:payable] ;
    self.strpPymntTf = [[STPPaymentCardTextField alloc] initWithFrame:CGRectMake(10,110,250,30)];
    self.strpPymntTf.delegate=self;
    [self.strpPopup addSubview:self.strpPymntTf];
    
    self.popSubmitBtn = [[UIButton alloc] initWithFrame:CGRectMake(20,150,100,30)];
    self.strpSubmitBtn.backgroundColor=[UIColor grayColor];
    [self.strpSubmitBtn setTitle: @"Submit" forState: UIControlStateNormal];
    self.strpSubmitBtn.userInteractionEnabled=TRUE;
    self.strpSubmitBtn.enabled=FALSE;
    [self.strpSubmitBtn addTarget:self action:@selector(submitStripePayment:) forControlEvents: UIControlEventTouchUpInside];
    self.strpSubmitBtn.backgroundColor=[UIColor grayColor];
    
    [self.strpPopup addSubview:self.strpSubmitBtn];
    
    self.strpCancelBtn = [[UIButton alloc] initWithFrame:CGRectMake(150,150,100,30)];
    self.strpCancelBtn.backgroundColor=[self.wnpConst getThemeBaseColor];
    // self.strpCancelBtn.backgroundColor=[UIColor grayColor];
    
    self.strpCancelBtn.userInteractionEnabled=TRUE;
    self.strpCancelBtn.enabled=TRUE;
    [self.strpCancelBtn setTitle: @"Cancel" forState: UIControlStateNormal];
    [self.strpCancelBtn addTarget:self action:@selector(cancelStripePayment:) forControlEvents: UIControlEventTouchUpInside];
    [self.strpPopup addSubview:self.strpCancelBtn];
    
    UITapGestureRecognizer *viewTap = [[UITapGestureRecognizer alloc] initWithTarget:self action: @selector(hideKeyBord)];
    viewTap.numberOfTapsRequired = 1;
    viewTap.numberOfTouchesRequired = 1;
    [self.self.strpPopup setUserInteractionEnabled:YES];
    [self.self.strpPopup addGestureRecognizer:viewTap];
}

- (IBAction)cancelStripePayment:(id)sender {
    [self.strpPopup removeFromSuperview];
    for(UIView *subViews in self.view.subviews){
        subViews.alpha=1.0;
        subViews.userInteractionEnabled=TRUE;
    }
    [self startFade:self.nextImage];
    [self startFade:self.previousImage];
    self.view.alpha=1.0;
    self.view.userInteractionEnabled=TRUE;
}

-(void) showMeetingPopup:(UITapGestureRecognizer *) rec
{
    self.isShowMeeting =TRUE;
    self.isExpanded =false;
    int index = 0;
    for(ReservationModel *rsvModel in self.currSchedules){
        if(rsvModel.reservationId.intValue == rec.view.tag){
            self.selResrvationModel = rsvModel;
            break;
            
        }
        index++;
    }

    index = 0;
    for(NSMutableDictionary *dic in self.selSmartSpace.resourceList){
        ResourceModel *res = [[ResourceModel alloc]init];
        res = [res initWithDictionary:dic];
        if(res.resourceId.intValue == self.selResrvationModel.resourceId.intValue){
            self.selResource =res;
            break;
        }
         index++;
    }

    for(NSMutableDictionary *dic in self.orgList){
       OrganizationModel *org = [[OrganizationModel alloc]init];
       org = [org initWithDictionary:dic];
        if(org.orgId.intValue == self.selResrvationModel.reservedByOrg.intValue){
            self.selOrg =org;
            break;
        }
    }
    
    self.view.backgroundColor=[UIColor grayColor];
    for(UIView *subViews in [self.view subviews]){
        subViews.alpha=0.2;
        subViews.userInteractionEnabled=false;
    }
    float centerY = self.view.frame.size.height/2;
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat tableWidth = screenRect.size.width-40;

    self.view.userInteractionEnabled=false;
    NSDate *meetingEnds =[NSDate dateWithTimeIntervalSince1970:self.selResrvationModel.endTime.doubleValue/1000];
    NSString *localEndTime = [self.mdyhmFormatter stringFromDate:meetingEnds];
    meetingEnds = [self.mdyhmFormatter dateFromString:localEndTime];

    if([self isAfter:[NSDate date] CompareTo:meetingEnds]){
        if(self.orgList.count > 1){
            self.popup=[[UIView alloc] initWithFrame:CGRectMake(10,centerY-148,tableWidth+20,435)];
        }else{
            self.popup=[[UIView alloc] initWithFrame:CGRectMake(10,centerY-108,tableWidth+20,355)];
        }
    }else{
        if(self.orgList.count > 1){
            self.popup=[[UIView alloc] initWithFrame:CGRectMake(10,centerY-113,tableWidth+20,365)];
        }else{
            self.popup=[[UIView alloc] initWithFrame:CGRectMake(10,centerY-73,tableWidth+20,285)];
        }
        
    }
    self.popup.backgroundColor = [UIColor whiteColor];
    self.popup.layer.borderColor = [self.wnpConst getThemeBaseColor].CGColor;
    self.popup.layer.borderWidth = 1.0f;
    self.popup.alpha=1.0;
    //  [self.view addSubview:self.popup];
    [[UIApplication sharedApplication].keyWindow addSubview:self.popup];
    
    UILabel *headerLbl =[[UILabel alloc] initWithFrame:CGRectMake(0,0,tableWidth+20,35)];
    headerLbl.text=@"Edit/Delete Reservation";
    headerLbl.textAlignment=NSTextAlignmentCenter;
    //UIFont *txtFont = [headerLbl.font fontWithSize:fontSize];
   // headerLbl.font = txtFont;
    headerLbl.textColor=[UIColor whiteColor];
    headerLbl.backgroundColor=[self.wnpConst getThemeBaseColor];
    UIFont *txtFont = [headerLbl.font fontWithSize:17];
    headerLbl.font = txtFont;
    [self.popup addSubview:headerLbl];
    
    UIImageView *close = [[UIImageView alloc] initWithFrame:CGRectMake(tableWidth-15,0,35,35)];
    [close setImage:[UIImage imageNamed:@"close.png"]];
    
    
   
    [self.popup addSubview:close];
    //[self.popup bringSubviewToFront:close];
    
    self.popupError = [[UILabel alloc] initWithFrame:CGRectMake(10, 40 , tableWidth-20, 30)];
    self.popupError.hidden=true;
    self.popupError.textColor=[UIColor redColor];
    [self.popup addSubview: self.popupError];
    
    UILabel *smartSpace = [[UILabel alloc] initWithFrame:CGRectMake(5, 75 , (tableWidth*0.25), 30)];
    smartSpace.textAlignment = NSTextAlignmentLeft;
    smartSpace.text=@"Location";
    [self.popup addSubview: smartSpace];

    UILabel *smartSpaceVal = [[UILabel alloc] initWithFrame:CGRectMake((tableWidth*0.25)+10, 75 , (tableWidth*0.75), 30)];
    smartSpaceVal.textAlignment = NSTextAlignmentLeft;
    smartSpaceVal.text=self.selResrvationModel.smSpaceName;
    [self.popup addSubview: smartSpaceVal];
    
    UILabel *date = [[UILabel alloc] initWithFrame:CGRectMake(5, 115 , (tableWidth*0.25), 30)];
    date.textAlignment = NSTextAlignmentLeft;
    date.text=@"Date";
    [self.popup addSubview: date];
    
    self.datVal =[[UILabel alloc] initWithFrame:CGRectMake((tableWidth*0.25)+10, 115 , (tableWidth*0.75), 30)];
    self.datVal.textAlignment = NSTextAlignmentLeft;
    self.datVal.text=[self.mdyFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:self.selResrvationModel.startDate.doubleValue/1000]];
    [self.popup addSubview: self.datVal];
    
   UILabel *startTime = [[UILabel alloc] initWithFrame:CGRectMake(5, 155 , (tableWidth*0.25), 30)];
    startTime.textAlignment = NSTextAlignmentLeft;
    startTime.text=@"Time";
    [self.popup addSubview: startTime];
    
    self.startTimeVal =[[UILabel alloc] initWithFrame:CGRectMake((tableWidth*0.25)+10, 155 , (tableWidth*0.3), 30)];
    self.startTimeVal.textAlignment = NSTextAlignmentLeft;
    
    self.startTimeVal.text=[self.hmFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:self.selResrvationModel.startDate.doubleValue/1000]];
    [self.popup addSubview: self.startTimeVal];
    
    UILabel *endTime = [[UILabel alloc] initWithFrame:CGRectMake((tableWidth*0.55)+10, 155 , (tableWidth*0.15), 30)];
    endTime.textAlignment = NSTextAlignmentCenter;
    endTime.text=@"To";
    [self.popup addSubview: endTime];
    
    self.endTimeVal =[[UILabel alloc] initWithFrame:CGRectMake((tableWidth*0.7)+15, 155 , (tableWidth*0.3), 30)];
    self.endTimeVal.textAlignment = NSTextAlignmentCenter;
   // UIFont *endTimeValFont = [self.endTimeVal.font fontWithSize:16.0];
   // self.endTimeVal.font = endTimeValFont;
    
    //UIFont *startTimeValFont = [self.startTimeVal.font fontWithSize:16.0];
    //self.startTimeVal.font = startTimeValFont;
    self.endTimeVal.text=[self.hmFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:self.selResrvationModel.endTime.doubleValue/1000]];
    [self.popup addSubview: self.endTimeVal];
    

    self.duration = self.selResrvationModel .duration;
    NSString *datStr =[NSString stringWithFormat:@"%@%s%@",self.datVal.text," ",self.startTimeVal.text];
    self.selectedStartDate = [self.mdyhmFormatter dateFromString:datStr];
    self.selectedEndDate = [self.selectedStartDate dateByAddingTimeInterval:self.duration.intValue*60];
   
    
    
    UILabel *name = [[UILabel alloc] initWithFrame:CGRectMake(5, 195 , (tableWidth*0.25), 30)];
    name.textAlignment = NSTextAlignmentLeft;
    name.text=@"Name";
    [self.popup addSubview: name];
    
    self.meetingName =[[UITextField alloc] initWithFrame:CGRectMake((tableWidth*0.25)+10, 195 , (tableWidth*0.75), 30)];
    self.meetingName.textAlignment = NSTextAlignmentLeft;
    self.meetingName.text=self.selResrvationModel.reservationName;
    UIImage *blueBGImg = [UIImage imageNamed:@"edt_bg_grey.png"];
    
    self.meetingName.background = blueBGImg;
    [self.popup addSubview: self.meetingName];
    self.meetingName.delegate = self;
    UILabel *confRoom = [[UILabel alloc] initWithFrame:CGRectMake(5, 235 , (tableWidth*0.25), 30)];
    confRoom.textAlignment = NSTextAlignmentLeft;
    confRoom.text=@"Where";
    [self.popup addSubview: confRoom];
    
    self.confRoomName = [[UILabel alloc] initWithFrame:CGRectMake((tableWidth*0.25)+10, 235 , (tableWidth*0.75), 30)];
    self.confRoomName.textAlignment = NSTextAlignmentLeft;
    self.confRoomName.text=self.selResrvationModel.resourceName;
    [self.popup addSubview: self.confRoomName];
    
    self.confRoomVal =[[UITableView alloc] initWithFrame:CGRectMake((tableWidth*0.25)+10, 235 , (tableWidth*0.75), 70)];
    [self.popup addSubview: self.confRoomVal];
    self.confRoomVal.delegate=self;
    self.confRoomVal.dataSource=self;
    self.confRoomVal.layer.borderColor = [UIColor grayColor].CGColor;
    self.confRoomVal.layer.borderWidth = 1.0f;
    self.confRoomVal.hidden=true;
    self.confRoomName.hidden=false;
    int nextPos = 80;
    if(self.orgList.count > 1){
        UILabel *org = [[UILabel alloc] initWithFrame:CGRectMake(5, 315 , (tableWidth*0.25), 30)];
        org.textAlignment = NSTextAlignmentLeft;
        org.text=@"Organization";
        [self.popup addSubview: org];
        
        self.orgVal =[[UITableView alloc] initWithFrame:CGRectMake((tableWidth*0.25)+10, 315 , (tableWidth*0.75), 70)];
     self.orgVal.layer.borderColor = [UIColor grayColor].CGColor;
     self.orgVal.layer.borderWidth = 1.0f;
        self.orgVal.delegate=self;
        self.orgVal.dataSource=self;
        nextPos=160;
    }
    [self.popup addSubview: self.orgVal];

    self.popSubmitBtn = [[UIButton alloc] initWithFrame:CGRectMake(10,(235+nextPos),130,30)];
    self.popSubmitBtn.backgroundColor=[UIColor grayColor];
    [self.popSubmitBtn setTitle: @"Edit" forState: UIControlStateNormal];
    self.popSubmitBtn.userInteractionEnabled=TRUE;
    [self.popSubmitBtn addTarget:self action:@selector(editMeeting:) forControlEvents: UIControlEventTouchUpInside];
    self.popSubmitBtn.backgroundColor=[self.wnpConst getThemeBaseColor];
    
    [self.popup addSubview:self.popSubmitBtn];
    
    self.popCancelBtn = [[UIButton alloc] initWithFrame:CGRectMake(tableWidth-120,(235+nextPos),130,30)];
    self.popCancelBtn.backgroundColor=[self.wnpConst getThemeBaseColor];
    // self.strpCancelBtn.backgroundColor=[UIColor grayColor];
    
    self.popCancelBtn.userInteractionEnabled=TRUE;
    self.popCancelBtn.enabled=TRUE;
    [self.popCancelBtn setTitle: @"Delete" forState: UIControlStateNormal];
    [self.popCancelBtn addTarget:self action:@selector(showConfirmationPopup:) forControlEvents: UIControlEventTouchUpInside];
    [self.popup addSubview:self.popCancelBtn];
    
    
    if([self isAfter:[NSDate date] CompareTo:meetingEnds]){
        self.popCancelBtn.hidden=false;
        self.popSubmitBtn.hidden=false;
        self.popCancelBtn.userInteractionEnabled=TRUE;
        self.popSubmitBtn.userInteractionEnabled=TRUE;
        self.popCancelBtn.enabled=TRUE;
        self.popSubmitBtn.enabled=TRUE;
        headerLbl.text=@"Edit/Delete Reservation";
    }else{
        self.popCancelBtn.hidden=true;
        self.popSubmitBtn.hidden=true;
        self.popCancelBtn.userInteractionEnabled=false;
        self.popSubmitBtn.userInteractionEnabled=false;
        self.popCancelBtn.enabled=false;
        self.popSubmitBtn.enabled=false;
        headerLbl.text=@"Reservation details";
    }
    self.startTimeVal.layer.borderColor = [UIColor whiteColor].CGColor;
    self.startTimeVal.layer.borderWidth = 0.0f;
    self.startTimeVal.enabled =FALSE;
    
    self.datVal.enabled =FALSE;
    self.datVal.layer.borderColor = [UIColor whiteColor].CGColor;
    self.datVal.layer.borderWidth = 0.0f;
    
    self.endTimeVal.enabled =FALSE;
    self.endTimeVal.layer.borderColor = [UIColor whiteColor].CGColor;
    self.endTimeVal.layer.borderWidth = 0.0f;
    
    self.meetingName.enabled =FALSE;
    self.confRoomVal.userInteractionEnabled=FALSE;
    self.orgVal.userInteractionEnabled=FALSE;
    self.datVal.userInteractionEnabled=FALSE;
    self.startTimeVal.userInteractionEnabled=FALSE;
    self.endTimeVal.userInteractionEnabled=FALSE;
    
    UITapGestureRecognizer *dayTap = [[UITapGestureRecognizer alloc] initWithTarget:self action: @selector(changeDate:)];
    dayTap.numberOfTapsRequired = 1;
    dayTap.numberOfTouchesRequired = 1;
    //[self.datVal setUserInteractionEnabled:YES];
    [self.datVal addGestureRecognizer:dayTap];
    
    UITapGestureRecognizer *startTimeTap = [[UITapGestureRecognizer alloc] initWithTarget:self action: @selector(changeDate:)];
    startTimeTap.numberOfTapsRequired = 1;
    startTimeTap.numberOfTouchesRequired = 1;
    //[self.startTimeVal setUserInteractionEnabled:YES];
    [self.startTimeVal addGestureRecognizer:startTimeTap];
    
    UITapGestureRecognizer *endTimeTap = [[UITapGestureRecognizer alloc] initWithTarget:self action: @selector(changeDate:)];
    endTimeTap.numberOfTapsRequired = 1;
    endTimeTap.numberOfTouchesRequired = 1;
   // [self.endTimeVal setUserInteractionEnabled:YES];
    [self.endTimeVal addGestureRecognizer:endTimeTap];
    
    UITapGestureRecognizer *closeTap = [[UITapGestureRecognizer alloc] initWithTarget:self action: @selector(CloseMeetingPopup:)];
    closeTap.numberOfTapsRequired = 1;
    closeTap.numberOfTouchesRequired = 1;
    [close setUserInteractionEnabled:YES];
    [close addGestureRecognizer:closeTap];
}
-(void) CloseMeetingPopup:(UITapGestureRecognizer *) rec{
    self.view.backgroundColor=[UIColor whiteColor];
    for(UIView *subViews in [self.popup subviews]){
        [subViews removeFromSuperview];
    }
    
    for(UIView *subViews in [self.view subviews]){
        subViews.alpha=1.0;
        subViews.userInteractionEnabled=true;
    }
    self.view.alpha=1.0;
    [self startFade:self.nextImage];
    [self startFade:self.previousImage];
     self.view.userInteractionEnabled=TRUE;
    [self.popup removeFromSuperview];
}

-(void)cancelMeeting:(UITapGestureRecognizer *) rec{
    @try{
        NSString *status = [self.smSpaceDAO deleteReservation:self.selResrvationModel];
        if ([status isEqual:@"SUCCESS"]){
            
            [self showPopup:@"Successful" Message:@"Deleted successfully." AnotherPopup:NO];
           // [self CloseMeetingPopup:rec];
        }else{
            self.popupError.text= status;
            self.popupError.hidden=false;
        }
    }@catch (NSException *exception) {
        self.popupError.text= exception.description;
        self.popupError.hidden=false;
    }
}

-(void) showConfirmationPopup:(UITapGestureRecognizer *)rec
{
    if(self.isShowMeeting){
        NSDate *meetingEnds =[NSDate dateWithTimeIntervalSince1970:self.selResrvationModel.endTime.doubleValue/1000];
        NSString *localEndTime = [self.mdyhmFormatter stringFromDate:meetingEnds];
        meetingEnds = [self.mdyhmFormatter dateFromString:localEndTime];

        if([self isAfter:[NSDate date] CompareTo:meetingEnds]){
            NSString *title =@"Confirm";
            NSString *message =@"Do you wish to delete this reservation ?";
            self.popup.backgroundColor=[UIColor grayColor];
            for(UIView *subViews in [self.popup subviews]){
                subViews.alpha=0.2;
                subViews.userInteractionEnabled=false;
            }
            float centerX = self.popup.frame.size.width/2;
            float centerY = self.popup.frame.size.height/2;
            self.alertView = [[UIView alloc] initWithFrame:CGRectMake(centerX-150, centerY-90 , 300, 180)];
            self.alertView.backgroundColor = [UIColor whiteColor];
            self.alertView.layer.borderColor = [self.wnpConst getThemeBaseColor].CGColor;
            self.alertView.layer.borderWidth = 1.0f;
            [self.popup addSubview: self.alertView];
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
            
            UIButton *yesBtn = [[UIButton alloc] initWithFrame:CGRectMake( 55,140 , 70, 30)];
            yesBtn.backgroundColor=[self.wnpConst getThemeBaseColor];
            [yesBtn setTitle: @"Yes" forState: UIControlStateNormal];
            yesBtn.userInteractionEnabled=TRUE;
            yesBtn.enabled=TRUE;
            [yesBtn addTarget:self action:@selector(cancelMeeting:) forControlEvents: UIControlEventTouchUpInside];
            [self.alertView addSubview: yesBtn];
            
            UIButton *noBtn = [[UIButton alloc] initWithFrame:CGRectMake( 175,140 , 70, 30)];
            noBtn.backgroundColor=[self.wnpConst getThemeBaseColor];
            [noBtn setTitle: @"No" forState: UIControlStateNormal];
            noBtn.userInteractionEnabled=TRUE;
            noBtn.enabled=TRUE;
            [noBtn addTarget:self action:@selector(closePopup:) forControlEvents: UIControlEventTouchUpInside];
            [self.alertView addSubview: noBtn];
            [self.popup bringSubviewToFront:self.alertView];
            [self.alertView bringSubviewToFront:yesBtn];
            [self.alertView bringSubviewToFront:noBtn];
            self.alertView.userInteractionEnabled=true;
        }
       
    
    }else{
        self.isShowMeeting=TRUE;
        
        self.startTimeVal.layer.borderColor = [UIColor whiteColor].CGColor;
        self.startTimeVal.layer.borderWidth = 0.0f;
        self.startTimeVal.enabled =FALSE;
        
        self.datVal.enabled =FALSE;
        self.datVal.layer.borderColor = [UIColor whiteColor].CGColor;
        self.datVal.layer.borderWidth = 0.0f;
        
        self.endTimeVal.enabled =FALSE;
        self.endTimeVal.layer.borderColor = [UIColor whiteColor].CGColor;
        self.endTimeVal.layer.borderWidth = 0.0f;
        self.confRoomVal.hidden=true;
        self.confRoomName.hidden=false;
        self.confRoomVal.layer.borderColor = [UIColor grayColor].CGColor;
        self.confRoomVal.layer.borderWidth = 1.0f;
        
        self.orgVal.layer.borderColor = [UIColor grayColor].CGColor;
        self.orgVal.layer.borderWidth = 1.0f;
        
        self.meetingName.enabled =FALSE;
        self.confRoomVal.userInteractionEnabled=FALSE;
        self.orgVal.userInteractionEnabled=FALSE;
        self.datVal.userInteractionEnabled=FALSE;
        self.startTimeVal.userInteractionEnabled=FALSE;
        self.endTimeVal.userInteractionEnabled=FALSE;
        [self.popCancelBtn setTitle: @"Delete" forState: UIControlStateNormal];
        [self.popSubmitBtn setTitle: @"Edit" forState: UIControlStateNormal];
    }
}

- (IBAction)closePopup:(id)sender {
    self.popup.backgroundColor=[UIColor whiteColor];
    for(UIView *subViews in [self.popup subviews]){
        subViews.alpha=1.0;
        subViews.userInteractionEnabled=true;
    }
    [self.alertView removeFromSuperview];

}



-(void) showPopup:(NSString *) title Message:(NSString *) message AnotherPopup :(BOOL)closeThis
{
    self.view.backgroundColor=[UIColor grayColor];
    for(UIView *subViews in [self.popup subviews]){
        subViews.alpha=0.2;
        subViews.userInteractionEnabled=false;
    }
    float centerX = self.popup.frame.size.width/2;
    float centerY = self.popup.frame.size.height/2;
    self.alertView = [[UIView alloc] initWithFrame:CGRectMake(centerX-150, centerY-90 , 300, 180)];
    self.alertView.backgroundColor = [UIColor whiteColor];
    self.alertView.layer.borderColor = [self.wnpConst getThemeBaseColor].CGColor;
    self.alertView.layer.borderWidth = 1.0f;
    [self.popup addSubview: self.alertView];
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
- (IBAction)reloadData{
    [self viewDidLoad];
}
- (IBAction)loadMyReservations:(id)sender {
    self.view.backgroundColor=[UIColor whiteColor];
    for(UIView *subViews in [self.popup subviews]){
        [subViews removeFromSuperview];
    }
    
    for(UIView *subViews in [self.view subviews]){
        subViews.alpha=1.0;
        subViews.userInteractionEnabled=true;
    }
    self.view.alpha=1.0;
    
    self.view.userInteractionEnabled=TRUE;
    [self.popup removeFromSuperview];
    UIStoryboard *stryBrd = [UIStoryboard storyboardWithName:@"MenuController" bundle:nil];
    MenuController *viewCtrl=[stryBrd instantiateViewControllerWithIdentifier:@"MenuController"];
    if(viewCtrl != nil){
        viewCtrl.modalTransitionStyle=UIModalTransitionStyleFlipHorizontal;
        viewCtrl.viewName=@"MyConfBookings";
        viewCtrl.currSchedules=self.currSchedules;
        [self presentViewController:viewCtrl animated:YES completion:nil];
    }
}
-(BOOL) isAfter:(NSDate *) fisrtDate CompareTo:(NSDate *)secondDat{
    NSTimeInterval diff = [fisrtDate timeIntervalSinceDate:secondDat];
    if(diff <=0){
        return TRUE;
    }else{
        return FALSE;
    }
    
}

-(BOOL) isBefore:(NSDate *) fisrtDate CompareTo:(NSDate *)secondDat{
    NSTimeInterval diff = [fisrtDate timeIntervalSinceDate:secondDat];
    if(diff <=0){
        return FALSE;
    }else{
        return TRUE;
    }
    
}
-(void) editMeeting:(UITapGestureRecognizer *) rec{
    if(self.isShowMeeting){
        NSDateFormatter *mdyhmFormatter = [[NSDateFormatter alloc] init];
        [mdyhmFormatter setDateFormat:@"MM/dd/yyyy hh:mm a"];

        NSDate *meetingEnds =[NSDate dateWithTimeIntervalSince1970:self.selResrvationModel.endTime.doubleValue/1000];
        NSString *localStartTime = [mdyhmFormatter stringFromDate:meetingEnds];
                meetingEnds = [self.mdyhmFormatter dateFromString:localStartTime];
        NSDate *currDate = [NSDate date];
        NSString *localcurrDate = [mdyhmFormatter stringFromDate:currDate];
        currDate = [self.mdyhmFormatter dateFromString:localcurrDate];
        if([self isAfter:currDate CompareTo:meetingEnds]){
            self.isShowMeeting=FALSE;
            self.startTimeVal.layer.borderColor = [self.wnpConst getThemeBaseColor].CGColor;
            self.startTimeVal.layer.borderWidth = 1.0f;
            self.startTimeVal.enabled =TRUE;
            
            self.datVal.enabled =TRUE;
            self.datVal.layer.borderColor = [self.wnpConst getThemeBaseColor].CGColor;
            self.datVal.layer.borderWidth = 1.0f;
            
            self.endTimeVal.enabled =TRUE;
            self.endTimeVal.layer.borderColor = [self.wnpConst getThemeBaseColor].CGColor;
            self.endTimeVal.layer.borderWidth = 1.0f;
            
            self.confRoomVal.layer.borderColor = [self.wnpConst getThemeBaseColor].CGColor;
            self.confRoomVal.layer.borderWidth = 1.0f;
            
            self.orgVal.layer.borderColor = [self.wnpConst getThemeBaseColor].CGColor;
            self.orgVal.layer.borderWidth = 1.0f;
            self.confRoomVal.hidden=false;
            self.confRoomName.hidden=true;
            self.meetingName.enabled =TRUE;
            self.confRoomVal.userInteractionEnabled=true;
            self.orgVal.userInteractionEnabled=true;
            [self.popCancelBtn setTitle: @"Undo" forState: UIControlStateNormal];
            [self.popSubmitBtn setTitle: @"Save" forState: UIControlStateNormal];
            self.datVal.userInteractionEnabled=TRUE;
            self.startTimeVal.userInteractionEnabled=TRUE;
            self.endTimeVal.userInteractionEnabled=TRUE;
        }
        
        
    }else{
        [self updateReservation:rec];
    }
    
}
-(void) updateReservation:(UITapGestureRecognizer *)rec{
    NSString *datStr =[NSString stringWithFormat:@"%@%s%@",self.datVal.text," ",self.startTimeVal.text];
    NSDate *strtTm = [self.mdyhmFormatter dateFromString:datStr];
    NSDate *endTm = [strtTm dateByAddingTimeInterval:self.duration.intValue*60];
    NSMutableArray *dailyArray = [self.dailySchedules objectForKey:[self.mdyFormatter stringFromDate:strtTm]];
    BOOL isAvl =true;
    if(dailyArray != (id)[NSNull null] && dailyArray != nil){
        for(ReservationModel *resrvModel in dailyArray){
            if(self.selResource.resourceId.intValue != resrvModel.resourceId.intValue){
                continue;
            }
            if(self.selResrvationModel.reservationId == resrvModel.reservationId){
                continue;
            }
            NSDate *rsrvStart =[NSDate dateWithTimeIntervalSince1970:resrvModel.startDate.doubleValue/1000];
            NSDate *rsrvEnd =[rsrvStart dateByAddingTimeInterval:resrvModel.duration.intValue*60];
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
        [self showPopup:@"Error" Message:@"This slot is not available" AnotherPopup:YES];
        
    }else {
        self.selResrvationModel.reservedByOrg = self.selOrg.orgId;
        self.selResrvationModel.reservedByOrgName=self.selOrg.orgName;
        self.selResrvationModel.startDate=[self.ymdhmFormatter stringFromDate:strtTm];
        self.selResrvationModel.endTime=[self.ymdhmFormatter stringFromDate:endTm];
        self.selResrvationModel.duration =self.duration;
        self.selResrvationModel.resourceId=self.selResource.resourceId;
        self.selResrvationModel.resourceName=self.selResource.resourceName;
        self.selResrvationModel.reservationName=self.meetingName.text;
        @try{

            NSDictionary *result= [self.smSpaceDAO updateReservation:self.selResrvationModel CardToken:nil TrialPeriod:[NSNumber numberWithDouble:0] AmountPaid:[NSNumber numberWithDouble:0]GateWay:@"STRIPE" Agreed:false];
            
            NSString *statusStr = [result objectForKey:@"STATUS"]    ;
            NSLog(@"%@",statusStr);
            if(statusStr != nil && [statusStr isEqual:@"SUCCESS"]){
                
                NSNumber* makePayment = [result objectForKey:@"makePayment"];
                if ([makePayment boolValue] == YES){
                    self.jSonResult = result;
                    NSString *paymentDesc = [result objectForKey:@"paymentDescription"];
                    NSNumber* newPayment = [result objectForKey:@"newPayment"];
                    NSNumber *payableAmount = [self.jSonResult objectForKey:@"payableAmount"];
                    if ([newPayment boolValue] == YES){
                        NSNumber* haveAccount = [result objectForKey:@"haveAccount"];
                        if ([newPayment boolValue] == YES){
                            [self showUpdatePopup: @"Payment" Message:paymentDesc  CloseThis:NO];
                        }else{
                            [self showStripePopup:payableAmount.doubleValue Message:paymentDesc];
                        }
                        
                    }else{
                       [self showUpdatePopup: @"Payment" Message:paymentDesc  CloseThis:NO];
                    }
                    
                }else{
                      [self showPopup:@"Successful" Message:@"Updated successfully."  AnotherPopup:NO];
                }
                
            }else{
                NSLog(@"%@",[result objectForKey:@"ERRORMESSAGE"] );
                NSException *e = [NSException exceptionWithName:@"UserException" reason:[result objectForKey:@"ERRORMESSAGE"] userInfo:nil];
                @throw e;
            }
            
        }@catch(NSException *exp){
            self.popupError.text= exp.description;
            self.popupError.hidden=false;
        }
        
        
        
        
      }
}
- (void)changeDate:(UITapGestureRecognizer *) rec{
    
    float centerX = self.popup.frame.size.width/2;
    float centerY = self.popup.frame.size.height/2;
    float scrWidth = self.popup.frame.size.width;
    self.datepickerView = [[UIView alloc] initWithFrame:CGRectMake(centerX-(scrWidth/2) ,centerY-125, scrWidth, 250)];
    self.datepicker=[[UIDatePicker alloc] initWithFrame:CGRectMake(5, 5, scrWidth,200)];
    self.datepicker.backgroundColor=[UIColor whiteColor];
    self.datepicker.hidden = NO;
    
    if(rec.view == self.startTimeVal){
        self.datepicker.date =[self.hmFormatter dateFromString:self.startTimeVal.text];
        self.datepicker.datePickerMode = UIDatePickerModeTime;
        self.selectedTimeLabel = self.startTimeVal;
    }else if(rec.view == self.endTimeVal){
        self.datepicker.date =[self.hmFormatter dateFromString:self.endTimeVal.text];
        self.datepicker.datePickerMode = UIDatePickerModeTime;
        self.selectedTimeLabel = self.endTimeVal;
    }else if(rec.view == self.datVal){
        self.datepicker.date =[self.mdyFormatter dateFromString:self.datVal.text];
        self.datepicker.datePickerMode = UIDatePickerModeDate;
        self.selectedTimeLabel = self.datVal;
    }
    self.popup.backgroundColor=[UIColor grayColor];
    for(UIView *subViews in [self.popup subviews]){
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
    [self.popup addSubview:self.datepickerView];
    //[self.popup bringSubviewToFront:self.datepickerView];
    
}

- (void)LabelChange:(id)sender{
    self.popup.backgroundColor=[UIColor whiteColor];
    for(UIView *subViews in [self.popup subviews]){
        subViews.alpha=1.0;
        subViews.userInteractionEnabled=true;
    }
    NSString *dat=nil;
    NSDate *selDate = nil;
    if(self.selectedTimeLabel == self.startTimeVal){
        dat =[NSString stringWithFormat:@"%@%s%@",self.datVal.text," ",[self.hmFormatter stringFromDate:self.datepicker.date]];
        selDate = [self.mdyhmFormatter dateFromString:dat];
    }else if(self.selectedTimeLabel == self.endTimeVal){
        dat =[NSString stringWithFormat:@"%@%s%@",self.datVal.text," ",[self.hmFormatter stringFromDate:self.datepicker.date]];
        selDate = [self.mdyhmFormatter dateFromString:dat];
    }else if(self.selectedTimeLabel== self.datVal){
        selDate = self.datepicker.date;
        if([[self.mdyFormatter stringFromDate:self.datepicker.date] isEqualToString:[self.mdyFormatter stringFromDate:[NSDate date]]]){
            selDate =[[NSDate date] dateByAddingTimeInterval:300];
        }else{
            NSString *datStr =[NSString stringWithFormat:@"%@%s%s",[self.mdyFormatter stringFromDate:self.datepicker.date]," ","09:00 am"];
            selDate = [self.mdyhmFormatter dateFromString:datStr];
        }
    }
    
    if([self.utils isBefore:selDate CompareTo:[NSDate date]]){
        [self showPopup:@"Error" Message:@"Past Date/time not allowed" AnotherPopup:YES];
        
    }else
    if(self.selectedTimeLabel == self.startTimeVal){
        self.startTimeVal.text=[self.hmFormatter stringFromDate:self.datepicker.date];
        self.duration = [NSNumber numberWithInt:30];
        self.selectedStartDate=self.datepicker.date;
        self.selectedEndDate = [self.selectedStartDate dateByAddingTimeInterval:1800];
        self.endTimeVal.text= [self.hmFormatter stringFromDate:self.selectedEndDate];

        
    }else if(self.selectedTimeLabel == self.endTimeVal){
        NSTimeInterval distanceBetweenDates = [self.datepicker.date timeIntervalSinceDate:self.selectedStartDate];
        
        if (distanceBetweenDates <= 0){
             [self showPopup:@"Error" Message:@"End time should be after start time" AnotherPopup:YES];
            
        }else{
            self.selectedEndDate = self.datepicker.date;
            self.endTimeVal.text=[self.hmFormatter stringFromDate:self.datepicker.date];
            self.duration = [NSNumber numberWithInt:(distanceBetweenDates/60)];
        }
        
    }else if(self.selectedTimeLabel== self.datVal){
        self.duration = [NSNumber numberWithInt:30];
        self.selectedStartDate=self.datepicker.date;
        self.startTimeVal.text= [self.hmFormatter stringFromDate:self.selectedStartDate];
        self.selectedEndDate = [self.selectedStartDate dateByAddingTimeInterval:1800];
        self.endTimeVal.text= [self.hmFormatter stringFromDate:self.selectedEndDate];
        self.datVal.text=[self.mdyFormatter stringFromDate:self.selectedStartDate];

    }
    [self.datepickerView removeFromSuperview];
    [self.datepicker removeFromSuperview];
}
- (void)LabelChangeCancel:(id)sender{
    self.popup.backgroundColor=[UIColor whiteColor];
    for(UIView *subViews in [self.popup subviews]){
        subViews.alpha=1.0;
        subViews.userInteractionEnabled=true;
    }
    
    [self.datepicker removeFromSuperview];
    [self.datepickerView removeFromSuperview];
    
}

-(void) hideKeyBord{
    [self.strpPymntTf resignFirstResponder];
    [self.view endEditing:YES];
}
- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(tableView == self.orgVal){
        return self.orgList.count;
    }else{
        return  self.selSmartSpace.resourceList.count;
    }
    
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
     if(tableView == self.orgVal){
         UITapGestureRecognizer *codeSel=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(setSelectedOrg:)];
         [codeSel setNumberOfTapsRequired:1];
         [code addGestureRecognizer:codeSel];
        
             OrganizationModel *orgModel = [[OrganizationModel alloc]init];
             orgModel = [orgModel initWithDictionary:[self.orgList objectAtIndex:indexPath.item]];
             code.text=[NSString stringWithFormat:@"%s%@", "  ", orgModel.orgName];
             code.tag = orgModel.orgId.intValue;
             if(self.selOrg.orgId.intValue == orgModel.orgId.intValue){
                 code.backgroundColor=[UIColor grayColor];
                  self.previousOrgRow=code;
             }else{
                 code.backgroundColor=[UIColor whiteColor];
             }
         
     }else{
         
         UITapGestureRecognizer *codeSel=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(setSelectedResource:)];
         [codeSel setNumberOfTapsRequired:1];
         [code addGestureRecognizer:codeSel];
         ResourceModel *resModel =[[ResourceModel alloc]init];
         resModel =[resModel initWithDictionary:[self.selSmartSpace.resourceList objectAtIndex:indexPath.item]];
         code.tag = resModel.resourceId.intValue;
         code.text=[NSString stringWithFormat:@"%s%@", "  ", resModel.resourceName];
        
         if(self.selResource.resourceId.intValue == resModel.resourceId.intValue){
             [self.confRoomVal scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
             code.backgroundColor=[UIColor grayColor];
              self.previousRow=code;
         }else{
             code.backgroundColor=[UIColor whiteColor];
         }
 
     }
    [cell addSubview:code];
   // [cell bringSubviewToFront:code];
    
    
    UIView *seperator = [[UIView alloc] initWithFrame:CGRectMake(0, 31 , tableWidth, 1)];
    [cell addSubview:seperator];
    self.confRoomVal.rowHeight=32;
    return cell;
}
-(void) setSelectedOrg:(UITapGestureRecognizer *) rec{
    UILabel *btn = (UILabel *)rec.view;
    int tag = btn.tag;
    for(NSMutableDictionary *dic in self.orgList){
        OrganizationModel *orgModel = [[OrganizationModel alloc]init];
        orgModel = [orgModel initWithDictionary:dic];
        if(orgModel.orgId.intValue==tag){
            self.selOrg = orgModel;
            break;
        }
    }
    rec.view.backgroundColor=SelectedCellBGColor;
    if(self.previousOrgRow !=nil){
        self.previousOrgRow.backgroundColor=NotSelectedCellBGColor;
    }
    self.previousOrgRow=rec.view;
    
}

-(void) setSelectedResource:(UITapGestureRecognizer *) rec{
    UILabel *btn = (UILabel *)rec.view;
    int tag = btn.tag;
    for(NSMutableDictionary *dic in self.selSmartSpace.resourceList){
        ResourceModel *resModel = [[ResourceModel alloc]init];
        resModel = [resModel initWithDictionary:dic];
        if(resModel.resourceId.intValue==tag){
            self.selResource = resModel;
            break;
        }
    }
    rec.view.backgroundColor=SelectedCellBGColor;
    if(self.previousRow !=nil){
        self.previousRow.backgroundColor=NotSelectedCellBGColor;
    }
    self.previousRow=rec.view;
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
- (IBAction)submitStripePayment:(id)sender {
    self.popupError.text= @"";
    self.popupError.hidden=true;
    self.strpSubmitBtn.backgroundColor=[UIColor grayColor];
    self.strpSubmitBtn.userInteractionEnabled=FALSE;
    self.strpSubmitBtn.enabled=FALSE;
    
    self.strpCancelBtn.backgroundColor=[UIColor grayColor];
    self.strpCancelBtn.userInteractionEnabled=FALSE;
    self.strpCancelBtn.enabled=FALSE;
    if(self.adminAcct.strpPubKey == (id)[NSNull null] || self.adminAcct.strpPubKey == nil){
        self.popupError.text= @"Invalid Stripe  account";
        self.popupError.hidden=false;
        return;
    }

    NSString *publicKey=[self.utils decode:self.adminAcct.strpPubKey];
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
                @try {
                    NSNumber *payableAmount = [self.jSonResult objectForKey:@"payableAmount"];
                    NSDictionary *i =[self.jSonResult objectForKey:@"ReservationModel"];
                    ReservationModel *resModel = [[ReservationModel alloc]init];
                    resModel = [resModel initWithDictionary:i];
                    NSDate *startDate = [NSDate date];
                    NSNumber *plnStart = [NSNumber numberWithLong:[startDate timeIntervalSince1970]];
                    NSDate *plnEndDate  = [NSDate dateWithTimeIntervalSince1970:resModel.startDate.doubleValue/1000];
                    NSNumber *plnEnd = [NSNumber numberWithLong:[plnEndDate timeIntervalSince1970]];
                    long duaration = (plnEnd.longValue - plnStart.longValue)/(1000*60*60*24);
                    
                    NSDictionary *result= [self.smSpaceDAO updateReservation:resModel CardToken:nil TrialPeriod:[NSNumber numberWithLong:duaration] AmountPaid:payableAmount GateWay:@"STRIPE" Agreed:true];
                    
                    NSString *statusStr = [result objectForKey:@"STATUS"]    ;
                    NSLog(@"%@",statusStr);
                    if(statusStr != nil && [statusStr isEqual:@"SUCCESS"]){
                        [self showPopup:@"Successful" Message:@"Updated successfully."  AnotherPopup:NO];
                    }else{
                        self.popupError.text= [result objectForKey:@"ERRORMESSAGE"];
                        self.popupError.hidden=false;
                        self.strpCancelBtn.backgroundColor=[self.wnpConst getThemeBaseColor];
                        // self.strpCancelBtn.backgroundColor=[UIColor grayColor];
                        
                        self.strpCancelBtn.userInteractionEnabled=TRUE;
                        self.strpCancelBtn.enabled=TRUE;
                        
                        self.strpCancelBtn.userInteractionEnabled=TRUE;
                        self.strpCancelBtn.enabled=TRUE;
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

-(void)showSelectedDayData:(UITapGestureRecognizer *) rec{
    int tag =rec.view.tag;
    NSDate *selDate = [self.mdyFormatter dateFromString:[self.daysInMonthArray objectAtIndex:tag]];
    [self setSelectedDat:@"Day" SelectedDate:selDate];
}
-(void) showUpdatePopup:(NSString *) title Message:(NSString *) message CloseThis :(BOOL)closeThis
{
    
    self.view.backgroundColor=[UIColor grayColor];
    for(UIView *subViews in [self.view subviews]){
        subViews.alpha=0.2;
        subViews.userInteractionEnabled=false;
    }
    float centerX = self.popup.frame.size.width/2;
    float centerY = self.popup.frame.size.height/2;
    self.alertView = [[UIView alloc] initWithFrame:CGRectMake(centerX-150, centerY-90 , 300, 180)];
    self.alertView.backgroundColor = [UIColor whiteColor];
    self.alertView.layer.borderColor = [self.wnpConst getThemeBaseColor].CGColor;
    self.alertView.layer.borderWidth = 1.0f;
    [self.popup addSubview: self.alertView];
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
    [cancelButton addTarget:self action:@selector(closePopup:) forControlEvents: UIControlEventTouchUpInside];
    
    
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

        NSDictionary *result= [self.smSpaceDAO updateReservation:resModel CardToken:nil TrialPeriod:[NSNumber numberWithLong:duaration] AmountPaid:payableAmount GateWay:@"STRIPE" Agreed:true];
        NSString *statusStr = [result objectForKey:@"STATUS"]    ;
        NSLog(@"%@",statusStr);
        if(statusStr != nil && [statusStr isEqual:@"SUCCESS"]){
            [self showPopup:@"Successful" Message:@"Updated successfully."  AnotherPopup:NO];
        }else{
            [self showPopup:@"Failed" Message:[result objectForKey:@"ERRORMESSAGE"] AnotherPopup:YES];
        }
        
    }@catch(NSException *exp){
        [self showPopup:@"Failed" Message:exp.description AnotherPopup:YES];
    }
}

@end
