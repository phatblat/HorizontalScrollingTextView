//
//  TextView.m
//  HorizontalScrollingTextView
//
//  Created by Ben Chatelain on 10/12/14.
//  Copyright (c) 2014 phatblat. All rights reserved.
//

#import "TextView.h"

@implementation TextView

#pragma mark - UIScrollView

- (void)setContentOffset:(CGPoint)contentOffset
{
    //    // restrict movement to vertical only
    //    CGPoint newOffset = CGPointMake(0, contentOffset.y);

    // restrict movement to horizontal only
//    CGPoint newOffset = CGPointMake(contentOffset.x, 0);

//    [super setContentOffset:newOffset];
    [super setContentOffset:contentOffset];
}

- (void)setContentOffset:(CGPoint)contentOffset animated:(BOOL)animated
{
    //    // restrict movement to vertical only
    //    CGPoint newOffset = CGPointMake(0, contentOffset.y);

    // restrict movement to horizontal only
//    CGPoint newOffset = CGPointMake(contentOffset.x, 0);

//    [super setContentOffset:newOffset animated:animated];
    [super setContentOffset:contentOffset];
}

- (BOOL)touchesShouldBegin:(NSSet *)touches
                 withEvent:(UIEvent *)event
             inContentView:(UIView *)view
{
    NSLog(@"");
    return YES;
}

- (BOOL)touchesShouldCancelInContentView:(UIView *)view
{
    NSLog(@"");
    return YES;
}

@end
