//
//  BUKPhotoFiltersScrollView.m
//  BUKPhotoEditViewController
//
//  Created by Lazy on 1/14/16.
//  Copyright © 2016 lazy. All rights reserved.
//

#import "BUKPhotoFiltersScrollView.h"
#import "BUKPhotoFilterView.h"

#define FILTER_VIEW_TAG 4000
#define SCREEN_FACTOR [UIScreen mainScreen].bounds.size.width/414.0

@interface BUKPhotoFiltersScrollView ()

@property (nonatomic, strong) UIImage *image;

@end

@implementation BUKPhotoFiltersScrollView

const static CGFloat kFiltersHorizontalPadding = 7.0f;
const static CGFloat kFiltersVerticalPadding = 15.0f;
const static CGFloat kFiltersLeadingMargin = 18.0f;
const static CGFloat kFilterItemWidth = 70.0f;

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:CGRectZero];
    if (self) {
        [self reloadData];
    }
    return self;
}

- (void)reloadData
{
    NSInteger count = [self filtersCount];
    
    if (count <= 0) {
        return;
    }
    
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    NSInteger index = 0;
    while (index < count) {
        BUKPhotoFilterView *filterView = [self.dataSource buk_photoFiltersScrollView:self filterViewAtIndex:index];
        filterView.tag = FILTER_VIEW_TAG + index;
        [self addSubview:filterView];
        
        filterView.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
        [filterView addGestureRecognizer:tap];
        
        BUKPhotoFilterView *lastFilterView = [self viewWithTag:FILTER_VIEW_TAG + index - 1];
        
        if (!lastFilterView) {
            [filterView setFrame:CGRectMake(kFiltersLeadingMargin * SCREEN_FACTOR, kFiltersVerticalPadding * SCREEN_FACTOR, kFilterItemWidth * SCREEN_FACTOR, self.frame.size.height - 2 * kFiltersVerticalPadding * SCREEN_FACTOR)];
        } else {
            [filterView setFrame:CGRectMake((kFiltersLeadingMargin + index * (kFiltersHorizontalPadding + kFilterItemWidth)) * SCREEN_FACTOR, kFiltersVerticalPadding * SCREEN_FACTOR, kFilterItemWidth * SCREEN_FACTOR, self.frame.size.height - 2 * kFiltersVerticalPadding * SCREEN_FACTOR)];
        }
        
        [filterView generateFilter];
        index++;
    }
    
    [self setContentSize:CGSizeMake((kFiltersLeadingMargin * 2 + (count - 1) * kFiltersHorizontalPadding + count * kFilterItemWidth) * SCREEN_FACTOR, self.frame.size.height * SCREEN_FACTOR)];
}

- (NSInteger)filtersCount
{
    if ([self.dataSource respondsToSelector:@selector(buk_numberOfFiltersInPhotoFiltersScrollView:)]) {
        return [self.dataSource buk_numberOfFiltersInPhotoFiltersScrollView:self];
    }
    return 0;
}

- (UIImage *)filteredImageAtIndex:(NSInteger)index
{
    BUKPhotoFilterView *filterView = [self viewWithTag:FILTER_VIEW_TAG + index];
    return (filterView) ? [filterView filteredImage] : nil;
}

#pragma mark - event handler -

- (void)handleTap:(UITapGestureRecognizer *)tap
{
    UIView *filterView = tap.view;
    if ([filterView isKindOfClass:[BUKPhotoFilterView class]] && [self.filtersDelegate respondsToSelector:@selector(buk_photoFiltersScrollView:didSelectPhotoFilterAtIndex:)]) {
        NSInteger index = filterView.tag - FILTER_VIEW_TAG;
        [self.filtersDelegate buk_photoFiltersScrollView:self didSelectPhotoFilterAtIndex:index];
    }
}

@end
