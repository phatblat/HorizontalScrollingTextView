//
//  ViewController.m
//  HorizontalScrollingTextView
//
//  Created by Ben Chatelain on 10/12/14.
//  Copyright (c) 2014 phatblat. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

/**
 Defined in storyboard.
 */
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

/**
 Created in code for precise control of frame.
 */
@property (strong, nonatomic) IBOutlet UITextView *textView;

@end

@implementation ViewController

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    UIFont *font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    NSDictionary *attributes = @{ NSFontAttributeName: font };

    // Load text and detect size
    NSString *contentText = [self loadText];
    CGRect contentRect = [contentText boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, self.textView.frame.size.height)
                                                   options:(NSStringDrawingUsesLineFragmentOrigin)
                                                attributes:attributes context:nil];
    // Fix up values
    contentRect = CGRectMake(contentRect.origin.x, contentRect.origin.y, ceil(contentRect.size.width), ceil(contentRect.size.height));

    CGSize contentSize = contentRect.size;
    CGFloat contentWidth = contentRect.size.width;
    if (contentWidth < self.view.frame.size.width) {
        // text view minimum frame width is the width of the root view frame
        contentWidth = self.view.frame.size.width;
    }
    CGFloat contentHeight = contentRect.size.height;
    if (contentHeight < self.view.frame.size.height) {
        // text view minimum frame width is the width of the root view frame
        contentHeight = self.view.frame.size.width;
    }

    // TextView frame
    CGRect textViewFrame = CGRectMake(0, 0, contentWidth, contentHeight);
    NSLog(@"textViewFrame: %@", NSStringFromCGRect(textViewFrame));

    self.textView = [[UITextView alloc] initWithFrame:textViewFrame];
    self.textView.translatesAutoresizingMaskIntoConstraints = NO;
    self.textView.editable = NO;
    self.textView.scrollEnabled = YES; // When this is NO nothing shows up

    // TextView border for debugging
    self.textView.layer.borderWidth = 1;
    self.textView.layer.borderColor = [UIColor redColor].CGColor;

    // Text Style
    self.textView.font = font;

    // Load text into textView
    self.textView.text = contentText;
//    self.textView.contentSize = contentSize;
//    self.textView.textContainer.size = contentSize;
    [self.textView sizeToFit];

    [self.scrollView addSubview:self.textView];

    NSLog(@"contentSize: %@", NSStringFromCGSize(contentSize));
    NSLog(@"self.textView.contentSize: %@", NSStringFromCGSize(self.textView.contentSize));
    NSLog(@"textContainer.size: %@", NSStringFromCGSize(self.textView.textContainer.size));

//    CGSize scrollSize = CGSizeMake(contentWidth, self.view.frame.size.height);
    self.scrollView.contentSize = contentSize; // scrollSize;
    self.scrollView.contentInset = UIEdgeInsetsMake(0, 0, 40, -40);
}

#pragma mark - Private Methods

- (NSString *)loadText
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Content" ofType:@"txt"];
    NSString *content = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    return content;
}


@end
