//
//  ViewController.m
//  NineSquareLock
//
//  Created by 胡双飞 on 15/8/21.
//  Copyright (c) 2015年 HSF. All rights reserved.
//

#import "ViewController.h"
#import "NineSquareInView.h"
#import "SuccessViewController.h"

@interface ViewController ()
//存放九宫格View
@property (weak, nonatomic) IBOutlet NineSquareInView* nineSquarView;
@property (weak, nonatomic) IBOutlet UIImageView* imageView;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    //设置背景色
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Home_refresh_bg"]];

    //    self.view.backgroundColor = [UIColor whiteColor];
    NSString* string = @"012";

    self.nineSquarView.passWordBlock = ^(NSString* str, UIImage* image) {

        if ([string isEqualToString:str]) {
            //跳转
            image = nil;
            [self successView];
            return YES;
        }
        else {
            self.imageView.image = image;
            return NO;
        }
    };
}
#pragma mark - 状态栏样式
- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

#pragma mark - 登陆成功要跳转页面
- (void)successView
{
    SuccessViewController* successView = [[SuccessViewController alloc] init];
    successView.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"main"]];

    [self presentViewController:successView animated:YES completion:nil];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
