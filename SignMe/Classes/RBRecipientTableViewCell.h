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

@property (nonatomic, strong) UIImage *image;
@property (nonatomic, copy) NSString *mainText;
@property (nonatomic, copy) NSString *detailText;
@property (nonatomic, copy) NSString *placeholderText;
@property (nonatomic, assign) int code;
@property (nonatomic, assign) int signerType;
@property (nonatomic, assign) int orderOfSigner;
@property (nonatomic, assign) BOOL idcheck;
@property (nonatomic, unsafe_unretained) id<RBRecipientTableViewCellDelegate> delegate;

- (void)enableAuth;
- (void)disableAuth;
- (void)enableTypeSelection;
- (void)disableTypeSelection;

@end

@protocol RBRecipientTableViewCellDelegate <NSObject>
- (void)cell:(RBRecipientTableViewCell *)cell changedCode:(int)code idCheck:(BOOL)idCheck;
- (void)cell:(RBRecipientTableViewCell *)cell changedSignerType:(int)type;
- (void)didSelectRowWithOrderOfSigner:(NSUInteger)orderType AndTouches:(NSSet *)touches;
@end
