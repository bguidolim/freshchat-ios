//
//  ViewController.m
//  Hotline
//
//  Created by AravinthChandran on 9/7/15.
//  Copyright (c) 2015 Freshdesk. All rights reserved.
//

#import "ViewController.h"
#import "HotlineSDK/Hotline.h"
#import "FDSettingsController.h"
#import "AppDelegate.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIButton *chatButton;
@property (nonatomic, strong) UIImageView *imageView;

@end

@implementation ViewController

- (void)viewDidLoad {

    self.imageView = [[UIImageView alloc]initWithFrame:self.view.frame];
    [self.view insertSubview:self.imageView atIndex:0];
    
    self.view.backgroundColor = [UIColor colorWithHue:0 saturation:0 brightness:0.95 alpha:1];
    [super viewDidLoad];
}

-(void)viewWillAppear:(BOOL)animated{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    self.imageView.image = appDelegate.pickedImage;
}

- (IBAction)chatButtonPressed:(id)sender {
    [[Hotline sharedInstance]showConversations:self];
}

@end