//
//  FEZDatabaseConnector.m
//  FirebaseEZ
//
//  Created by Joan Molinas Ramon on 29/12/16.
//  Copyright © 2016 NSBeard. All rights reserved.
//

#import "FEZDatabaseConnector.h"

@interface FEZDatabaseConnector ()
@property (nonatomic, strong) FIRDatabaseReference *reference;
@property (nonatomic, assign) FIRDatabaseHandle addedHandler;
@property (nonatomic, assign) FIRDatabaseHandle removedHandler;
@property (nonatomic, assign) FIRDatabaseHandle changedHandler;
@property (nonatomic, assign) FIRDatabaseHandle movedHandler;
@property (nonatomic, assign) FIRDatabaseHandle valueHandler;
 @end

@implementation FEZDatabaseConnector

+ (instancetype)linkWithDatabaseName:(NSString *)databaseName {
    return [[FEZDatabaseConnector alloc] initWithDatabaseName:databaseName];
}

- (instancetype)initWithDatabaseName:(NSString *)databaseName {
    if (self = [super init]) {
        NSAssert([FEZManager sharedManager].configured, @"Configure FEZManager first");
        _databaseName = databaseName;
        _reference = [[FIRDatabase database] reference];
        
        _objects = [NSMutableArray new];
    }
    
    return self;
}

- (void)observeWithType:(FEZDatabaseEvent)type {
    switch (type) {
        case FEZDatabaseEventAddedObject:
            self.addedHandler = [self _observeEventTypeChildAdded];
            break;
        case FEZDatabaseEventRemovedObject:
            self.removedHandler = [self _observeEventTypeChildRemoved];
            break;
        case FEZDatabaseEventChangedObject:
            self.changedHandler = [self _observeEventTypeChildChanged];
            break;
        case FEZDatabaseEventMovedObject:
            self.movedHandler = [self _observeEventTypeChildMoved];
            break;
        case FEZDatabaseEventValue:
            self.valueHandler = [self _observeEventTypeValue];
            break;
        default:
            break;
    }
}

- (void)observeSingleEventOfType:(FEZDatabaseEvent)type
                       withBlock:(void (^)(FIRDataSnapshot *value, NSError *error))block{
    FIRDatabaseHandle handler;
    switch (type) {
        case FEZDatabaseEventAddedObject:
            handler = FIRDataEventTypeChildAdded;
            break;
        case FEZDatabaseEventRemovedObject:
            handler = FIRDataEventTypeChildRemoved;
            break;
        case FEZDatabaseEventChangedObject:
            handler = FIRDataEventTypeChildChanged;
            break;
        case FEZDatabaseEventMovedObject:
            handler = FIRDataEventTypeChildMoved;
            break;
        case FEZDatabaseEventValue:
            handler = FIRDataEventTypeValue;
            break;
        default:
            break;
    }
    
    [[self.reference child:_databaseName]
     observeSingleEventOfType:handler
     withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
         block(snapshot, nil);
     } withCancelBlock:^(NSError * _Nonnull error) {
         block(nil, error);
     }];
}

- (void)dropWithType:(FEZDatabaseEvent)type {
    FIRDatabaseHandle handler;
    switch (type) {
        case FEZDatabaseEventAddedObject:
            handler = self.addedHandler;
            break;
        case FEZDatabaseEventRemovedObject:
            handler = self.removedHandler;
            break;
        case FEZDatabaseEventChangedObject:
            handler = self.changedHandler;
            break;
        case FEZDatabaseEventMovedObject:
            handler = self.movedHandler;
            break;
        case FEZDatabaseEventValue:
            handler = self.valueHandler;
            break;
        default:
            break;
    }
    
    [self.reference removeObserverWithHandle:handler];
}

- (void)send:(NSDictionary *)message withCompletionBlock:(void(^)(NSError * _Nullable error))completionBlock {
    [[[self.reference child:self.databaseName] childByAutoId] setValue:[message copy] withCompletionBlock:^(NSError * _Nullable error, FIRDatabaseReference * _Nonnull ref) {
        completionBlock(error);
    }];
}

- (void)updateValues:(NSDictionary *)values withCompletionBlock:(void (^)(NSError * _Nullable))completionBlock {
    [[self.reference child:self.databaseName] updateChildValues:values withCompletionBlock:^(NSError * _Nullable error, FIRDatabaseReference * _Nonnull ref) {
        
    }];
    
    
}

- (void)remove {
    [[self.reference child:self.databaseName] removeValue];
}

- (BOOL)isConnected {
    return self.addedHandler || self.removedHandler || self.changedHandler || self.movedHandler || self.valueHandler;
}


#pragma mark - Private Api
- (FIRDatabaseHandle)_observeEventTypeChildAdded {
    __weak typeof(self)weakSelf = self;
    FIRDatabaseHandle handle = [[self.reference child:_databaseName] observeEventType:FIRDataEventTypeChildAdded withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        __strong typeof(weakSelf)strongSelf = weakSelf;
        [strongSelf.objects addObject:snapshot.value];
        [strongSelf.delegate databaseConnector:strongSelf objectIdentifier:snapshot.key didAddNewObject:snapshot.value];
    }];
    
    return handle;
}
- (FIRDatabaseHandle)_observeEventTypeChildRemoved {
    __weak typeof(self)weakSelf = self;
    FIRDatabaseHandle handle = [[self.reference child:_databaseName] observeEventType:FIRDataEventTypeChildRemoved withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        __strong typeof(weakSelf)strongSelf = weakSelf;
        [strongSelf.objects removeObject:snapshot.value];
        [strongSelf.delegate databaseConnector:strongSelf objectIdentifier:snapshot.key didRemoveObject:snapshot.value];
    }];
    
    return handle;
}

- (FIRDatabaseHandle)_observeEventTypeChildChanged {
    __weak typeof(self)weakSelf = self;
    FIRDatabaseHandle handle = [[self.reference child:_databaseName] observeEventType:FIRDataEventTypeChildChanged withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        __strong typeof(weakSelf)strongSelf = weakSelf;
        [strongSelf.delegate databaseConnector:strongSelf objectIdentifier:snapshot.key didChangedObject:snapshot.value];
    }];
    
    return handle;
}

- (FIRDatabaseHandle)_observeEventTypeChildMoved {
    __weak typeof(self)weakSelf = self;
    FIRDatabaseHandle handle = [[self.reference child:_databaseName] observeEventType:FIRDataEventTypeChildMoved withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        __strong typeof(weakSelf)strongSelf = weakSelf;
        [strongSelf.delegate databaseConnector:strongSelf objectIdentifier:snapshot.key didMovedObject:snapshot.value];
    }];
    
    return handle;
}

- (FIRDatabaseHandle)_observeEventTypeValue {
    __weak typeof(self)weakSelf = self;
    FIRDatabaseHandle handle = [[self.reference child:_databaseName] observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        __strong typeof(weakSelf)strongSelf = weakSelf;
        [strongSelf.delegate databaseConnector:strongSelf objectIdentifier:snapshot.key fireEventObject:snapshot.value];
    }];
    
    return handle;
}


- (void)child:(NSString *)clildID observeSingleEventOfType:(FEZDatabaseEvent)type {
//    [[[_reference child:_databaseName] child:clildID]
//     observeEventType:FIRDataEventTypeValue
//     withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
//     
//     } withCancelBlock:^(NSError * _Nonnull error) {
//     
//     }];
}

- (void)queryByValue:(NSString *)value {
    __weak typeof(self)weakSelf = self;
    [[[self.reference child:self.databaseName] queryOrderedByChild:value] observeEventType:FIRDataEventTypeChildAdded withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        __strong typeof(weakSelf)strongSelf = weakSelf;
        [strongSelf.delegate databaseConnector:strongSelf
                              objectIdentifier:snapshot.key
                               didAddNewObject:snapshot.value];
    }];
}

- (void)queryByValue:(NSString *)value
     startingAtValue:(NSString *)startValue {
    __weak typeof(self)weakSelf = self;
    [[[[self.reference child:self.databaseName] queryOrderedByChild:value] queryStartingAtValue:startValue] observeEventType:FIRDataEventTypeChildAdded  withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        __strong typeof(weakSelf)strongSelf = weakSelf;
        [strongSelf.delegate databaseConnector:strongSelf
                              objectIdentifier:snapshot.key
                               didAddNewObject:snapshot.value];
    }];
}

//Using an unspecified index. Consider adding ".indexOn": "date" at /notifications/TjVqNmmjMEds0auotYEzBZCqwuA3 to your security rules for better performance

@end
