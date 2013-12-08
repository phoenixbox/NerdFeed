//
//  BNRFeedStore.m
//  NerdFeed
//
//  Created by Shane Rogers on 12/7/13.
//  Copyright (c) 2013 Shane Rogers. All rights reserved.
//

#import "BNRFeedStore.h"
#import "RSSChannel.h"
#import "BNRConnection.h"

@implementation BNRFeedStore

+(BNRFeedStore *)sharedStore {
    static BNRFeedStore *feedStore = nil;
    
    if(!feedStore) {
        feedStore = [[BNRFeedStore alloc]init];
    };
    return feedStore;
}

-(void)fetchRSSFeedWithCompletion:(void(^)(RSSChannel *obj, NSError *err))block
{
    NSString *requestString = @"http://forums.bignerdranch.com/"
    @"smartfeed.php?limit=1_DAY&sort_by=standard"
    @"&feed_type=RSS2.0&feed_style=COMPACT";
    
    NSURL *url = [NSURL URLWithString:requestString];
    NSURLRequest *req = [NSURLRequest requestWithURL:url];
    
    // Create the empty channel to pass to connection
    RSSChannel *channel = [[RSSChannel alloc]init];
    
    // Create the connection actor that transfers data from the server
    BNRConnection *connection = [[BNRConnection alloc]initWithRequest:req];
    
    // When the connnection completes - call the controller block
    [connection setCompletionBlock:block];
    
    // Let the empty channel parse the returning data from the web service
    [connection setXmlRootObject:channel];
    
    // Begin the connection
    [connection start];
}

-(void)fetchTopSongs:(int)count withCompletion:(void (^)(RSSChannel *, NSError *))block
{
    // Construct the cache path
    NSString *cachePath =
    [NSSearchPathForDirectoriesInDomains(NSCachesDirectory,
                                         NSUserDomainMask,
                                         YES) objectAtIndex:0];
    cachePath = [cachePath stringByAppendingPathComponent:@"apple.archive"];
    
    // Make sure we have cached at least once before by checking to see
    // if this date exists!
    NSDate *tscDate = [self topSongsCacheDate];
    if (tscDate) {
        // How old is the cache?
        NSTimeInterval cacheAge = [tscDate timeIntervalSinceNow];
        if (cacheAge > -300.0) {
            // If it is less than 300 seconds (5 minutes) old, return cache
            // in completion block
            NSLog(@"Reading cache!");
            RSSChannel *cachedChannel = [NSKeyedUnarchiver
                                         unarchiveObjectWithFile:cachePath];
            if (cachedChannel) {
                // Execute the controller's completion block to reload its table
                block(cachedChannel, nil);
                // Don't need to make the request, just get out of this method
                return; }
        } }
    
    // Prepare a request URL incl. controller argument passed over
    NSString *requestString = [NSString stringWithFormat:@"http://itunes.apple.com/us/rss/topsongs/limit=%d/json", count];
    NSURL *url = [NSURL URLWithString:requestString];
    
    // Set the connection
    NSURLRequest *req = [NSURLRequest requestWithURL:url];
    RSSChannel *channel = [[RSSChannel alloc]init];
    BNRConnection *connection = [[BNRConnection alloc]initWithRequest:req];
    
    [connection setCompletionBlock:^(RSSChannel *obj, NSError *err) {
        // This is the store's completion code:
        // If everything went smoothly, save the channel to disk and set cache date
        if (!err) {
            [self setTopSongsCacheDate:[NSDate date]];
            [NSKeyedArchiver archiveRootObject:obj toFile:cachePath];
        }
        // This is the controller's completion code:
        block(obj, err);
    }];
    [connection setJsonRootObject:channel];
    
    [connection start];
}
// topSongsCacheDate SETTER
-(void)setTopSongsCacheDate:(NSDate *)topSongsCacheDate
{
    [[NSUserDefaults standardUserDefaults] setObject:topSongsCacheDate
                                              forKey:@"topSongsCacheDate"];
}
// topSongsCacheDate GETTER
-(NSDate *)topSongsCacheDate
{
    return [[NSUserDefaults standardUserDefaults]objectForKey:@"topSongsCacheDate"];
}
@end
