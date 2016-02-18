//
//  KonotorUser.m
//  HotlineSDK
//
//  Created by Aravinth Chandran on 15/02/16.
//  Copyright © 2016 Freshdesk. All rights reserved.
//

#import "KonotorUser.h"
#import "KonotorCustomProperty.h"
#import "KonotorDataManager.h"
#import "HLMacros.h"
#import "FDUtilities.h"

@implementation KonotorUser

@dynamic appSpecificIdentifier;
@dynamic email;
@dynamic isUserCreatedOnServer;
@dynamic name;
@dynamic phoneNumber;
@dynamic countryCode;
@dynamic userAlias;
@dynamic hasProperties;

+(KonotorUser *)createUserWithInfo:(HotlineUser *)userInfo{
    NSManagedObjectContext *context = [[KonotorDataManager sharedInstance]mainObjectContext];
    KonotorUser *user = [self getUser];
    
    if (!user) {
        user = [NSEntityDescription insertNewObjectForEntityForName:@"KonotorUser" inManagedObjectContext:context];
    }
    
    if (userInfo.userName && ![userInfo.userName isEqualToString:@""]) {
        user.name = userInfo.userName;
        [KonotorCustomProperty createNewPropertyForKey:@"name" WithValue:userInfo.userName isUserProperty:YES];
    }
    
    if (userInfo.emailAddress && [FDUtilities isValidEmail:userInfo.emailAddress]) {
        user.email = userInfo.emailAddress;
        [KonotorCustomProperty createNewPropertyForKey:@"email" WithValue:userInfo.emailAddress isUserProperty:YES];
    }else{
        NSString *exceptionName   = @"HOTLINE_SDK_INVALID_EMAIL_EXCEPTION";
        NSString *exceptionReason = @"You are attempting to set a null/invalid email address, Please provide a valid one";
        [[[NSException alloc]initWithName:exceptionName reason:exceptionReason userInfo:nil]raise];
    }
    
    if (userInfo.externalID && ![userInfo.externalID isEqualToString:@""]) {
        user.appSpecificIdentifier = userInfo.externalID;
        [KonotorCustomProperty createNewPropertyForKey:@"identifier" WithValue:userInfo.externalID isUserProperty:YES];
    }

    if (userInfo.phoneNumber && ![userInfo.phoneNumber isEqualToString:@""]) {
        user.phoneNumber = userInfo.phoneNumber;
        [KonotorCustomProperty createNewPropertyForKey:@"phone" WithValue:userInfo.phoneNumber isUserProperty:YES];
    }
    
    if (userInfo.countryCode && ![userInfo.countryCode isEqualToString:@""]) {
        user.countryCode = userInfo.countryCode;
        [KonotorCustomProperty createNewPropertyForKey:@"phoneCountry" WithValue:userInfo.countryCode isUserProperty:YES];
    }
    
    [[KonotorDataManager sharedInstance]save];
    return user;
}

+(KonotorUser *)getUser{
    KonotorUser *user = nil;
    NSManagedObjectContext *context = [[KonotorDataManager sharedInstance]mainObjectContext];
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"KonotorUser"];
    NSArray *matches             = [context executeFetchRequest:fetchRequest error:nil];
    if (matches.count == 1) {
        user = matches.firstObject;
    }
    if (matches.count > 1) {
        user = nil;
        FDLog(@"Attention! Duplicates found in users table !");
    }
    return user;
}

@end