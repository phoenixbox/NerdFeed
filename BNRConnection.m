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
-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    id rootObject = nil;
    // If there is a root object - then parse the data
    if([self xmlRootObject]){
        // Create the parser with the incoming data and let the root object parse its contents
        NSXMLParser *parser = [[NSXMLParser alloc]initWithData:container];
        [parser setDelegate:[self xmlRootObject]];
        [parser parse];
    } else if ([self jsonRootObject]){
        // Turn the JSON into model objects
        NSDictionary *d = [NSJSONSerialization JSONObjectWithData:container
                                                          options:0
                                                            error:nil];
        // Have the root json object construct itself from the basic model objects
        [[self jsonRootObject] readFromJSONDictionary:d];
        
        rootObject = [self jsonRootObject];
    }
    // Pass the root object to the completion block supplied by the controller
    if([self completionBlock]){
        [self completionBlock]([self xmlRootObject], nil);
    }
    
    // Destroy the connection
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
