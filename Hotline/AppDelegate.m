//
//  AppDelegate.m
//  Hotline
//
//  Created by AravinthChandran on 9/7/15.
//  Copyright (c) 2015 Freshdesk. All rights reserved.
//

#import "AppDelegate.h"
#import "HotlineSDK/Hotline.h"
#import "ViewController.h"
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>

@interface AppDelegate ()

@property (nonatomic, strong)UIViewController *rootController;

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [self hotlineIntegration];
    [self registerAppForNotifications];
    [self setupRootController];
    if ([[Hotline sharedInstance]isHotlineNotification:launchOptions]) {
        [[Hotline sharedInstance]handleRemoteNotification:launchOptions andAppstate:application.applicationState];
    }

    NSLog(@"launchoptions :%@", launchOptions);

    [Fabric with:@[[Crashlytics class]]];

    return YES;
}

-(void)setupRootController{
    
    BOOL isTabViewPreferred = YES;

    if (isTabViewPreferred) {
        UIViewController* mainView=[self.window rootViewController];
        [mainView setTitle:@"Order"];
        
        UITabBarController* tabBarController=[[UITabBarController alloc] init];
        
        UINavigationController *FAQController = [[UINavigationController alloc]initWithRootViewController:
                                                        [[Hotline sharedInstance] getFAQsControllerForEmbed]];
        [FAQController setTitle:@"FAQs"];
        
        UIViewController* channelsController = [[UINavigationController alloc]initWithRootViewController:
                                                [[Hotline sharedInstance] getConversationsControllerForEmbed]];
        
        [channelsController setTitle:@"Channels"];
        
        [tabBarController setViewControllers:@[mainView, FAQController, channelsController]];
        [tabBarController.tabBar setClipsToBounds:NO];
        [tabBarController.tabBar setTintColor:[UIColor colorWithRed:(0x33/0xFF) green:(0x36/0xFF) blue:(0x45/0xFF) alpha:1.0]];
        [tabBarController.tabBar setBarStyle:UIBarStyleDefault];
        [self.window setRootViewController:tabBarController];
        NSArray* items = [tabBarController.tabBar items];
        if(items){
            [[items objectAtIndex:0] setImage:[[UIImage imageNamed:@"tab1Image"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
            [[items objectAtIndex:1] setImage:[[UIImage imageNamed:@"tab2Image"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
            [[items objectAtIndex:2] setImage:[[UIImage imageNamed:@"tab3Image"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
        }
        [self.window makeKeyAndVisible];
        
    }
}

-(void)hotlineIntegration{
    HotlineConfig *config = [[HotlineConfig alloc]initWithAppID:@"e3280bde-4696-4bd5-8be7-e7919249bf9a"
                                                       andAppKey:@"9d456296-5f38-45ce-884e-b595f7e6301a"];
    
    config.voiceMessagingEnabled = YES;
    config.pictureMessagingEnabled = YES;
    
    HotlineUser *user = [HotlineUser sharedInstance];
    user.name = @"Sid";
    user.email = @"sid@freshdesk.com";
    user.phoneNumber = @"9898989898";
    user.phoneCountryCode = @"+91";
    config.pollWhenAppActive = YES;

    [[Hotline sharedInstance] updateUser:user];
    
    [[Hotline sharedInstance] updateUserProperties:@{
                                                     @"Key1" : @"Value1",
                                                     @"Key2" : @"1"
                                                     }];
    
        [[Hotline sharedInstance]initWithConfig:config];
    
    NSLog(@"Unread messages count :%d", (int)[[Hotline sharedInstance]unreadCount]);
    [[Hotline sharedInstance]unreadCountWithCompletion:^(NSInteger count) {
        NSLog(@"Unread count (Async) : %d", (int)count);
    }];
    
    [[NSNotificationCenter defaultCenter]addObserverForName:HOTLINE_UNREAD_MESSAGE_COUNT object:nil queue:nil usingBlock:^(NSNotification *note) {
        NSLog(@"updated unread messages count %@", note.userInfo[@"count"]);
    }];
}

-(void)registerAppForNotifications{
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    }else{
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes: (UIRemoteNotificationTypeNewsstandContentAvailability| UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
    }
}

- (void)application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)devToken {
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
        NSLog(@"is app registered for notifications :: %d" , [[UIApplication sharedApplication] isRegisteredForRemoteNotifications]);
    }
    [[Hotline sharedInstance] updateDeviceToken:devToken];
}

- (void)application:(UIApplication *)app didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"Failed to register remote notification  %@", error);
}

- (void) application:(UIApplication *)app didReceiveRemoteNotification:(NSDictionary *)info{
    if ([[Hotline sharedInstance]isHotlineNotification:info]) {
        [[Hotline sharedInstance]handleRemoteNotification:info andAppstate:app.applicationState];
    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application{
    NSInteger unreadCount = [[Hotline sharedInstance]unreadCount];
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:unreadCount];
}

/* 
 supported deep link URLs to test:
 hotline://?launch=shoes
 hotline://?launch=cloths
 */
-(BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation{
    if ([url.scheme isEqualToString:@"hotline"]) {

        if ([url.query isEqualToString:@"launch=shoes"]) {
            NSLog(@"Lauch shoes screen");
        }
        
        if ([url.query isEqualToString:@"launch=cloths"]) {
            NSLog(@"Launch cloths screen");
        }

    }
    
    return YES;
}

@end
