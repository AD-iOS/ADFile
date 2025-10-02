// SettingsViewController.m
#import "SettingsViewController.h"
#import "FileListViewController.h"
#import "AboutViewController.h"
#import "UpdateLogViewController.h"

@interface SettingsViewController ()

@property (nonatomic, strong) NSArray *settingsItems;

@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupUI];
    [self setupSettingsItems];
}

- (void)setupUI {
    self.title = @"设置";
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"SettingsCell"];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismissSettings)];
}

- (void)setupSettingsItems {
    self.settingsItems = @[
        @"显示隐藏文件",
        @"文件排序方式", 
        @"关于",
        @"更新日志"
    ];
}

- (void)dismissSettings {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.settingsItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SettingsCell" forIndexPath:indexPath];
    cell.textLabel.text = self.settingsItems[indexPath.row];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    // 显示隐藏文件开关
    if (indexPath.row == 0) {
        UISwitch *switchView = [[UISwitch alloc] init];
        switchView.on = self.fileListVC.showHiddenFiles;
        [switchView addTarget:self action:@selector(toggleHiddenFiles:) forControlEvents:UIControlEventValueChanged];
        cell.accessoryView = switchView;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    } else {
        cell.accessoryView = nil;
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    switch (indexPath.row) {
        case 1: // 文件排序方式
            [self showSortOptions];
            break;
        case 2: // 关于
            [self showAboutPage];
            break;
        case 3: // 更新日志
            [self showUpdateLog];
            break;
        default:
            break;
    }
}

- (void)toggleHiddenFiles:(UISwitch *)sender {
    self.fileListVC.showHiddenFiles = sender.on;
    [self.fileListVC loadDirectoryContents];
}

- (void)showSortOptions {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"排序方式" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"按名称" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self showSuccessAlert:@"已设置为按名称排序"];
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"按日期" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self showSuccessAlert:@"已设置为按日期排序"];
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"按大小" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self showSuccessAlert:@"已设置为按大小排序"];
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)showAboutPage {
    AboutViewController *aboutVC = [[AboutViewController alloc] init];
    [self.navigationController pushViewController:aboutVC animated:YES];
}

- (void)showUpdateLog {
    UpdateLogViewController *updateLogVC = [[UpdateLogViewController alloc] init];
    [self.navigationController pushViewController:updateLogVC animated:YES];
}

- (void)showSuccessAlert:(NSString *)message {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"成功" message:message preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

@end