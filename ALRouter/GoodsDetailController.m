//
//  GoodsDetailController.m
//  ALRouter
//
//  Created by hans on 2018/4/26.
//  Copyright © 2018年 hans. All rights reserved.
//

#import "GoodsDetailController.h"

@interface GoodsDetailController()

@end

@implementation GoodsDetailController
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:arc4random()%255 / 255.0 green:arc4random()%255 / 255.0 blue:arc4random()%255 / 255.0 alpha:1];
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
