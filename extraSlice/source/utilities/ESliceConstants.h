//
//  Constants.h
//  WalkNPay
//
//  Created by Irshad on 11/24/15.
//  Copyright © 2015 extraslice. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "UserModel.h"

static  NSMutableArray *purchasedProductsArray;
static NSNumber *loggedInUserId;
static NSString *loggedInUserName;
static NSNumber *selectedStoreId;
static NSString *currencyCode;
static NSString *currencySymbol;
static UserModel *loggedInUserModel;

//static NSString *urlStartsWith=@"https://extraslice.com/ExtraSliceWebService/jsonws/";
static NSString *urlStartsWith=@"http://walknpaydev01.cloudapp.net:8080/ExtraSliceWebService/jsonws/";
static int fontSize=15;
static UIColor *baseColor;
static UIColor *headerColor;
static double userLat;
static double userLong;
@interface ESliceConstants : NSObject

-(void )setColor:(int) colorIndex;
- (UIColor *)getThemeHeaderColor;
- (UIColor *)getThemeBaseColor;
- (NSNumber *) getUserId;
- (UIColor *)getThemeColorWithTransparency:(float) transparancy;
- (void) setUserId:(NSNumber *) userId;
- (UIColor *)getThemeColorWithLight;
- (NSNumber *) getSelectedStoreId;
- (void) setSelectedStoreId:(NSNumber *) storeId;

- (int ) getFontSize;
- (void) setFontSize:(int) fontSize;

- (NSString *) getUserName;
- (void) setUserName:(NSString *) userName;
- (NSString *) getUrlStartsWith;

- (NSString *) getCurrencyCode;
- (NSString *) getCurrencySymbol;

- (void ) setCurrencyCode:(NSString *) currCode;
- (void ) setCurrencySymbol:(NSString *) currSymb;



-(UIColor * )getColor:(int) colorIndex;

- (UserModel *) getUserModel;
- (void) setUserModel:(UserModel *) userModel;

- (double ) getUserLat;
- (double) getUserLong;
- (void) setUserLatLong:(double ) latitude Longitude:(double )longitude;

@end
