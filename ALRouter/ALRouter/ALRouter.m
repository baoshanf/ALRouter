//
//  ALRouter.m
//  HHRouterExample
//
//  Created by hans on 2018/4/20.
//  Copyright © 2018年 Huohua. All rights reserved.
//

#import "ALRouter.h"
#import <objc/runtime.h>

static NSString *const ALControllerKey = @"ALControllerKey";
static NSString *const ALRouteKey = @"route";


@interface ALRouter()

/**
 记录所有注册的controller
 */
@property (nonatomic,strong) NSMutableDictionary *routes;

@end

@implementation ALRouter
+ (instancetype)sharedInstance{
    static ALRouter *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}
+ (void)loadConfigPlist:(NSString *)plistName{
    plistName = plistName ? plistName : @"ALRouter.plist";
    NSString *path = [[NSBundle mainBundle] pathForResource:plistName ofType:nil];
    NSDictionary *configDic = [NSDictionary dictionaryWithContentsOfFile:path];
    [configDic enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSString * _Nonnull obj, BOOL * _Nonnull stop) {
        [self regist:key toControllerClass:NSClassFromString(obj)];
    }];
}
+ (void)regist:(NSString *)URL toControllerClass:(Class)controllerClass{
    NSMutableDictionary *subRoutes = [[self sharedInstance] subRoutesToRoute:URL];
    subRoutes[@"_"] = controllerClass;
}

+ (UIViewController *)openURL:(NSString *)URL{
   return [self openURL:URL withParams:nil];
}

+ (UIViewController *)openURL:(NSString *)URL withParams:(NSDictionary *)params{
    NSDictionary *routeParams = [[self sharedInstance] paramsInRoute:URL];
    Class controllerClass = routeParams[ALControllerKey];
    UIViewController *viewController = [[controllerClass alloc] init];
    viewController.params = params;
    return viewController;
}

+ (BOOL)canOpenURL:(NSString *)URL{
    NSDictionary *params = [[self sharedInstance] paramsInRoute:URL];
    if (params[ALControllerKey]) {
        return YES;
    }
    return NO;
}
#pragma mark - private
- (NSMutableDictionary *)subRoutesToRoute:(NSString *)route{
    NSArray *pathComponents = [self pathComponentsFromRoute:route];
    
    NSInteger index = 0;
    NSMutableDictionary *subRoutes = self.routes;
    
    while (index < pathComponents.count) {
        NSString *pathComponent = pathComponents[index];
        if (![subRoutes objectForKey:pathComponent]) {
            subRoutes[pathComponent] = [[NSMutableDictionary alloc] init];
        }
        subRoutes = subRoutes[pathComponent];
        index++;
    }
    
    return subRoutes;
}

- (NSArray *)pathComponentsFromRoute:(NSString *)route
{
    NSMutableArray *pathComponents = [NSMutableArray array];
    NSURL *url = [NSURL URLWithString:[route stringByRemovingPercentEncoding]];
    
    for (NSString *pathComponent in url.path.pathComponents) {
        if ([pathComponent isEqualToString:@"/"]) continue;
        if ([[pathComponent substringToIndex:1] isEqualToString:@"?"]) break;
        [pathComponents addObject:[pathComponent stringByRemovingPercentEncoding]];
    }
    
    return [pathComponents copy];
}

/**
  borrowed from HHRouter(https://github.com/Huohua/HHRouter)
 */
- (NSDictionary *)paramsInRoute:(NSString *)route{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    params[ALRouteKey] = [self stringFromFilterAppUrlScheme:route];
    
    NSMutableDictionary *subRoutes = self.routes;
    NSArray *pathComponents = [self pathComponentsFromRoute:params[ALRouteKey]];
    for (NSString *pathComponent in pathComponents) {
        BOOL found = NO;
        NSArray *subRoutesKeys = subRoutes.allKeys;
        for (NSString *key in subRoutesKeys) {
            if ([subRoutesKeys containsObject:pathComponent]) {
                found = YES;
                subRoutes = subRoutes[pathComponent];
                break;
            } else if ([key hasPrefix:@":"]) {
                found = YES;
                subRoutes = subRoutes[key];
                params[[key substringFromIndex:1]] = pathComponent;
                break;
            }
        }
        if (!found) {
            return nil;
        }
    }
    
    // Extract Params From Query.
    NSRange firstRange = [route rangeOfString:@"?"];
    if (firstRange.location != NSNotFound && route.length > firstRange.location + firstRange.length) {
        NSString *paramsString = [route substringFromIndex:firstRange.location + firstRange.length];
        NSArray *paramStringArr = [paramsString componentsSeparatedByString:@"&"];
        for (NSString *paramString in paramStringArr) {
            NSArray *paramArr = [paramString componentsSeparatedByString:@"="];
            if (paramArr.count > 1) {
                NSString *key = [paramArr objectAtIndex:0];
                NSString *value = [paramArr objectAtIndex:1];
                params[key] = value;
            }
        }
    }
    
    Class class = subRoutes[@"_"];
    if (class_isMetaClass(object_getClass(class))) {
        if ([class isSubclassOfClass:[UIViewController class]]) {
            params[ALControllerKey] = subRoutes[@"_"];
        } else {
            return nil;
        }
    } else {
        if (subRoutes[@"_"]) {
            params[@"block"] = [subRoutes[@"_"] copy];
        }
    }
    
    return [NSDictionary dictionaryWithDictionary:params];
}
- (NSString *)stringFromFilterAppUrlScheme:(NSString *)string{
    // filter out the app URL compontents.
    for (NSString *appUrlScheme in [self appUrlSchemes]) {
        if ([string hasPrefix:[NSString stringWithFormat:@"%@:", appUrlScheme]]) {
            return [string substringFromIndex:appUrlScheme.length + 2];
        }
    }
    
    return string;
}

/**
 APP白名单

 @return 白名单数组
 */
- (NSArray *)appUrlSchemes{
    NSMutableArray *appUrlSchemes = [NSMutableArray array];
    
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    
    for (NSDictionary *dic in infoDictionary[@"CFBundleURLTypes"]) {
        NSString *appUrlScheme = dic[@"CFBundleURLSchemes"][0];
        [appUrlSchemes addObject:appUrlScheme];
    }
    
    return [appUrlSchemes copy];
}
#pragma mark - lazy load
- (NSMutableDictionary *)routes{
    if (!_routes) {
        _routes = [[NSMutableDictionary alloc] init];
    }
    return _routes;
}
@end


#pragma mark - UIViewController Category

@implementation UIViewController (ALRouter)

static char kAssociatedParamsObjectKey;

- (void)setParams:(NSDictionary *)paramsDictionary
{
    objc_setAssociatedObject(self, &kAssociatedParamsObjectKey, paramsDictionary, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSDictionary *)params
{
    return objc_getAssociatedObject(self, &kAssociatedParamsObjectKey);
}

@end
