// HexEditorViewController.m
#import "HexEditorViewController.h"

@interface HexEditorViewController ()
@property (nonatomic, strong) UITextView *textView;
@end

@implementation HexEditorViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
    [self loadHexContent];
}

- (void)setupUI {
    self.textView = [[UITextView alloc] initWithFrame:self.view.bounds];
    self.textView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.textView.editable = NO;
    self.textView.font = [UIFont monospacedSystemFontOfSize:12 weight:UIFontWeightRegular];
    [self.view addSubview:self.textView];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:self action:@selector(goBack)];
}

- (void)loadHexContent {
    NSData *data = [NSData dataWithContentsOfFile:self.filePath];
    if (!data) {
        [self showErrorAlert:@"无法读取文件"];
        return;
    }
    
    NSMutableString *hexString = [NSMutableString string];
    const unsigned char *bytes = [data bytes];
    NSUInteger length = [data length];
    
    for (NSUInteger i = 0; i < length; i++) {
        if (i % 16 == 0) {
            [hexString appendFormat:@"%08lX: ", (unsigned long)i];
        }
        [hexString appendFormat:@"%02X ", bytes[i]];
        
        if (i % 16 == 15 || i == length - 1) {
            // 填充對齊
            NSUInteger remaining = 15 - (i % 16);
            for (NSUInteger j = 0; j < remaining; j++) {
                [hexString appendString:@"   "];
            }
            
            // 添加ASCII顯示
            [hexString appendString:@" "];
            NSUInteger start = i - (i % 16);
            NSUInteger end = MIN(start + 15, length - 1);
            
            for (NSUInteger j = start; j <= end; j++) {
                unsigned char byte = bytes[j];
                if (byte >= 32 && byte <= 126) {
                    [hexString appendFormat:@"%c", byte];
                } else {
                    [hexString appendString:@"."];
                }
            }
            [hexString appendString:@"\n"];
        }
    }
    
    self.textView.text = hexString;
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