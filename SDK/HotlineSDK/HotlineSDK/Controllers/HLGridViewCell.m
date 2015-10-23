//
//  HLCollectionViewCell.m
//  HotlineSDK
//
//  Created by kirthikas on 22/09/15.
//  Copyright © 2015 Freshdesk. All rights reserved.
//

#import "HLGridViewCell.h"
#import "HLTheme.h"

@interface HLGridViewCell()

@property (nonatomic,strong) UIView *view;

@end

@implementation HLGridViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.imageView = [[UIImageView alloc]init];
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
        self.imageView.backgroundColor = [[HLTheme sharedInstance] gridViewItemBackgroundColor];
        self.imageView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:self.imageView];
        
        CGSize maximumLabelSize = CGSizeMake(296, FLT_MAX);
        CGSize expectedLabelSize = [self.label.text sizeWithFont:[[HLTheme sharedInstance] tableViewCellFont] constrainedToSize:maximumLabelSize lineBreakMode:self.label.lineBreakMode];
        //adjust the label the the new height.
        CGRect newFrame = self.label.frame;
        newFrame.size.height = expectedLabelSize.height;
        self.label.frame = newFrame;
        self.label = [[UILabel alloc]initWithFrame:CGRectMake(0, 10, self.bounds.size.width, 40)];
        self.label.lineBreakMode=NSLineBreakByWordWrapping;
        self.label.textAlignment = NSTextAlignmentCenter;
        [self.label  setNumberOfLines:0];
        [self.label sizeToFit];
        self.label.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:self.label];
        
        NSDictionary *views = @{ @"imageView" : self.imageView, @"label" : self.label};
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[imageView]-10-|" options:0 metrics:nil views:views]];
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.label attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.imageView attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-10-[imageView]-[label]-|" options:0 metrics:nil views:views]];
    }
    return self;
}

-(void)prepareForReuse{
    [super prepareForReuse];
    self.imageView.image=[UIImage imageNamed:@"loading.png"];
}

-(void)layoutSubviews{
    [super layoutSubviews];
    self.label.preferredMaxLayoutWidth = self.bounds.size.width;
    [self.view layoutIfNeeded];
}

@end