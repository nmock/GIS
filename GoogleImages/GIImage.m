//
//  GIImage.m
//  GoogleImages
//
//  Created by Nathan Mock on 5/14/15.
//  Copyright (c) 2015 Nathan Mock. All rights reserved.
//

#import "GIImage.h"
#import "UIView+ViewHelpers.h"
#import "GIConstants.h"

@implementation GIImage
- (instancetype)initWithResultsData:(NSDictionary*)resultsData {
    self = [super init];
    
    if (self) {        
        self.uniqueID = [resultsData objectForKey:@"imageId"];
        
        self.URL = [NSURL URLWithString:[resultsData objectForKey:@"url"]];
        self.height = [[resultsData objectForKey:@"height"] integerValue];
        self.width = [[resultsData objectForKey:@"width"] integerValue];
        
        self.thumbnailURL = [NSURL URLWithString:[resultsData objectForKey:@"tbUrl"]];
        self.thumbnailHeight = [[resultsData objectForKey:@"tbHeight"] integerValue];
        self.thumbnailWidth = [[resultsData objectForKey:@"tbWidth"] integerValue];
        
        self.normalizedThumbnailSize = CGSizeZero;
    }
    
    return self;
}

- (CGSize)normalizedThumbnailSize {
    if (CGSizeEqualToSize(_normalizedThumbnailSize, CGSizeZero)) {
        CGFloat normalizedWidth = ([UIView screenSize].width - (GI_PADDING * (GI_COLUMNS + 1))) / GI_COLUMNS;
        CGFloat normalizedHeight;
        
        if (normalizedWidth > self.thumbnailWidth) {
            normalizedHeight = (self.thumbnailWidth / normalizedWidth) * self.thumbnailHeight;
        }
        else {
            normalizedHeight = (normalizedWidth / self.thumbnailWidth) * self.thumbnailHeight;
        }
        
        _normalizedThumbnailSize = CGSizeMake(round(normalizedWidth), round(normalizedHeight));
    }
    
    return _normalizedThumbnailSize;
}

- (void)invalidateLayoutCalculations {
    _normalizedThumbnailSize = CGSizeZero;
}
@end
