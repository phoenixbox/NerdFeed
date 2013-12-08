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
#import "RSSItem.h"

@implementation BNRFeedStore

+(BNRFeedStore *)sharedStore {
    static BNRFeedStore *feedStore = nil;
    
    if(!feedStore) {
        feedStore = [[BNRFeedStore alloc]init];
    };
    return feedStore;
}

-(id)init
{
    self = [super init];
    
    if(self){
        model = [NSManagedObjectModel mergedModelFromBundles:nil];
        NSPersistentStoreCoordinator *psc = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model];
        
        NSError *error = nil;
        NSString *dbPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES) objectAtIndex:0];
        dbPath = [dbPath stringByAppendingPathComponent:@"feed.db"];
        NSURL *dbURL = [NSURL fileURLWithPath:dbPath];
        
        if(![psc addPersistentStoreWithType:NSSQLiteStoreType
                              configuration:nil
                                        URL:dbURL
                                    options:nil
                                      error:&error]){
            [NSException raise:@"Open failed"
                        format:@"Reason: %@", [error localizedDescription]];
        }
        
        context = [[NSManagedObjectContext alloc]init];
        [context setPersistentStoreCoordinator:psc];
        
        [context setUndoManager:nil];
    }
    return self;
}

- (RSSChannel *)fetchRSSFeedWithCompletion:(void (^)(RSSChannel *obj, NSError *err))block
{
    NSURL *url = [NSURL URLWithString:@"http://forums.bignerdranch.com/"
                  @"smartfeed.php?limit=1_DAY&sort_by=standard"
                  @"&feed_type=RSS2.0&feed_style=COMPACT"];
    
    NSURLRequest *req = [NSURLRequest requestWithURL:url];
    
    // Create an empty channel
    RSSChannel *channel = [[RSSChannel alloc] init];
    
    // Create a connection "actor" object that will transfer data from the server
    BNRConnection *connection = [[BNRConnection alloc] initWithRequest:req];
    
    // When the connection completes, this block from the controller will be executed.
    NSString *cachePath =
    [NSSearchPathForDirectoriesInDomains(NSCachesDirectory,
                                         NSUserDomainMask,
                                         YES) objectAtIndex:0];
    
    cachePath = [cachePath stringByAppendingPathComponent:@"nerd.archive"];
    
    // Load the cached channel, or create an empty one to fill up
    RSSChannel *cachedChannel = [NSKeyedUnarchiver unarchiveObjectWithFile:cachePath];
    if(!cachedChannel)
        cachedChannel = [[RSSChannel alloc] init];
    
    RSSChannel *channelCopy = [cachedChannel copy];
    
    // When the connection completes, this block from the controller will be executed.
    [connection setCompletionBlock:^(RSSChannel *obj, NSError *err) {
        if(!err) {
            [channelCopy addItemsFromChannel:obj];
            [NSKeyedArchiver archiveRootObject:channelCopy toFile:cachePath];
        }
        
        block(channelCopy, err);
    }];
    
    // Let the empty channel parse the returning data from the web service
    [connection setXmlRootObject:channel];
    
    // Begin the connection
    [connection start];
    
    return cachedChannel;
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
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    // Execute the controller's completion block to reload its table
                    block(cachedChannel, nil);
                }];
    
                // Don't need to make the request, just get out of this method
                return;
            }
        }
    }
    
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
-(void)markItemAsRead:(RSSItem *)item
{
    //If the item is already in CoreData no need for duplicates
    if([self hasItemBeenRead:item]){
        return;
    }
    // Create a new link object and insert it into the context
    NSManagedObject *obj = [NSEntityDescription insertNewObjectForEntityForName:@"Link"
                                                         inManagedObjectContext:context];
    
    // Set the links URLString from the RSSItem
    [obj setValue:[item link] forKey:@"urlString"];
    
    // immediately save the changes
    [context save:nil];
}
-(BOOL)hasItemBeenRead:(RSSItem *)item
{
    // Create a request to fetch (from Core Data) all the links with the same url String as the item argument passsed
    NSFetchRequest *req = [[NSFetchRequest alloc]initWithEntityName:@"Link"];
    
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"urlString like %@", [item link]];
    [req setPredicate:pred];
    
    // If link count > 0 - then it has been read
    NSArray *entries = [context executeFetchRequest:req error:nil];
    if([entries count]>0){
        return YES;
    }
    // If the link count !> 0 - return NO
    return NO;
}
@end
