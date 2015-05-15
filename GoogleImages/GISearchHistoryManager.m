//
//  GISearchHistoryManager.m
//  GoogleImages
//
//  Created by Nathan Mock on 5/14/15.
//  Copyright (c) 2015 Nathan Mock. All rights reserved.
//

#import "GISearchHistoryManager.h"

@interface GISearchHistoryManager ()
@property (nonatomic, assign) BOOL cacheInvalid;
@property (nonatomic, strong) NSString *diskPath;
@end

@implementation GISearchHistoryManager
@synthesize recentSearches = _recentSearches;
+ (instancetype)sharedManager {
    static dispatch_once_t pred;
    static GISearchHistoryManager *shared = nil;
    
    dispatch_once(&pred, ^{
        shared = [[self alloc] init];
    });
    
    return shared;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _cacheInvalid = YES;

        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *docPath = [paths objectAtIndex:0];
        _diskPath = [docPath stringByAppendingPathComponent:@"GI-RecentSearches.plist"];
    }
    
    return self;
}

- (void)addSearchQuery:(NSString*)searchQuery {
    if (!searchQuery) {
        return;
    }
    
    NSMutableArray *recentSearchesCopy = [self.recentSearches mutableCopy];

    if ([recentSearchesCopy containsObject:searchQuery]) {
        [recentSearchesCopy removeObject:searchQuery];
    }
    
    [recentSearchesCopy addObject:searchQuery];
    _recentSearches = recentSearchesCopy;
    
    [self saveChanges];
    
    _cacheInvalid = YES; //invalidate cache
}

- (void)removeSearchQuery:(NSString*)searchQuery {
    NSMutableArray *recentSearchesCopy = [self.recentSearches mutableCopy];

    if (![recentSearchesCopy containsObject:searchQuery]) {
        NSLog(@"%@ not found", searchQuery);
        return;
    }
    else {
        [recentSearchesCopy removeObject:searchQuery];
    }
    
    _recentSearches = recentSearchesCopy;
    
    [self saveChanges];
    
    self.cacheInvalid = YES; //invalidate cache
}

- (NSArray*)recentSearches {
    if (_cacheInvalid) {
        BOOL existsAtPath;
        NSMutableArray *emptyArray = [[NSMutableArray alloc] init];
        
        // create new file if it doesn't exist
        if (![[NSFileManager defaultManager] fileExistsAtPath:_diskPath isDirectory:&existsAtPath] && !existsAtPath) {
            _recentSearches = emptyArray;
            
            [self saveChanges];
        }
        else {
            // retrieve plist
            NSArray *unarchivedArray = [NSKeyedUnarchiver unarchiveObjectWithFile:_diskPath];
            
            if (!unarchivedArray){
                NSLog(@"Error reading %@", _diskPath);
            }
            
            _recentSearches = unarchivedArray ? unarchivedArray : emptyArray;
        }
        
        _cacheInvalid = NO;
    }
    
    return [[_recentSearches reverseObjectEnumerator] allObjects];
}

- (BOOL)saveChanges {
    NSError *error;
    
    NSData *urlData = [NSKeyedArchiver archivedDataWithRootObject:_recentSearches];
    BOOL success = [urlData writeToFile:_diskPath options:0 error:&error];
    
    if (!success) {
        NSLog(@"Error saving changes to %@ with error %@", self.diskPath, error);
    }
    
    return success;
}

@end
