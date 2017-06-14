//
//  Constants.h
//  WalkNPay
//
//  Created by Irshad on 11/24/15.
//  Copyright © 2015 extraslice. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ProductModel.h"
#import "WnPUserModel.h"

static  NSMutableArray *purchasedProductsArray;
static NSNumber *loggedInUserId;
static NSString *loggedInUserName;
static NSNumber *selectedStoreId;
static NSString *currencyCode;
static NSString *currencySymbol;
static WnPUserModel *wnpUserModel;
static NSNumber *numberOfStores;
//testserver
//static NSString *wnpUrlStartsWith=@"http://walknpaydev01.cloudapp.net:8080/WalkNPayWebService/jsonws/";

//liveserver
static NSString *wnpUrlStartsWith=@"https://extraslice.com/WalkNPayWebService/jsonws/";
static int wnpFontSize=15;
static UIColor *baseColor;
static UIColor *headerColor;
static double userLat;
static double userLong;
@interface WnPConstants : NSObject

-(void )setColor:(int) colorIndex;
- (UIColor *)getThemeHeaderColor;
- (UIColor *)getThemeBaseColor;
- (void) addItemToArray:(ProductModel *) inputVal;
- (NSMutableArray *) getItemsFromArray;
- (void) removeItemFromArray:(ProductModel *) item;
- (NSNumber *) getUserId;
- (void) clearItemsArray;
- (void) setUserId:(NSNumber *) userId;
- (UIColor *)getThemeColorWithTransparency:(float) transparancy;
- (NSNumber *) getSelectedStoreId;
- (void) setSelectedStoreId:(NSNumber *) storeId;

- (int ) getFontSize;
- (void) setFontSize:(int) fontSize;

- (NSString *) getUserName;
- (void) setUserName:(NSString *) userName;
- (NSString *) getUrlStartsWith;

- (NSString *) getCurrencyCode;
- (NSString *) getCurrencySymbol;

- (NSNumber *) getNumberOfStores;
- (void) setNumberOfStores:(NSNumber *) no;



- (void ) setCurrencyCode:(NSString *) currCode;
- (void ) setCurrencySymbol:(NSString *) currSymb;



-(UIColor * )getColor:(int) colorIndex;

- (WnPUserModel *) getUserModel;
- (void) setUserModel:(WnPUserModel *) userModel;

- (double ) getUserLat;
- (double) getUserLong;
- (void) setUserLatLong:(double ) latitude Longitude:(double )longitude;

@end
