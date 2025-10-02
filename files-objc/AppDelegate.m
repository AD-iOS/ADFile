// AppDelegate.m
#import "AppDelegate.h"
#import "FileListViewController.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    
    FileListViewController *fileListVC = [[FileListViewController alloc] initWithPath:@"/"];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:fileListVC];
    
    self.window.rootViewController = navController;
    [self.window makeKeyAndVisible];
    
    return YES;
}

@end