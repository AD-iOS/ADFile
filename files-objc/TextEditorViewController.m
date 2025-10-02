// TextEditorViewController.m
#import "TextEditorViewController.h"

@interface TextEditorViewController ()

@property (nonatomic, strong) UITextView *textView;

@end

@implementation TextEditorViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
    [self loadFileContent];
}

- (void)setupUI {
    self.textView = [[UITextView alloc] initWithFrame:self.view.bounds];
    self.textView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.textView.font = [UIFont systemFontOfSize:16];
    [self.view addSubview:self.textView];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"保存" style:UIBarButtonItemStyleDone target:self action:@selector(saveFile)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:self action:@selector(goBack)];
}

- (void)loadFileContent {
    NSError *error;
    NSString *content = [NSString stringWithContentsOfFile:self.filePath encoding:NSUTF8StringEncoding error:&error];
    if (error) {
        [self showErrorAlert:[NSString stringWithFormat:@"读取文件失败: %@", error.localizedDescription]];
    } else {
        self.textView.text = content ?: @"";
    }
}

- (void)saveFile {
    NSError *error;
    if ([self.textView.text writeToFile:self.filePath atomically:YES encoding:NSUTF8StringEncoding error:&error]) {
        [self showSuccessAlert:@"保存成功"];
    } else {
        [self showErrorAlert:[NSString stringWithFormat:@"保存失败: %@", error.localizedDescription]];
    }
}

- (void)goBack {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)showErrorAlert:(NSString *)message {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"错误" message:message preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)showSuccessAlert:(NSString *)message {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"成功" message:message preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

@end