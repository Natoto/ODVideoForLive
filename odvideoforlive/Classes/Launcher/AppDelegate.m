//
//  AppDelegate.m
//  dianyingba
//
//  Created by 罗飞 on 23/09/2017.
//  Copyright © 2017 one. All rights reserved.
//

#import "AppDelegate.h"
#import "ODHomeViewController.h"
#import "ODURLProtocol.h"
#import "ODVarietyViewController.h"
#import "ODMovieViewController.h"
#import "ODAnimeViewController.h"
#import "ODURLCProtocol.h"
#import "ODSearchViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    self.window=[[UIWindow alloc]initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor=[UIColor whiteColor];
    
    UITabBarController *tabbar=[[UITabBarController alloc]init];
    
    ODHomeViewController *home = [[ODHomeViewController alloc]init];
    home.title=@"电视剧";
    
    ODAnimeViewController *anime = [[ODAnimeViewController alloc]init];
    anime.title=@"动漫";
    
    ODMovieViewController *movie = [[ODMovieViewController alloc]init];
    movie.title=@"电影";
    
    ODVarietyViewController *variety = [[ODVarietyViewController alloc]init];
    variety.title=@"综艺";
    
    ODSearchViewController *search=[[ODSearchViewController alloc]init];
    search.title=@"搜索";
    
    tabbar.viewControllers=@[[[UINavigationController alloc] initWithRootViewController:home],
                             [[UINavigationController alloc] initWithRootViewController: anime],
                             [[UINavigationController alloc] initWithRootViewController: movie],
                             [[UINavigationController alloc] initWithRootViewController: variety],
                             [[UINavigationController alloc] initWithRootViewController: search],
                             ];
    
    self.window.rootViewController=tabbar;
    [self.window makeKeyAndVisible];
    
    
    
    //注册scheme NSURLSesson 拦截
//    Class cls = NSClassFromString(@"WKBrowsingContextController");
//    SEL sel = NSSelectorFromString(@"registerSchemeForCustomProtocol:");
//    if ([cls respondsToSelector:sel]) {
//        // 通过http和https的请求，同理可通过其他的Scheme 但是要满足ULR Loading System
//        [cls performSelector:sel withObject:@"http"];
//        [cls performSelector:sel withObject:@"https"];
//    }
    
    [NSURLProtocol registerClass:ODURLCProtocol.class];
    
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
