//
//  ViewController.m
//  HorizontalScrollingTextView
//
//  Created by Ben Chatelain on 10/12/14.
//  Copyright (c) 2014 phatblat. All rights reserved.
//

#import "ViewController.h"
#import "TextContainer.h"
#import "TextView.h"

static NSString * NSStringFromUIGestureRegognizerState(UIGestureRecognizerState state) {
    switch (state) {
        case UIGestureRecognizerStatePossible:
            return @"UIGestureRecognizerStatePossible";
            break;
        case UIGestureRecognizerStateBegan:
            return @"UIGestureRecognizerStateBegan";
            break;
        case UIGestureRecognizerStateChanged:
            return @"UIGestureRecognizerStateChanged";
            break;
        case UIGestureRecognizerStateEnded:
            return @"UIGestureRecognizerStateEnded";
            break;
        case UIGestureRecognizerStateCancelled:
            return @"UIGestureRecognizerStateCancelled";
            break;
        case UIGestureRecognizerStateFailed:
            return @"UIGestureRecognizerStateFailed";
            break;
    }
}

@interface ViewController ()

@property (strong, nonatomic) TextView *textView;

/**
 This is a pointer to the textView's default scrollview UIPanGestureRecognizer
 */
@property (weak, nonatomic) UIGestureRecognizer *verticalPanGestureRecognizer;
@property (strong, nonatomic) UIGestureRecognizer *horizontalPanGestureRecognizer;
@property (assign, nonatomic) CGPoint lastHorizontalScrollPoint;

@end

@implementation ViewController

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Create a fresh TextKit stack - http://www.objc.io/issue-5/getting-to-know-textkit.html
    NSTextStorage *textStorage = [[NSTextStorage alloc] init];
    NSLayoutManager *layoutManager = [[NSLayoutManager alloc] init];
    [textStorage addLayoutManager:layoutManager];
    TextContainer *textContainer = [[TextContainer alloc] init];
    [layoutManager addTextContainer:textContainer];
    self.textView = [[TextView alloc] initWithFrame:self.view.frame textContainer:textContainer];

    // View hierarchy
    [self.view addSubview:self.textView];
    self.textView.translatesAutoresizingMaskIntoConstraints = NO;

    NSLayoutConstraint *topConstraint = [NSLayoutConstraint constraintWithItem:self.textView
                                                                     attribute:NSLayoutAttributeTop
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:self.view
                                                                     attribute:NSLayoutAttributeTop
                                                                    multiplier:1
                                                                      constant:0];
    NSLayoutConstraint *bottomConstraint = [NSLayoutConstraint constraintWithItem:self.textView
                                                                        attribute:NSLayoutAttributeBottom
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:self.view
                                                                        attribute:NSLayoutAttributeBottom
                                                                       multiplier:1
                                                                         constant:0];
    NSLayoutConstraint *leadingConstraint = [NSLayoutConstraint constraintWithItem:self.textView
                                                                         attribute:NSLayoutAttributeLeading
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:self.view
                                                                         attribute:NSLayoutAttributeLeading
                                                                        multiplier:1
                                                                          constant:0];
    NSLayoutConstraint *trailingConstraint = [NSLayoutConstraint constraintWithItem:self.textView
                                                                         attribute:NSLayoutAttributeTrailing
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:self.view
                                                                         attribute:NSLayoutAttributeTrailing
                                                                        multiplier:1
                                                                          constant:0];

    [self.view addConstraints:@[topConstraint, bottomConstraint, leadingConstraint, trailingConstraint]];

    // Delegates
    self.textView.delegate = self;
    self.textView.layoutManager.delegate = self;
    self.textView.textStorage.delegate = self;

    self.textView.scrollEnabled = YES;
    self.textView.editable = NO;
    self.textView.layoutManager.allowsNonContiguousLayout = YES;
    self.textView.clipsToBounds = NO;

    // Gesture recognizers
    self.verticalPanGestureRecognizer = self.textView.panGestureRecognizer;
//    [self.verticalPanGestureRecognizer addTarget:self action:@selector(handlePanForTextView:)];
    self.horizontalPanGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanForTextView:)];
    self.horizontalPanGestureRecognizer.delegate = self;
//    [self.horizontalPanGestureRecognizer requireGestureRecognizerToFail:self.verticalPanGestureRecognizer];
    [self.textView addGestureRecognizer:self.horizontalPanGestureRecognizer];
    NSLog(@"self.textView.panGestureRecognizer: %@", self.textView.panGestureRecognizer);
    NSLog(@"self.verticalPanGestureRecognizer: %@", self.verticalPanGestureRecognizer);
    NSLog(@"self.horizontalPanGestureRecognizer: %@", self.horizontalPanGestureRecognizer);

    // Text Style
    self.textView.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];

    // Load text into textView
    self.textView.text = [self loadText];

    NSLog(@"self.textView.contentSize: %@", NSStringFromCGSize(self.textView.contentSize));
    NSLog(@"textContainer.size: %@", NSStringFromCGSize(self.textView.textContainer.size));

    CGSize contentSize = self.textView.contentSize;
    CGFloat textLength = [self.textView.text boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, self.textView.frame.size.height)
                                                          options:0 attributes:nil context:nil].size.width;
    contentSize.width = textLength;
    self.textView.contentSize = contentSize;
    self.textView.textContainer.size = contentSize;
    textContainer.contentSize = contentSize;

    NSLog(@"contentSize: %@", NSStringFromCGSize(contentSize));
    NSLog(@"self.textView.contentSize: %@", NSStringFromCGSize(self.textView.contentSize));
    NSLog(@"textContainer.size: %@", NSStringFromCGSize(self.textView.textContainer.size));
}

#pragma mark - UITextViewDelegate
#pragma mark - UIScrollViewDelegate
#pragma mark - NSTextStorageDelegate
#pragma mark - NSLayoutManagerDelegate
#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)gestureRecognizer
{
    NSLog(@"");

    // Leave the stock UIScrollViewPanGestureRecognizer alone, it handles vertical scrolling
    if (gestureRecognizer == self.verticalPanGestureRecognizer) {
        return YES;
    }

    // Only allow the horizontalPanGestureRecognizer to begin when we are scrolling horizontally
    CGPoint velocity = [gestureRecognizer velocityInView:self.textView];
    return fabs(velocity.x) > fabs(velocity.y);
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
       shouldReceiveTouch:(UITouch *)touch
{
    NSLog(@"");
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    NSLog(@"");
    return YES;
}

#pragma mark - Private Methods

- (NSString *)loadText
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Content" ofType:@"txt"];
    NSString *content = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    return content;
}

- (void)handlePanForTextView:(UIPanGestureRecognizer *)gestureRecognizer
{
    NSLog(@"gestureRecognizer: %@", gestureRecognizer);
    //    NSLog(@"state: %@", NSStringFromUIGestureRegognizerState(gesture.state));

    if (gestureRecognizer == self.horizontalPanGestureRecognizer) {
        CGPoint newLocation = [gestureRecognizer locationInView:gestureRecognizer.view];
        NSLog(@"locationInView: %@", NSStringFromCGPoint(newLocation));

        switch (gestureRecognizer.state) {
            case UIGestureRecognizerStateBegan: {
                self.lastHorizontalScrollPoint = newLocation;
                break;
            }
            case UIGestureRecognizerStateChanged: {
                CGFloat horizontalDelta = newLocation.x - self.lastHorizontalScrollPoint.x;
                NSLog(@"horizontalDelta: %f", horizontalDelta);

                // Drive the contentOffset
                CGPoint contentOffset = self.textView.contentOffset;
                contentOffset.x -= horizontalDelta;
                [self.textView setContentOffset:contentOffset animated:YES];

                // Save the new location
                self.lastHorizontalScrollPoint = newLocation;
                break;
            }
            case UIGestureRecognizerStateEnded: {
                self.lastHorizontalScrollPoint = CGPointZero;
                break;
            }
            default:
                ;
        }
    }
}

@end
