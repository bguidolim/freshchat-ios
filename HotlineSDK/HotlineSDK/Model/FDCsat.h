//
//  FDCsat.h
//  HotlineSDK
//
//  Created by user on 10/11/16.
//  Copyright © 2016 Freshdesk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "KonotorConversation.h"

typedef enum {
    CSAT_RATED = 0,
    CSAT_NOT_RATED,
    CSAT_SENT
} CSAT_STATUS;

NS_ASSUME_NONNULL_BEGIN

@interface FDCsat : NSManagedObject

@property (nullable, nonatomic, retain) NSNumber *csatID;
@property (nullable, nonatomic, retain) NSString *question;
@property (nullable, nonatomic, retain) NSNumber *status;
@property (nullable, nonatomic, retain) NSString *userComments;
@property (nullable, nonatomic, retain) NSNumber *userRatingCount;
@property (nullable, nonatomic, retain) NSNumber *isManadatory;
@property (nullable, nonatomic, retain) NSNumber *mobileUserCommentsAllowed;
@property (nullable, nonatomic, retain) KonotorConversation *belongsToConversation;


@end

NS_ASSUME_NONNULL_END
