//
//  GIImageSearchViewController.h
//  GoogleImages
//
//  Created by Nathan Mock on 5/13/15.
//  Copyright (c) 2015 Nathan Mock. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CHTCollectionViewWaterfallLayout/CHTCollectionViewWaterfallLayout.h>

@interface GIImageSearchViewController : UIViewController <UITextFieldDelegate, UICollectionViewDataSource, UICollectionViewDelegate, CHTCollectionViewDelegateWaterfallLayout, UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate>

@end

