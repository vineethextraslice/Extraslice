//
//  Utilities.m
//  WalkNPay
//
//  Created by Irshad on 12/3/15.
//  Copyright © 2015 extraslice. All rights reserved.
//

#import "Utilities.h"
#import "NSString+AESCrypt.h"
#define kOFFSET_FOR_KEYBOARD 500
@implementation Utilities
-(void) showErrorMessage:(UIView *) view contView: (UILabel *) label errorLabel:(NSString *) errorText{
    label.text=errorText;
    label.center=view.center;
    [label sizeToFit];
    [view sizeToFit];
    view.hidden=FALSE;
    label.textColor=[UIColor redColor];
}
-(BOOL) isAfter:(NSDate *) fisrtDate CompareTo:(NSDate *)secondDat{
    NSTimeInterval diff = [fisrtDate timeIntervalSinceDate:secondDat];
    if(diff <0){
        return FALSE;
    }else{
        return TRUE;
    }
    
}
-(BOOL) isBefore:(NSDate *) fisrtDate CompareTo:(NSDate *)secondDat{
    NSTimeInterval diff = [secondDat timeIntervalSinceDate:fisrtDate];
    if(diff <0){
        return FALSE;
    }else{
        return TRUE;
    }

}
-(UserModel *) getLoggedinUser{
    return loggedinUser;
}
-(void) setLoggedinUser :(UserModel *)userModel{
    loggedinUser = userModel;
}
-(void) loadViewControlleWithAnimation :(UIViewController *)currController NextController:(UIViewController *)viewController{
    CATransition *animation = [CATransition animation];
    animation.type = kCATransitionFromLeft;
    animation.duration = 0.5;
    if(viewController != nil){
        viewController.modalTransitionStyle=UIModalTransitionStyleFlipHorizontal;
        [currController presentViewController:viewController animated:YES completion:nil];
    }
}
-(NSString *) getNumberFormatter :(double )numberToformat{
    self.formatter= [[NSNumberFormatter alloc] init];
    [self.formatter setPositiveFormat:@"0.##"];
    return [self.formatter stringFromNumber:[NSNumber numberWithDouble:numberToformat]];
}

-(void) hideErrorMessage:(UIView *) contView{
    contView.hidden=TRUE;
}

- (NSString *)changeDateFormat:(NSString *)inputDate {
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss.000";
    NSDate *yourDate = [dateFormatter dateFromString:inputDate];
    dateFormatter.dateFormat = @"MM-dd-yyyy HH:mm";
    return [dateFormatter stringFromDate:yourDate];
}

-(NSString *) encode:(NSString *) inputStr{
    NSString *theKey=@"SecKey@Slice4WnP";
    NSString *pwd =inputStr;
    NSData *utfString = [pwd dataUsingEncoding:NSASCIIStringEncoding];
    NSData *aesData = [utfString AES128EncryptWithKey: theKey];
    NSString *encodedStr =[aesData base64EncodedStringWithOptions:64];
    return encodedStr;
}

-(NSString *) decode:(NSString *) inputStr{
    NSString *theKey=@"SecKey@Slice4WnP";
    NSData *cipherData = [[NSData alloc] initWithBase64EncodedString:inputStr];
    NSString *decodedStr   = [[NSString alloc] initWithData:[cipherData AES128DecryptWithKey:theKey] encoding:NSUTF8StringEncoding];
    return decodedStr;
}
-(void) showTextOnKeyBoard:(UITextField *) seleTextView{
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat tableWidth = screenRect.size.width-8;
    self.keyboardDoneButtonView = [[UIToolbar alloc] init];
    [self.keyboardDoneButtonView sizeToFit];
    // UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStylePlain target:self action:@selector(doneClicked:)];
    //[keyboardDoneButtonView setItems:[NSArray arrayWithObjects:doneButton, nil]];
    self.showText=[[UILabel alloc] initWithFrame:CGRectMake(5, 2 , (tableWidth-50), 30)];
    self.showText.text =seleTextView.text;
    
    [self.currentSelectedTV addTarget:self action:@selector(editText:) forControlEvents: UIControlEventAllEditingEvents] ;
    self.showText.text=seleTextView.text;
    self.showText.textColor = [UIColor blueColor];
    [self.keyboardDoneButtonView addSubview:self.showText];
    self.currentSelectedTV.inputAccessoryView = self.keyboardDoneButtonView;
    
    
    
    UIButton *goBtn = [[UIButton alloc] initWithFrame:CGRectMake((tableWidth-50), 2 , 50, 25)];
    //goBtn.backgroundColor=[self.wnpCont getThemeBaseColor];
    goBtn.backgroundColor = [UIColor colorWithRed:26.0/255.0 green:143.0/255.0 blue:189.0/255.0 alpha:1.0];
    [goBtn setTitle: @"Done" forState: UIControlStateNormal];
    goBtn.userInteractionEnabled=TRUE;
    goBtn.enabled=TRUE;
    [goBtn addTarget:self action:@selector(endEditing:) forControlEvents: UIControlEventTouchUpInside];
    [self.keyboardDoneButtonView addSubview:goBtn];
}
-(void)endEditing:(UIGestureRecognizer *)recognizer{
    [self.keyboardDoneButtonView removeFromSuperview];
   [self.currentSelectedTV endEditing:YES];
}

-(void)editText:(UIGestureRecognizer *)recognizer{
    self.showText.text=self.currentSelectedTV.text;
}

-(void)setViewMovedUp:(BOOL)movedUp ParentView:(UIView *)parentView CurrTextView:(UITextField *) currTF{
    [UIView beginAnimations:nil context:NULL];
    CGRect rect = parentView.frame;
    float divisor = 222.0/568.0;
    float keyBoardHeight = divisor*rect.size.height;
    if (movedUp)
    {
        
        if((currTF.frame.origin.y+currTF.frame.size.height) > (rect.size.height - (keyBoardHeight))){
             rect.origin.y -= ((currTF.frame.origin.y+currTF.frame.size.height) -(rect.size.height - (keyBoardHeight+5)));
          // rect.size.height += ((currTF.frame.origin.y+currTF.frame.size.height) -kOFFSET_FOR_KEYBOARD);;
        }
    }
    else
    {
        if((currTF.frame.origin.y+currTF.frame.size.height) > (rect.size.height - keyBoardHeight)){
            rect.origin.y +=  ((currTF.frame.origin.y+currTF.frame.size.height) -(rect.size.height - (keyBoardHeight+5)));

       }
    }
    parentView.frame = rect;
    [UIView commitAnimations];
}

@end
