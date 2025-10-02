// FavoritesManager.h
#import <Foundation/Foundation.h>

@interface FavoritesManager : NSObject

+ (instancetype)sharedManager;

- (void)addFavoriteWithPath:(NSString *)path name:(NSString *)name;
- (void)removeFavoriteWithPath:(NSString *)path;
- (void)removeFavoriteWithName:(NSString *)name;
- (NSDictionary *)getFavorites;
- (BOOL)isFavoritePath:(NSString *)path;

@end