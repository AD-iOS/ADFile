// FileItem.m
#import "FileItem.h"
#import <sys/stat.h>

@implementation FileItem

- (instancetype)initWithPath:(NSString *)path {
    self = [super init];
    if (self) {
        _path = path;
        _name = [path lastPathComponent];
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        BOOL isDir;
        [fileManager fileExistsAtPath:path isDirectory:&isDir];
        _isDirectory = isDir;
        
        NSError *error;
        NSDictionary *attributes = [fileManager attributesOfItemAtPath:path error:&error];
        if (!error) {
            _fileSize = [attributes[NSFileSize] unsignedLongLongValue];
            _modificationDate = attributes[NSFileModificationDate];
        } else {
            _fileSize = 0;
            _modificationDate = [NSDate date];
        }
        
        _permissions = [self getFilePermissions:path];
        _isHidden = [_name hasPrefix:@"."];
    }
    return self;
}

- (NSString *)getFilePermissions:(NSString *)path {
    struct stat statInfo;
    if (stat([path UTF8String], &statInfo) == 0) {
        mode_t permissions = statInfo.st_mode & 0777;
        return [NSString stringWithFormat:@"%o", permissions];
    }
    return @"755";
}

- (NSString *)displayName {
    return self.isHidden ? [NSString stringWithFormat:@"%@ (隐藏)", self.name] : self.name;
}

@end