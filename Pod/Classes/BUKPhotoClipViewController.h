//
//  BUKPhotoClipViewController.h
//  BUKPhotoEditViewController
//
//  Created by lazy on 15/10/27.
//  Copyright © 2015年 lazy. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BUKPhotoClipViewController;

@protocol BUKPhotoClipViewControllerDelegate <NSObject>

- (void)photoClipViewController:(BUKPhotoClipViewController *)controller didFinishEditingPhoto:(UIImage *)photo;
- (void)photoClipViewControllerDidCancelEditingPhoto:(BUKPhotoClipViewController *)controller;

@end

@interface BUKPhotoClipViewController : UIViewController

- (instancetype)initWithPhoto:(UIImage *)photo;

@property (weak, nonatomic) id<BUKPhotoClipViewControllerDelegate> delegate;

@end
