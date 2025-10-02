// FileItem.h
#import <Foundation/Foundation.h>

@interface FileItem : NSObject

@property (nonatomic, strong) NSString *path;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, assign) BOOL isDirectory;
@property (nonatomic, assign) unsigned long long fileSize;
@property (nonatomic, strong) NSDate *modificationDate;
@property (nonatomic, strong) NSString *permissions;
@property (nonatomic, assign) BOOL isHidden;

- (instancetype)initWithPath:(NSString *)path;
- (NSString *)displayName;

@end