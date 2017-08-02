//
//  HLMessageCell.h
//  HotlineSDK
//
//  Created by user on 28/07/17.
//  Copyright © 2017 Freshdesk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Message.h"

#define KONOTOR_PROFILEIMAGE_DIMENSION 40.0

@protocol HLMessageCellDelegate <NSObject>

-(void)agentCellPerfomAction:(FragmentData *)fragment;

@end

@class FDImageFragment;
@class FDHtmlFragment;

@interface HLAgentMessageCell : UITableViewCell

- (instancetype) initWithReuseIdentifier:(NSString *)identifier andDelegate:(id<HLMessageCellDelegate>)delegate;
- (void) drawMessageViewForMessage:(MessageData *)currentMessage parentView:(UIView*)parentView;

@property (nonatomic) BOOL showsProfile;
@property (nonatomic) BOOL showsSenderName;
@property (nonatomic) BOOL showsTimeStamp;
@property (nonatomic) BOOL showsUploadStatus;
@property (strong, nonatomic) UIFont *messageTextFont;
@property (strong, nonatomic) NSString* customFontName;
@property (nonatomic) NSInteger maxcontentWidth;
@property (nonatomic, strong) MessageData *messageData;
@property (nonatomic, weak) id<HLMessageCellDelegate> delegate;

@property (nonatomic) UIEdgeInsets agentChatBubbleInsets;
@property (strong, nonatomic) UIImage *agentChatBubble;
@property (strong, nonatomic) UIView* contentEncloser;
@property (strong, nonatomic) UITextView* senderNameLabel;
@property (strong, nonatomic) UITextView* messageSentTimeLabel;
@property (strong, nonatomic) UITextView* messageTextView;
@property (strong, nonatomic) UIImage* sentImage;
@property (strong, nonatomic) UIImage* sendingImage;
@property (strong, nonatomic) UIImageView* profileImageView;
@property (strong, nonatomic) UIImageView* uploadStatusImageView;
@property (strong, nonatomic) UIImageView* chatBubbleImageView;


@end