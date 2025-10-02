// FavoritesManager.m
#import "FavoritesManager.h"

@implementation FavoritesManager

+ (instancetype)sharedManager {
    static FavoritesManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (void)addFavoriteWithPath:(NSString *)path name:(NSString *)name {
    NSMutableDictionary *favorites = [[[NSUserDefaults standardUserDefaults] dictionaryForKey:@"favoriteDirectories"] mutableCopy];
    if (!favorites) {
        favorites = [NSMutableDictionary dictionary];
    }
    favorites[name] = path;
    [[NSUserDefaults standardUserDefaults] setObject:favorites forKey:@"favoriteDirectories"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)removeFavoriteWithPath:(NSString *)path {
    NSMutableDictionary *favorites = [[[NSUserDefaults standardUserDefaults] dictionaryForKey:@"favoriteDirectories"] mutableCopy];
    if (favorites) {
        NSString *keyToRemove = nil;
        for (NSString *key in favorites) {
            if ([favorites[key] isEqualToString:path]) {
                keyToRemove = key;
                break;
            }
        }
        if (keyToRemove) {
            [favorites removeObjectForKey:keyToRemove];
            [[NSUserDefaults standardUserDefaults] setObject:favorites forKey:@"favoriteDirectories"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }
}

- (void)removeFavoriteWithName:(NSString *)name {
    NSMutableDictionary *favorites = [[[NSUserDefaults standardUserDefaults] dictionaryForKey:@"favoriteDirectories"] mutableCopy];
    if (favorites) {
        [favorites removeObjectForKey:name];
        [[NSUserDefaults standardUserDefaults] setObject:favorites forKey:@"favoriteDirectories"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (NSDictionary *)getFavorites {
    return [[NSUserDefaults standardUserDefaults] dictionaryForKey:@"favoriteDirectories"] ?: @{};
}

- (BOOL)isFavoritePath:(NSString *)path {
    NSDictionary *favorites = [self getFavorites];
    return [[favorites allValues] containsObject:path];
}

@end