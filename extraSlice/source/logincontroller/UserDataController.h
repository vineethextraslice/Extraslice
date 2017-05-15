//
//  UserInfoController.h
//  extraSlice
//
//  Created by Administrator on 19/06/16.
//  Copyright © 2016 Extraslice Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PlanModel.h"
#import "AdminAccountModel.h"
#import "PlanOfferModel.h"

@class StripePaymentViewController;

@protocol StripePaymentViewControllerDelegate<NSObject>

- (void)stripePaymentViewController:(StripePaymentViewController *)controller didFinish:(NSError *)error;

@end
@interface UserDataController : UIViewController<UITextFieldDelegate>
@property(strong,nonatomic) NSMutableArray *planArray;
@property(strong,nonatomic) NSNumber *payableAmount;
@property(strong,nonatomic) NSMutableArray *selectedPlanArray;
@property(strong,nonatomic) NSMutableArray *orgList;
@property(strong,nonatomic) NSMutableArray *addonList;
@property(strong,nonatomic)  NSMutableSet *selectedAddonIds;
@property(strong,nonatomic)  NSMutableSet *selectedPlansResIds;
@property(strong,nonatomic) NSMutableDictionary *selectedPlnMap;
@property(strong,nonatomic) AdminAccountModel *adminAcctModel;
@property (nonatomic, weak) id<StripePaymentViewControllerDelegate> delegate;

@property (weak, nonatomic) IBOutlet UIView *goBackView;

@property (weak, nonatomic) IBOutlet UILabel *headerText;
@property (weak, nonatomic) IBOutlet UIImageView *selIndividual;
@property (weak, nonatomic) IBOutlet UIImageView *selOrg;
@property (weak, nonatomic) IBOutlet UILabel *paydescrText;
@property (weak, nonatomic) IBOutlet UILabel *errorText;
@property (weak, nonatomic) IBOutlet UIView *errorLyt;
@property (weak, nonatomic) IBOutlet UIImageView *goBack;
@property (weak, nonatomic) IBOutlet UITextField *noOfSeats;
@property (weak, nonatomic) IBOutlet UITextField *userName;
@property (weak, nonatomic) IBOutlet UIView *membershipType;
@property (weak, nonatomic) IBOutlet UITextField *email;
@property (weak, nonatomic) IBOutlet UITextField *contactNo;
@property (weak, nonatomic) IBOutlet UIView *tcView;
@property (weak, nonatomic) IBOutlet UITextField *password;
@property (weak, nonatomic) IBOutlet UITextField *confPassword;
@property (weak, nonatomic) IBOutlet UIImageView *tcChecbox;
@property (weak, nonatomic) IBOutlet UILabel *tcText;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nameHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *emailHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *passwordHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *confPwdHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *seatHieght;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *membTypeHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *errorHieght;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *phoneHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *payDescHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tcHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *errorTop;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *userTop;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *emailTop;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *phoneTop;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *passwordTop;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *confPwdTop;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *seatTop;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *membTypeTop;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tcTop;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *payDescTop;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *joinTop;
@property (weak, nonatomic) IBOutlet UIButton *joinNowBtn;


@property(strong,nonatomic) NSMutableArray *offerList;
@property(strong,nonatomic) PlanOfferModel *selectedOffer;


@property(strong,nonatomic) NSNumber *noOfdaystoSubsDate ;
@property(strong,nonatomic) NSNumber *trialEndsAt ;
@property(strong,nonatomic) NSNumber *firstsubDate;
@property(strong,nonatomic) NSNumber *noOFDaysInMoth ;
@property(strong,nonatomic) NSString *message;
@property(strong,nonatomic) NSNumber *noOfdaystoNextMonth;








- (IBAction)setSelected:(id)sender;
- (IBAction)setUnselected:(id)sender;
- (IBAction)registerThisUser:(id)sender;

@end
