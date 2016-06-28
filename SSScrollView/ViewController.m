//
//  ViewController.m
//  SSScrollView
//
//  Created by Spence Shi on 16/6/20.
//  Copyright © 2016年 Spence Shi. All rights reserved.
//

#import "ViewController.h"
#import "SSScrollView.h"

@interface ViewController ()

@property(nonatomic, assign) BOOL opened;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.ssScrollView = [[SSScrollView alloc] initWithPosition:CGPointMake(([UIScreen mainScreen].bounds.size.width-219.5)/2.0, 165) bgViewWidth:219.5 opened:NO];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(openOrClose:)];
    [self.ssScrollView addGestureRecognizer:tap];
    [self.view addSubview:self.ssScrollView];
    self.opened = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)openOrClose:(UITapGestureRecognizer *)tap {
    [self.ssScrollView scrollAnimationWithDuration:1 open:!self.opened removedOnCompletion:NO];
    self.opened = !self.opened;
    //    __weak SSScrollView *weakScrollView = self.ssScrollView;
    self.ssScrollView.animationWillStopBlock = ^() {
        //卷轴打开后的回调
    };
}


@end
