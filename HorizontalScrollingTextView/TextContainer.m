//
//  TextContainer.m
//  HorizontalScrollingTextView
//
//  Created by Ben Chatelain on 10/12/14.
//  Copyright (c) 2014 phatblat. All rights reserved.
//

#import "TextContainer.h"

@implementation TextContainer

#pragma mark - UITextContainer

- (CGRect)lineFragmentRectForProposedRect:(CGRect)proposedRect
                                  atIndex:(NSUInteger)characterIndex
                         writingDirection:(NSWritingDirection)baseWritingDirection
                            remainingRect:(CGRect *)remainingRect
{
//    NSLog(@"proposedRect: %@", NSStringFromCGRect(proposedRect));

//    CGRect resultingRect = [super lineFragmentRectForProposedRect:proposedRect atIndex:characterIndex writingDirection:baseWritingDirection remainingRect:remainingRect];
//    NSLog(@"resultingRect: %@", NSStringFromCGRect(resultingRect));

    if (proposedRect.size.width > self.contentSize.width) {
        proposedRect.size.width = self.contentSize.width;
//        NSLog(@">>> proposedRect: %@", NSStringFromCGRect(proposedRect));
    }

    return proposedRect;
}

@end
