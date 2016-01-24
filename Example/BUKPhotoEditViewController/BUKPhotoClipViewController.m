//
//  BUKPhotoClipViewController.m
//  BUKPhotoEditViewController
//
//  Created by lazy on 15/10/27.
//  Copyright © 2015年 lazy. All rights reserved.
//

#import "BUKPhotoClipViewController.h"
#import "UIColor+Theme.h"

@interface BUKPhotoClipViewController (){
    CGPoint initialPosition;
    CGPoint initialCenter;
    
    CGRect currentMaskRect;
}

@property (nonatomic, strong) UIImageView *photoView;
@property (nonatomic, strong) UIImage *photo;

@property (nonatomic, strong) UIImageView *clipView;
@property (nonatomic, strong) UIView *maskView;

@property (nonatomic, strong) UIButton *confirmButton;
@property (nonatomic, strong) UIButton *cancelButton;

@property (nonatomic, strong) CAShapeLayer *blackLayer;
@property (nonatomic, strong) CAShapeLayer *transparentLayer;

@end

@implementation BUKPhotoClipViewController

static const CGFloat kImagePinchMaxScale = 3.0f;
static const CGFloat kImagePinchMinScale = 1.0f;
static const CGFloat kImageBottom = 92.0f;

static const CGFloat KButtonToLeft = 37.0f;
static const CGFloat kButtonToBottom = 28.0f;
static const CGFloat kButtonWidth = 24.0f;

#pragma mark - initializer -

- (instancetype)initWithPhoto:(UIImage *)photo
{
    self = [super init];
    if (self) {
        _photo = photo;
        [self setupViewsWithPhoto:photo];
    }
    return self;
}

#pragma mark - lifecycle -

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self layoutFrame];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - event response -

- (void)cancel:(id)sender
{
    self.photoView.hidden = YES;
    self.clipView.hidden = YES;
    [self.delegate photoClipViewControllerDidCancelEditingPhoto:self];
}

- (void)confirm:(id)sender
{
    self.clipView.hidden = YES;
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
    
    self.photoView.image = photo;
    
    [self.view addSubview:self.photoView];
    [self.view addSubview:self.clipView];
    [self.view addSubview:self.maskView];
    [self.view addSubview:self.confirmButton];
    [self.view addSubview:self.cancelButton];

    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    self.photoView.frame = CGRectMake(0, 0, screenSize.width, screenSize.height - kImageBottom - 64);
    CGFloat heightByWidth = (self.photo.size.height / self.photo.size.width);
    CGFloat height = screenSize.width * heightByWidth;
    if (height > self.photoView.frame.size.height) {
        self.photoView.frame = CGRectMake(0, 0, self.photoView.frame.size.height * (self.photo.size.width / self.photo.size.height), self.photoView.frame.size.height);
    } else {
        self.photoView.frame = CGRectMake(0, 0, screenSize.width, screenSize.width * heightByWidth);
    }
    
    self.photoView.clipsToBounds = YES;
    self.photoView.center = [self imageCenter];
}

- (void)layoutFrame
{
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    
    self.clipView.frame = CGRectMake(0, 0, screenSize.width, screenSize.width);
    self.clipView.center = [self imageCenter];
    self.maskView.frame = CGRectMake(0, screenSize.height - kImageBottom, screenSize.width, kImageBottom);
    
    self.confirmButton.frame = CGRectMake(screenSize.width - KButtonToLeft - kButtonWidth, screenSize.height - kButtonToBottom - kButtonWidth, kButtonWidth, kButtonWidth);
    self.cancelButton.frame = CGRectMake(KButtonToLeft, screenSize.height - kButtonToBottom - kButtonWidth, kButtonWidth, kButtonWidth);
    
    [self makeTransparentLayer];
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
    CGFloat y = (64 + screenSize.height - kImageBottom) / 2;
    return CGPointMake(screenSize.width / 2, y);
}

- (void)makeTransparentLayer
{
    [self.blackLayer removeFromSuperlayer];
    [self.transparentLayer removeFromSuperlayer];
    
    CAShapeLayer *maskWithHole = [CAShapeLayer layer];
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    
    // Both frames are defined in the same coordinate system
    CGRect biggerRect = CGRectMake(0, 0, screenSize.width, screenSize.height - kImageBottom);
    CGRect smallerRect = self.clipView.frame;
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
    
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:self.clipView.frame];
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
        UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinch:)];
        [_photoView addGestureRecognizer:pinch];
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
        [_photoView addGestureRecognizer:pan];
    }
    return _photoView;
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

- (UIImageView *)clipView {
	if(_clipView == nil) {
		_clipView = [[UIImageView alloc] init];
        _clipView.image = [UIImage imageNamed:@"qingquan_clip_bound"];
	}
	return _clipView;
}

- (UIButton *)confirmButton {
    if(_confirmButton == nil) {
        _confirmButton = [[UIButton alloc] init];
        [_confirmButton setImage:[UIImage imageNamed:@"photo_edit_done"] forState:UIControlStateNormal];
        _confirmButton.translatesAutoresizingMaskIntoConstraints = NO;
        [_confirmButton addTarget:self action:@selector(confirm:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _confirmButton;
}

- (UIButton *)cancelButton {
    if(_cancelButton == nil) {
        _cancelButton = [[UIButton alloc] init];
        [_cancelButton setImage:[UIImage imageNamed:@"qingquan_edit_cancel"] forState:UIControlStateNormal];
        _cancelButton.translatesAutoresizingMaskIntoConstraints = NO;
        [_cancelButton addTarget:self action:@selector(cancel:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cancelButton;
}

@end
