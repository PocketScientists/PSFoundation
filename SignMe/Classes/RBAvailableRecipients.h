//
//  RBAvailableRecipients.h
//  SignMe
//
//  Created by Michael Schwarz on 11.09.12.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface RBAvailableRecipients : NSManagedObject

@property (nonatomic, retain) NSString * firstname;
@property (nonatomic, retain) NSString * lastname;
@property (nonatomic, retain) NSNumber * superiorGroup;
@property (nonatomic, retain) NSString * email;

@end
