//
//  BUKPhotoFiltersScrollView.h
//  BUKPhotoEditViewController
//
//  Created by Lazy on 1/14/16.
//  Copyright © 2016 lazy. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BUKPhotoFiltersScrollView;
@class BUKPhotoFilterView;

@protocol BUKPhotoFiltersDataSource <NSObject>

@required

- (NSInteger)buk_numberOfFiltersInPhotoFiltersScrollView:(BUKPhotoFiltersScrollView *)photoFiltersScrollView;
- (BUKPhotoFilterView *)buk_photoFiltersScrollView:(BUKPhotoFiltersScrollView *)photoFiltersScrollView filterViewAtIndex:(NSInteger)index;

@end

@protocol BUKPhotoFiltersDelegate <NSObject>

- (void)buk_photoFiltersScrollView:(BUKPhotoFiltersScrollView *)photoFiltersScrollView didSelectPhotoFilterAtIndex:(NSInteger)index;

@end

@interface BUKPhotoFiltersScrollView : UIScrollView

@property (nonatomic, weak) id<BUKPhotoFiltersDataSource> dataSource;
@property (nonatomic, weak) id<BUKPhotoFiltersDelegate> filtersDelegate;

- (void)reloadData;
- (UIImage *)filteredImageAtIndex:(NSInteger)index;

@end
