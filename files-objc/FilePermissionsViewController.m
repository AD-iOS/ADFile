// FilePermissionsViewController.m
#import "FilePermissionsViewController.h"
#import "FileItem.h"
#import "FileOperations.h"
#import <sys/stat.h>
#import <pwd.h>
#import <grp.h>

@interface FilePermissionsViewController ()

@property (nonatomic, strong) NSString *permissions;
@property (nonatomic, strong) NSString *owner;
@property (nonatomic, strong) NSString *group;

@end

@implementation FilePermissionsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
    [self loadFileInfo];
}

- (void)setupUI {
    self.title = @"文件权限";
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    [self.tableView registerClass:[TextFieldTableViewCell class] forCellReuseIdentifier:@"TextFieldCell"];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"保存" style:UIBarButtonItemStyleDone target:self action:@selector(savePermissions)];
}

- (void)loadFileInfo {
    // 获取文件权限信息
    struct stat statInfo;
    if (stat([self.filePath UTF8String], &statInfo) == 0) {
        self.permissions = [NSString stringWithFormat:@"%o", statInfo.st_mode & 0777];
        
        // 获取所有者信息
        struct passwd *pwd = getpwuid(statInfo.st_uid);
        if (pwd) {
            self.owner = [NSString stringWithUTF8String:pwd->pw_name];
        } else {
            self.owner = @"root";
        }
        
        // 获取组信息
        struct group *grp = getgrgid(statInfo.st_gid);
        if (grp) {
            self.group = [NSString stringWithUTF8String:grp->gr_name];
        } else {
            self.group = @"wheel";
        }
    } else {
        self.permissions = @"755";
        self.owner = @"root";
        self.group = @"wheel";
    }
    
    [self.tableView reloadData];
}

- (void)savePermissions {
    // 使用 C 函数执行 chmod 和 chown
    int chmodResult = execute_chmod([self.permissions UTF8String], [self.filePath UTF8String]);
    
    NSString *ownerGroup = [NSString stringWithFormat:@"%@:%@", self.owner, self.group];
    int chownResult = execute_chown([ownerGroup UTF8String], [self.filePath UTF8String]);
    
    if (chmodResult == 0 && chownResult == 0) {
        [self showSuccessAlert:@"权限修改成功"];
    } else {
        [self showErrorAlert:@"权限修改失败"];
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TextFieldTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TextFieldCell" forIndexPath:indexPath];
    
    // 使用 if-else 替代 switch 來避免 block 作用域問題
    if (indexPath.row == 0) {
        cell.textLabel.text = @"权限";
        cell.textField.text = self.permissions;
        cell.textField.placeholder = @"例如: 755";
        __weak __typeof(self) weakSelf = self;
        cell.textFieldDidChange = ^(NSString *text) {
            weakSelf.permissions = text ?: @"755";
        };
    } 
    else if (indexPath.row == 1) {
        cell.textLabel.text = @"所有者";
        cell.textField.text = self.owner;
        cell.textField.placeholder = @"例如: root";
        __weak __typeof(self) weakSelf = self;
        cell.textFieldDidChange = ^(NSString *text) {
            weakSelf.owner = text ?: @"root";
        };
    } 
    else if (indexPath.row == 2) {
        cell.textLabel.text = @"组";
        cell.textField.text = self.group;
        cell.textField.placeholder = @"例如: wheel";
        __weak __typeof(self) weakSelf = self;
        cell.textFieldDidChange = ^(NSString *text) {
            weakSelf.group = text ?: @"wheel";
        };
    }
    
    return cell;
}

- (void)showSuccessAlert:(NSString *)message {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"成功" message:message preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self.navigationController popViewControllerAnimated:YES];
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)showErrorAlert:(NSString *)message {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"错误" message:message preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

@end

@implementation TextFieldTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    self.textField = [[UITextField alloc] init];
    self.textField.translatesAutoresizingMaskIntoConstraints = NO;
    self.textField.textAlignment = NSTextAlignmentRight;
    [self.textField addTarget:self action:@selector(textFieldChanged) forControlEvents:UIControlEventEditingChanged];
    [self.contentView addSubview:self.textField];
    
    [NSLayoutConstraint activateConstraints:@[
        [self.textField.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-16],
        [self.textField.centerYAnchor constraintEqualToAnchor:self.contentView.centerYAnchor],
        [self.textField.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:100]
    ]];
}

- (void)textFieldChanged {
    if (self.textFieldDidChange) {
        self.textFieldDidChange(self.textField.text);
    }
}

@end