//
//  GIImagesManager.h
//  GoogleImages
//
//  Created by Nathan Mock on 5/13/15.
//  Copyright (c) 2015 Nathan Mock. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GIImage.h"

typedef void (^GIBlock)(void);
typedef void (^GIFailureBlock)(NSError *error);


@interface GIImagesManager : NSObject

@property (nonatomic, strong) NSArray *images;
@property (nonatomic, assign) BOOL endReached;
@property (nonatomic, strong, readonly) NSString *currentQuery;

+ (instancetype)sharedManager;
- (void)getImagesForQuery:(NSString*)query success:(GIBlock)success failure:(GIFailureBlock)failure;
- (void)getNextPage:(GIBlock)success failure:(GIFailureBlock)failure;
- (void)cancelCurrentOperation;
- (void)clearAllResults;
@end
