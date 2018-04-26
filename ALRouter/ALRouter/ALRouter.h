//
//  ALRouter.h
//  HHRouterExample
//
//  Created by hans on 2018/4/20.
//  Copyright © 2018年 Huohua. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ALRouter : NSObject

/**
 读取plist的注册表

 @param plistName 如“ALRouter.plist”
 */
+ (void)loadConfigPlist:(NSString *)plistName;


/**
 注册单个URL

 @param route URL
 @param controllerClass [UIViewController]
 */
+ (void)regist:(NSString *)route toControllerClass:(Class)controllerClass;

+ (UIViewController *)openURL:(NSString *)URL;

+ (UIViewController *)openURL:(NSString *)URL withParams:(NSDictionary *)params;

+ (BOOL)canOpenURL:(NSString *)URL;

@end

/**
 用于传值的category
 */
@interface UIViewController (ALRouter)

@property (nonatomic, strong) NSDictionary *params;

@end
