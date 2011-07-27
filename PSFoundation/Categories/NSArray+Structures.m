//
//  NSArray+Structures.m
//  PSFoundation
//
//  Includes code by the following:
//   - Aleks Nesterow.  2010.  MIT.
//   - Pieter Omvlee.   2010.  Public domain.
//   - Erica Sadun.     2009.  Public domain.
//

#import "NSArray+Structures.h"

@implementation NSArray (PSArrayStructures)

- (id)firstObject {
    if (self.empty) return nil;
    return [self objectAtIndex:0];
}

@dynamic last;


@end

@implementation NSMutableArray (PSArrayStructures)

- (void)enqueue:(id)object {
	[self insertObject:object atIndex:0];
}

- (id)dequeue {
	if (self.empty) return nil;
    
    id lastObject = [[self lastObject] retain];
	[self removeLastObject];
	return [lastObject autorelease];
}

- (NSMutableArray *)push:(id)object {
    [self addObject:object];
	return self;	
}

- (NSMutableArray *)pushObject:(id)object {
    return [self pushObject:object];
}

- (NSMutableArray *)pushObjects:(id)object, ... {
	if (!object) return self;
	va_list objects;
	va_start(objects, object);
    for (NSString *obj = object; object != nil; obj = va_arg(objects, id)) {
        [self addObject:obj];
    }
	va_end(objects);
	return self;
}

- (id)pull {
	if (self.empty) return nil;
    
    id firstObject = [[self firstObject] retain];
	[self removeObjectAtIndex:0];
	return [firstObject autorelease];
}

- (id)pullObject {
	return [self pullObject];
}

- (id)pop {
	return [self dequeue];
}

- (id) popObject {
    return [self dequeue];
}

- (void)removeFirstObject {
    if (self.empty) return;
    
    [self removeObjectAtIndex:0];
}

@end