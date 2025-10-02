// FileListViewController.h
#import <UIKit/UIKit.h>
#import "TextEditorViewController.h"
@class FileItem;

@interface FileListViewController : UITableViewController

@property (nonatomic, strong) NSString *currentPath;
@property (nonatomic, assign) BOOL showHiddenFiles;
@property (nonatomic, strong) NSMutableArray *fileItems;

- (instancetype)initWithPath:(NSString *)path;
- (void)loadDirectoryContents;
- (void)showErrorAlert:(NSString *)message;
- (void)showSuccessAlert:(NSString *)message;

// 文件操作相关方法
- (void)createFolder:(NSString *)folderName;
- (void)createFile:(NSString *)fileName;
- (void)deleteItemAtIndexPath:(NSIndexPath *)indexPath;
- (void)renameItem:(FileItem *)item toName:(NSString *)newName;
- (void)compressItem:(FileItem *)item;
- (void)decompressItem:(FileItem *)item;

// 文件查看器相关
// - (void)openTextEditor:(FileItem *)fileItem;
- (void)openImageBrowser:(FileItem *)fileItem;
- (void)openPDFViewer:(FileItem *)fileItem;
- (void)openMediaPlayer:(FileItem *)fileItem;
- (void)openHexEditor:(FileItem *)fileItem;
- (void)openTextEditor:(FileItem *)fileItem;

@end