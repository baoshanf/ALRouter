# ALRouter
基于HHRouter的一款URL跳转路由
#前言
目前有很多市面上很不错的`URL`跳转路由器，例如 [MGJRouter](https://github.com/meili/MGJRouter)、[CTMediator](https://github.com/casatwy/CTMediator)、[HHRouter](https://github.com/lightory/HHRouter) 。
本着简洁、易维护、符合业务、编码方便的前提，简单研究了下源码之后，[HHRouter](https://github.com/lightory/HHRouter)  简洁的代码让人有cover住的信心，巧妙的用法也大大提升了效率。
[HHRouter](https://github.com/lightory/HHRouter) 的缺点
- 需要每个类在`+load`方法注册，感觉统计和维护起来并没那么直观
- 获取到`controller`之后才能传递参数

我们希望在`plist`表里就能看到`URL`对应的关系，`openURL`时可以传递相应的`param`,借鉴 [MGJRouter](https://github.com/meili/MGJRouter)使用的思想，于是在[MGJRouter](https://github.com/meili/MGJRouter)和[HHRouter](https://github.com/lightory/HHRouter)的基础上实现了[ALRouter](https://github.com/baoshanf/ALRouter)。
#使用
1. 在plist里面添加相应的键值对，`URL`为`key`，类名为`value`。
2. 在`application:(UIApplication *)application didFinishLaunchingWithOptions:`注册URL对应的类名：
```
[ALRouter loadConfigPlist:nil];
```
也可以直接注册某个controller
```
[ALRouter regist:@"GoodsDetailController" toControllerClass:[self class]];
```
3.通过URL获取controller
```
[self.navigationController pushViewController:[ALRouter openURL:@"GoodsDetail"] animated:YES];
```
或者传递参数
```
[self presentViewController:[ALRouter openURL:@"GoodsDetail" withParams:@{}] animated:YES completion:nil];
```
#End
github地址在[这里](https://github.com/baoshanf/ALRouter)
