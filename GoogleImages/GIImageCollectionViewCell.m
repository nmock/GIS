//
//  GIImageCollectionViewCell.m
//  GoogleImages
//
//  Created by Nathan Mock on 5/14/15.
//  Copyright (c) 2015 Nathan Mock. All rights reserved.
//

#import "GIImageCollectionViewCell.h"
#import <AFNetworking/UIImageView+AFNetworking.h>
#import "UIColor+BFKit.h"
#import "UIColor+LightAndDark.h"
#import "UIView+ViewHelpers.h"

@interface GIImageCollectionViewCell ()
@property (nonatomic, weak) GIImage *gImage;
@property (nonatomic, strong) UIImageView *imageView;
@end

@implementation GIImageCollectionViewCell
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        self.imageView = [[UIImageView alloc] init];
        self.imageView.layer.cornerRadius = 2.0;
        self.imageView.layer.masksToBounds = YES;
        [self addSubview:self.imageView];
    }
    
    return self;
}

- (void)updateWithImage:(GIImage*)gImage {
    self.gImage = gImage;
    
    self.imageView.size = gImage.normalizedThumbnailSize;
    [self.imageView setImageWithURL:gImage.thumbnailURL placeholderImage:[[UIColor colorWithHexString:@"9B989A"] imageFromColor]];
}

@end
