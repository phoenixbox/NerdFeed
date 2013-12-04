//
//  ListViewController.h
//  NerdFeed
//
//  Created by Shane Rogers on 12/1/13.
//  Copyright (c) 2013 Shane Rogers. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RSSChannel;
@class WebViewController;

@interface ListViewController : UITableViewController <NSXMLParserDelegate>
{
    NSURLConnection *connection;
    NSMutableData *xmlData;
    
    RSSChannel *channel;
}

@property (nonatomic, strong) WebViewController * webViewController;

-(void)fetchEntries;

@end

// A new protocol named ListViewControllerDelegate
@protocol ListViewControllerDelegate <NSObject>
// Classes that conform to this protocol must implement this method:
- (void)listViewController:(ListViewController *)lvc handleObject:(id)object;
@end