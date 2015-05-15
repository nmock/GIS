//
//  UIColor+LightAndDark.h
//  MetaReader
//
//  Created by Nathan Mock on 1/18/15.
//  Copyright (c) 2015 Nathan Mock. All rights reserved.
//
//  http://stackoverflow.com/a/11598127/349238

#import <UIKit/UIKit.h>

@interface UIColor (LightAndDark)
- (UIColor *)lighterColor;
- (UIColor *)darkerColor;
- (UIImage*)imageFromColor;
@end
