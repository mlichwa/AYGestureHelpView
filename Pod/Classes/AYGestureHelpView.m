//
//  AYGestureHelpView.m
//  AYGestureHelpView
//
//  Created by Ayan Yenbekbay on 10/22/15.
//  Copyright © 2015 Ayan Yenbekbay. All rights reserved.
//

#import "AYGestureHelpView.h"
#import "AYTouchView.h"

static UIEdgeInsets const kHelpViewPadding = {20, 20, 20, 20};
static CGFloat const kHelpViewDefaultTouchRadius = 25;

@interface AYGestureHelpView ()

@property (copy, nonatomic) AYGestureHelpViewDismissHandler dismissHandler;
@property (nonatomic) BOOL hideOnDismiss;
@property (nonatomic) AYTouchView *touchView;
@property (nonatomic) NSTimer *timer;
@property (nonatomic) UILabel *label;

@end

@implementation AYGestureHelpView

#pragma mark Initialization

- (instancetype)init {
    return [self initWithFrame:[UIScreen mainScreen].bounds labelFont:[UIFont systemFontOfSize:[UIFont labelFontSize]] touchRadius:kHelpViewDefaultTouchRadius];
}

- (instancetype)initWithFrame:(CGRect)frame {
    return [self initWithFrame:frame labelFont:[UIFont systemFontOfSize:[UIFont labelFontSize]] touchRadius:kHelpViewDefaultTouchRadius];
}

- (instancetype)initWithTouchRadius:(CGFloat)touchRadius {
    return [self initWithFrame:[UIScreen mainScreen].bounds labelFont:[UIFont systemFontOfSize:[UIFont labelFontSize]] touchRadius:touchRadius];
}

- (instancetype)initWithLabelFont:(UIFont *)labelFont {
    return [self initWithFrame:[UIScreen mainScreen].bounds labelFont:labelFont touchRadius:kHelpViewDefaultTouchRadius];
}

- (instancetype)initWithFrame:(CGRect)frame labelFont:(UIFont *)labelFont touchRadius:(CGFloat)touchRadius {
    self = [super initWithFrame:frame];
    if (!self) return nil;
    
    _labelFont = labelFont;
    _touchRadius = touchRadius;
    [self setUpViews];
    
    return self;
}

#pragma mark Setters

- (void)setLabelFont:(UIFont *)labelFont {
    _labelFont = labelFont;
    self.label.font = labelFont;
}

- (void)setTouchRadius:(CGFloat)touchRadius {
    _touchRadius = touchRadius;
    self.touchView.frame = CGRectMake(CGRectGetMinX(self.touchView.frame), CGRectGetMinY(self.touchView.frame), self.touchRadius * 2, self.touchRadius * 2);
}

#pragma mark Public

- (void)tapWithLabelText:(NSString *)labelText labelPoint:(CGPoint)labelPoint touchPoint:(CGPoint)touchPoint dismissHandler:(AYGestureHelpViewDismissHandler)dismissHandler hideOnDismiss:(BOOL)hideOnDismiss {
    [self tapWithLabelText:labelText labelPoint:labelPoint touchPoint:touchPoint dismissHandler:dismissHandler doubleTap:NO hideOnDismiss:hideOnDismiss];
}

- (void)doubleTapWithLabelText:(NSString *)labelText labelPoint:(CGPoint)labelPoint touchPoint:(CGPoint)touchPoint dismissHandler:(AYGestureHelpViewDismissHandler)dismissHandler hideOnDismiss:(BOOL)hideOnDismiss {
    [self tapWithLabelText:labelText labelPoint:labelPoint touchPoint:touchPoint dismissHandler:dismissHandler doubleTap:YES hideOnDismiss:hideOnDismiss];
}


- (void)longPressWithLabelText:(NSString *)labelText labelPoint:(CGPoint)labelPoint touchPoint:(CGPoint)touchPoint dismissHandler:(AYGestureHelpViewDismissHandler)dismissHandler hideOnDismiss:(BOOL)hideOnDismiss {
    
    
    UILongPressGestureRecognizer* _longPressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressDetected:)];
    
    while (self.gestureRecognizers.count) {
        [self removeGestureRecognizer:[self.gestureRecognizers objectAtIndex:0]];
    };
    [self addGestureRecognizer:_longPressRecognizer];
    
      [self longPressWithLabelText:labelText labelPoint:labelPoint touchPoint:touchPoint dismissHandler:dismissHandler longPress:YES hideOnDismiss:hideOnDismiss];

}



- (void)swipeWithLabelText:(NSString *)labelText labelPoint:(CGPoint)labelPoint touchStartPoint:(CGPoint)touchStartPoint touchEndPoint:(CGPoint)touchEndPoint dismissHandler:(AYGestureHelpViewDismissHandler)dismissHandler hideOnDismiss:(BOOL)hideOnDismiss {
    self.touchView.center = touchStartPoint;
    self.touchView.startPoint = touchStartPoint;
    self.touchView.endPoint = touchEndPoint;
    self.label.text = labelText;
    [self.label sizeToFit];
    self.label.center = labelPoint;
    self.dismissHandler = dismissHandler;
    self.hideOnDismiss = hideOnDismiss;
    
    if (!self.superview) {
       [[[UIApplication sharedApplication] delegate].window addSubview:self];
    }
    [self showIfNeededWithCompletionBlock:^{
        if (self.timer) {
            [self.timer invalidate];
        }
        [self.touchView addSwipeAnimation];
        self.timer = [NSTimer scheduledTimerWithTimeInterval:1.5f target:self.touchView selector:@selector(addSwipeAnimation) userInfo:nil repeats:YES];
    }];
}

#pragma mark Private

- (void)setUpViews {
    self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.75f];
    self.alpha = 0;
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTap:)];
    [self addGestureRecognizer:tapGestureRecognizer];
    
    self.touchView = [[AYTouchView alloc] initWithFrame:CGRectMake(0, 0, self.touchRadius * 2, self.touchRadius * 2)];
    [self addSubview:self.touchView];
    
    self.label = [[UILabel alloc] initWithFrame:CGRectMake(kHelpViewPadding.left, 0, CGRectGetWidth(self.bounds) - kHelpViewPadding.left - kHelpViewPadding.right, 0)];
    self.label.font = self.labelFont;
    self.label.textColor = [UIColor whiteColor];
    self.label.numberOfLines = 0;
    self.label.textAlignment = NSTextAlignmentCenter;
    [self addSubview:self.label];
}

- (void)tapWithLabelText:(NSString *)labelText labelPoint:(CGPoint)labelPoint touchPoint:(CGPoint)touchPoint dismissHandler:(AYGestureHelpViewDismissHandler)dismissHandler doubleTap:(BOOL)doubleTap hideOnDismiss:(BOOL)hideOnDismiss {
    self.touchView.center = touchPoint;
    self.label.text = labelText;
    [self.label sizeToFit];
    self.label.center = labelPoint;
    self.dismissHandler = dismissHandler;
    self.hideOnDismiss = hideOnDismiss;
    
    if (!self.superview) {
        [[[UIApplication sharedApplication] delegate].window addSubview:self];
    }
    [self showIfNeededWithCompletionBlock:^{
        if (self.timer) {
            [self.timer invalidate];
        }
        if (doubleTap) {
            [self.touchView addDoubleTapAnimation];
            self.timer = [NSTimer scheduledTimerWithTimeInterval:2 target:self.touchView selector:@selector(addDoubleTapAnimation) userInfo:nil repeats:YES];
        } else {
            [self.touchView addTapAnimation];
            self.timer = [NSTimer scheduledTimerWithTimeInterval:1.5f target:self.touchView selector:@selector(addTapAnimation) userInfo:nil repeats:YES];
        }
    }];
}


- (void)longPressWithLabelText:(NSString *)labelText labelPoint:(CGPoint)labelPoint touchPoint:(CGPoint)touchPoint dismissHandler:(AYGestureHelpViewDismissHandler)dismissHandler longPress:(BOOL)longPress hideOnDismiss:(BOOL)hideOnDismiss {
    self.touchView.center = touchPoint;
    self.label.text = labelText;
    [self.label sizeToFit];
    self.label.center = labelPoint;
    self.dismissHandler = dismissHandler;
    self.hideOnDismiss = hideOnDismiss;
    
    if (!self.superview) {
        [[[UIApplication sharedApplication] delegate].window addSubview:self];
    }
    [self showIfNeededWithCompletionBlock:^{
        if (self.timer) {
            [self.timer invalidate];
        }
        if (longPress) {
            [self.touchView addLongPressAnimation];
            self.timer = [NSTimer scheduledTimerWithTimeInterval:1.5 target:self.touchView selector:@selector(addLongPressAnimation) userInfo:nil repeats:YES];
        } else {
            [self.touchView addLPressAnimation];
            self.timer = [NSTimer scheduledTimerWithTimeInterval:1.5f target:self.touchView selector:@selector(addLPressAnimation) userInfo:nil repeats:YES];
        }
    }];
}


- (void)showIfNeededWithCompletionBlock:(void (^ _Nonnull)(void))completionBlock {
    if (self.alpha == 0) {
        [UIView animateWithDuration:0.5f animations:^{
            self.alpha = 1;
        } completion:^(BOOL finished) {
            completionBlock();
        }];
    } else {
        completionBlock();
    }
}

- (void)didTap:(UITapGestureRecognizer *)tapGestureRecognizer {
    if (self.hideOnDismiss) {
        [self.timer invalidate];
        [UIView animateWithDuration:0.5f animations:^{
            self.alpha = 0;
        } completion:^(BOOL finished) {
            [self removeFromSuperview];
        }];
    }
    if (self.dismissHandler) {
        self.dismissHandler();
    }
}

/**
 *  UIGestureRecognizer for long press.
 *
 *  @param gestureRecognizer
 */
- (void)longPressDetected:(UIGestureRecognizer *)gestureRecognizer{
    
    if( gestureRecognizer.state == UIGestureRecognizerStateBegan){
        
        [self.delegate longPressStateBegan];
    }
    
    if( gestureRecognizer.state == UIGestureRecognizerStateChanged){
        
        [self.delegate longPressStateChanged];
    
    }
    

    if( gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        
        [self.delegate longPressStateEnded];
        
        if (self.hideOnDismiss) {
            [self.timer invalidate];
            [UIView animateWithDuration:0.5f animations:^{
                self.alpha = 0;
            } completion:^(BOOL finished) {
                [self removeFromSuperview];
            }];
        }
        if (self.dismissHandler) {
            self.dismissHandler();
        }
    }
}




@end
