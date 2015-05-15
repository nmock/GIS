//
//  GIImagesManager.m
//  GoogleImages
//
//  Created by Nathan Mock on 5/13/15.
//  Copyright (c) 2015 Nathan Mock. All rights reserved.
//

#import "GIImagesManager.h"
#import <AFNetworking/AFHTTPRequestOperationManager.h>
#import "GIConstants.h"

@interface GIImagesManager()
@property (nonatomic, strong) AFHTTPRequestOperationManager *operationManager;
@property (nonatomic, assign) int currentPage;
@property (nonatomic, strong) AFHTTPRequestOperation *currentOperation;
@end

@implementation GIImagesManager

+ (instancetype)sharedManager {
    static dispatch_once_t pred;
    static GIImagesManager *shared = nil;
    
    dispatch_once(&pred, ^{
        shared = [[self alloc] init];
    });
    
    return shared;
}

- (instancetype)init {
    self = [super init];
    
    if (self) {
        _operationManager = [[AFHTTPRequestOperationManager alloc] init];
        _operationManager.requestSerializer = [AFJSONRequestSerializer serializer];
        _currentPage = 0;
    }
    
    return self;
}

- (void)getImagesForQuery:(NSString*)query success:(GIBlock)success failure:(GIFailureBlock)failure {
    if (![_currentQuery isEqualToString:query]) {
        [self cancelCurrentOperation];
        [self clearAllResults];
    }
    else if (self.endReached) {
        if (failure) {
            failure(nil);
        }
        
        return;
    }
    
    NSDictionary *parameters = @{@"v" : @"1.0",
                                 @"rsz" : [NSNumber numberWithInt:GI_RESULTS_PER_PAGE],
                                 @"q" : query,
                                 @"start" : [NSNumber numberWithInt:GI_RESULTS_PER_PAGE * _currentPage]};
    
    _currentOperation = [_operationManager GET:GI_IMAGE_SEARCH_URL parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *responseDict = responseObject;
        NSNumber *responseStatusCode = [responseDict objectForKey:@"responseStatus"];
        NSString *responseDetails = [responseDict objectForKey:@"responseDetails"];
        
        if ([responseStatusCode isEqualToNumber:@200]) {
            NSArray *imageResultsData = [[responseDict objectForKey:@"responseData"] objectForKey:@"results"];
            
            if (![_currentQuery isEqualToString:query]) {
                [self clearAllResults];
            }
            
            _currentPage++;
            _currentQuery = query;
            
            NSMutableArray *gImages = [[NSMutableArray alloc] initWithArray:self.images];
            
            for (NSDictionary *imageResult in imageResultsData) {
                GIImage *gImage = [[GIImage alloc] initWithResultsData:imageResult];
                [gImages addObject:gImage];
            }
            
            _images = gImages;
            
            if (success) {
                success();
            }
        }
        else if ([responseStatusCode isEqualToNumber:@400] && [responseDetails isEqualToString:@"out of range start"]){
            _endReached = YES;
            
            if (failure) {
                failure(nil);
            }
        }
        else {
            // ideally, would pass error into failure block and handle in vc
            NSLog(@"API Error: %@", responseDetails);
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"API Error"
                                                            message:responseDetails
                                                           delegate:nil cancelButtonTitle:nil
                                                  otherButtonTitles:@"OK", nil];
            [alert show];
            
            _endReached = YES;
            
            if (failure) {
                failure(nil);
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        // TODO: handle error
        
        if (failure) {
            failure(error);
        }
    }];
}

- (void)getNextPage:(GIBlock)success failure:(GIFailureBlock)failure {
    [self getImagesForQuery:_currentQuery success:success failure:failure];
}

- (void)cancelCurrentOperation {
    [_currentOperation cancel];
}

- (void)clearAllResults {
    _endReached = NO;
    _currentPage = 0;
    _currentQuery = nil;
    _images = nil;
}
@end
