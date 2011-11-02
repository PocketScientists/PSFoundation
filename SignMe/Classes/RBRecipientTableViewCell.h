//
//  RBRecipientTableViewCell.h
//  SignMe
//
//  Created by Tretter Matthias on 28.07.11.
//  Copyright 2011 NOUS Wissensmanagement GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ABTableViewCell.h"

@protocol RBRecipientTableViewCellDelegate;

@interface RBRecipientTableViewCell : ABTableViewCell

+ (NSString *)cellIdentifier;
+ (id)cellForTableView:(UITableView *)tableView style:(UITableViewCellStyle)style;

@property (nonatomic, retain) UIImage *image;
@property (nonatomic, copy) NSString *mainText;
@property (nonatomic, copy) NSString *detailText;
@property (nonatomic, copy) NSString *placeholderText;
@property (nonatomic, assign) int code;
@property (nonatomic, assign) BOOL idcheck;
@property (nonatomic, assign) id<RBRecipientTableViewCellDelegate> delegate;

- (void)enableAuth;
- (void)disableAuth;

@end

@protocol RBRecipientTableViewCellDelegate <NSObject>
- (void)cell:(RBRecipientTableViewCell *)cell changedCode:(int)code idCheck:(BOOL)idCheck;
@end
