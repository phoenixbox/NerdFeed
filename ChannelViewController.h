//
//  ChannelViewController.h
//  NerdFeed
//
//  Created by Shane Rogers on 12/3/13.
//  Copyright (c) 2013 Shane Rogers. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ListViewController.h"

@interface ChannelViewController : UITableViewController <ListViewControllerDelegate, UISplitViewControllerDelegate>
{
    RSSChannel *channel;
}
@end
