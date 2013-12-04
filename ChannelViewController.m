//
//  ChannelViewController.m
//  NerdFeed
//
//  Created by Shane Rogers on 12/3/13.
//  Copyright (c) 2013 Shane Rogers. All rights reserved.
//

#import "ChannelViewController.h"
#import "RSSChannel.h"

@implementation ChannelViewController

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
    
    if(!cell){
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue2
                                     reuseIdentifier:@"UITableViewCell"];
    }
    // For the alternate channel info view - want two lines with title and description
    if([indexPath row]==0){
        // Title of channel in row 0
        [[cell textLabel]setText:@"Title"];
        [[cell detailTextLabel]setText:[channel title]];
    } else {
        // Put the description of the channel in row 1
        [[cell textLabel] setText:@"Info"];
        [[cell detailTextLabel] setText:[channel infoString]];
    }
    return cell;
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)io
{
    if([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPad){
        return YES;
    }
    return io == UIInterfaceOrientationLandscapeLeft;
}
-(void)listViewController:(ListViewController *)lvc handleObject:(id)object
{
    // Make sure the argument passed is and RSSChannel object
    if(![object isKindOfClass:[RSSChannel class]]){
        return;
    }
    channel = object;
    
    [[self tableView]reloadData];
}
-(void)splitViewController:(UISplitViewController *)svc
    willHideViewController:(UIViewController *)aViewController
         withBarButtonitem:(UIBarButtonItem *)barButtonItem
      forPopoverController:(UIPopoverController *)pc
{
    // Give the button a name or it wont show
    [barButtonItem setTitle:@"List"];
    // Set the button in the navigation
    [[self navigationItem] setLeftBarButtonItem:barButtonItem];
}
-(void)splitViewController:(UISplitViewController *)svc
    willShowViewController:(UIViewController *)aViewController
 invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    if(barButtonItem == [[self navigationItem] leftBarButtonItem]){
        [[self navigationItem] setLeftBarButtonItem:nil];
    }
}
@end
