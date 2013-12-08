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
    // Prepare a request URL incl. controller argument passed over
    NSString *requestString = [NSString stringWithFormat:@"http://itunes.apple.com/us/rss/topsongs/limit=%d/json", count];
    NSURL *url = [NSURL URLWithString:requestString];
    
    // Set the connection
    NSURLRequest *req = [NSURLRequest requestWithURL:url];
    RSSChannel *channel = [[RSSChannel alloc]init];
    BNRConnection *connection = [[BNRConnection alloc]initWithRequest:req];
    [connection setCompletionBlock:block];
    
    [connection setJsonRootObject:channel];
    
    [connection start];
}

@end
