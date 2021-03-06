//
//  HPLTagCloudGenerator.m
//  Awkward
//
//  Created by Matthew Conlen on 5/8/13.
//  Copyright (c) 2013 Huffington Post Labs. All rights reserved.
//

#import "HPLTagCloudGenerator.h"
#import <math.h>

@interface HPLTagCloudGenerator () {
    int spiralCount;
}

@end

@implementation HPLTagCloudGenerator

- (id) init {
    self = [super init];
    spiralCount = 0;
    self.spiralStep = 0.35;
    self.a = 1; //5;
    self.b = 2; //6;
    return self;
}

- (CGPoint) getNextPosition {
    float angle = self.spiralStep * spiralCount++;

    float offsetX = self.size.width * 0.5f;
    float offsetY = self.size.height * 0.5f;
    int x = (self.a + self.b*angle)*cos(angle);
    int y = (self.a + self.b*angle)*sin(angle);

    return CGPointMake(x+offsetX,y+offsetY);
}

- (CGPoint) getNextRandomPositionForView:(UIView *)view {
    static float angle = 0.0f;
    static float step = 0.0f;
    static UIView *lastView = nil;
    if (lastView != view) {
        lastView = view;
        step = 0.0f;
        angle = (float)(rand() % (int)(2 * M_PI * 1000)) / 1000.0f;
    }
    
    step += (float)MIN_FONT_SIZE;
    
    float offsetX = self.size.width * 0.5f;
    float offsetY = self.size.height * 0.5f;
    int x = (step + self.b*angle)*cos(angle);
    int y = (step + self.b*angle)*sin(angle);
    
    return CGPointMake(x+offsetX,y+offsetY);
}

- (BOOL) fitsScreen:(UIView *)checkView
{
    static dispatch_once_t onceToken = 0;
    static CGRect screen;
    dispatch_once(&onceToken, ^{
        screen.origin.x += self.size.width * 0.1f;
        screen.origin.y += self.size.width * 0.1f;
        screen.size.width = self.size.width * 0.8f;
        screen.size.height = self.size.height * 0.5f;
    });
    
    return CGRectIntersectsRect(checkView.frame, screen);
}

- (BOOL) checkIntersectionWithView:(UIView *)checkView viewArray:(NSArray*)viewArray {
    for (UIView *view in viewArray) {
        CGRect viewFrame = view.frame;
        CGRect checkFrame = checkView.frame;
        //checkFrame.size.height *= 0.5f;
        /*const float k = 0.1f;
        viewFrame.origin.x += k * viewFrame.size.width;
        viewFrame.origin.y += k * viewFrame.size.height;
        viewFrame.size.width *= k;
        viewFrame.size.height *= k;*/
        if(CGRectIntersectsRect(checkFrame, viewFrame)) {
            return YES;
        }
    }
    return NO;
}

- (NSMutableArray *)generateTagViews {
    float maxFontsize = 60.0;

    NSMutableDictionary *smoothedTagDict = [NSMutableDictionary dictionaryWithDictionary:self.tagDict];

    NSMutableArray *tagViews = [[NSMutableArray alloc] init];

    NSArray *sortedTags = [self.tagDict keysSortedByValueUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        int v1 = [obj1 intValue];
        int v2 = [obj2 intValue];
        if (v1 > v2)
            return NSOrderedAscending;
        else if (v1 < v2)
            return NSOrderedDescending;
        else
            return NSOrderedSame;
    }];

    // Smooth the Values
    // Artifically ensure that the count of any tags is always distinct...
    //
    //
    // e.g.
    //      tag1 ~> 1
    //      tag2 ~> 1
    //      tag3 ~> 1
    //      tag4 ~> 1
    //
    // becomes
    //      tag1 ~> 1
    //      tag2 ~> 2
    //      tag3 ~> 3
    //      tag4 ~> 4
    //
    // so that things look nicer

    for(int i=[sortedTags count]-1; i>0; i--) {
        int curVal = [(NSNumber *) [smoothedTagDict objectForKey:[sortedTags objectAtIndex:i]] intValue];
        int nextVal = [(NSNumber *) [smoothedTagDict objectForKey:[sortedTags objectAtIndex:i-1]] intValue];

        if(nextVal <= curVal) {
            nextVal = curVal+1;
            [smoothedTagDict setValue:[NSNumber numberWithInt:nextVal] forKey:[sortedTags objectAtIndex:i-1]];
        }
    }

    int max = [(NSNumber *) [smoothedTagDict objectForKey:[sortedTags objectAtIndex:0]] intValue];
    int min = [(NSNumber *) [smoothedTagDict objectForKey:[sortedTags objectAtIndex:[sortedTags count]-1]] intValue];
    min--;

    CGFloat maxWidth = [[UIScreen mainScreen] bounds].size.width - 30;
    
    NSString *tag = @"+";
    UIFont *tagFont = [UIFont systemFontOfSize:maxFontsize * 2.0f];
    CGSize size = [tag sizeWithAttributes:@{ NSFontAttributeName : tagFont }];
    CGPoint center = [self getNextPosition];
    UILabel *tagLabel = [[UILabel alloc] initWithFrame:CGRectMake(center.x - size.width * 0.5f, center.y - size.height * 0.5f, size.width, size.height)];
    tagLabel.text = tag;
    tagLabel.font = tagFont;
    [tagViews addObject:tagLabel];
    
    for (NSString* tag in self.customTags) {
        smoothedTagDict[tag] = @(max);
        UILabel *tagLabel = [self generateTag:tag
                              smoothedTagDict:smoothedTagDict
                                          max:max
                                          min:min
                                  maxFontsize:&maxFontsize
                                     maxWidth:maxWidth
                                     tagViews:tagViews];
        [tagViews addObject:tagLabel];
    }

    for (NSString *tag in sortedTags) {
        UILabel *tagLabel = [self generateTag:tag
                              smoothedTagDict:smoothedTagDict
                                          max:max
                                          min:min
                                  maxFontsize:&maxFontsize
                                     maxWidth:maxWidth
                                     tagViews:tagViews];
        [tagViews addObject:tagLabel];
    }

    return tagViews;
}

- (UILabel *) generateTag:(NSString *)tag
          smoothedTagDict:(NSMutableDictionary *)smoothedTagDict
                      max:(int)max
                      min:(int)min
              maxFontsize:(float *)maxFontsize
                 maxWidth:(CGFloat)maxWidth
                 tagViews:(NSMutableArray *)tagViews
{
    int count = [(NSNumber *) [smoothedTagDict objectForKey:tag] intValue];
    float fontSize = ceilf(*maxFontsize * (count - min) / (max - min)) + MIN_FONT_SIZE;
    
    UIFont *tagFont = [UIFont systemFontOfSize:fontSize];
    CGSize size = [tag sizeWithAttributes:@{ NSFontAttributeName : tagFont }];
    
    while (size.width >= maxWidth) {
        *maxFontsize -= 2;
        fontSize = ceilf(*maxFontsize * (count - min) / (max - min)) + MIN_FONT_SIZE;
        
        tagFont = [UIFont systemFontOfSize:fontSize];
        size = [tag sizeWithAttributes:@{ NSFontAttributeName : tagFont }];
    }
    
    // check intersections
    CGPoint center = [self getNextPosition];
    UILabel *tagLabel = [[UILabel alloc] initWithFrame:CGRectMake(center.x - size.width * 0.5f, center.y - size.height * 0.5f, size.width, size.height)];
    
    tagLabel.text = tag;
    tagLabel.font = tagFont;
    
    //int try = 0;
    while([self checkIntersectionWithView:tagLabel viewArray:tagViews]) {
        CGPoint center = [self getNextPosition];
        tagLabel.frame = CGRectMake(center.x - size.width * 0.5f, center.y - size.height * 0.5f, size.width, size.height);
        
        /*if (try++ >= MAX_POSITION_TRIES || [self fitsScreen:tagLabel] == NO) {
            try = 0;
            while([self checkIntersectionWithView:tagLabel viewArray:tagViews] || [self fitsScreen:tagLabel] == NO) {
                CGPoint center = [self getNextRandomPositionForView:tagLabel];
                tagLabel.frame = CGRectMake(center.x - size.width * 0.5f, center.y - size.height * 0.5f, size.width, size.height);
                if (try++ >= MAX_POSITION_TRIES) {
                    break;
                }
            }
            break;
        }*/
    }
    
    //tagLabel.backgroundColor = [UIColor yellowColor];
    return tagLabel;
}

@end
