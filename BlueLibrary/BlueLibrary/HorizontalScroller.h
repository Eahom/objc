//
//  HorizontalScroller.h
//  BlueLibrary
//
//  Created by InfyMacBook on 18/03/15.
//  Copyright (c) 2015 Eli Ganem. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol HorizontalScrollerDelegate;

@interface HorizontalScroller : UIView

@property (weak) id<HorizontalScrollerDelegate> delegate;

- (void)reload;

@end

@protocol HorizontalScrollerDelegate <NSObject>

@required
/**
 *  ask the delegate how many views he wants to present inside the horizontal scroller
 *
 *  @param scroller
 *
 *  @return
 */
- (NSInteger)numberOfViewForHorizontalScroller:(HorizontalScroller *)scroller;

/**
 *  ask the delegate to return the view that should appear at <index>
 *
 *  @param scroller
 *  @param index
 *
 *  @return
 */
- (UIView *)horizontalScroller:(HorizontalScroller *)scroller viewAtIndex:(int)index;

/**
 *  inform the delegate what the view at <index> has been clicked
 *
 *  @param scroller
 *  @param index
 */
- (void)horizontalScroller:(HorizontalScroller *)scroller clickedViewAtIndex:(int)index;

@optional
/**
 *  ask teh delegate for the index of the initial view to display. this method is optional
 *  and defaults to 0 if it's not implemented by the delegate
 *
 *  @param scroller <#scroller description#>
 *
 *  @return <#return value description#>
 */
- (NSInteger)initialViewIndexForHorizontalScroller:(HorizontalScroller *)scroller;

@end