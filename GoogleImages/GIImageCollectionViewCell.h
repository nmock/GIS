//
//  GIImageCollectionViewCell.h
//  GoogleImages
//
//  Created by Nathan Mock on 5/14/15.
//  Copyright (c) 2015 Nathan Mock. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GIImage.h"

@interface GIImageCollectionViewCell : UICollectionViewCell
- (void)updateWithImage:(GIImage*)gImage;
@end
