//
//  Constants.m
//  WalkNPay
//
//  Created by Irshad on 11/24/15.
//  Copyright © 2015 extraslice. All rights reserved.
//

#import "ESliceConstants.h"

@implementation ESliceConstants

-(void )setColor:(int) colorIndex{
    if(colorIndex==0){
        baseColor = [UIColor colorWithRed:38.0/255.0 green:140.0/255.0 blue:171.0/255.0 alpha:1.0];
        headerColor= [UIColor colorWithRed:230.0/255.0 green:230.0/255.0 blue:230.0/255.0 alpha:1.0];
        
    }else if(colorIndex==1){
        baseColor = [UIColor colorWithRed:38.0/255.0 green:140.0/255.0 blue:171.0/255.0 alpha:1.0];
        headerColor= [UIColor colorWithRed:230.0/255.0 green:230.0/255.0 blue:230.0/255.0 alpha:1.0];
    }else{
        baseColor = [UIColor colorWithRed:38.0/255.0 green:140.0/255.0 blue:171.0/255.0 alpha:1.0];
        headerColor= [UIColor colorWithRed:230.0/255.0 green:230.0/255.0 blue:230.0/255.0 alpha:1.0];
        
    }

}

-(UIColor * )getColor:(int) colorIndex{
    if(colorIndex==0){
        return [UIColor colorWithRed:38.0/255.0 green:140.0/255.0 blue:171.0/255.0 alpha:1.0];
    }else if(colorIndex==1){
        return  [UIColor colorWithRed:38.0/255.0 green:140.0/255.0 blue:171.0/255.0 alpha:1.0];
    }else{
        return [UIColor colorWithRed:38.0/255.0 green:140.0/255.0 blue:171.0/255.0 alpha:1.0];
    }
}
- (UIColor *)getThemeHeaderColor{
    return headerColor;
}
- (UIColor *)getThemeColorWithTransparency:(float) transparancy{
    return [UIColor colorWithRed:38.0/255.0 green:140.0/255.0 blue:171.0/255.0 alpha:transparancy];
}
- (UIColor *)getThemeBaseColor{
    return baseColor ;
}

- (NSNumber *) getUserId{
    return loggedInUserId;
}

- (void) setUserId:(NSNumber *) userId{
    loggedInUserId=userId;
}

- (NSString *) getUserName{
    return loggedInUserName;
}
- (void) setUserName:(NSString *) userName{
    loggedInUserName =userName;
}
- (NSNumber *) getSelectedStoreId{
    //selectedStoreId = [NSNumber numberWithInt:1];
    return selectedStoreId;
}
- (void) setSelectedStoreId:(NSNumber *) storeId{
    selectedStoreId = storeId;
}

- (int ) getFontSize{
    fontSize=15;
    return fontSize;
}
- (void) setFontSize:(int) size{
    fontSize=size;
    
}
- (NSString *) getUrlStartsWith{
    return urlStartsWith;
}

- (UserModel *) getUserModel{
    return loggedInUserModel;
}
- (void) setUserModel:(UserModel *) userModel{
    loggedInUserModel=userModel;
}

- (NSString *) getCurrencyCode{
    return currencyCode;
}
- (NSString *) getCurrencySymbol{
    if(currencySymbol == nil){
            return @"";
    }else{
        return currencySymbol;
    }
}

- (void ) setCurrencyCode:(NSString *) currCode{
    currencyCode=currCode;
}
- (void ) setCurrencySymbol:(NSString *) currSymb{
    if([currSymb isEqualToString:@"INR"]){
        currencySymbol=@"₹";
    }else{
        currencySymbol=currSymb;
    }
}

- (double ) getUserLat{
    return userLat;
}
- (double) getUserLong{
    return userLong;
}
- (void) setUserLatLong:(double ) latitude Longitude:(double )longitude{
    userLat=latitude;
    userLong=longitude;
}

@end
