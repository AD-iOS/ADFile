// AboutViewController.m
#import "AboutViewController.h"

@interface AboutViewController ()

@property (nonatomic, strong) NSArray *aboutItems;

@end

@implementation AboutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"关于";
    [self setupAboutItems];
}

- (void)setupAboutItems {
    self.aboutItems = @[
        @[@"iOS越狱交流群", @"1030152896"],
        @[@"创作者AD", @"3897069329"],
        @[@"创作者AD(备用QQ号)", @"1107154510"],
        @[@"Telegraph频道", @"https://t.me/adsukisuultra"],
        @[@"向开发者反馈", @"3897069329\n1107154510"],
        @[@"邮箱", @"3897069329@qq.com\n1107154510@qq.com"],
        @[@"hello", @"这是我第三天写iOS的应用程序"]
    ];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.aboutItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AboutCell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"AboutCell"];
    }
    
    NSArray *item = self.aboutItems[indexPath.row];
    cell.textLabel.text = item[0];
    cell.detailTextLabel.text = item[1];
    cell.detailTextLabel.numberOfLines = 0;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSArray *item = self.aboutItems[indexPath.row];
    [UIPasteboard generalPasteboard].string = item[1];
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"已复制" message:[NSString stringWithFormat:@"%@ 已复制到剪贴板", item[0]] preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *item = self.aboutItems[indexPath.row];
    NSString *detailText = item[1];
    
    CGFloat width = tableView.frame.size.width - 120;
    CGSize size = [detailText boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX)
                                          options:NSStringDrawingUsesLineFragmentOrigin
                                       attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:14]}
                                          context:nil].size;
    
    return MAX(60, size.height + 30);
}

@end