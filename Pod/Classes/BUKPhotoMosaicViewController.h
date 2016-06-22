//
//  BUKPhotoMosaicViewController.h
//  BUKPhotoEditViewController
//
//  Created by lazy on 15/10/27.
//  Copyright © 2015年 lazy. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BUKPhotoMosaicViewController;

@protocol BUKPhotoMosaicViewControllerDelegate <NSObject>

- (void)photoMosaicViewController:(BUKPhotoMosaicViewController *)controller didFinishEditingPhoto:(UIImage *)photo;
- (void)photoMosaicViewControllerDidCancelEditingPhoto:(BUKPhotoMosaicViewController *)controller;

@end


@interface BUKPhotoMosaicViewController : UIViewController

- (instancetype)initWithPhoto:(UIImage *)photo;

@property (weak, nonatomic) id<BUKPhotoMosaicViewControllerDelegate> delegate;

@end
