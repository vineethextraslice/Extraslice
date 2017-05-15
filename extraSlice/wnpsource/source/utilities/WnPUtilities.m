//
//  Utilities.m
//  WalkNPay
//
//  Created by Irshad on 12/3/15.
//  Copyright © 2015 extraslice. All rights reserved.
//

#import "WnPUtilities.h"
#import "NSString+AESCrypt.h"
@implementation WnPUtilities
-(void) showErrorMessage:(UIView *) view contView: (UILabel *) label errorLabel:(NSString *) errorText;{
    label.text=errorText;
    label.center=view.center;
    [label sizeToFit];
    [view sizeToFit];
    view.hidden=FALSE;
    label.textColor=[UIColor redColor];
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
-(NSString *) getNumberFormatter :(double )numberToformat{
    self.formatter= [[NSNumberFormatter alloc] init];
    [self.formatter setPositiveFormat:@"0.##"];
    return [self.formatter stringFromNumber:[NSNumber numberWithDouble:numberToformat]];
}
@end
