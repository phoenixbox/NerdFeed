//
//  RSSItem.h
//  NerdFeed
//
//  Created by Shane Rogers on 12/1/13.
//  Copyright (c) 2013 Shane Rogers. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSONSerializable.h"

@interface RSSItem : NSObject <NSXMLParserDelegate, JSONSerializable, NSCoding>
{
    NSMutableString *currentString;
}
@property (nonatomic, strong)id parentParserDelegate;

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *link;

@property (nonatomic, strong) NSDate *publicationDate;


@end
