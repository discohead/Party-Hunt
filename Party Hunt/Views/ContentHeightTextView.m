//
//  ContentHeightTextView.m
//  Party Hunt
//
//  Created by Jared McFarland on 11/27/14.
//  Copyright (c) 2014 Jared Colin McFarland. All rights reserved.
//

#import "ContentHeightTextView.h"

@interface ContentHeightTextView ()
@property (strong, nonatomic) NSLayoutConstraint *heightConstraint;
@end

@implementation ContentHeightTextView

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self setNeedsUpdateConstraints];
}

- (void)updateConstraints
{
    CGSize size = [self sizeThatFits:CGSizeMake(self.bounds.size.width, FLT_MAX)];
    
    if (!self.heightConstraint)
    {
        self.heightConstraint = [NSLayoutConstraint constraintWithItem:self
                                                             attribute:NSLayoutAttributeHeight
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:nil
                                                             attribute:0
                                                            multiplier:1.0f
                                                              constant:size.height];
        
        [self addConstraint:self.heightConstraint];
    }
    
    self.heightConstraint.constant = size.height;
    [super updateConstraints];
}

@end
