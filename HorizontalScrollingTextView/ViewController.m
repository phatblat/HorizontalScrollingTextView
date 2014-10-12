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

@interface ViewController ()

@property (strong, nonatomic) UITextView *textView;

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
    NSTextContainer *textContainer = [[NSTextContainer alloc] init];
    [layoutManager addTextContainer:textContainer];
    self.textView = [[TextView alloc] initWithFrame:self.view.frame textContainer:textContainer];

    // View hierarchy
    [self.view addSubview:self.textView];
    self.textView.translatesAutoresizingMaskIntoConstraints = NO;
//    NSArray *horizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[textView]|"
//                                                                             options:NSLayoutFormatDirectionLeadingToTrailing
//                                                                             metrics:nil
//                                                                               views:@{ @"textView": self.textView }];
//    NSArray *verticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[textView]|"
//                                                                           options:NSLayoutFormatDirectionLeadingToTrailing
//                                                                           metrics:nil
//                                                                             views:@{ @"textView": self.textView }];

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
    [self.view setNeedsLayout];

    // Delegates
    self.textView.delegate = self;
    self.textView.layoutManager.delegate = self;
    self.textView.textStorage.delegate = self;

    self.textView.scrollEnabled = YES;
    self.textView.editable = NO;
//    self.textView.textContainer.widthTracksTextView = NO;
//    self.textView.textContainerInset = UIEdgeInsetsMake(0, 100, 0, 0);

    // Text Style
    self.textView.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];

    // Load text into textView
    self.textView.text = [self loadText];
    //    self.textView.text = [self attrbituedTextForCommit:self.currentCommit].string;

    CGSize contentSize = self.textView.contentSize;
    //    CGSize size = [self.textView.text sizeWithAttributes:nil];
    CGFloat textLength = [self.textView.text sizeWithFont:self.textView.font
                                        constrainedToSize:CGSizeMake(CGFLOAT_MAX, self.textView.frame.size.height)
                                            lineBreakMode:NSLineBreakByWordWrapping].width;
    contentSize.width = textLength;
//    self.textView.contentSize = contentSize;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.textView sizeToFit];
    [self.textView layoutIfNeeded];
}

#pragma mark - UITextViewDelegate
#pragma mark - UIScrollViewDelegate
#pragma mark - NSTextStorageDelegate
#pragma mark - NSLayoutManagerDelegate

#pragma mark - Private Methods

- (NSString *)loadText
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Content" ofType:@"txt"];
    NSString *content = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    return content;
}

@end
