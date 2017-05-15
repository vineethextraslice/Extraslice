//
//  WebServiceDAO.h
//  WalkNPay
//
//  Created by Irshad on 11/27/15.
//  Copyright © 2015 extraslice. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WnPWebServiceDAO : NSObject

-(NSDictionary *)getDataFromWebService:(NSString *)urlString requestJson:(NSString *)requestString;

@end
