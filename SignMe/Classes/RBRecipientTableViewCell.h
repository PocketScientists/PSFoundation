//
//  RBRecipientTableViewCell.h
//  SignMe
//
//  Created by Tretter Matthias on 28.07.11.
//  Copyright 2011 NOUS Wissensmanagement GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ABTableViewCell.h"

@interface RBRecipientTableViewCell : ABTableViewCell

+ (NSString *)cellIdentifier;
+ (id)cellForTableView:(UITableView *)tableView style:(UITableViewCellStyle)style;

@property (nonatomic, retain) UIImage *image;
@property (nonatomic, copy) NSString *mainText;
@property (nonatomic, copy) NSString *detailText;

@end
