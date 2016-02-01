//
//  UIImage+BXOperation.h
//  Baixing
//
//  Created by phoebus on 11/11/14.
//  Copyright (c) 2014 baixing. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Crop)

- (UIImage *)imageCroppedToSize:(CGSize)size;
- (UIImage *)thumbnailWithSize:(CGSize)size;
+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize;
- (UIImage *)crop:(CGRect)rect;

@end
