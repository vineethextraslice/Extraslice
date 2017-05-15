//
//  Utilities.h
//  WalkNPay
//
//  Created by Irshad on 12/3/15.
//  Copyright © 2015 extraslice. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "UserModel.h"
static UserModel *loggedinUser;
@interface Utilities : NSObject
-(void) showErrorMessage:(UIView *) view contView: (UILabel *) label errorLabel:(NSString *) errorText;
-(void)setViewMovedUp:(BOOL)movedUp ParentView:(UIView *)parentView CurrTextView:(UITextField *) currTF;
-(void) hideErrorMessage:(UIView *) contView;
- (NSString *)changeDateFormat:(NSString *)inputDate;
-(NSString *) encode:(NSString *) inputStr;
-(NSString *) decode:(NSString *) inputStr;
-(void) showTextOnKeyBoard:(UITextField *) selectedView;
@property (strong, nonatomic) IBOutlet UILabel *showText;
@property (weak, nonatomic) IBOutlet UITextField *currentSelectedTV;
@property (strong, nonatomic) UIToolbar *keyboardDoneButtonView ;
@property(strong,nonatomic) NSNumberFormatter *formatter;
-(NSString *) getNumberFormatter :(double )numberToformat;
-(void) loadViewControlleWithAnimation :(UIViewController *)currController NextController:(UIViewController *)viewController;
-(void) setLoggedinUser :(UserModel * )userModel;
-(UserModel *) getLoggedinUser;
-(BOOL) isAfter:(NSDate *) fisrtDate CompareTo:(NSDate *)secondDat;
-(BOOL) isBefore:(NSDate *) fisrtDate CompareTo:(NSDate *)secondDat;
@end
