//
//  DetailCell.m
//  NerdFeed
//
//  Created by Shane Rogers on 12/11/13.
//  Copyright (c) 2013 Shane Rogers. All rights reserved.
//

#import "DetailCell.h"

@implementation DetailCell
@synthesize titleLabel, collectionLabel, thumbnailImage, priceLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
