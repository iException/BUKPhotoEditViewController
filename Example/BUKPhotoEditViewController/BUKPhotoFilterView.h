//
//  BUKPhotoFilterView.h
//  BUKPhotoEditViewController
//
//  Created by Lazy on 1/14/16.
//  Copyright © 2016 lazy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BUKPhotoFilterView : UIView

- (instancetype)initWithPhoto:(UIImage *)photo name:(NSString *)name filter:(CIFilter *)filter;

- (void)generateFilter;
- (UIImage *)filteredImage;

@end
