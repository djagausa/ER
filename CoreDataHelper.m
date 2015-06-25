//
//  CoreDataHelper.m
//  ExerciseRecording
//
//  Created by Douglas Alexander on 3/28/15.
//  Copyright (c) 2015 Douglas Alexander. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CoreDataHelper.h"

@implementation CoreDataHelper

#pragma mark - Core Data
- (void)fetchItemsMatching:(NSString *)entityName forAttribute:(NSString *)attribute sortingBy:(NSString *)sortAttribute withPredicate:(NSDictionary *)predicate groupBy:(NSString *)groupBy
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:self.managedObjectContext];
        
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
    if ([predicate count] > 0) {
        NSPredicate *filter = [NSPredicate predicateWithFormat:@"%K like[cd] %@",predicate[@"propertyName"], predicate[@"value"]];
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

- (NSArray*)fetchDefaultDataFor:(NSString *)entityName withSortKey:(NSString *)sortKey ascending:(BOOL)ascending usePredicate:(BOOL)usePredicate
{
    NSFetchRequest *fetchRequst = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:self.managedObjectContext];
    [fetchRequst setEntity:entity];
    
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:sortKey ascending:ascending];
    [fetchRequst setSortDescriptors:[NSArray arrayWithObject:sort]];
    
    if (usePredicate) {
        NSPredicate *filter = [NSPredicate predicateWithFormat:@"enabled == YES"];
        [fetchRequst setPredicate:filter];
    }

    NSError *error;
    NSArray *defaultData = [self.managedObjectContext executeFetchRequest:fetchRequst error:&error];

    return defaultData;
}

- (NSArray*)fetchDataFor:(NSString *)entityName  withPredicate:(NSDictionary *)predicate
{
    NSFetchRequest *fetchRequst = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:self.managedObjectContext];
    [fetchRequst setEntity:entity];
    
    if ([predicate count] > 0) {
        NSPredicate *filter = [NSPredicate predicateWithFormat:@"%K == %@", predicate[@"propertyName"], predicate[@"value"]];
        [fetchRequst setPredicate:filter];
    }
    
    NSError *error;
    NSArray *defaultData = [self.managedObjectContext executeFetchRequest:fetchRequst error:&error];
    
    return defaultData;
}

- (ScheduledEvent *)fetchScheduledEvent:(NSArray *)scheduledEvents week:(NSInteger)week day:(NSInteger)day
{
    // if events exists
    if ([scheduledEvents count] > 0) {
        Schedule *schedule;
        schedule = [scheduledEvents firstObject];
        NSSet *scheduledDayEvents = schedule.scheduledEvents;
        NSLog(@"Count: %ld", scheduledDayEvents.count);
        
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"day" ascending:YES];
        NSArray *sortedSchedule = [scheduledDayEvents sortedArrayUsingDescriptors:[NSArray arrayWithObjects:sortDescriptor, nil]];
        
        // lookk for an event for the selected cell
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(week == %ld) && (day == %ld)", week, day];
        
        NSArray *events = [sortedSchedule filteredArrayUsingPredicate:predicate];
        if ([events count] > 0){
            // only one entry per day
            ScheduledEvent *dayEvent = [events firstObject];
#ifdef DEBUG
            NSLog(@"Week: %@; Day: %@; Color: %@; Aerobic Event Count: %ld; Weight Event Count: %ld", dayEvent.week, dayEvent.day, dayEvent.cellColor, dayEvent.aerobicEvent.count, dayEvent.weightEvent.count );
#endif
            return dayEvent;
        }
    }
    return nil;
}

- (NSArray *)fetchSaveEvents:(NSString *)entityName fetchPropertyName:(NSString *)fetchPropertyName fetchPropertyCategory:(NSString *)fetchPropertyCategory
{
    NSFetchRequest *fetchRequst = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:self.managedObjectContext];
    [fetchRequst setEntity:entity];
    
    [fetchRequst setResultType:NSDictionaryResultType];
    [fetchRequst setReturnsDistinctResults:YES];
    [fetchRequst setPropertiesToFetch:@[fetchPropertyName, fetchPropertyCategory]];
    
    NSSortDescriptor *sortByProperty = [[NSSortDescriptor alloc] initWithKey:fetchPropertyName ascending:YES];
    [fetchRequst setSortDescriptors:[NSArray arrayWithObject:sortByProperty]];

    NSError *error;
    NSArray *objects = [self.managedObjectContext executeFetchRequest:fetchRequst error:&error];
    
    return objects;
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

- (NSInteger)numberOfEntities:(NSString *)entityName
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:entityName inManagedObjectContext:self.managedObjectContext]];
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
- (NSManagedObject *)newObject:(NSString *)entityName
{
    NSManagedObject *object = [NSEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext:self.managedObjectContext];
    return object;
}

@end