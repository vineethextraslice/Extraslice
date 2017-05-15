//
//  OrganizationModel.m
//  extraSlice
//
//  Created by Administrator on 21/06/16.
//  Copyright © 2016 Extraslice Inc. All rights reserved.
//

#import "OrganizationModel.h"
#import "objc/runtime.h"
@implementation OrganizationModel
- (instancetype)init
{
    self = [super init];
    if (self) {
        
        self.orgName = @"";
        self.keyWords =  @"";
        self.contactEmail =  @"";
        self.contactNo =  @"";
        self.address =  @"";
        self.orgRoleId =  @-1;
        self.approved = FALSE;
        self.individualRefOrg = FALSE;
        self.orgId =  @-1;
    }
    return self;
}

- (NSDictionary *) dictionaryWithPropertiesOfObject:(id)obj
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    unsigned count;
    objc_property_t *properties = class_copyPropertyList([obj class], &count);
    
    for (int i = 0; i < count; i++) {
        NSString *key = [NSString stringWithUTF8String:property_getName(properties[i])];
        [dict setObject:[obj valueForKey:key] forKey:key];
    }
    
    free(properties);
    
    return [NSDictionary dictionaryWithDictionary:dict];
}
-(NSData *) convertObjectToJsonData:(BOOL) prettyPrint{
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:([self dictionaryWithPropertiesOfObject:self])
                                                       options:(NSJSONWritingOptions)    (prettyPrint ? NSJSONWritingPrettyPrinted : 0)
                                                         error:&error];
    
    if (! jsonData) {
        NSLog(@"bv_jsonStringWithPrettyPrint: error: %@", error.localizedDescription);
        return nil;
    } else {
        return jsonData;
    }
    
}
-(NSString*) convertObjectToJsonString:(BOOL) prettyPrint {
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:([self dictionaryWithPropertiesOfObject:self])
                                                       options:(NSJSONWritingOptions)    (prettyPrint ? NSJSONWritingPrettyPrinted : 0)
                                                         error:&error];
    
    if (! jsonData) {
        NSLog(@"bv_jsonStringWithPrettyPrint: error: %@", error.localizedDescription);
        return nil;
    } else {
        return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
}
- (OrganizationModel *)initWithDictionary:(NSDictionary*)dictionary {
    if (self = [super init]) {
        NSArray*keys=[dictionary allKeys];
        for (NSString* key in keys) {
            NSString *setterStr = [NSString stringWithFormat:@"set%@%@:",
                                   [[key substringToIndex:1] capitalizedString],
                                   [key substringFromIndex:1]];
            
            if ([self respondsToSelector:NSSelectorFromString(setterStr)]) {
                NSObject *valueString = [dictionary objectForKey:key];
                [self setValue:valueString forKey:key];
            }
            
        }
    }
    return self;
}
@end
