//
//  GoodsListController.m
//  ALRouter
//
//  Created by hans on 2018/4/26.
//  Copyright © 2018年 hans. All rights reserved.
//

#import "GoodsListController.h"

@interface GoodsListController ()

@end

@implementation GoodsListController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.navigationController pushViewController:[ALRouter openURL:@"GoodsDetail"] animated:YES];
}
@end
