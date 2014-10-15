//
//  ViewController.m
//  HorizontalScrollingTextView
//
//  Created by Ben Chatelain on 10/12/14.
//  Copyright (c) 2014 phatblat. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UITextView *textView;

@end

@implementation ViewController

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    UIFont *font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];

    // Load text and detect size
    NSString *contentText = [self loadText];
    CGRect contentRect = [contentText boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, self.textView.frame.size.height)
                                                   options:(NSStringDrawingUsesLineFragmentOrigin)
                                                attributes:nil context:nil];
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
    [self.textView removeFromSuperview];
    self.textView = [[UITextView alloc] initWithFrame:textViewFrame];
    self.textView.translatesAutoresizingMaskIntoConstraints = NO;
//    self.textView.frame = textViewFrame;
    NSLog(@"textViewFrame: %@", NSStringFromCGRect(textViewFrame));

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
}

#pragma mark - Private Methods

- (NSString *)loadText
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Content" ofType:@"txt"];
    NSString *content = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    return content;
}


@end
