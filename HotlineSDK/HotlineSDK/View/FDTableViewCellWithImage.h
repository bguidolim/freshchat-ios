//
//  FDCategoryTableViewCell.h
//  HotlineSDK
//
//  Created by user on 27/10/15.
//  Copyright © 2015 Freshdesk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HLTheme.h"
#import "FDImageView.h"

@interface FDTableViewCellWithImage : UITableViewCell

@property (strong, nonatomic) FDImageView *imgView;
@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UILabel *detailLabel;
@property (strong, nonatomic) UIView *contentEncloser;

-(void)setupTheme;

// Need to be implemented by subclasses if accessory view is required
-(void)addAccessoryView;

@end