//
//  Utilities.h
//  WalkNPay
//
//  Created by Irshad on 12/3/15.
//  Copyright © 2015 extraslice. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface WnPUtilities : NSObject
-(void) showErrorMessage:(UIView *) view contView: (UILabel *) label errorLabel:(NSString *) errorText;

-(void) hideErrorMessage:(UIView *) contView;
- (NSString *)changeDateFormat:(NSString *)inputDate;
-(NSString *) encode:(NSString *) inputStr;
-(NSString *) decode:(NSString *) inputStr;
@property(strong,nonatomic) NSNumberFormatter *formatter;
-(NSString *) getNumberFormatter :(double )numberToformat;
@end
