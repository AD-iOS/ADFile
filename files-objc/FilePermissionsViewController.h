// FilePermissionsViewController.h
#import <UIKit/UIKit.h>

@class FileItem;

@interface FilePermissionsViewController : UITableViewController

@property (nonatomic, strong) FileItem *fileItem;
@property (nonatomic, strong) NSString *filePath;

@end

@interface TextFieldTableViewCell : UITableViewCell
@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, copy) void (^textFieldDidChange)(NSString *text);
@end