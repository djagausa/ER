//
//  CoreDataHelper.h
//  ExerciseRecording
//
//  Created by Douglas Alexander on 3/28/15.
//  Copyright (c) 2015 Douglas Alexander. All rights reserved.
//

@import CoreData;


@interface CoreDataHelper : NSObject
@property (nonatomic) NSString *defaultSortAttribute;

@property (nonatomic) NSManagedObjectContext *managedObjectContext;
@property (nonatomic) NSFetchedResultsController *fetchedResultsController;

@property (nonatomic, readonly) NSInteger numberOfSections;
@property (nonatomic, readonly) NSInteger numberOfEntities;

//- (void)setupCoreData;

- (void)fetchData;
- (void)fetchItemsMatching:(NSString *)entityName forAttribute:(NSString *)attribute sortingBy:(NSString *)sortAttribute withPredicate:(NSDictionary *)predicate groupBy:(NSString *)groupBy;
- (NSArray*)fetchDefaultDataFor:(NSString *)entityName withSortKey:(NSString *)sortKey ascending:(BOOL)ascending usePredicate:(BOOL)usePredicate;
- (BOOL)save;
- (NSManagedObject *)newObject:(NSString *)entityName;
- (NSArray*)fetchDataFor:(NSString *)entityName  withPredicate:(NSDictionary *)predicate;

- (BOOL)clearData;
- (BOOL)deleteObject:(NSManagedObject *)object;

- (NSInteger)numberOfItemsInSection:(NSInteger)section;
- (NSInteger)numberOfEntities:(NSString *)entityName;

@end

