// PDFViewController.m
#import "PDFViewController.h"
#import <PDFKit/PDFKit.h>

@interface PDFViewController ()
@property (nonatomic, strong) PDFView *pdfView;
@end

@implementation PDFViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.pdfView = [[PDFView alloc] initWithFrame:self.view.bounds];
    self.pdfView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.pdfView.autoScales = YES;
    [self.view addSubview:self.pdfView];
    
    NSURL *fileURL = [NSURL fileURLWithPath:self.filePath];
    PDFDocument *pdfDocument = [[PDFDocument alloc] initWithURL:fileURL];
    if (pdfDocument) {
        self.pdfView.document = pdfDocument;
    } else {
        [self showErrorAlert:@"无法加载PDF文件"];
    }
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:self action:@selector(goBack)];
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