// MediaViewController.m
#import "MediaViewController.h"
#import <AVKit/AVKit.h>

@interface MediaViewController ()
@property (nonatomic, strong) AVPlayerViewController *playerViewController;
@end

@implementation MediaViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
    [self loadMedia];
}

- (void)setupUI {
    self.playerViewController = [[AVPlayerViewController alloc] init];
    [self addChildViewController:self.playerViewController];
    [self.view addSubview:self.playerViewController.view];
    self.playerViewController.view.frame = self.view.bounds;
    [self.playerViewController didMoveToParentViewController:self];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:self action:@selector(goBack)];
}

- (void)loadMedia {
    NSURL *fileURL = [NSURL fileURLWithPath:self.filePath];
    AVPlayer *player = [AVPlayer playerWithURL:fileURL];
    self.playerViewController.player = player;
    [player play];
}

- (void)goBack {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)showErrorAlert:(NSString *)message {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"错误" message:message preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

@end