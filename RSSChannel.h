//
//  RSSChannel.h
//  NerdFeed
//
//  Created by Shane Rogers on 12/1/13.
//  Copyright (c) 2013 Shane Rogers. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSONSerializable.h

@interface RSSChannel : NSObject <NSXMLParserDelegate, JSONSerializable>
{
    NSMutableString *currentString;
}

@property (nonatomic, weak)id parentParserDelegate;

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *infoString;
@property (nonatomic, readonly, strong) NSMutableArray *items;

-(void)trimItemTitles;

@end
