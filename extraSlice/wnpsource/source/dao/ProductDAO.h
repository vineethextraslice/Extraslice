//
//  ProductDAO.h
//  WalkNPay
//
//  Created by Administrator on 17/12/15.
//  Copyright © 2015 Extraslice. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ProductModel.h"

@interface ProductDAO : NSObject

-(ProductModel *) getProductForStoreByCode:(NSString *)code StoreId:(NSNumber *)storeId StatusFilter:(NSString *) statusFilter;

@end
