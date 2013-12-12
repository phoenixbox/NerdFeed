//
//  BNRConnection.m
//  NerdFeed
//
//  Created by Shane Rogers on 12/7/13.
//  Copyright (c) 2013 Shane Rogers. All rights reserved.
//

#import "BNRConnection.h"

// Keep a reference to all connections so they are not released by ARC
static NSMutableArray *sharedConnectionList = nil;

@implementation BNRConnection
@synthesize request, completionBlock, xmlRootObject, jsonRootObject;

-(id)initWithRequest:(NSURLRequest *)req
{
    self = [super init];
    if (self) {
        [self setRequest:req];
    }
    return self;
}
-(void)start
{
    // Initialize container for data collected from the NSURLConnection
    container = [[NSMutableData alloc]init];
    // Spawn Connection
    internalConnection = [[NSURLConnection alloc]initWithRequest:[self request]
                                                        delegate:self
                                                startImmediately:YES];
    
    // Create the static connection array if this is the first connection
    if(!sharedConnectionList){
        sharedConnectionList = [[NSMutableArray alloc]init];
    }
    // Add the connection to the Array so its not auto released by ARC
    [sharedConnectionList addObject:self];
}
-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [container appendData:data];
}
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    id rootObject = nil;
    if ([self xmlRootObject]) {
        NSXMLParser *parser = [[NSXMLParser alloc] initWithData:container];
        [parser setDelegate:[self xmlRootObject]];
        [parser parse];
        rootObject = [self xmlRootObject];
    } else if ([self jsonRootObject]) {
            // Turn JSON data into basic model objects
            NSDictionary *d = [NSJSONSerialization JSONObjectWithData:container
                                                              options:0
                                                                error:nil];
            // Have the root object construct itself from basic model objects
            [[self jsonRootObject] readFromJSONDictionary:d];
            rootObject = [self jsonRootObject];
        }
    if ([self completionBlock]){
        [self completionBlock](rootObject, nil);
    }
    [sharedConnectionList removeObject:self];
}
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    // Pass the error from the connection to the completionBlock
    if([self completionBlock]){
        [self completionBlock](nil, error);
    }
    
    // Destroy the connection
    [sharedConnectionList removeObject:self];
}
@end
