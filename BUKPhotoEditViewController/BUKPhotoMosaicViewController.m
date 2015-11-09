//
//  BUKPhotoMosaicViewController.m
//  BUKPhotoEditViewController
//
//  Created by lazy on 15/10/27.
//  Copyright © 2015年 lazy. All rights reserved.
//

#import "BUKPhotoMosaicViewController.h"
#import "LCMosaicImageView.h"
#import "UIColor+hex.h"

@interface BUKPhotoMosaicViewController () <LCMosaicImageViewDelegate>

@property (nonatomic, strong) LCMosaicImageView *photoView;
@property (nonatomic, strong) UIImage *lastMosaicImage;

@property (nonatomic, strong) UIButton *undoButton;
@property (nonatomic, strong) UIButton *redoButton;
@property (nonatomic, strong) UIButton *strokeSmallButton;
@property (nonatomic, strong) UIButton *strokeMediumButton;
@property (nonatomic, strong) UIButton *strokeLargeButton;

@property (nonatomic, strong) UILabel *strokeLabel;
@property (nonatomic, strong) UILabel *undoLabel;
@property (nonatomic, strong) UILabel *redoLabel;

@property (nonatomic, strong) UIButton *lastSelectedButton;

@end

@implementation BUKPhotoMosaicViewController

static const CGFloat kButtonToBottomPadding = 83.0f;
static const CGFloat kLabelToBottomPadding = 25.0f;
static const CGFloat kButtonBaseWidth = 40.0f;
static const CGFloat kPortraitPhotoPadding = 200.0f;
static const CGFloat kLabelBaseWidth = 60.0f;
static const CGFloat kDefaultFontSize = 14.0f;
static const CGFloat kStrokeButtonBasedWidth = 18.0f;

#pragma mark - initializer -

- (instancetype)initWithPhoto:(UIImage *)photo
{
    self = [super init];
    if (self) {
        [self setupViewsWithPhoto:photo];
        [self layoutFrame];
        
        self.lastSelectedButton = self.strokeMediumButton;
        [self.lastSelectedButton setImage:[UIImage imageNamed:@"photo_mosaic_strokefill"] forState:UIControlStateNormal];
        self.photoView.strokeScale = self.lastSelectedButton.tag;
    }
    return self;
}

#pragma mark - lifecycle -

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

#pragma mark - event response -

- (void)undo:(id)sender
{
    if (!self.lastMosaicImage) {
        self.lastMosaicImage = self.photoView.image;
        [self.photoView reset];
    }
}

- (void)redo:(id)sender
{
    if (self.lastMosaicImage) {
        self.photoView.image = self.lastMosaicImage;
        self.lastMosaicImage = nil;
    }
}

- (void)strokeTapped:(id)sender
{
    UIButton *button = (UIButton *)sender;
    self.photoView.strokeScale = button.tag;
    if ([self.lastSelectedButton isEqual:button]) {
        return;
    } else {
        [button setImage:[UIImage imageNamed:@"photo_mosaic_strokefill"] forState:UIControlStateNormal];
        [self.lastSelectedButton setImage:[UIImage imageNamed:@"photo_mosaic_strokeempty"] forState:UIControlStateNormal];
        self.lastSelectedButton = button;
    }
}

- (void)cancel:(id)sender
{
    [self.delegate photoMosaicViewControllerDidCancelEditingPhoto:self];
}

- (void)confirm:(id)sender
{
    [self.delegate photoMosaicViewController:self didFinishEditingPhoto:self.photoView.image];
}

#pragma mark - delegate -

- (void)imageViewDidMosaicImage:(LCMosaicImageView *)imageView
{
    self.lastMosaicImage = nil;
}

#pragma mark - private -

- (void)setupViewsWithPhoto:(UIImage *)photo
{
    self.navigationItem.title = @"马赛克";
    self.view.backgroundColor = [UIColor blackColor];
    
    UIBarButtonItem *leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(cancel:)];
    leftBarButtonItem.tintColor = [UIColor colorWithHex:@"FF4465"];
    self.navigationItem.leftBarButtonItem = leftBarButtonItem;
    UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"确定" style:UIBarButtonItemStylePlain target:self action:@selector(confirm:)];
    rightBarButtonItem.tintColor = [UIColor colorWithHex:@"FF4465"];
    self.navigationItem.rightBarButtonItem = rightBarButtonItem;
    
    [self.view addSubview:self.undoButton];
    [self.view addSubview:self.redoButton];
    [self.view addSubview:self.strokeSmallButton];
    [self.view addSubview:self.strokeMediumButton];
    [self.view addSubview:self.strokeLargeButton];
    [self.view addSubview:self.strokeLabel];
    [self.view addSubview:self.undoLabel];
    [self.view addSubview:self.redoLabel];
    
    self.photoView = [[LCMosaicImageView alloc] initWithImage:photo];
    self.photoView.mosaicEnabled = YES;
    self.photoView.mosaicLevel = LCMosaicLevelHigh;
    self.photoView.strokeScale = LCStrokeScaleLarge;
    self.photoView.delegate = self;
    self.photoView.backgroundColor = [UIColor clearColor];

    [self.view addSubview:self.photoView];
    
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    if (photo.size.width >= photo.size.height) {
        CGFloat ratio = (photo.size.height / photo.size.width);
        NSInteger height = (ratio > 0.75f) ? 0.75f * screenSize.width : ratio * screenSize.width;
        self.photoView.frame = CGRectMake(0, 0, screenSize.width, (double)height);
    } else {
        NSInteger width = (photo.size.width / photo.size.height) * (screenSize.height - kPortraitPhotoPadding);
        self.photoView.frame = CGRectMake(0, 0, (double)width, screenSize.height - kPortraitPhotoPadding);
    }
    self.photoView.clipsToBounds = YES;
    self.photoView.center = [self imageCenter];
}

- (void)layoutFrame
{
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    CGFloat scale = [UIScreen mainScreen].scale;
    
    self.strokeSmallButton.frame = CGRectMake(screenSize.width / 8.0f - (kStrokeButtonBasedWidth * scale) / 2, screenSize.height - (kStrokeButtonBasedWidth * scale) / 2 - kButtonToBottomPadding, kStrokeButtonBasedWidth * scale, kStrokeButtonBasedWidth * scale);
    self.strokeMediumButton.frame = CGRectMake(2 * screenSize.width / 8.0f - (kStrokeButtonBasedWidth * 1.25 * scale) / 2, screenSize.height - (kStrokeButtonBasedWidth * 1.25 * scale) / 2 - kButtonToBottomPadding, kStrokeButtonBasedWidth * 1.25 * scale, kStrokeButtonBasedWidth * 1.25 * scale);
    self.strokeLargeButton.frame = CGRectMake(3 * screenSize.width / 8.0f - (kStrokeButtonBasedWidth * 1.5 * scale) / 2, screenSize.height - (kStrokeButtonBasedWidth * 1.5 * scale) / 2 - kButtonToBottomPadding, kStrokeButtonBasedWidth * 1.5 * scale, kStrokeButtonBasedWidth * 1.5 * scale);
    self.undoButton.frame = CGRectMake(5 * screenSize.width / 8.0f - (kButtonBaseWidth * scale) / 2, screenSize.height - (kButtonBaseWidth * scale) / 2 - kButtonToBottomPadding, kButtonBaseWidth * scale, kButtonBaseWidth * scale);
    self.redoButton.frame = CGRectMake(7 * screenSize.width / 8.0f - (kButtonBaseWidth * scale) / 2, screenSize.height - (kButtonBaseWidth * scale) / 2 - kButtonToBottomPadding, kButtonBaseWidth * scale, kButtonBaseWidth * scale);
    
    self.strokeLabel.frame = CGRectMake(2 * screenSize.width / 8.0f - kLabelBaseWidth / 2, screenSize.height - kLabelBaseWidth / 2 - kLabelToBottomPadding, kLabelBaseWidth, 30);
    self.undoLabel.frame = CGRectMake(5 * screenSize.width / 8.0f - kLabelBaseWidth / 2, screenSize.height - kLabelBaseWidth / 2 - kLabelToBottomPadding, kLabelBaseWidth, 30);
    self.redoLabel.frame = CGRectMake(7 * screenSize.width / 8.0f - kLabelBaseWidth / 2, screenSize.height - kLabelBaseWidth / 2 - kLabelToBottomPadding, kLabelBaseWidth, 30);
}

- (CGPoint)imageCenter
{
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    CGFloat scale = [UIScreen mainScreen].scale;
    CGFloat y = screenSize.height / 2 - ((kButtonBaseWidth * scale) / 2 - kButtonToBottomPadding + 66) / 2;
    return CGPointMake(screenSize.width / 2, y);
}

#pragma mark - getter & setter -

- (UIButton *)redoButton
{
    if (!_redoButton) {
        _redoButton = [[UIButton alloc] init];
        [_redoButton setImage:[UIImage imageNamed:@"photo_mosaic_redo"] forState:UIControlStateNormal];
        _redoButton.translatesAutoresizingMaskIntoConstraints = NO;
        [_redoButton addTarget:self action:@selector(redo:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _redoButton;
}

- (UIButton *)undoButton
{
    if (!_undoButton) {
        _undoButton = [[UIButton alloc] init];
        [_undoButton setImage:[UIImage imageNamed:@"photo_mosaic_undo"] forState:UIControlStateNormal];
        _undoButton.translatesAutoresizingMaskIntoConstraints = NO;
        [_undoButton addTarget:self action:@selector(undo:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _undoButton;
}

- (UIButton *)strokeSmallButton
{
    if (!_strokeSmallButton) {
        _strokeSmallButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_strokeSmallButton setContentVerticalAlignment:UIControlContentVerticalAlignmentFill];
        [_strokeSmallButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentFill];
        [_strokeSmallButton setImage:[UIImage imageNamed:@"photo_mosaic_strokeempty"] forState:UIControlStateNormal];
        _strokeSmallButton.tag = LCStrokeScaleSmall;
        _strokeSmallButton.contentEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10);
        _strokeSmallButton.translatesAutoresizingMaskIntoConstraints = NO;
        [_strokeSmallButton addTarget:self action:@selector(strokeTapped:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _strokeSmallButton;
}

- (UIButton *)strokeMediumButton
{
    if (!_strokeMediumButton) {
        _strokeMediumButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_strokeMediumButton setContentVerticalAlignment:UIControlContentVerticalAlignmentFill];
        [_strokeMediumButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentFill];
        [_strokeMediumButton setImage:[UIImage imageNamed:@"photo_mosaic_strokeempty"] forState:UIControlStateNormal];
        _strokeMediumButton.contentEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10);
        _strokeMediumButton.tag = LCStrokeScaleMedium;
        _strokeMediumButton.translatesAutoresizingMaskIntoConstraints = NO;
        [_strokeMediumButton addTarget:self action:@selector(strokeTapped:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _strokeMediumButton;
}

- (UIButton *)strokeLargeButton
{
    if (!_strokeLargeButton) {
        _strokeLargeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_strokeLargeButton setContentVerticalAlignment:UIControlContentVerticalAlignmentFill];
        [_strokeLargeButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentFill];
        [_strokeLargeButton setImage:[UIImage imageNamed:@"photo_mosaic_strokeempty"] forState:UIControlStateNormal];
        _strokeLargeButton.contentEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10);
        _strokeLargeButton.tag = LCStrokeScaleLarge;
        _strokeLargeButton.translatesAutoresizingMaskIntoConstraints = NO;
        [_strokeLargeButton addTarget:self action:@selector(strokeTapped:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _strokeLargeButton;
}

- (UILabel *)strokeLabel
{
    if (!_strokeLabel) {
        _strokeLabel = [[UILabel alloc] init];
        _strokeLabel.text = @"画笔设置";
        _strokeLabel.textColor = [UIColor whiteColor];
        _strokeLabel.font = [UIFont systemFontOfSize:kDefaultFontSize];
        _strokeLabel.textAlignment = NSTextAlignmentCenter;
        _strokeLabel.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _strokeLabel;
}

- (UILabel *)undoLabel
{
    if (!_undoLabel) {
        _undoLabel = [[UILabel alloc] init];
        _undoLabel.text = @"撤销";
        _undoLabel.textColor = [UIColor whiteColor];
        _undoLabel.font = [UIFont systemFontOfSize:kDefaultFontSize];
        _undoLabel.textAlignment = NSTextAlignmentCenter;
        _undoLabel.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _undoLabel;
}

- (UILabel *)redoLabel
{
    if (!_redoLabel) {
        _redoLabel = [[UILabel alloc] init];
        _redoLabel.text = @"还原";
        _redoLabel.textColor = [UIColor whiteColor];
        _redoLabel.font = [UIFont systemFontOfSize:kDefaultFontSize];
        _redoLabel.textAlignment = NSTextAlignmentCenter;
        _redoLabel.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _redoLabel;
}


@end
