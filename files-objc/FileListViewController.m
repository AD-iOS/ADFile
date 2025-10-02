// FileListViewController.m
#import "FileListViewController.h"
#import "FileItem.h"
#import "FileOperations.h"
#import "FavoritesManager.h"
#import "SettingsViewController.h"
#import "ImageViewController.h"
#import "PDFViewController.h"
#import "MediaViewController.h"
#import "HexEditorViewController.h"
#import "FilePermissionsViewController.h"
#import <CoreGraphics/CoreGraphics.h>

@interface FileListViewController () <UIDocumentInteractionControllerDelegate>

@property (nonatomic, strong) UIDocumentInteractionController *documentController;

@end

@implementation FileListViewController

- (instancetype)init {
    return [self initWithPath:@"/"];
}

- (instancetype)initWithPath:(NSString *)path {
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        _currentPath = path ? path : @"/";
        _showHiddenFiles = NO;
        _fileItems = [NSMutableArray array];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupTableView];
    [self loadDirectoryContents];
    [self setupNavigationBar];
    [self updateTitle];
    [self updateFavoriteButton];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self loadDirectoryContents];
    [self updateFavoriteButton];
}

- (void)setupTableView {
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"FileCell"];
}

- (void)setupNavigationBar {
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(showCreateMenu)];
    UIBarButtonItem *favoriteButton = [[UIBarButtonItem alloc] initWithImage:[UIImage systemImageNamed:@"star"] style:UIBarButtonItemStylePlain target:self action:@selector(showFavorites)];
    UIBarButtonItem *settingsButton = [[UIBarButtonItem alloc] initWithImage:[UIImage systemImageNamed:@"gear"] style:UIBarButtonItemStylePlain target:self action:@selector(showSettings)];
    
    self.navigationItem.rightBarButtonItems = @[addButton, favoriteButton, settingsButton];
    [self updateFavoriteButton];
}

- (void)updateFavoriteButton {
    BOOL isFavorited = [[FavoritesManager sharedManager] isFavoritePath:self.currentPath];
    UIBarButtonItem *favoriteButton = self.navigationItem.rightBarButtonItems[1];
    favoriteButton.image = [UIImage systemImageNamed:isFavorited ? @"star.fill" : @"star"];
    favoriteButton.tintColor = isFavorited ? [UIColor systemYellowColor] : [UIColor systemBlueColor];
}

- (void)showFavorites {
    BOOL isFavorited = [[FavoritesManager sharedManager] isFavoritePath:self.currentPath];
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"收藏目录" message:@"选择操作" preferredStyle:UIAlertControllerStyleActionSheet];
    
    if (isFavorited) {
        [alert addAction:[UIAlertAction actionWithTitle:@"取消收藏" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            [self removeFromFavorites];
        }]];
        
        [alert addAction:[UIAlertAction actionWithTitle:@"管理收藏" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self showFavoritesManager];
        }]];
    } else {
        [alert addAction:[UIAlertAction actionWithTitle:@"添加收藏" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self promptForFavoriteName];
        }]];
    }
    
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)promptForFavoriteName {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"添加收藏" message:@"为当前目录设置一个名称" preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"收藏名称";
        textField.text = [self.currentPath lastPathComponent];
    }];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"添加" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSString *name = alert.textFields.firstObject.text;
        if (name && name.length > 0) {
            [self addToFavorites:name];
        }
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)addToFavorites:(NSString *)name {
    [[FavoritesManager sharedManager] addFavoriteWithPath:self.currentPath name:name];
    [self updateFavoriteButton];
    [self showSuccessAlert:@"已添加到收藏"];
}

- (void)removeFromFavorites {
    [[FavoritesManager sharedManager] removeFavoriteWithPath:self.currentPath];
    [self updateFavoriteButton];
    [self showSuccessAlert:@"已取消收藏"];
}

- (void)showFavoritesManager {
    NSDictionary *favorites = [[FavoritesManager sharedManager] getFavorites];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"收藏目录" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    for (NSString *name in favorites) {
        NSString *path = favorites[name];
        [alert addAction:[UIAlertAction actionWithTitle:[NSString stringWithFormat:@"%@ - %@", name, path] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self navigateToFavorite:path];
        }]];
    }
    
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)navigateToFavorite:(NSString *)path {
    FileListViewController *nextVC = [[FileListViewController alloc] initWithPath:path];
    nextVC.showHiddenFiles = self.showHiddenFiles;
    [self.navigationController pushViewController:nextVC animated:YES];
}

- (void)updateTitle {
    if ([self.currentPath isEqualToString:@"/"]) {
        self.title = @"根目录";
    } else {
        self.title = [self.currentPath lastPathComponent];
    }
    self.navigationItem.prompt = [NSString stringWithFormat:@"路径: %@", self.currentPath];
}

- (void)loadDirectoryContents {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    
    NSArray *contents = [fileManager contentsOfDirectoryAtPath:self.currentPath error:&error];
    
    if (error) {
        NSLog(@"读取目录失败: %@", error);
        [self showErrorAlert:[NSString stringWithFormat:@"无法读取目录: %@", error.localizedDescription]];
        return;
    }
    
    NSMutableArray *items = [NSMutableArray array];
    for (NSString *fileName in contents) {
        NSString *fullPath;
        if ([self.currentPath isEqualToString:@"/"]) {
            fullPath = [@"/" stringByAppendingPathComponent:fileName];
        } else {
            fullPath = [self.currentPath stringByAppendingPathComponent:fileName];
        }
        
        FileItem *item = [[FileItem alloc] initWithPath:fullPath];
        [items addObject:item];
    }
    
    // 过滤隐藏文件
    if (!self.showHiddenFiles) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isHidden == NO"];
        items = [[items filteredArrayUsingPredicate:predicate] mutableCopy];
    }
    
    // 排序：文件夹在前，文件在后，按名称排序
    [items sortUsingComparator:^NSComparisonResult(FileItem *item1, FileItem *item2) {
        if (item1.isDirectory && !item2.isDirectory) {
            return NSOrderedAscending;
        } else if (!item1.isDirectory && item2.isDirectory) {
            return NSOrderedDescending;
        } else {
            return [item1.name localizedCaseInsensitiveCompare:item2.name];
        }
    }];
    
    self.fileItems = items;
    [self.tableView reloadData];
    [self updateTitle];
}

- (void)openFile:(FileItem *)fileItem {
    if (fileItem.isDirectory) {
        FileListViewController *nextVC = [[FileListViewController alloc] initWithPath:fileItem.path];
        nextVC.showHiddenFiles = self.showHiddenFiles;
        [self.navigationController pushViewController:nextVC animated:YES];
        return;
    }
    
    [self showFileOpenOptions:fileItem];
}

- (void)showFileOpenOptions:(FileItem *)fileItem {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"打开方式" message:[NSString stringWithFormat:@"选择打开 %@ 的方式", fileItem.name] preferredStyle:UIAlertControllerStyleActionSheet];
    
    NSString *fileExtension = [[fileItem.name pathExtension] lowercaseString];
    
    // 系统应用打开
    [alert addAction:[UIAlertAction actionWithTitle:@"系统应用打开" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self openWithSystemApp:fileItem];
    }]];
    
    // 文本文件
    if ([self isTextFile:fileExtension]) {
        [alert addAction:[UIAlertAction actionWithTitle:@"文本编辑器" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self openTextEditor:fileItem];
        }]];
    }
    
    // 图片文件
    if ([self isImageFile:fileExtension]) {
        [alert addAction:[UIAlertAction actionWithTitle:@"图片浏览器" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self openImageBrowser:fileItem];
        }]];
    }
    
    // PDF文件
    if ([fileExtension isEqualToString:@"pdf"]) {
        [alert addAction:[UIAlertAction actionWithTitle:@"PDF阅读器" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self openPDFViewer:fileItem];
        }]];
    }
    
    // 媒体文件
    if ([self isMediaFile:fileExtension]) {
        [alert addAction:[UIAlertAction actionWithTitle:@"媒体播放器" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self openMediaPlayer:fileItem];
        }]];
    }
    
    // 十六进制编辑器（所有文件）
    [alert addAction:[UIAlertAction actionWithTitle:@"十六进制编辑器" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self openHexEditor:fileItem];
    }]];
    
    // 压缩文件
    if ([fileExtension isEqualToString:@"zip"]) {
        [alert addAction:[UIAlertAction actionWithTitle:@"解压缩" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self decompressItem:fileItem];
        }]];
    }
    
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    
    // iPad 适配
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        UIPopoverPresentationController *popover = alert.popoverPresentationController;
        NSInteger index = [self.fileItems indexOfObject:fileItem];
        if (index != NSNotFound) {
            UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
            popover.sourceView = cell;
            popover.sourceRect = cell.bounds;
        }
    }
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (BOOL)isTextFile:(NSString *)ext {
    NSArray *textExtensions = @[@"txt", @"md", @"json", @"xml", @"html", @"htm", @"css", @"js", @"py", @"java", @"c", @"cpp", @"h", @"m", @"mm", @"swift", @"plist", @"strings", @"log", @"sh", @"bash", @"zsh", @"hpp"];
    return [textExtensions containsObject:ext];
}

- (BOOL)isImageFile:(NSString *)ext {
    NSArray *imageExtensions = @[@"jpg", @"jpeg", @"png", @"gif", @"bmp", @"tiff", @"webp", @"heic"];
    return [imageExtensions containsObject:ext];
}

- (BOOL)isMediaFile:(NSString *)ext {
    NSArray *mediaExtensions = @[@"mp4", @"mov", @"avi", @"mkv", @"mp3", @"wav", @"aac", @"m4a"];
    return [mediaExtensions containsObject:ext];
}

- (void)openWithSystemApp:(FileItem *)fileItem {
    NSURL *fileURL = [NSURL fileURLWithPath:fileItem.path];
    self.documentController = [UIDocumentInteractionController interactionControllerWithURL:fileURL];
    self.documentController.delegate = self;
    
    if (![self.documentController presentPreviewAnimated:YES]) {
        [self.documentController presentOpenInMenuFromRect:CGRectZero inView:self.view animated:YES];
    }
}

- (void)decompressItem:(FileItem *)fileItem {
    int result = execute_unzip([fileItem.path UTF8String], [self.currentPath UTF8String]);
    
    if (result == 0) {
        [self loadDirectoryContents];
        [self showSuccessAlert:@"解压成功"];
    } else {
        [self showErrorAlert:[NSString stringWithFormat:@"解压失败，错误码: %d", result]];
    }
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

- (void)showCreateMenu {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"创建" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"新建文件夹" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self promptForFolderName];
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"新建文件" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self promptForFileName];
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)showSettings {
    SettingsViewController *settingsVC = [[SettingsViewController alloc] init];
    settingsVC.fileListVC = self;
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:settingsVC];
    [self presentViewController:navController animated:YES completion:nil];
}

- (void)promptForFolderName {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"新建文件夹" message:@"请输入文件夹名称" preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addTextFieldWithConfigurationHandler:nil];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"创建" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSString *folderName = alert.textFields.firstObject.text;
        if (folderName && folderName.length > 0) {
            [self createFolder:folderName];
        }
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)promptForFileName {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"新建文件" message:@"请输入文件名称" preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addTextFieldWithConfigurationHandler:nil];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"创建" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSString *fileName = alert.textFields.firstObject.text;
        if (fileName && fileName.length > 0) {
            [self createFile:fileName];
        }
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)createFolder:(NSString *)folderName {
    NSString *newPath = [self.currentPath stringByAppendingPathComponent:folderName];
    NSError *error;
    
    if ([[NSFileManager defaultManager] createDirectoryAtPath:newPath withIntermediateDirectories:YES attributes:nil error:&error]) {
        [self loadDirectoryContents];
        [self showSuccessAlert:@"文件夹创建成功"];
    } else {
        [self showErrorAlert:[NSString stringWithFormat:@"创建文件夹失败: %@", error.localizedDescription]];
    }
}

- (void)createFile:(NSString *)fileName {
    NSString *newPath = [self.currentPath stringByAppendingPathComponent:fileName];
    
    if ([[NSFileManager defaultManager] createFileAtPath:newPath contents:nil attributes:nil]) {
        [self loadDirectoryContents];
        [self showSuccessAlert:@"文件创建成功"];
    } else {
        [self showErrorAlert:@"创建文件失败"];
    }
}

#pragma mark - 文件操作

- (void)deleteItemAtIndexPath:(NSIndexPath *)indexPath {
    FileItem *fileItem = self.fileItems[indexPath.row];
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"确认删除" 
                                                                   message:[NSString stringWithFormat:@"确定要删除 %@ 吗？", fileItem.name]
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"删除" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        NSError *error;
        if ([[NSFileManager defaultManager] removeItemAtPath:fileItem.path error:&error]) {
            [self.fileItems removeObjectAtIndex:indexPath.row];
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            [self showSuccessAlert:@"删除成功"];
        } else {
            [self showErrorAlert:[NSString stringWithFormat:@"删除失败: %@", error.localizedDescription]];
        }
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)renameItem:(FileItem *)item toName:(NSString *)newName {
    NSString *newPath = [[item.path stringByDeletingLastPathComponent] stringByAppendingPathComponent:newName];
    NSError *error;
    
    if ([[NSFileManager defaultManager] moveItemAtPath:item.path toPath:newPath error:&error]) {
        [self loadDirectoryContents];
        [self showSuccessAlert:@"重命名成功"];
    } else {
        [self showErrorAlert:[NSString stringWithFormat:@"重命名失败: %@", error.localizedDescription]];
    }
}

- (void)compressItem:(FileItem *)item {
    NSString *destPath = [self.currentPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.zip", item.name]];
    int result = [FileOperations zipItemAtPath:item.path toPath:destPath isDirectory:item.isDirectory];
    
    if (result == 0) {
        [self loadDirectoryContents];
        [self showSuccessAlert:@"压缩成功"];
    } else {
        [self showErrorAlert:[NSString stringWithFormat:@"压缩失败，错误码: %d", result]];
    }
}

#pragma mark - 文件查看器

- (void)openImageBrowser:(FileItem *)fileItem {
    ImageViewController *imageVC = [[ImageViewController alloc] init];
    imageVC.filePath = fileItem.path;
    imageVC.title = fileItem.name;
    [self.navigationController pushViewController:imageVC animated:YES];
}

- (void)openPDFViewer:(FileItem *)fileItem {
    PDFViewController *pdfVC = [[PDFViewController alloc] init];
    pdfVC.filePath = fileItem.path;
    pdfVC.title = fileItem.name;
    [self.navigationController pushViewController:pdfVC animated:YES];
}

- (void)openMediaPlayer:(FileItem *)fileItem {
    MediaViewController *mediaVC = [[MediaViewController alloc] init];
    mediaVC.filePath = fileItem.path;
    mediaVC.title = fileItem.name;
    [self.navigationController pushViewController:mediaVC animated:YES];
}

- (void)openHexEditor:(FileItem *)fileItem {
    HexEditorViewController *hexVC = [[HexEditorViewController alloc] init];
    hexVC.filePath = fileItem.path;
    hexVC.title = fileItem.name;
    [self.navigationController pushViewController:hexVC animated:YES];
}

- (void)openTextEditor:(FileItem *)fileItem {
    TextEditorViewController *textEditor = [[TextEditorViewController alloc] init];
    textEditor.filePath = fileItem.path;
    textEditor.title = fileItem.name;
    [self.navigationController pushViewController:textEditor animated:YES];
}

/*
- (void)openTextEditor:(FileItem *)fileItem {
    NSString *content = [NSString stringWithContentsOfFile:fileItem.path encoding:NSUTF8StringEncoding error:nil];
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:fileItem.name 
                                                                   message:@"文本内容" 
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(10, 50, 250, 150)];
    textView.text = content ?: @"";
    [alert.view addSubview:textView];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"保存" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSError *error;
        if ([textView.text writeToFile:fileItem.path atomically:YES encoding:NSUTF8StringEncoding error:&error]) {
            [self showSuccessAlert:@"保存成功"];
        } else {
            [self showErrorAlert:[NSString stringWithFormat:@"保存失败: %@", error.localizedDescription]];
        }
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    
    alert.preferredContentSize = CGSizeMake(300, 250);
    
    [self presentViewController:alert animated:YES completion:nil];
}
*/

- (void)showFilePermissions:(FileItem *)fileItem {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"文件信息" 
                                                                   message:[NSString stringWithFormat:@"名称: %@\n路径: %@\n大小: %llu bytes\n权限: %@\n修改时间: %@", 
                                                                            fileItem.name, fileItem.path, fileItem.fileSize, fileItem.permissions, fileItem.modificationDate]
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)manageFilePermissions:(FileItem *)fileItem {
    FilePermissionsViewController *permissionVC = [[FilePermissionsViewController alloc] init];
    permissionVC.fileItem = fileItem;
    permissionVC.filePath = fileItem.path;
    [self.navigationController pushViewController:permissionVC animated:YES];
}

#pragma mark - 上下文菜单 (iOS 13+)

- (UIContextMenuConfiguration *)tableView:(UITableView *)tableView contextMenuConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath point:(CGPoint)point {
    FileItem *fileItem = self.fileItems[indexPath.row];
    
    return [UIContextMenuConfiguration configurationWithIdentifier:nil previewProvider:nil actionProvider:^UIMenu * _Nullable(NSArray<UIMenuElement *> * _Nonnull suggestedActions) {
        
        // 創建操作菜單
        UIAction *viewPermissionAction = [UIAction actionWithTitle:@"查看權限" image:[UIImage systemImageNamed:@"info.circle"] identifier:nil handler:^(__kindof UIAction * _Nonnull action) {
            [self showFilePermissions:fileItem];
        }];
        
        UIAction *managePermissionAction = [UIAction actionWithTitle:@"權限管理" image:[UIImage systemImageNamed:@"lock"] identifier:nil handler:^(__kindof UIAction * _Nonnull action) {
            [self manageFilePermissions:fileItem];
        }];
        
        UIAction *renameAction = [UIAction actionWithTitle:@"重命名" image:[UIImage systemImageNamed:@"pencil"] identifier:nil handler:^(__kindof UIAction * _Nonnull action) {
            [self promptForRename:fileItem];
        }];
        
        UIAction *compressAction = [UIAction actionWithTitle:@"压缩" image:[UIImage systemImageNamed:@"archivebox"] identifier:nil handler:^(__kindof UIAction * _Nonnull action) {
            [self compressItem:fileItem];
        }];
        
        UIAction *deleteAction = [UIAction actionWithTitle:@"删除" image:[UIImage systemImageNamed:@"trash"] identifier:nil handler:^(__kindof UIAction * _Nonnull action) {
            [self deleteItemAtIndexPath:indexPath];
        }];
        deleteAction.attributes = UIMenuElementAttributesDestructive;
        
        NSMutableArray *actions = [NSMutableArray arrayWithArray:@[
            viewPermissionAction, 
            managePermissionAction, 
            renameAction, 
            compressAction, 
            deleteAction
        ]];
        
        // 如果是zip文件，添加解压操作
        if ([fileItem.name hasSuffix:@".zip"]) {
            UIAction *decompressAction = [UIAction actionWithTitle:@"解压缩" image:[UIImage systemImageNamed:@"arrow.up.bin"] identifier:nil handler:^(__kindof UIAction * _Nonnull action) {
                [self decompressItem:fileItem];
            }];
            [actions insertObject:decompressAction atIndex:4];
        }
        
        return [UIMenu menuWithTitle:fileItem.name children:actions];
    }];
}

- (void)promptForRename:(FileItem *)fileItem {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"重命名" message:@"请输入新名称" preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.text = fileItem.name;
    }];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSString *newName = alert.textFields.firstObject.text;
        if (newName && newName.length > 0) {
            [self renameItem:fileItem toName:newName];
        }
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.fileItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FileCell" forIndexPath:indexPath];
    FileItem *fileItem = self.fileItems[indexPath.row];
    
    cell.textLabel.text = fileItem.displayName;
    cell.textLabel.textColor = fileItem.isHidden ? [UIColor lightGrayColor] : [UIColor labelColor];
    
    NSString *sizeString = fileItem.isDirectory ? @"文件夹" : [NSString stringWithFormat:@"%llu bytes", fileItem.fileSize];
    NSString *detailText = [NSString stringWithFormat:@"%@ | 权限: %@", sizeString, fileItem.permissions];
    cell.detailTextLabel.text = detailText;
    
    // 设置图标
    if (fileItem.isDirectory) {
        cell.imageView.image = [UIImage systemImageNamed:fileItem.isHidden ? @"folder.fill" : @"folder"];
        cell.imageView.tintColor = fileItem.isHidden ? [UIColor lightGrayColor] : [UIColor systemBlueColor];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    } else {
        cell.imageView.image = [UIImage systemImageNamed:fileItem.isHidden ? @"doc.fill" : @"doc"];
        cell.imageView.tintColor = fileItem.isHidden ? [UIColor lightGrayColor] : [UIColor labelColor];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    FileItem *fileItem = self.fileItems[indexPath.row];
    [self openFile:fileItem];
}

#pragma mark - UIDocumentInteractionControllerDelegate

- (UIViewController *)documentInteractionControllerViewControllerForPreview:(UIDocumentInteractionController *)controller {
    return self;
}

@end