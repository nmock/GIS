//
//  GISearchHistoryManager.h
//  GoogleImages
//
//  Created by Nathan Mock on 5/14/15.
//  Copyright (c) 2015 Nathan Mock. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GISearchHistoryManager : NSObject

@property (nonatomic, strong, readonly) NSArray *recentSearches;

+ (instancetype)sharedManager;
- (void)addSearchQuery:(NSString*)searchQuery;
- (void)removeSearchQuery:(NSString*)searchQuery;
@end
