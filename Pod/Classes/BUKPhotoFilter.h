//
//  BUKPhotoFilter.h
//  BUKPhotoEditViewController
//
//  Created by Lazy on 1/22/16.
//  Copyright © 2016 lazy. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface BUKPhotoFilter : NSObject

+ (UIImage *)filterImageWithImage:(UIImage *)image filter:(CIFilter *)filter;

@end
