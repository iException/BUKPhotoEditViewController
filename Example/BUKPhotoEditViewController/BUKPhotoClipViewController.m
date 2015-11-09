//
//  BUKPhotoClipViewController.m
//  BUKPhotoEditViewController
//
//  Created by lazy on 15/10/27.
//  Copyright © 2015年 lazy. All rights reserved.
//

#import "BUKPhotoClipViewController.h"
#import "UIColor+hex.h"

@interface BUKPhotoClipViewController (){
    CGPoint initialPosition;
    CGPoint initialCenter;
    
    CGRect currentMaskRect;
}

@property (nonatomic, strong) UIImageView *photoView;

@property (nonatomic, strong) UIImageView *horizontalClipView;
@property (nonatomic, strong) UIImageView *verticalClipView;

@property (nonatomic, strong) UIButton *landscapeButton;
@property (nonatomic, strong) UIButton *portraitButton;

@property (nonatomic, strong) UILabel *landscapeLabel;
@property (nonatomic, strong) UILabel *portraitLabel;

@property (nonatomic, strong) UIView *maskView;

@property (nonatomic, strong) CAShapeLayer *blackLayer;
@property (nonatomic, strong) CAShapeLayer *transparentLayer;

@property (nonatomic, assign) BOOL isVerticalMode;

@end

@implementation BUKPhotoClipViewController

static const CGFloat kButtonToBottomPadding = 83.0f;
static const CGFloat kLabelToBottomPadding = 25.0f;
static const CGFloat kButtonBaseWidth = 40.0f;
static const CGFloat kLabelBaseWidth = 60.0f;
static const CGFloat kDefaultFontSize = 14.0f;
static const CGFloat kImagePinchMaxScale = 3.0f;
static const CGFloat kImagePinchMinScale = 1.0f;
static const CGFloat kTopBarHeight = 68.0f;

#pragma mark - initializer -

- (instancetype)initWithPhoto:(UIImage *)photo
{
    self = [super init];
    if (self) {
        [self setupViewsWithPhoto:photo];
        [self layoutFrame];
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

#pragma mark - event response -

- (void)landscapeRotate:(id)sender
{
    self.horizontalClipView.hidden = NO;
    self.verticalClipView.hidden = YES;
    self.isVerticalMode = NO;
    
    [self makeTransparentLayer];
    
    CGPoint newOriginPoint = [self originForCurrentPhotoView];
    
    [UIView animateWithDuration:0.2f animations:^{
        self.photoView.frame = CGRectMake(newOriginPoint.x, newOriginPoint.y, self.photoView.frame.size.width, self.photoView.frame.size.height);
    }];
}

- (void)portraitRotate:(id)sender
{
    self.horizontalClipView.hidden = YES;
    self.verticalClipView.hidden = NO;
    self.isVerticalMode = YES;
    
    [self makeTransparentLayer];
    
    CGPoint newOriginPoint = [self originForCurrentPhotoView];
    
    [UIView animateWithDuration:0.2f animations:^{
        self.photoView.frame = CGRectMake(newOriginPoint.x, newOriginPoint.y, self.photoView.frame.size.width, self.photoView.frame.size.height);
    }];
}

- (void)cancel:(id)sender
{
    [self.delegate photoClipViewControllerDidCancelEditingPhoto:self];
}

- (void)confirm:(id)sender
{
    self.horizontalClipView.hidden = YES;
    self.verticalClipView.hidden = YES;
    
    UIImage *image = [self clipPhoto];
    self.photoView.transform = CGAffineTransformIdentity;
    
    [self.delegate photoClipViewController:self didFinishEditingPhoto:image];
}

- (void)handlePinch:(UIPinchGestureRecognizer *)pinch
{
    self.photoView.transform = CGAffineTransformScale(self.photoView.transform, pinch.scale, pinch.scale);
    
    if (pinch.state == UIGestureRecognizerStateEnded) {
        if (self.photoView.transform.d > kImagePinchMaxScale) {
            [UIView animateWithDuration:0.5f animations:^{
                self.photoView.transform = CGAffineTransformMake(kImagePinchMaxScale, 0, 0, kImagePinchMaxScale, 0, 0);
            } completion:^(BOOL finished) {
                CGPoint newOriginPoint = [self originForCurrentPhotoView];
                
                [UIView animateWithDuration:0.2f animations:^{
                    self.photoView.frame = CGRectMake(newOriginPoint.x, newOriginPoint.y, self.photoView.frame.size.width, self.photoView.frame.size.height);
                }];
            }];
        } else if (self.photoView.transform.d < kImagePinchMinScale) {
            [UIView animateWithDuration:0.5f animations:^{
                self.photoView.transform = CGAffineTransformMake(kImagePinchMinScale, 0, 0, kImagePinchMinScale, 0, 0);
            } completion:^(BOOL finished) {
                CGPoint newOriginPoint = [self originForCurrentPhotoView];
                
                [UIView animateWithDuration:0.2f animations:^{
                    self.photoView.frame = CGRectMake(newOriginPoint.x, newOriginPoint.y, self.photoView.frame.size.width, self.photoView.frame.size.height);
                }];
            }];
        } else {
            CGPoint newOriginPoint = [self originForCurrentPhotoView];
            
            [UIView animateWithDuration:0.2f animations:^{
                self.photoView.frame = CGRectMake(newOriginPoint.x, newOriginPoint.y, self.photoView.frame.size.width, self.photoView.frame.size.height);
            }];
        }
    }
    
    pinch.scale = 1;
}

- (void)handlePan:(UIPanGestureRecognizer *)pan
{
    CGPoint point = [pan locationInView:self.view];
    if (pan.state == UIGestureRecognizerStateBegan) {
        
    } else if (pan.state == UIGestureRecognizerStateChanged) {
        CGFloat deltaX = point.x - initialPosition.x;
        CGFloat deltaY = point.y - initialPosition.y;
        self.photoView.center = CGPointMake(deltaX + initialCenter.x, deltaY + initialCenter.y);
    } else if (pan.state == UIGestureRecognizerStateEnded) {
        
        CGPoint newOriginPoint = [self originForCurrentPhotoView];
        
        [UIView animateWithDuration:0.2f animations:^{
            self.photoView.frame = CGRectMake(newOriginPoint.x, newOriginPoint.y, self.photoView.frame.size.width, self.photoView.frame.size.height);
        }];
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self.view];
    initialPosition = point;
    initialCenter = self.photoView.center;
}

#pragma mark - delegate -
#pragma mark - private -

- (UIImage *)clipPhoto
{
    CGFloat clipOriginx = (self.photoView.frame.origin.x > currentMaskRect.origin.x) ? self.photoView.frame.origin.x : currentMaskRect.origin.x;
    CGFloat clipOriginY = (self.photoView.frame.origin.y > currentMaskRect.origin.y) ? self.photoView.frame.origin.y : currentMaskRect.origin.y;
    CGFloat clipWidth = (self.photoView.frame.size.width < currentMaskRect.size.width) ? self.photoView.frame.size.width : currentMaskRect.size.width;
    CGFloat clipHeight = (self.photoView.frame.size.height < currentMaskRect.size.height) ? self.photoView.frame.size.height : currentMaskRect.size.height;
    CGRect clipArea = CGRectMake(clipOriginx, clipOriginY, clipWidth, clipHeight);
    
    UIGraphicsBeginImageContext(self.view.bounds.size);
    [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    CGRect rect = clipArea;
    CGImageRef imageRef = CGImageCreateWithImageInRect([viewImage CGImage], rect);
    UIImage *img = [UIImage imageWithCGImage:imageRef];
    
    CGImageRelease(imageRef);
    
    return img;
}

- (void)setupViewsWithPhoto:(UIImage *)photo
{
    self.navigationItem.title = @"裁剪";
    self.view.backgroundColor = [UIColor blackColor];
    
    UIBarButtonItem *leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(cancel:)];
    leftBarButtonItem.tintColor = [UIColor colorWithHex:@"FF4465"];
    self.navigationItem.leftBarButtonItem = leftBarButtonItem;
    UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"确定" style:UIBarButtonItemStylePlain target:self action:@selector(confirm:)];
    rightBarButtonItem.tintColor = [UIColor colorWithHex:@"FF4465"];
    self.navigationItem.rightBarButtonItem = rightBarButtonItem;
    
    self.photoView.image = photo;
    
    [self.view addSubview:self.photoView];
    [self.view addSubview:self.horizontalClipView];
    [self.view addSubview:self.verticalClipView];
    [self.view addSubview:self.maskView];
    [self.view addSubview:self.landscapeButton];
    [self.view addSubview:self.portraitButton];
    [self.view addSubview:self.landscapeLabel];
    [self.view addSubview:self.portraitLabel];

    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    if (photo.size.width >= photo.size.height) {
        CGFloat ratio = (photo.size.height / photo.size.width);
        CGFloat height = (ratio > 0.75f) ? 0.75f * screenSize.width : ratio * screenSize.width;
        self.photoView.frame = CGRectMake(0, 0, screenSize.width, height);
    } else {
        CGFloat ratio = (photo.size.height / photo.size.width);
        self.photoView.frame = CGRectMake(0, 0, screenSize.width, screenSize.width * ratio);
    }
    self.photoView.clipsToBounds = YES;
    self.photoView.center = [self imageCenter];
    
}

- (void)layoutFrame
{
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    CGFloat scale = [UIScreen mainScreen].scale;
    
    self.landscapeButton.frame = CGRectMake(screenSize.width / 4.0f - (kButtonBaseWidth * scale) / 2, screenSize.height - (kButtonBaseWidth * scale) / 2 - kButtonToBottomPadding, kButtonBaseWidth * scale, kButtonBaseWidth * scale);
    self.portraitButton.frame = CGRectMake(3 * screenSize.width / 4.0f - (kButtonBaseWidth * scale) / 2, screenSize.height - (kButtonBaseWidth * scale) / 2 - kButtonToBottomPadding, kButtonBaseWidth * scale, kButtonBaseWidth * scale);
    
    self.landscapeLabel.frame = CGRectMake(screenSize.width / 4.0f - kLabelBaseWidth / 2, screenSize.height - kLabelBaseWidth / 2 - kLabelToBottomPadding, kLabelBaseWidth, 30);
    self.portraitLabel.frame = CGRectMake(3 * screenSize.width / 4.0f - kLabelBaseWidth / 2, screenSize.height - kLabelBaseWidth / 2 - kLabelToBottomPadding, kLabelBaseWidth, 30);
    
    self.horizontalClipView.frame = CGRectMake(0, 0, screenSize.width, 3 * screenSize.width / 4);
    self.horizontalClipView.center = [self imageCenter];
    self.verticalClipView.frame = CGRectMake(0, 0, screenSize.width * 4 / 5, screenSize.width);
    self.verticalClipView.center = [self imageCenter];
    
    self.verticalClipView.hidden = YES;
    self.isVerticalMode = NO;
    
    [self makeTransparentLayer];
    
    self.maskView.frame = CGRectMake(0, self.portraitButton.frame.origin.y + 10, screenSize.width, screenSize.height - self.portraitButton.frame.origin.y - 10);

    if (self.verticalClipView.frame.origin.y < kTopBarHeight) {
        CGFloat verticalHeight = self.maskView.frame.origin.y - kTopBarHeight;
        self.verticalClipView.frame = CGRectMake(0, 0, 4 * verticalHeight / 5, verticalHeight);
    }
    self.verticalClipView.center = [self imageCenter];
}

- (CGPoint)originForCurrentPhotoView
{
    CGFloat exceedUp = (self.photoView.frame.origin.y > currentMaskRect.origin.y) ? currentMaskRect.origin.y : self.photoView.frame.origin.y;
    CGFloat exceedLeft = (self.photoView.frame.origin.x > 0) ? 0 : self.photoView.frame.origin.x;
    CGFloat exceedDown = ((self.photoView.frame.origin.y + self.photoView.frame.size.height) < currentMaskRect.origin.y + currentMaskRect.size.height) ? currentMaskRect.origin.y + currentMaskRect.size.height - self.photoView.frame.size.height : self.photoView.frame.origin.y;
    CGFloat exceedRight = ((self.photoView.frame.origin.x + self.photoView.frame.size.width) < self.view.frame.size.width) ? (self.view.frame.size.width - self.photoView.frame.size.width) : self.photoView.frame.origin.x;
    
    CGFloat newOriginX;
    CGFloat newOriginY;
    
    if ((exceedUp == currentMaskRect.origin.y && exceedDown == (currentMaskRect.origin.y + currentMaskRect.size.height - self.photoView.frame.size.height)) || self.photoView.frame.size.height < currentMaskRect.size.height) {
        newOriginY = [self imageCenter].y - self.photoView.frame.size.height / 2;
    } else {
        if (exceedUp == currentMaskRect.origin.y) {
            newOriginY = currentMaskRect.origin.y;
        } else if (exceedDown == (currentMaskRect.origin.y + currentMaskRect.size.height - self.photoView.frame.size.height)) {
            newOriginY = currentMaskRect.origin.y + currentMaskRect.size.height - self.photoView.frame.size.height;
        } else {
            newOriginY = self.photoView.frame.origin.y;
        }
    }

    if (exceedLeft == 0) {
        newOriginX = 0;
    } else if (exceedRight == (self.view.frame.size.width - self.photoView.frame.size.width)) {
        newOriginX = self.view.frame.size.width - self.photoView.frame.size.width;
    } else {
        newOriginX = self.photoView.frame.origin.x;
    }
    
    return CGPointMake(newOriginX, newOriginY);
}

- (CGPoint)imageCenter
{
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    CGFloat scale = [UIScreen mainScreen].scale;
    CGFloat y = screenSize.height / 2 - ((kButtonBaseWidth * scale) / 2 - kButtonToBottomPadding + kTopBarHeight + 20) / 2;
    return CGPointMake(screenSize.width / 2, y);
}

- (void)makeTransparentLayer
{
    [self.blackLayer removeFromSuperlayer];
    [self.transparentLayer removeFromSuperlayer];
    
    CAShapeLayer *maskWithHole = [CAShapeLayer layer];
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    
    // Both frames are defined in the same coordinate system
    CGRect biggerRect = CGRectMake(0, 0, screenSize.width, screenSize.height - kButtonToBottomPadding - kButtonBaseWidth / 2);
    CGRect smallerRect = (self.isVerticalMode) ? self.verticalClipView.frame : self.horizontalClipView.frame;
    currentMaskRect = smallerRect;
    
    UIBezierPath *maskPath = [UIBezierPath bezierPath];
    [maskPath moveToPoint:CGPointMake(CGRectGetMinX(biggerRect), CGRectGetMinY(biggerRect))];
    [maskPath addLineToPoint:CGPointMake(CGRectGetMinX(biggerRect), CGRectGetMaxY(biggerRect))];
    [maskPath addLineToPoint:CGPointMake(CGRectGetMaxX(biggerRect), CGRectGetMaxY(biggerRect))];
    [maskPath addLineToPoint:CGPointMake(CGRectGetMaxX(biggerRect), CGRectGetMinY(biggerRect))];
    [maskPath addLineToPoint:CGPointMake(CGRectGetMinX(biggerRect), CGRectGetMinY(biggerRect))];
    
    [maskPath moveToPoint:CGPointMake(CGRectGetMinX(smallerRect), CGRectGetMinY(smallerRect))];
    [maskPath addLineToPoint:CGPointMake(CGRectGetMinX(smallerRect), CGRectGetMaxY(smallerRect))];
    [maskPath addLineToPoint:CGPointMake(CGRectGetMaxX(smallerRect), CGRectGetMaxY(smallerRect))];
    [maskPath addLineToPoint:CGPointMake(CGRectGetMaxX(smallerRect), CGRectGetMinY(smallerRect))];
    [maskPath addLineToPoint:CGPointMake(CGRectGetMinX(smallerRect), CGRectGetMinY(smallerRect))];
    
    [maskWithHole setPath:[maskPath CGPath]];
    [maskWithHole setFillRule:kCAFillRuleEvenOdd];
    [maskWithHole setFillColor:[[UIColor blackColor] CGColor]];
    maskWithHole.opacity = 0.4f;
    
    self.blackLayer = maskWithHole;
    [self.view.layer addSublayer:self.blackLayer];
    
    UIBezierPath *path;
    if (self.isVerticalMode) {
        path = [UIBezierPath bezierPathWithRect:self.verticalClipView.frame];
    } else {
        path = [UIBezierPath bezierPathWithRect:self.horizontalClipView.frame];
    }
    [path setUsesEvenOddFillRule:YES];
    
    CAShapeLayer *fillLayer = [CAShapeLayer layer];
    fillLayer.path = path.CGPath;
    fillLayer.fillRule = kCAFillRuleEvenOdd;
    fillLayer.fillColor = [UIColor clearColor].CGColor;
    fillLayer.opacity = 0.0;
    
    self.transparentLayer = fillLayer;
    [self.view.layer addSublayer:self.transparentLayer];
}

#pragma mark - getter & setter -

- (UIImageView *)photoView
{
    if (!_photoView) {
        _photoView = [[UIImageView alloc] init];
        _photoView.userInteractionEnabled = YES;
        _photoView.contentMode = UIViewContentModeScaleAspectFill;
        UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinch:)];
        [_photoView addGestureRecognizer:pinch];
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
        [_photoView addGestureRecognizer:pan];
    }
    return _photoView;
}

- (UIImageView *)horizontalClipView
{
    if (!_horizontalClipView) {
        _horizontalClipView = [[UIImageView alloc] init];
        _horizontalClipView.image = [UIImage imageNamed:@"photo_clip_hframe"];
    }
    return _horizontalClipView;
}

- (UIImageView *)verticalClipView
{
    if (!_verticalClipView) {
        _verticalClipView = [[UIImageView alloc] init];
        _verticalClipView.image = [UIImage imageNamed:@"photo_clip_vframe"];
    }
    return _verticalClipView;
}

- (UIButton *)landscapeButton
{
    if (!_landscapeButton) {
        _landscapeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_landscapeButton setImage:[UIImage imageNamed:@"photo_clip_horizontal"] forState:UIControlStateNormal];
        _landscapeButton.translatesAutoresizingMaskIntoConstraints = NO;
        [_landscapeButton addTarget:self action:@selector(landscapeRotate:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _landscapeButton;
}

- (UIButton *)portraitButton
{
    if (!_portraitButton) {
        _portraitButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_portraitButton setImage:[UIImage imageNamed:@"photo_clip_vertical"] forState:UIControlStateNormal];
        _portraitButton.translatesAutoresizingMaskIntoConstraints = NO;
        [_portraitButton addTarget:self action:@selector(portraitRotate:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _portraitButton;
}

- (UILabel *)landscapeLabel
{
    if (!_landscapeLabel) {
        _landscapeLabel = [[UILabel alloc] init];
        _landscapeLabel.text = @"横屏";
        _landscapeLabel.textColor = [UIColor whiteColor];
        _landscapeLabel.font = [UIFont systemFontOfSize:kDefaultFontSize];
        _landscapeLabel.textAlignment = NSTextAlignmentCenter;
        _landscapeLabel.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _landscapeLabel;
}

- (UILabel *)portraitLabel
{
    if (!_portraitLabel) {
        _portraitLabel = [[UILabel alloc] init];
        _portraitLabel.text = @"竖屏";
        _portraitLabel.textColor = [UIColor whiteColor];
        _portraitLabel.font = [UIFont systemFontOfSize:kDefaultFontSize];
        _portraitLabel.textAlignment = NSTextAlignmentCenter;
        _portraitLabel.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _portraitLabel;
}

- (UIView *)maskView
{
    if (!_maskView) {
        _maskView = [[UIView alloc] init];
        _maskView.translatesAutoresizingMaskIntoConstraints = NO;
        _maskView.backgroundColor = [UIColor blackColor];
        _maskView.userInteractionEnabled = NO;
        _maskView.opaque = NO;
    }
    return _maskView;
}

@end
