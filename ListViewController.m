//
//  ListViewController.m
//  NerdFeed
//
//  Created by Shane Rogers on 12/1/13.
//  Copyright (c) 2013 Shane Rogers. All rights reserved.
//

#import "ListViewController.h"

@implementation ListViewController

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 0;
}

-(UITableViewCell *)tableView:(UITableViewCell *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

-(void)fetchEntries
{
    // Create an empty container to put the response in - assign it to our instance variable
    xmlData = [[NSMutableData alloc]init];
    
    // Construct a string URL to request data - concatenate strings over multiple lines
    NSURL *url = [NSURL URLWithString:
                  @"http://forums.bignerdranch.com/smartfeed.php?"
                  @"limit=1_DAY&sort_by=standard&feed_type=RSS2.0&feed_style=COMPACT"];
    // Or if want Apple's hot news feed
    // NSURL *url = [NSURL URLWithString:@"http://www.apple.com/pr/feeds/pr.rss"];
    
    //Convert the string URL to an NSURLRequest object
    NSURLRequest *req = [NSURLRequest requestWithURL:url];
    
    // Create a connection that will make the request - asssign it to the connection instance variable
    connection = [[NSURLConnection alloc] initWithRequest:req
                                                 delegate:self
                                         startImmediately:YES];
}
-(id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    
    if(self){
        [self fetchEntries];
    }
    return self;
}
// Called successively as data is received
-(void)connection:(NSURLConnection *)conn didReceiveData:(NSData *)data
{
    // Add the piece of data to the data container instance variable
    // The data order is always correct
    [xmlData appendData:data];
}
-(void)connectionDidFinishLoading:(NSURLConnection *)conn
{
    NSString *xmlCheck = [[NSString alloc]initWithData:xmlData encoding:NSUTF8StringEncoding];
    NSLog(@"xml check is this value = %@", xmlCheck);
}
-(void)connection:(NSURLConnection *)conn didFailWithError:(NSError *)error
{
    // Release the connection object
    connection = nil;
    
    // Release the xmlData object
    xmlData = nil;
    
    // Get the error description
    NSString *errorString = [NSString stringWithFormat:@"Fetch Failed: %@", [error localizedDescription]];
    
    // Display the error in an AlertView
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Error"
                                                 message:errorString
                                                delegate:nil
                                       cancelButtonTitle:@"OK"otherButtonTitles:nil];
    [av show];
}
@end
