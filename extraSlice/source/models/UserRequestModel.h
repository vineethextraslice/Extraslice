//
//  UserRequestModel.h
//  extraSlice
//
//  Created by Administrator on 21/06/16.
//  Copyright © 2016 Extraslice Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserRequestModel : NSObject
@property(strong, nonatomic) NSString *name;
@property(strong, nonatomic) NSString *email;
@property(strong, nonatomic) NSString *contactNo;
@property(strong, nonatomic) NSString *planName;
@property(strong, nonatomic) NSNumber *userId ;
@property(strong, nonatomic) NSNumber *noOfSeats ;

- (NSDictionary *) dictionaryWithPropertiesOfObject:(id)obj;
-(NSString*) convertObjectToJsonString:(BOOL) prettyPrint;
-(NSData *) convertObjectToJsonData:(BOOL) prettyPrint;
- (UserRequestModel *)initWithDictionary:(NSDictionary*)dictionary;
@end
