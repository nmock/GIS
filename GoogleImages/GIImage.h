//
//  GIImage.h
//  GoogleImages
//
//  Created by Nathan Mock on 5/14/15.
//  Copyright (c) 2015 Nathan Mock. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface GIImage : NSObject

@property (nonatomic, strong) NSString *uniqueID;

// full sized images
@property (nonatomic, strong) NSURL *URL;
@property (nonatomic, assign) NSInteger height;
@property (nonatomic, assign) NSInteger width;


// thumbnails
@property (nonatomic, strong) NSURL *thumbnailURL;
@property (nonatomic, assign) NSInteger thumbnailHeight;
@property (nonatomic, assign) NSInteger thumbnailWidth;

@property (nonatomic, assign) CGSize normalizedThumbnailSize;

- (instancetype)initWithResultsData:(NSDictionary*)resultsData NS_DESIGNATED_INITIALIZER;
- (void)invalidateLayoutCalculations;
@end
