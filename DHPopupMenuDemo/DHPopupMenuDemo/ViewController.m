//
//  ViewController.m
//  DHPopupMenuDemo
//
//  Created by 张丁豪 on 2017/4/18.
//  Copyright © 2017年 zhangdinghao. All rights reserved.
//

#import "ViewController.h"
#import "DHPopupMenu.h"

@interface ViewController ()<DHPopupMenuDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    UITouch *t = touches.anyObject;
    CGPoint p = [t locationInView: self.view];
    
    NSArray *arr = @[@"One",@"Two",@"Three",@"Four",@"Other",@"Six"];
    DHPopupMenu *popupMenu = [DHPopupMenu showAtPoint:p titles:arr icons:nil menuWidth:130 delegate:self];
    popupMenu.dismissOnSelected = NO;
    popupMenu.isShowShadow = YES;
    popupMenu.delegate = self;
    popupMenu.offset = 10;
    popupMenu.type = DHPopupMenuTypeDark;
}

#pragma mark - YBPopupMenuDelegate
- (void)dhPopupMenuDidSelectedAtIndex:(NSInteger)index dhPopupMenu:(DHPopupMenu *)dhPopupMenu
{
    NSLog(@"点击了 %ld",index);
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
