//
//  HPLTagCloudGenerator.h
//  Awkward
//
//  Created by Matthew Conlen on 5/8/13.
//  Copyright (c) 2013 Huffington Post Labs. All rights reserved.
//

#import <Foundation/Foundation.h>

static const int MIN_FONT_SIZE = 15;
static const int MAX_POSITION_TRIES = 30;

@interface HPLTagCloudGenerator : NSObject

// Dictionary of tags -> # of occurances
@property NSDictionary *tagDict;

@property NSArray *customTags;

// The size of the view that
// we are creating a tag cloud for
@property CGSize size;

// How far along the spiral do
// we increment each time.
// defaults to 0.35
@property float spiralStep;

// The spiral is defined
// by the equation
//
// r = a + b*Θ
//
// where Θ is the angle
//
@property float a;
@property float b;


// Returns an array of views.
- (NSMutableArray *)generateTagViews;

@end
