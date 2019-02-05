//
//  FDSecureStore.m
//  FreshdeskSDK
//
//  Created by Aravinth on 01/08/14.
//  Copyright (c) 2014 Freshdesk. All rights reserved.
//

#import "FCSecureStore.h"
#import "FCKeyChainStore.h"
#import "FCMacros.h"

#define FRESHCHAT_SERVICE_NAME @"com.freshworks.freshchat.%@"
#define HOTLINE_SERVICE_NAME @"com.freshdesk.hotline.%@"

@interface FCSecureStore ()

@property (strong, nonatomic) FCKeyChainStore  *secureStore;

@end

@implementation FCSecureStore

#pragma mark - Shared Manager

+(instancetype)sharedInstance{
    static FCSecureStore *sharedFDSecureStore = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedFDSecureStore = [[self alloc]initWithPersistedStore:NO];
    });
    return sharedFDSecureStore;
}

+(instancetype)persistedStoreInstance{
    static FCSecureStore *persistedSecureStore = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        persistedSecureStore = [[self alloc]initWithPersistedStore:YES];
    });
    return persistedSecureStore;
}

- (instancetype)initWithPersistedStore:(BOOL)isPreferred{
    self = [super init];
    if (self) {
        FCKeyChainStore *store = nil;
        NSString *appID = [[NSBundle bundleForClass:[self class]] infoDictionary][@"CFBundleIdentifier"];
        NSString *serviceName = [NSMutableString stringWithFormat:FRESHCHAT_SERVICE_NAME,appID];
        NSString *persistedStoreServiceName = [NSString stringWithFormat:@"%@%@",serviceName,@"-persistedStore"];
        
        if (isPreferred) {
            store = [FCKeyChainStore keyChainStoreWithService:persistedStoreServiceName];
        }else{
            store = [FCKeyChainStore keyChainStoreWithService:serviceName];
            if ([self isFirstLaunch]){
                [store removeAllItems];
                FDLog(@"Clearing keys for %d",isPreferred);
            }
        }
        
        self.secureStore = store;
        [self clearHotlineKeys];
    }
    return self;
}

-(void) clearHotlineKeys {
    NSString *appID = [[NSBundle bundleForClass:[self class]] infoDictionary][@"CFBundleIdentifier"];
    NSString *serviceName = [NSMutableString stringWithFormat:HOTLINE_SERVICE_NAME,appID];
    NSString *persistedStoreServiceName = [NSString stringWithFormat:@"%@%@",serviceName,@"-persistedStore"];
    FCKeyChainStore *persistentStore = [FCKeyChainStore keyChainStoreWithService:persistedStoreServiceName];
    FCKeyChainStore *store = [FCKeyChainStore keyChainStoreWithService:persistedStoreServiceName];
    if(persistentStore) {
        [persistentStore removeAllItems];
    }
    if(store) {
        [store removeAllItems];
    }
}

-(BOOL)isFirstLaunch{
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"FD_HOTLINE_IS_FIRST_LAUNCH"]) {
        return NO;
    }else{
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"FD_HOTLINE_IS_FIRST_LAUNCH"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        return YES;
    }
}

-(void)setIntValue:(NSInteger)value forKey:(NSString *)key{
    NSNumber *number = [NSNumber numberWithInteger:value];
    [self setObject:number forKey:key];
}

-(NSInteger)intValueForKey:(NSString *)key{
    return [[self objectForKey:key]integerValue];
}

-(void)setBoolValue:(BOOL)value forKey:(NSString *)key{
    NSNumber *boolValue = [NSNumber numberWithBool:value];
    [self setObject:boolValue forKey:key];
}

-(BOOL)boolValueForKey:(NSString *)key{
    return [[self objectForKey:key]boolValue];
}

-(void)setObject:(id)object forKey:(NSString *)key{
    @synchronized(self) {
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:object];
        [self.secureStore setData:data forKey:key];
    }
}

-(id)objectForKey:(NSString *)key{
    NSData *data = [self.secureStore dataForKey:key];
    return (data) ? [NSKeyedUnarchiver unarchiveObjectWithData:data] : NULL;
}

-(void)removeObjectWithKey:(NSString *)key{
    @synchronized(self) {
        [self.secureStore removeItemForKey:key];
    }
}

-(BOOL)checkItemWithKey:(NSString *)key{
    return [self objectForKey:key] ? YES : NO;
}

-(void)clearStoreData{
    [self.secureStore removeAllItems];
}

-(NSString *)description{
    return [NSString stringWithFormat:@"Secure Store Contents %@",self.secureStore];
}

@end