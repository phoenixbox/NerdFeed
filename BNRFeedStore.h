//
//  BNRFeedStore.h
//  NerdFeed
//
//  Created by Shane Rogers on 12/7/13.
//  Copyright (c) 2013 Shane Rogers. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RSSChannel;

@interface BNRFeedStore : NSObject

+(BNRFeedStore *)sharedStore;

-(void)fetchTopSongs:(int)count withCompletion:(void(^)(RSSChannel *obj, NSError *err))block;

-(void)fetchRSSFeedWithCompletion:(void (^)(RSSChannel *obj, NSError *err))block;

@end
