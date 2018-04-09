//
//  Help.h
//  JRLinkageEffect
//
//  Created by hqtech on 2018/4/9.
//  Copyright © 2018年 tulip. All rights reserved.
//

#ifndef Help_h
#define Help_h


#endif /* Help_h */

//检测系统版本
#define CurrentSystemVersion ([[[UIDevice currentDevice] systemVersion] floatValue])

//屏幕的宽高
#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height

//判断是否是iPhone X
#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define IS_IPHONE_X (IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 812.0f)

//导航栏背景色
#define NAV_BACK_COLOR [UIColor colorWithHex:0x181818]
