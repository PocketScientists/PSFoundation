//
//  PSTableViewController.h
//  PSFoundation
//
//  Created by Peter Steinberger on 05.10.10.
//  Copyright 2010 Peter Steinberger. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PSBaseViewController.h"

// custom reimplementation of UITableViewController for more flexibility
@interface PSBaseTableViewController : PSBaseViewController <UITableViewDelegate, UITableViewDataSource> {
@private
  BOOL useShadows;
  UITableView *tableView;
  UITableViewStyle _tableViewStyle;
}

@property (nonatomic, retain) UITableView *tableView;
@property (nonatomic, readonly) UITableViewStyle tableViewStyle;
@property (nonatomic) BOOL useShadows;


- (id)initWithStyle:(UITableViewStyle)style;
- (UITableView *)createTableView;

@end
