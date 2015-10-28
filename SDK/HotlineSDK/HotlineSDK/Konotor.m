//
//  Konotor.m
//  Konotor
//
//  Created by Vignesh G on 04/07/13.
//  Copyright (c) 2013 Vignesh G. All rights reserved.
//

#import "Konotor.h"
#import "KonotorUser.h"
#import "KonotorDataManager.h"
#import <AVFoundation/AVAudioPlayer.h>
#import <AVFoundation/AVAudioSession.h>
#import <AVFoundation/AVFoundation.h>
#import "CoreAudio/CoreAudioTypes.h"
#import <Foundation/NSUUID.h>
#import "KonotorAudioRecorder.h"
#import "KonotorApp.h"
#import "KonotorAudioPlayer.h"
#import "WebServices.h"
#import "KonotorShareMessageEvent.h"
#import <CommonCrypto/CommonDigest.h>


extern  bool KONOTOR_APP_INIT_DONE;
static NSString* kon_unlock_key=nil;

@interface NSString(MD5)

- (NSString *)MD5;

@end

@implementation NSString(MD5)

- (NSString*)MD5
{
    // Create pointer to the string as UTF8
    const char *ptr = [self UTF8String];
    
    // Create byte array of unsigned chars
    unsigned char md5Buffer[16];
    
    // Create 16 byte MD5 hash value, store in buffer
    CC_MD5(ptr,(unsigned int) strlen(ptr), md5Buffer);
    
    // Convert MD5 value in the buffer to NSString of hex values
    NSMutableString *output = [NSMutableString stringWithCapacity:16 * 2];
    for(int i = 0; i < 16; i++)
        [output appendFormat:@"%02x",md5Buffer[i]];
    
    return output;
}

@end

@implementation Konotor

static id <KonotorDelegate> _delegate;

+(id) delegate
{
    return _delegate;
}

+(void) setDelegate:(id)delegate
{
    _delegate = delegate;
}

+(void) setSecretKey:(NSString*)key
{
    kon_unlock_key=key;
}

+(void) InitSequenceWithAppID :(NSString *) AppID AppKey: (NSString *) AppKey withDelegate:(id) delegate
{
    if(KONOTOR_APP_INIT_DONE)
    {
        return;
    }
    
    [KonotorApp InitWithAppID:AppID WithAppKey:AppKey];
    _delegate = delegate;
    [KonotorUser InitUser];
    [KonotorApp UpdateAppAndSDKVersions];
}

+(void) InitWithAppID: (NSString *) AppID AppKey: (NSString *) AppKey withDelegate:(id) delegate
{
    
    /*NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *urlString = [defaults stringForKey:@"currentKonotorAppDetails"];
    if(urlString)
    {
        NSURL *mouri = [NSURL URLWithString:urlString];
        NSPersistentStoreCoordinator *coord = [[KonotorDataManager sharedInstance]persistentStoreCoordinator];
        NSManagedObjectContext *context = [[KonotorDataManager sharedInstance]managedObjectContext];
        
        KonotorApp *appData = (KonotorApp*)[context objectWithID:[coord managedObjectIDForURIRepresentation:mouri]];
        [appData setAppID:AppID];
        [appData setAppKey:AppKey];
        
        [[KonotorDataManager sharedInstance]save];

    }
    
    else
    {
        KonotorApp *appData = (KonotorApp *)[NSEntityDescription insertNewObjectForEntityForName:@"KonotorApp" inManagedObjectContext:[[KonotorDataManager sharedInstance]managedObjectContext]];
        
        [appData setAppID:AppID];
        [appData setAppKey:AppKey];
        [[KonotorDataManager sharedInstance]save];
        
               
        
        NSURL *moURI = [[appData objectID] URIRepresentation];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:[moURI absoluteString] forKey:@"currentKonotorAppDetails"];
        [defaults synchronize];
     }*/
    
    if(KONOTOR_APP_INIT_DONE)
    {
        return;
    }
    

    if (![NSThread isMainThread])
    {
        dispatch_async(dispatch_get_main_queue(),
        ^{
            [Konotor InitSequenceWithAppID:AppID AppKey:AppKey withDelegate:delegate];
        });
        
    }
    
    else
    {
        [Konotor InitSequenceWithAppID:AppID AppKey:AppKey withDelegate:delegate];
                           
    }
    

    
}

+(void) sendAllUnsentMessages{
    if(KONOTOR_APP_INIT_DONE){
        [KonotorMessage uploadAllUnuploadedMessages];
    }
}


+(void) PerformAllPendingTasks
{
    dispatch_async(dispatch_get_main_queue(),
    ^{

        if(KONOTOR_APP_INIT_DONE)
        {
            [KonotorShareMessageEvent UploadAllUnuploadedEvents];
            [KonotorCustomProperty UploadAllUnuploadedProperties];
            [KonotorMessage uploadAllUnuploadedMessages];
            [KonotorConversation DownloadAllMessages];
            [KonotorApp SendCachedTokenIfNotUpdated];
            [KonotorApp UpdateAppAndSDKVersions];

        }
    });

    
}


+(BOOL) areConversationsDownloading
{
    return [KonotorApp areConversationsDownloading];
}
+(void) DownloadAllMessages
{
    [KonotorConversation DownloadAllMessages];
}

+(BOOL) handleRemoteNotification:(NSDictionary*)userInfo
{
    return [_delegate handleRemoteNotification:userInfo];
}

+(BOOL) handleRemoteNotification:(NSDictionary*)userInfo withShowScreen:(BOOL)showScreen
{
    return [_delegate handleRemoteNotification:userInfo withShowScreen:showScreen];
}

+(double) getCurrentPlayingAudioTime
{
    return [KonotorAudioPlayer audioPlayerGetCurrentTime];
}

+(BOOL) startRecording
{
    return [KonotorAudioRecorder startRecording];
}
+(NSString *) stopRecording
{
    return[KonotorAudioRecorder stopRecording];
}

+ (NSTimeInterval) getTimeElapsedSinceStartOfRecording
{
    return[KonotorAudioRecorder getTimeElapsedSinceStartOfRecording];

}

+(BOOL) cancelRecording
{
    return[KonotorAudioRecorder cancelRecording];

}

+(float) getDecibelLevel
{
  return [KonotorAudioRecorder getDecibelLevel];
}
+(void) uploadVoiceRecordingWithMessageID: (NSString *)MessageID
{
    [KonotorAudioRecorder SendRecordingWithMessageID:MessageID];
}

+(void) uploadVoiceRecordingWithMessageID: (NSString *)MessageID toConversationID: (NSString *)ConversationID
{
    
}


+(BOOL) StopPlayback
{
    return [KonotorAudioPlayer StopMessage];
}

+(NSString *)getCurrentPlayingMessageID
{
    return [KonotorAudioPlayer currentPlaying:nil set:NO ];
}

+(void) uploadTextFeedback:(NSString *)textFeedback
{
    NSString *messageID = [KonotorMessage saveTextMessageInCoreData:textFeedback];
    KonotorMessage *message = [KonotorMessage retriveMessageForMessageId: messageID];
    
    if(messageID)
    {
        [KonotorWebServices UploadMessage:message toConversation:nil];
    }

}


+(void) uploadImage:(UIImage *) image
{
    NSString *messageID = [KonotorMessage savePictureMessageInCoreData:image withCaption:nil];
    KonotorMessage *message = [KonotorMessage retriveMessageForMessageId: messageID];
    
    if(messageID)
    {
        [KonotorWebServices UploadMessage:message toConversation:nil];
    }

}

+(void) uploadImage:(UIImage *) image withCaption:(NSString *)caption
{
    NSString *messageID = [KonotorMessage savePictureMessageInCoreData:image withCaption:caption];
    KonotorMessage *message = [KonotorMessage retriveMessageForMessageId: messageID];
    
    if(messageID)
    {
        [KonotorWebServices UploadMessage:message toConversation:nil];
    }
}


+(void)MarkMessageAsRead:(NSString *) messageID
{
    KonotorMessage *message = [KonotorMessage retriveMessageForMessageId:messageID];
    if(message)
    {
        [message markAsReadwithNotif:YES];
    }
}

+(void) MarkMarketingMessageAsClicked:(NSNumber *) marketingId;
{
    if(marketingId)
    {
        [KonotorMessage markMarketingMessageAsClicked:marketingId ];
    }
}
+(void)markAllMessagesAsRead
{
    [KonotorMessage markAllMessagesAsRead];

}
+(BOOL) playMessageWithMessageID:(NSString *) messageID
{
    return [KonotorAudioPlayer playMessageWithMessageID:messageID];
    
}

+(BOOL) playMessageWithMessageID:(NSString *) messageID atTime:(double)time
{
    return [KonotorAudioPlayer PlayMessage:messageID atTime:time];
    
}



+(BOOL) setBinaryImage:(NSData *)imageData forMessageId:(NSString *)messageId
{
    return [KonotorMessage setBinaryImage:imageData forMessageId:messageId];
}
+(BOOL) setBinaryImageThumbnail:(NSData *)imageData forMessageId:(NSString *)messageId
{
    return [KonotorMessage setBinaryImageThumbnail:imageData forMessageId:messageId];
}

+(NSArray *) getAllMessagesForDefaultConversation
{
    return [KonotorMessage getAllMessagesForDefaultConversation];
}

+(NSArray*) getAllConversations
{
    return [KonotorConversation ReturnAllConversations];
}

+(NSArray *) getAllMessagesForConversation:(NSString *) conversationID
{
    return [KonotorMessage getAllMessagesForConversation:conversationID];
}

+(void) setWelcomeMessage:(NSString *) text
{
    if(![KonotorApp hasWelcomeMessageDisplayed])
    {
        [KonotorMessage insertLocalTextMessage:text Read:YES IsWelcomeMessage:YES];
        [KonotorApp setWelcomeMessageStatus:YES];
    }
    else{
        [KonotorMessage updateWelcomeMessageText:text];
    }
}

+(void) setUnreadWelcomeMessage:(NSString *) text
{
    if(![KonotorApp hasWelcomeMessageDisplayed])
    {
        [KonotorMessage insertLocalTextMessage:text Read:NO IsWelcomeMessage:YES];
        [KonotorApp setWelcomeMessageStatus:YES];
    }
    else{
        [KonotorMessage updateWelcomeMessageText:text];
    }
}

+(int) getUnreadMessagesCount
{
    NSArray* allConvs=[Konotor getAllConversations];
    if((allConvs!=nil)&&([allConvs count]>0))
        return [[(KonotorConversationData*)[allConvs objectAtIndex:0] unreadMessagesCount] intValue];
    else
        return 0;
}

+(BOOL) isUserMe:(NSString *) userId
{
    NSString *currentUserID = [KonotorUser GetUserAlias];
    if(currentUserID)
    {
        if([currentUserID isEqualToString:userId])
            return TRUE;
    }
    
    return FALSE;
}




+(BOOL) addDeviceToken:(NSData *) deviceToken
{
    NSString *tokenStr = [deviceToken description];
    NSString *strDeviceToken = [[[tokenStr stringByReplacingOccurrencesOfString:@"<"withString:@""] stringByReplacingOccurrencesOfString:@">"withString:@""] stringByReplacingOccurrencesOfString:@" "withString:@""] ;
    [KonotorApp addDeviceToken:strDeviceToken];
    return YES;
    
}

+(void) setUserIdentifier: (NSString *) UserIdentifier
{
    [KonotorUser setUserIdentifier:UserIdentifier];
}

+(void) setUserName: (NSString *) fullName
{
    [KonotorUser setUserName:fullName];
}

+(void) setUserEmail: (NSString *) email
{
    [KonotorUser setUserEmail:email];
}

+(void) setCustomUserProperty:(NSString *) value forKey: (NSString*) key
{
    [KonotorUser setCustomUserProperty:value forKey:key];
}

+(void) shareEventWithMessageID: (NSString *)messageID shareType:(NSString*)shareType
{
    KonotorShareMessageEvent* event = [KonotorShareMessageEvent sharedMessageWithID:messageID withShareType:shareType];
    [KonotorWebServices sendShareMessageEvent:event];
    return;
    
}
//////Start of undocumented functions/////

+(void) conversationsDownloaded
{
    if([Konotor delegate])
    {
        if([[Konotor delegate] respondsToSelector:@selector(didFinishDownloadingMessages) ])
        {
    
            [[Konotor delegate] didFinishDownloadingMessages];
        }
    }
}

+(void)UploadFinishedNotifcation: (NSString *) messageID
{
    if([Konotor delegate])
    {
        if([[Konotor delegate] respondsToSelector:@selector(didFinishUploading:) ])
        {
            
            [[Konotor delegate] didFinishUploading:messageID];
        }
    }
    
}


+(void)UploadFailedNotifcation: (NSString *) messageID
{
    if([Konotor delegate])
    {
        if([[Konotor delegate] respondsToSelector:@selector(didEncounterErrorWhileUploading:) ])
        {
            
            [[Konotor delegate] didEncounterErrorWhileUploading:messageID];
        }
    }
    
}

+(void) messageFinishedPlayingNotification:(NSString *) messageID
{
    if([Konotor delegate])
    {
        if([[Konotor delegate] respondsToSelector:@selector(didFinishPlaying:) ])
        {
            
            [[Konotor delegate] didFinishPlaying:messageID];
        }
    }
}

+(void) MediaStartedNotification:(NSString *) messageID
{
    if([Konotor delegate])
    {
        if([[Konotor delegate] respondsToSelector:@selector(didStartPlaying:) ])
        {
            
            [[Konotor delegate] didStartPlaying:messageID];
        }
    }
}

+(void) MediaDownloadFailedNotification:(NSString *) messageID
{
    if([Konotor delegate])
    {
        if([[Konotor delegate] respondsToSelector:@selector(didEncounterErrorWhileDownloading:) ])
        {
            
            [[Konotor delegate] didEncounterErrorWhileDownloading:messageID];
        }
    }
}

+(void) conversationsDownloadFailed
{
    if([Konotor delegate])
    {
        if([[Konotor delegate] respondsToSelector:@selector(didEncounterErrorWhileDownloadingConversations) ])
        {
            
            [[Konotor delegate] didEncounterErrorWhileDownloadingConversations];
        }
    }
}

+(void) newSession
{
    dispatch_async(dispatch_get_main_queue(),
    ^{
        [KonotorUser InitUser];
        [Konotor PerformAllPendingTasks];
        [KonotorWebServices DAUCall];
    });

    
}

+(BOOL) isPushEnabled
{
    if([KonotorApp GetCachedDeviceToken])
        return YES;
    else
        return NO;
}

+(BOOL) isPoweredByHidden
{
    if(kon_unlock_key==nil) return NO;
    NSString* myString=[[KonotorApp GetAppKey] stringByAppendingString:[KonotorApp GetAppID]];
    NSMutableString *reversedString = [NSMutableString stringWithCapacity:[myString length]];
    
    [myString enumerateSubstringsInRange:NSMakeRange(0,[myString length])
                                 options:(NSStringEnumerationReverse | NSStringEnumerationByComposedCharacterSequences)
                              usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
                                  [reversedString appendString:substring];
                              }];
    
    if([[reversedString MD5] isEqualToString:kon_unlock_key])
        return YES;
    else
        return NO;
}


@end

@implementation KonotorConversationData



@end

@implementation KonotorMessageData



@end
