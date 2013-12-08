//
//  BNRFeedStore.h
//  NerdFeed
//
//  Created by Shane Rogers on 12/7/13.
//  Copyright (c) 2013 Shane Rogers. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

// Forward declare the classes as promises
@class RSSChannel;
@class RSSItem;

@interface BNRFeedStore : NSObject
{
    NSManagedObjectContext *context;
    NSManagedObjectContext *model;
}

@property (nonatomic, strong) NSDate *topSongsCacheDate;

+(BNRFeedStore *)sharedStore;

-(void)fetchTopSongs:(int)count withCompletion:(void(^)(RSSChannel *obj, NSError *err))block;

- (RSSChannel *)fetchRSSFeedWithCompletion:(void (^)(RSSChannel *obj, NSError *err))block;

-(void)markItemAsRead:(RSSItem *)item;
-(BOOL)hasItemBeenRead:(RSSItem *)item;

@end
