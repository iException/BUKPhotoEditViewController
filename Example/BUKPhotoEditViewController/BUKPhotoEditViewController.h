//
//  ViewController.h
//  BUKPhotoEditViewController
//
//  Created by lazy on 15/10/27.
//  Copyright © 2015年 lazy. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BUKPhotoEditViewController;

@protocol BUKPhotoEditViewControllerDelegate <NSObject>

- (void)photoEditViewController:(BUKPhotoEditViewController *)controller didFinishEditingPhoto:(UIImage *)photo;
- (void)photoEditViewControllerDidCancelEditingPhoto:(BUKPhotoEditViewController *)controller;

@end

@interface BUKPhotoEditViewController : UIViewController

- (instancetype)initWithPhoto:(UIImage *)photo;

@property (weak, nonatomic) id<BUKPhotoEditViewControllerDelegate> delegate;

@end

