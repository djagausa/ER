//
//  CoreDataHelper.m
//  ExerciseRecording
//
//  Created by Douglas Alexander on 3/28/15.
//  Copyright (c) 2015 Douglas Alexander. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CoreDataHelper.h"
#import "WeightLiftingEvent.h"
#import "DefaultWeightLifting.h"

#define DOCUMENTS_FOLDER [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]

@implementation CoreDataHelper

#pragma mark - Core Data
- (void)fetchItemsMatching:(NSString *)searchString forAttribute:(NSString *)attribute sortingBy:(NSString *)sortAttribute withPredicate:(NSString *)predicate groupBy:(NSString *)groupBy
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:self.entityName inManagedObjectContext:self.managedObjectContext];
    
//    [fetchRequest setResultType:NSDictionaryResultType];
    
    // set Attributes
    if ([attribute length] > 0) {
        NSAttributeDescription *searchAttribute = [entity.attributesByName objectForKey:attribute];
        [fetchRequest setPropertiesToGroupBy:[NSArray arrayWithObject:searchAttribute]];
    }
    
    [fetchRequest setEntity:entity];
    [fetchRequest setFetchBatchSize:0];
    
    // Apply an ascending sort for the items
    NSString *sortKey = sortAttribute ? : self.defaultSortAttribute;
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:sortKey ascending:NO selector:nil];
    NSArray *descriptors = @[sortDescriptor];
    fetchRequest.sortDescriptors = descriptors;
    
    // setup Predicate
    if ([predicate length] > 0) {
        NSPredicate *filter = [NSPredicate predicateWithFormat:@"defaultEvent.eventName like[cd] %@", predicate];
        [fetchRequest setPredicate:filter];
    }
    
    // setup Group BY
    if ([groupBy length] > 0) {
        NSAttributeDescription *grouping = [entity.attributesByName objectForKey:groupBy];
        [fetchRequest setPropertiesToGroupBy:[NSArray arrayWithObject:grouping]];
    }

    NSError *error;
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:@"sectionIdentifier" cacheName:@"Root"];
    
    // Perform the fetch
    if (![self.fetchedResultsController performFetch:&error])
        NSLog(@"Error fetching data: %@", error.localizedFailureReason);
}

- (void)fetchData
{
    [self fetchItemsMatching:nil forAttribute:nil sortingBy:nil withPredicate:nil groupBy:nil];
}

- (NSArray*)fetchDefaultDataFor:(NSString *)entityName
{
    NSFetchRequest *fetchRequst = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:self.managedObjectContext];
    [fetchRequst setEntity:entity];
    
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"eventName" ascending:YES];
    [fetchRequst setSortDescriptors:[NSArray arrayWithObject:sort]];
    
    NSPredicate *filter = [NSPredicate predicateWithFormat:@"enabled == YES"];
    [fetchRequst setPredicate:filter];
    
    NSError *error;
    NSArray *defaultData = [self.managedObjectContext executeFetchRequest:fetchRequst error:&error];

    return defaultData;
}
#pragma mark - Info
- (NSInteger)numberOfSections
{
    return self.fetchedResultsController.sections.count;
}

- (NSInteger)numberOfItemsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = self.fetchedResultsController.sections[section];
    return sectionInfo.numberOfObjects;
}

- (NSInteger)numberOfEntities
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:_entityName inManagedObjectContext:self.managedObjectContext]];
    [request setIncludesSubentities:YES];
    
    NSError __autoreleasing *error;
    NSUInteger count = [self.managedObjectContext countForFetchRequest:request error:&error];
    if(count == NSNotFound)
    {
        NSLog(@"Error: Could not count entities %@", error.localizedFailureReason);
        return 0;
    }
    
    return count;
}

# pragma mark - Management
// Save
- (BOOL)save
{
    NSError __autoreleasing *error;
    BOOL success;
    if (!(success = [self.managedObjectContext save:&error]))
        NSLog(@"Error saving context: %@", error.localizedFailureReason);
    return success;
}

// Delete all objects
- (BOOL)clearData
{
    [self fetchData];
    if (!self.fetchedResultsController.fetchedObjects.count) return YES;
    for (NSManagedObject *entry in _fetchedResultsController.fetchedObjects)
        [self.managedObjectContext deleteObject:entry];
    return [self save];
}

// Delete one object
- (BOOL)deleteObject:(NSManagedObject *)object
{
    [self.managedObjectContext.undoManager beginUndoGrouping];
    [self.managedObjectContext deleteObject:object];
    [self.managedObjectContext.undoManager endUndoGrouping];
    [self.managedObjectContext.undoManager setActionName:@"Delete"];
    return [self save];
}

// Create new object
- (NSManagedObject *)newObject
{
    NSManagedObject *object = [NSEntityDescription insertNewObjectForEntityForName:self.entityName inManagedObjectContext:self.managedObjectContext];
    return object;
}

/*
#pragma mark - Init
- (BOOL)hasStore
{
    if (!_entityName)
    {
        NSLog(@"Error: entity name not set");
        return NO;
    }
    
    NSString *path = [NSString stringWithFormat:@"%@/%@-collection.sqlite", DOCUMENTS_FOLDER, _entityName];
    return [[NSFileManager defaultManager] fileExistsAtPath:path];
}
*/

@end