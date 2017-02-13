//
//  FDGrowingTextView.m
//  HotlineSDK
//
//  Created by user on 14/11/16.
//  Copyright © 2016 Freshdesk. All rights reserved.
//

#import "FDGrowingTextView.h"
#import "HLMacros.h"

@interface FDGrowingTextView ()

@property (nonatomic, retain) UILabel *placeHolderLabel;

@end

@implementation FDGrowingTextView

- (id)initWithFrame:(CGRect)frame{
    if( (self = [super initWithFrame:frame]) ){
        [self setPlaceholder:@""];
        [self setPlaceholderColor:[UIColor lightGrayColor]];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textChanged:) name:UITextViewTextDidChangeNotification object:nil];
    }
    return self;
}

- (void)textChanged:(NSNotification *)notification{
    if([[self placeholder] length] == 0){
        return;
    }
    
    if([[self text] length] == 0){
        self.placeHolderLabel.alpha = 1;
    }else{
        self.placeHolderLabel.alpha = 0;
    }
}

- (void)setText:(NSString *)text {
    [super setText:text];
    [self textChanged:nil];
}

- (void)drawRect:(CGRect)rect{
    if( [[self placeholder] length] > 0 ){
        if (_placeHolderLabel == nil ){
            _placeHolderLabel = [[UILabel alloc] initWithFrame:CGRectMake(5,5,self.bounds.size.width - 16,0)];
            _placeHolderLabel.font = [UIFont systemFontOfSize:14];
            _placeHolderLabel.lineBreakMode = NSLineBreakByWordWrapping;
            _placeHolderLabel.numberOfLines = 0;
            _placeHolderLabel.backgroundColor = [UIColor clearColor];
            _placeHolderLabel.textColor = self.placeholderColor;
            _placeHolderLabel.alpha = 0;
            [self addSubview:_placeHolderLabel];
        }
        
        _placeHolderLabel.text = self.placeholder;
        [_placeHolderLabel sizeToFit];
        [self sendSubviewToBack:_placeHolderLabel];
    }
    
    if( [[self text] length] == 0 && [[self placeholder] length] > 0 ){
        _placeHolderLabel.alpha = 1;
    }
    [super drawRect:rect];
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextViewTextDidChangeNotification object:nil];
}

@end