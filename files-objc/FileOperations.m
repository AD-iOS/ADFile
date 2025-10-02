// FileOperations.m
#import "FileOperations.h"

@implementation FileOperations

+ (int)zipItemAtPath:(NSString *)sourcePath toPath:(NSString *)destPath isDirectory:(BOOL)isDirectory {
    return execute_zip(isDirectory ? 1 : 0, [sourcePath UTF8String], [destPath UTF8String]);
}

+ (int)unzipItemAtPath:(NSString *)zipPath toPath:(NSString *)extractPath {
    return execute_unzip([zipPath UTF8String], [extractPath UTF8String]);
}

+ (int)changePermissions:(NSString *)mode forPath:(NSString *)path {
    return execute_chmod([mode UTF8String], [path UTF8String]);
}

+ (int)changeOwner:(NSString *)ownerGroup forPath:(NSString *)path {
    return execute_chown([ownerGroup UTF8String], [path UTF8String]);
}

+ (int)createDirectory:(NSString *)path {
    return execute_mkdir([path UTF8String]);
}

+ (int)createFile:(NSString *)path {
    return execute_touch([path UTF8String]);
}

+ (int)removeItem:(NSString *)path {
    return execute_rm([path UTF8String]);
}

+ (int)moveItem:(NSString *)sourcePath toPath:(NSString *)destPath {
    return execute_mv([sourcePath UTF8String], [destPath UTF8String]);
}

@end