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

//static NSString * NSStringFromUIGestureRegognizerState(UIGestureRecognizerState state) {
//    switch (state) {
//        case UIGestureRecognizerStatePossible:
//            return @"UIGestureRecognizerStatePossible";
//            break;
//        case UIGestureRecognizerStateBegan:
//            return @"UIGestureRecognizerStateBegan";
//            break;
//        case UIGestureRecognizerStateChanged:
//            return @"UIGestureRecognizerStateChanged";
//            break;
//        case UIGestureRecognizerStateEnded:
//            return @"UIGestureRecognizerStateEnded";
//            break;
//        case UIGestureRecognizerStateCancelled:
//            return @"UIGestureRecognizerStateCancelled";
//            break;
//        case UIGestureRecognizerStateFailed:
//            return @"UIGestureRecognizerStateFailed";
//            break;
//    }
//}

@interface ViewController ()

//@property (strong, nonatomic) UIScrollView *scrollView;
//@property (strong, nonatomic) TextView *textView;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UITextView *textView;

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

    // Scrollview for horizontal scrolling
//    self.scrollView = [[UIScrollView alloc] initWithFrame:self.view.frame];
//    [self constrainView:self.scrollView toParentView:self.view];

    // Load text and detect size
    NSString *contentText = [self loadText];
    CGRect contentRect = [contentText boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, self.textView.frame.size.height)
                                                   options:NSStringDrawingUsesLineFragmentOrigin
                                                attributes:nil context:nil];
    CGSize contentSize = contentRect.size;
    CGFloat contentWidth = contentRect.size.width;
    if (contentWidth < self.view.frame.size.width) {
        // text view minimum frame width is the width of the root view frame
        contentWidth = self.view.frame.size.width;
    }

    CGRect textViewFrame = CGRectMake(0, 0, contentWidth, self.view.frame.size.height);
    self.textView.frame = textViewFrame;
    NSLog(@"textViewFrame: %@", NSStringFromCGRect(textViewFrame));

    CGSize scrollSize = CGSizeMake(contentWidth, self.view.frame.size.height);
    self.scrollView.contentSize = scrollSize;
    NSLog(@"scrollSize: %@", NSStringFromCGSize(scrollSize));

    self.scrollView.delegate = self;
    self.scrollView.scrollsToTop = NO;

    // Create a fresh TextKit stack - http://www.objc.io/issue-5/getting-to-know-textkit.html
//    NSTextStorage *textStorage = [[NSTextStorage alloc] init];
//    NSLayoutManager *layoutManager = [[NSLayoutManager alloc] init];
//    [textStorage addLayoutManager:layoutManager];
//    TextContainer *textContainer = [[TextContainer alloc] init];
//    [layoutManager addTextContainer:textContainer];
//    self.textView = [[TextView alloc] initWithFrame:textViewFrame textContainer:textContainer];

    // View hierarchy
//    [self.scrollView addSubview:self.textView];
//    self.textView.translatesAutoresizingMaskIntoConstraints = NO;
//
//    NSLayoutConstraint *topConstraint = [NSLayoutConstraint constraintWithItem:self.textView
//                                                                     attribute:NSLayoutAttributeTop
//                                                                     relatedBy:NSLayoutRelationEqual
//                                                                        toItem:self.scrollView
//                                                                     attribute:NSLayoutAttributeTop
//                                                                    multiplier:1
//                                                                      constant:0];
//    NSLayoutConstraint *bottomConstraint = [NSLayoutConstraint constraintWithItem:self.textView
//                                                                        attribute:NSLayoutAttributeBottom
//                                                                        relatedBy:NSLayoutRelationEqual
//                                                                           toItem:self.scrollView
//                                                                        attribute:NSLayoutAttributeBottom
//                                                                       multiplier:1
//                                                                         constant:0];
//    NSLayoutConstraint *leadingConstraint = [NSLayoutConstraint constraintWithItem:self.textView
//                                                                         attribute:NSLayoutAttributeLeading
//                                                                         relatedBy:NSLayoutRelationEqual
//                                                                            toItem:self.scrollView
//                                                                         attribute:NSLayoutAttributeLeading
//                                                                        multiplier:1
//                                                                          constant:0];
//    NSLayoutConstraint *trailingConstraint = [NSLayoutConstraint constraintWithItem:self.textView
//                                                                         attribute:NSLayoutAttributeTrailing
//                                                                         relatedBy:NSLayoutRelationEqual
//                                                                            toItem:self.scrollView
//                                                                         attribute:NSLayoutAttributeTrailing
//                                                                        multiplier:1
//                                                                          constant:0];
//
//    [self.scrollView addConstraints:@[topConstraint, bottomConstraint, leadingConstraint, trailingConstraint]];

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
//    self.verticalPanGestureRecognizer.delegate = self;
    [self.verticalPanGestureRecognizer addTarget:self action:@selector(handlePanGesture:)];

    self.horizontalPanGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
//    self.horizontalPanGestureRecognizer = self.scrollView.panGestureRecognizer;
    self.horizontalPanGestureRecognizer.delegate = self;
    [self.horizontalPanGestureRecognizer addTarget:self action:@selector(handlePanGesture:)];

//    [self.horizontalPanGestureRecognizer requireGestureRecognizerToFail:self.verticalPanGestureRecognizer];
    [self.scrollView addGestureRecognizer:self.horizontalPanGestureRecognizer];

    NSLog(@"self.verticalPanGestureRecognizer: %@", self.verticalPanGestureRecognizer);
    NSLog(@"self.horizontalPanGestureRecognizer: %@", self.horizontalPanGestureRecognizer);

    // Text Style
//    self.textView.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];

    // Load text into textView
    self.textView.text = contentText;
    self.textView.contentSize = contentSize;
    [self.textView sizeToFit];

    NSLog(@"self.textView.contentSize: %@", NSStringFromCGSize(self.textView.contentSize));
    NSLog(@"textContainer.size: %@", NSStringFromCGSize(self.textView.textContainer.size));

//    self.textView.contentSize = contentSize;
//    self.textView.textContainer.size = contentSize;
//    textContainer.contentSize = contentSize;

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

    if (gestureRecognizer == self.horizontalPanGestureRecognizer) {
        if (self.verticalPanGestureRecognizer.state == UIGestureRecognizerStateBegan ||
            self.verticalPanGestureRecognizer.state == UIGestureRecognizerStateChanged) {
            // Disallow horizontal tracking while vertical tracking
            return NO;
        }
        // Only allow the horizontalPanGestureRecognizer to begin when we are scrolling horizontally
        CGPoint velocity = [gestureRecognizer velocityInView:self.textView];
        return fabs(velocity.x) > fabs(velocity.y);
    }

    if (gestureRecognizer == self.verticalPanGestureRecognizer) {
        if (self.horizontalPanGestureRecognizer.state == UIGestureRecognizerStateBegan ||
            self.horizontalPanGestureRecognizer.state == UIGestureRecognizerStateChanged) {
            // Disallow vertical tracking while horizontal tracking
            return NO;
        }
        return YES;
    }

    // Shouldn't be able to get here
    return YES;
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

- (void)handlePanGesture:(UIPanGestureRecognizer *)gestureRecognizer
{
//    NSLog(@"gestureRecognizer: %@", gestureRecognizer);
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
                CGPoint contentOffset = self.scrollView.contentOffset;
                contentOffset.x -= horizontalDelta;
                [self.scrollView setContentOffset:contentOffset animated:YES];

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


- (UIView *)constrainView:(UIView *)subview toParentView:(UIView *)parentView
{
    [parentView addSubview:subview];
    subview.translatesAutoresizingMaskIntoConstraints = NO;

    NSLayoutConstraint *topConstraint = [NSLayoutConstraint constraintWithItem:subview
                                                                     attribute:NSLayoutAttributeTop
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:parentView
                                                                     attribute:NSLayoutAttributeTop
                                                                    multiplier:1
                                                                      constant:0];
    NSLayoutConstraint *bottomConstraint = [NSLayoutConstraint constraintWithItem:subview
                                                                        attribute:NSLayoutAttributeBottom
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:parentView
                                                                        attribute:NSLayoutAttributeBottom
                                                                       multiplier:1
                                                                         constant:0];
    NSLayoutConstraint *leadingConstraint = [NSLayoutConstraint constraintWithItem:subview
                                                                         attribute:NSLayoutAttributeLeading
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:parentView
                                                                         attribute:NSLayoutAttributeLeading
                                                                        multiplier:1
                                                                          constant:0];
    NSLayoutConstraint *trailingConstraint = [NSLayoutConstraint constraintWithItem:subview
                                                                          attribute:NSLayoutAttributeTrailing
                                                                          relatedBy:NSLayoutRelationEqual
                                                                             toItem:parentView
                                                                          attribute:NSLayoutAttributeTrailing
                                                                         multiplier:1
                                                                           constant:0];

    [parentView addConstraints:@[topConstraint, bottomConstraint, leadingConstraint, trailingConstraint]];
    [parentView layoutIfNeeded];

    return subview;
}

@end
