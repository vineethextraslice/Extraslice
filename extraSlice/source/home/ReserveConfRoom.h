//
//  ReserveConfRoom.h
//  extraSlice
//
//  Created by Administrator on 27/06/16.
//  Copyright © 2016 Extraslice Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AdminAccountModel.h"
@class StripePaymentViewController;

@protocol StripePaymentViewControllerDelegate<NSObject>

- (void)stripePaymentViewController:(StripePaymentViewController *)controller didFinish:(NSError *)error;

@end
@interface ReserveConfRoom:UIViewController<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *orgTableBottom;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *orgTableHeight;
@property (weak, nonatomic) IBOutlet UITableView *orgTable;
@property (weak, nonatomic) IBOutlet UIView *smarspaceSpinner;
@property (weak, nonatomic) IBOutlet UIView *dayHeader;
@property (weak, nonatomic) IBOutlet UILabel *startDate;
@property (weak, nonatomic) IBOutlet UIScrollView *confRoomLyt;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *smSpaceLytHt;
@property (weak, nonatomic) IBOutlet UILabel *startTime;
@property (weak, nonatomic) IBOutlet UILabel *endTime;
@property (weak, nonatomic) IBOutlet UITextField *meetingName;
@property(strong,nonatomic) NSDate *selectedStartDate;
@property(strong,nonatomic) NSDate *selectedEndDate;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *orgTableTop;
- (IBAction)loadMyReservations:(id)sender;
@property(strong,nonatomic) AdminAccountModel *adminAcctModel;
@property(strong,nonatomic) NSDate *selectedDate;
@property(strong,nonatomic) NSString *selectedRoomType;
@property (weak, nonatomic) IBOutlet UILabel *roomTypeLbl;
@property (strong, nonatomic) IBOutlet UITableView *roomType;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *roomTypeHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *roomBottom;


@end
