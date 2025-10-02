// FileOperations.h
#import <Foundation/Foundation.h>

// C 函数声明
int execute_zip(int is_directory, const char* source, const char* dest);
int execute_unzip(const char* zip_path, const char* extract_path);
int execute_chmod(const char* mode, const char* path);
int execute_chown(const char* owner_group, const char* path);
int execute_mkdir(const char* path);
int execute_touch(const char* path);
int execute_rm(const char* path);
int execute_mv(const char* source, const char* dest);

@interface FileOperations : NSObject

// Objective-C 包装方法
+ (int)zipItemAtPath:(NSString *)sourcePath toPath:(NSString *)destPath isDirectory:(BOOL)isDirectory;
+ (int)unzipItemAtPath:(NSString *)zipPath toPath:(NSString *)extractPath;
+ (int)changePermissions:(NSString *)mode forPath:(NSString *)path;
+ (int)changeOwner:(NSString *)ownerGroup forPath:(NSString *)path;
+ (int)createDirectory:(NSString *)path;
+ (int)createFile:(NSString *)path;
+ (int)removeItem:(NSString *)path;
+ (int)moveItem:(NSString *)sourcePath toPath:(NSString *)destPath;

@end