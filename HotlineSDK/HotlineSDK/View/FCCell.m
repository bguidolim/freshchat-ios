//
//  FDCell.m
//  HotlineSDK
//
//  Created by Aravinth Chandran on 30/03/16.
//  Copyright © 2016 Freshdesk. All rights reserved.
//

#import "FCCell.h"
#import "FCTheme.h"
#import "FCAutolayoutHelper.h"

#define TITLE_MAX_LINES 2
#define LAST_UPDATED_WIDTH 55
static float height = 0;
@implementation FCCell

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier isChannelCell:(BOOL)isChannel{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.isChannelCell = isChannel;
        FCTheme *theme = [FCTheme sharedInstance];
        self.contentEncloser = [[UIView alloc]init];
        self.contentEncloser.translatesAutoresizingMaskIntoConstraints = NO;
        
        self.titleLabel = [[FCLabel alloc] init];
        [self.titleLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self.titleLabel setNumberOfLines:TITLE_MAX_LINES];
        [self.titleLabel setLineBreakMode:NSLineBreakByWordWrapping];
        
        self.detailLabel = [[FCLabel alloc] init];
        [self.detailLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
        
        if(isChannel){
            if(![theme numberOfChannelListDescriptionLines]){
                [self.detailLabel setNumberOfLines:1];
            }
            else{
                [self.detailLabel setNumberOfLines:[theme numberOfChannelListDescriptionLines]];
            }
        }
        else{
            if(![theme numberOfCategoryListDescriptionLines]){
                [self.detailLabel setNumberOfLines:1];
            }
            else{
                [self.detailLabel setNumberOfLines:[theme numberOfCategoryListDescriptionLines]];
            }
        }
        [self.detailLabel setLineBreakMode:NSLineBreakByTruncatingTail];

        self.imgView=[[UIImageView alloc] init];
        self.imgView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.imgView.layer setMasksToBounds:YES];
        self.imgView.contentMode = UIViewContentModeScaleAspectFit;
        
        //View hierarchy
        [self.contentView addSubview:self.imgView];
        [self.contentView addSubview:self.contentEncloser];
        [self.contentEncloser addSubview:self.titleLabel];
        [self.contentEncloser addSubview:self.detailLabel];

        //Constraints
        NSMutableDictionary *views = [NSMutableDictionary
                                      dictionaryWithDictionary:@{@"imageView" : self.imgView, @"contentEncloser" : self.contentEncloser,
                                                                                     @"title" : self.titleLabel,@"subtitle":self.detailLabel }];

        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[imageView(50)]" options:0 metrics:nil views:views]];
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[imageView(50)]-[contentEncloser]" options:0 metrics:nil views:views]];
        
        [self.contentEncloser addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[title][subtitle]|" options:0 metrics:nil  views:views]];
        
        self.encloserHeightConstraint = [FCAutolayoutHelper setHeight:0 forView:self.contentEncloser inView:self.contentView];

        [FCAutolayoutHelper centerY:self.contentEncloser onView:self.contentView];
        [FCAutolayoutHelper centerY:self.imgView onView:self.contentView];
        
        UIImageView *accessoryView = [[UIImageView alloc] init];
        accessoryView.image = [[FCTheme sharedInstance] getImageWithKey:IMAGE_TABLEVIEW_ACCESSORY_ICON];
        accessoryView.translatesAutoresizingMaskIntoConstraints=NO;
        [self.contentView addSubview:accessoryView];
        
        [FCAutolayoutHelper centerY:accessoryView onView:self.contentView];
        
        self.rightArrowImageView = accessoryView;
        
        views[@"accessoryView"] = accessoryView;
        
        if (isChannel) {
            self.lastUpdatedLabel = [[UILabel alloc] init];
            self.lastUpdatedLabel.textAlignment = UITextAlignmentRight;
            self.lastUpdatedLabel.translatesAutoresizingMaskIntoConstraints = NO;
            [self.contentView addSubview:self.lastUpdatedLabel];
            
            self.badgeView  = [[FCBadgeView alloc]initWithFrame:CGRectZero];
            self.badgeView.translatesAutoresizingMaskIntoConstraints = NO;
            [self.contentView addSubview:self.badgeView];
            
            views[@"lastUpdated"] = self.lastUpdatedLabel;
            views[@"badgeView"] = self.badgeView;
            
            [self.contentEncloser addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[title]|" options:0 metrics:nil views:views]];
            [self.contentEncloser addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[subtitle]" options:0 metrics:nil views:views]];
            
            self.lastUpdatedTimeWidthConstraint = [FCAutolayoutHelper setWidth:LAST_UPDATED_WIDTH forView:self.lastUpdatedLabel inView:self.contentView];
            
            self.detailLableRightConstraint = [NSLayoutConstraint constraintWithItem:self.detailLabel attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.contentEncloser attribute:NSLayoutAttributeTrailing multiplier:1 constant:0];
            
            [self.contentEncloser addConstraint:self.detailLableRightConstraint];
            
            [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[badgeView(30)]-10-[accessoryView(6)]-10-|" options:0 metrics:nil views:views]];
            
            [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-10-[lastUpdated(15)]-5-[badgeView(20)]" options:0 metrics:nil views:views]];
            
            [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[contentEncloser]-2-[lastUpdated]-10-|" options:0 metrics:nil views:views]];

        }else{
            [self.contentEncloser addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[title]|" options:0 metrics:nil views:views]];
            [self.contentEncloser addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[subtitle]|" options:0 metrics:nil views:views]];
            [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[contentEncloser]-[accessoryView(6)]-10-|" options:0 metrics:nil views:views]];
        }
        
        [self theme];
    }
    return self;
}

- (float) getSingleTitleLineSize{

    if(height){
        return height;
    }
    UILabel *tempLabel = [[UILabel alloc] init];
    tempLabel.text = @"text";
    tempLabel.font = [[FCTheme sharedInstance] channelTitleFont];
    CGSize singleSize = [tempLabel sizeThatFits:CGSizeMake(100, 999)];
    height = singleSize.height;
    return height;
}

-(void)adjustPadding{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self setNeedsLayout];
        [self layoutIfNeeded];
        float size = (self.lastUpdatedLabel.frame.size.width) ? (self.lastUpdatedLabel.frame.origin.x-self.titleLabel.frame.origin.x) : ((self.lastUpdatedLabel.frame.origin.x - LAST_UPDATED_WIDTH)-self.titleLabel.frame.origin.x);
        
        CGRect textRect = [self.titleLabel.text boundingRectWithSize:CGSizeMake(size,9999)
                                             options:NSStringDrawingUsesLineFragmentOrigin
                                          attributes:@{NSFontAttributeName:self.titleLabel.font}
                                             context:nil];
        
        int noLines = MIN(textRect.size.height /self.titleLabel.font.pointSize, TITLE_MAX_LINES);
        
        CGFloat titleHeight  = [self getSingleTitleLineSize] * noLines;
        CGFloat detailHeight = self.detailLabel.intrinsicContentSize.height;
        
        CGFloat lastUpdatedTimeWidth = self.lastUpdatedLabel.intrinsicContentSize.width;
        
        self.lastUpdatedTimeWidthConstraint.constant = lastUpdatedTimeWidth;
        self.encloserHeightConstraint.constant = titleHeight + detailHeight;
        
        if (self.badgeView.isHidden) {
            self.detailLableRightConstraint.constant = lastUpdatedTimeWidth - self.rightArrowImageView.frame.size.width;
        }else{
            self.detailLableRightConstraint.constant = 0;
        }
    });
}

-(void)theme{
    FCTheme *theme = [FCTheme sharedInstance];
    if (self.isChannelCell) {
        self.backgroundColor     = [theme channelListCellBackgroundColor];
        self.titleLabel.textColor = [theme channelTitleFontColor];
        self.titleLabel.font      = [theme channelTitleFont];
        self.detailLabel.font = [theme channelDescriptionFont];
        self.detailLabel.textColor = [theme channelDescriptionFontColor];
        self.lastUpdatedLabel.font = [theme channelLastUpdatedFont];
        self.lastUpdatedLabel.textColor = [theme channelLastUpdatedFontColor];
    }else{
        self.backgroundColor = [theme faqListViewCellBackgroundColor];
        self.titleLabel.textColor = [theme faqCategoryTitleFontColor];
        self.titleLabel.font      = [theme faqCategoryTitleFont];
        self.detailLabel.font = [theme faqCategoryDetailFont];
        self.detailLabel.textColor = [theme faqCategoryDetailFontColor];
    }
}

+(UIImage *)generateImageForLabel:(NSString *)labelText withColor :(UIColor *)color{
    FCTheme *theme = [FCTheme sharedInstance];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 60, 60)];
    NSString *firstLetter = [labelText substringToIndex:1];
    firstLetter = [firstLetter uppercaseString];
    label.text = firstLetter;
    label.font = [theme channelIconPlaceholderImageCharFont];
    label.textColor = [UIColor whiteColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.backgroundColor = color;
    label.layer.cornerRadius = label.frame.size.height / 8.0f;
    label.clipsToBounds = YES;
    
    UIGraphicsBeginImageContextWithOptions(label.frame.size, NO, 0.0);
    
    [[label layer] renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}


-(void)drawRect:(CGRect)rect{
    [super drawRect:rect];
   // self.layer.borderWidth = 0.9;
    self.imgView.layer.cornerRadius = self.imgView.frame.size.width / 8;
    self.imgView.layer.masksToBounds = YES;
   //self.layer.borderColor = [[FCTheme sharedInstance] channelListCellSeparatorColor].CGColor;
}

@end