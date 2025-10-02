// SettingsViewController.h
#import <UIKit/UIKit.h>

@class FileListViewController;

@interface SettingsViewController : UITableViewController

@property (nonatomic, weak) FileListViewController *fileListVC;

@end