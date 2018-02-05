//
//  ViewController.m
//  JXBezierDemo
//
//  Created by pconline on 2018/1/30.
//  Copyright © 2018年 tianguo. All rights reserved.
//

#import "ViewController.h"
#import "JXTopView.h"

@interface ViewController ()
@property(nonatomic,strong) JXTopView *topView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.topView = [[JXTopView alloc] initWithFrame:CGRectMake(0, 100, self.view.bounds.size.width, self.view.bounds.size.height-100)];
    [self.view addSubview:self.topView];
    
    //向下隐藏后，双击恢复初始状态
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTap:)];
    doubleTap.numberOfTapsRequired = 2;
    [self.view addGestureRecognizer:doubleTap];
}

- (void)doubleTap:(UITapGestureRecognizer*)tap{
    [self.topView comeBack];
}

@end
