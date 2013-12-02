//
//  ListViewController.h
//  NerdFeed
//
//  Created by Shane Rogers on 12/1/13.
//  Copyright (c) 2013 Shane Rogers. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RSSChannel;

@interface ListViewController : UITableViewController
{
    NSURLConnection *connection;
    NSMutableData *xmlData;
    
    RSSChannel *channel;
}

-(void)fetchEntries;

@end
