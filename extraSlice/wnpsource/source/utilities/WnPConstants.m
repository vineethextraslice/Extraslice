//
//  Constants.m
//  WalkNPay
//
//  Created by Irshad on 11/24/15.
//  Copyright © 2015 extraslice. All rights reserved.
//

#import "WnPConstants.h"

@implementation WnPConstants

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
- (UIColor *)getThemeBaseColor{
    return baseColor ;
}
- (void) addItemToArray:(NSString *) item {
    if (purchasedProductsArray == nil) {
        purchasedProductsArray = [[NSMutableArray alloc] init];
    }
    [purchasedProductsArray addObject:item];
}

- (void) removeItemFromArray:(ProductModel *) item {
    if (purchasedProductsArray == nil) {
        purchasedProductsArray = [[NSMutableArray alloc] init];
    }
    [purchasedProductsArray removeObject:item];
}
- (void) clearItemsArray{
    purchasedProductsArray = nil;
    purchasedProductsArray=[[NSMutableArray alloc]init];
}

- (NSMutableArray *) getItemsFromArray {
    return purchasedProductsArray ;
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
    wnpFontSize=15;
    return wnpFontSize;
}
- (void) setFontSize:(int) size{
    wnpFontSize=size;
    
}
- (NSString *) getUrlStartsWith{
    return wnpUrlStartsWith;
}

- (WnPUserModel *) getUserModel{
    return wnpUserModel;
}
- (void) setUserModel:(WnPUserModel *) userModel{
    wnpUserModel=userModel;
}

- (NSString *) getCurrencyCode{
    return currencyCode;
}
- (NSString *) getCurrencySymbol{
    if(currencySymbol == nil){
            return @"$";
    }else{
        return currencySymbol;
    }
}

- (void ) setCurrencyCode:(NSString *) currCode{
    currencyCode=currCode;
}
- (void ) setCurrencySymbol:(NSString *) currSymb{
    if (currSymb == (id)[NSNull null] || currSymb==nil ||currSymb == 0 ){
        currencySymbol=@"$";
    }else if([currSymb isEqualToString:@"INR"]){
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

- (NSNumber *) getNumberOfStores{
    return numberOfStores;
}
- (void) setNumberOfStores:(NSNumber *) no{
    numberOfStores = no;
}
@end
