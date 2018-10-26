//
//  FCJWTUtilities.m
//  FreshchatSDK
//
//  Created by Harish Kumar on 09/10/18.
//  Copyright © 2018 Freshdesk. All rights reserved.
//

#import "FCJWTUtilities.h"
#import "FCRemoteConfig.h"
#import "FCUtilities.h"
#import "FCUserDefaults.h"
#import "FCSecureStore.h"
#import "FCJWTAuthValidator.h"

@implementation FCJWTUtilities

+ (NSDictionary *) getJWTUserPayloadFromToken : (NSString *) jwtIdToken{
    if(!jwtIdToken.length) return @{};
    NSArray *tokenStucture = [jwtIdToken componentsSeparatedByString:@"."];
    
    NSString *tokenPayload = [tokenStucture objectAtIndex:1];
    int modPayload = tokenPayload.length % 4;
    int repeatCount= 0;
    if(modPayload!=0) {
        repeatCount = 4-modPayload;
    }
    
    NSString *pay = [tokenPayload stringByPaddingToLength:[tokenPayload length]+repeatCount withString:@"=" startingAtIndex:0];
    
    NSData *decodedData = [[NSData alloc] initWithBase64EncodedString:pay options:NSDataBase64DecodingIgnoreUnknownCharacters];
      NSString *decodedString = [[NSString alloc] initWithData:decodedData encoding:NSUTF8StringEncoding];
    NSDictionary *payloadDict = [NSJSONSerialization JSONObjectWithData:[decodedString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
    return payloadDict;
}

+ (BOOL) isUserAuthEnabled {
    return ([FCRemoteConfig sharedInstance].userAuthConfig.isjwtAuthEnabled
            && [FCRemoteConfig sharedInstance].userAuthConfig.isStrictModeEnabled);
}

+ (BOOL) isValidityExpiedForJWTToken :(NSString*) jwtIdToken {
    if(jwtIdToken.length > 0){
        NSDictionary *jwtTokenInfo = [self getJWTUserPayloadFromToken:jwtIdToken];
        if([jwtTokenInfo objectForKey:@"exp"]){
            NSTimeInterval currentRequestTime = [FCUtilities getCurrentTimeInMillis];
            if(currentRequestTime > ([[jwtTokenInfo objectForKey:@"exp"] longValue] * ONE_SECONDS_IN_MS)){
                return TRUE;
            }
        }
    }
    return FALSE;
}

+ (NSString*) getReferenceID: (NSString *) jwtIdToken {
    if(jwtIdToken){
        NSDictionary *jwtTokenInfo = [self getJWTUserPayloadFromToken:jwtIdToken];
        if([jwtTokenInfo objectForKey:@"reference_id"]){
            return [jwtTokenInfo objectForKey:@"reference_id"];
        }
    }
    return nil;
}

+ (NSString*) getAliasFrom: (NSString *) jwtIdToken {
    if(jwtIdToken){
        NSDictionary *jwtTokenInfo = [self getJWTUserPayloadFromToken:jwtIdToken];
        if([jwtTokenInfo objectForKey:@"freshchat_uuid"]){
            return [jwtTokenInfo objectForKey:@"freshchat_uuid"];
        }
    }
    return nil;
}

+ (BOOL) hasValidRefIdForJWTToken :(NSString *) jwtIdToken {
    NSDictionary *jwtTokenInfo = [self getJWTUserPayloadFromToken:[FreshchatUser sharedInstance].jwtToken];
    if([jwtTokenInfo objectForKey:@"reference_id"] != nil){
        return true;
    }
    return false;
}

+ (void) setTokenInitialState{
    if([FCJWTUtilities isUserAuthEnabled]
       && ([FreshchatUser sharedInstance].jwtToken == nil && ![[FreshchatUser sharedInstance].jwtToken isEqualToString:@""]) ){
        [[FCJWTAuthValidator sharedInstance] updateAuthState:TOKEN_NOT_SET];
    }
}

+(BOOL) isJwtWaitingToAuth {
    return ([FCJWTUtilities getPendingJWTToken] != nil);
}

+(NSString *) getPendingJWTToken {
    return [[FCSecureStore sharedInstance] objectForKey:FRESHCHAT_DEFAULTS_USER_VERIFICATION_PENDING_TOKEN];
}

+(void) setPendingJWTToken : (NSString *) jwtIdToken {
    [[FCSecureStore sharedInstance] setObject:jwtIdToken forKey:FRESHCHAT_DEFAULTS_USER_VERIFICATION_PENDING_TOKEN];
}

+(void) removePendingJWTToken {
    [[FCSecureStore sharedInstance] removeObjectWithKey:FRESHCHAT_DEFAULTS_USER_VERIFICATION_PENDING_TOKEN];
}

+ (void) setPendingRestoreJWTToken : (NSString *) jwtIdToken {
    [[FCSecureStore sharedInstance] setObject:jwtIdToken forKey:FRESHCHAT_DEFAULTS_USER_AUTH_ID_RESTORE_PENDING_TOKEN];
}

+ (void) removePendingRestoreJWTToken {
    [[FCSecureStore sharedInstance] removeObjectWithKey:FRESHCHAT_DEFAULTS_USER_AUTH_ID_RESTORE_PENDING_TOKEN];
}

+ (NSString *) getPendingRestoreJWTToken {
    return [[FCSecureStore sharedInstance] objectForKey:FRESHCHAT_DEFAULTS_USER_AUTH_ID_RESTORE_PENDING_TOKEN];
}

+ (void) performPendingJWTTasks {
    if([FCJWTUtilities isUserAuthEnabled] && [FCJWTUtilities isJwtWaitingToAuth]) {
        [[Freshchat sharedInstance] setUserWithIdToken : [FCJWTUtilities getPendingJWTToken]];
        return;
    }
    
    if([FCJWTUtilities isUserAuthEnabled] && [FCJWTUtilities getPendingRestoreJWTToken]){
        [[Freshchat sharedInstance] restoreUserWithIdToken:[FCJWTUtilities getPendingRestoreJWTToken]];
        return;
    }
}

@end
