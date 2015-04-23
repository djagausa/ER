//
//  CoreDataHelper.h
//  ExerciseRecording
//
//  Created by Douglas Alexander on 3/28/15.
//  Copyright (c) 2015 Douglas Alexander. All rights reserved.
//

@import CoreData;


@interface CoreDataHelper : NSObject
@property (nonatomic) NSString *entityName;
@property (nonatomic) NSString *defaultSortAttribute;

@property (nonatomic) NSManagedObjectContext *managedObjectContext;
@property (nonatomic) NSFetchedResultsController *fetchedResultsController;

@property (nonatomic, readonly) BOOL hasStore;
@property (nonatomic, readonly) NSInteger numberOfSections;
@property (nonatomic, readonly) NSInteger numberOfEntities;

//- (void)setupCoreData;

- (void)fetchData;
- (void)fetchItemsMatching:(NSString *)searchString forAttribute:(NSString *)attribute sortingBy:(NSString *)sortAttribute withPredicate:(NSString *)predicate groupBy:(NSString *)groupBy;
- (NSArray*)fetchDefaultDataFor:(NSString *)entityName;
- (BOOL)save;
- (NSManagedObject *)newObject;
- (BOOL)clearData;
- (BOOL)deleteObject:(NSManagedObject *)object;

- (NSInteger)numberOfItemsInSection:(NSInteger)section;
@end

