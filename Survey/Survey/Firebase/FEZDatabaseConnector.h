//
//  FEZDatabaseConnector.h
//  FirebaseEZ
//
//  Created by Joan Molinas Ramon on 29/12/16.
//  Copyright © 2016 NSBeard. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FEZManager.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, FEZDatabaseEvent) {
    FEZDatabaseEventAddedObject = 0,
    FEZDatabaseEventRemovedObject,
    FEZDatabaseEventChangedObject,
    FEZDatabaseEventMovedObject,
    FEZDatabaseEventValue
};

@class FEZDatabaseConnector;
@protocol FEZDatabaseConnectorDelegate
@optional
- (void)databaseConnector:(FEZDatabaseConnector *)databaseConnector
         objectIdentifier:(NSString *)identifier
          didAddNewObject:(id)object;

- (void)databaseConnector:(FEZDatabaseConnector *)databaseConnector
         objectIdentifier:(NSString *)identifier
          didRemoveObject:(id)object;
- (void)databaseConnector:(FEZDatabaseConnector *)databaseConnector
         objectIdentifier:(NSString *)identifier
          didChangedObject:(id)object;
- (void)databaseConnector:(FEZDatabaseConnector *)databaseConnector
         objectIdentifier:(NSString *)identifier
          didMovedObject:(id)object;
- (void)databaseConnector:(FEZDatabaseConnector *)databaseConnector
         objectIdentifier:(NSString *)identifier
          fireEventObject:(id)object;
@end

@interface FEZDatabaseConnector : NSObject

@property (nonatomic, strong, readonly) NSString *databaseName;
@property (nonatomic, weak) id<FEZDatabaseConnectorDelegate> delegate;
@property (nonatomic, strong, readonly) NSMutableArray *objects;
@property (nonatomic, assign, readonly, getter=isConnected) BOOL connected;

+ (instancetype)linkWithDatabaseName:(NSString *)databaseName;

- (void)observeWithType:(FEZDatabaseEvent)type;
- (void)observeSingleEventOfType:(FEZDatabaseEvent)type
                       withBlock:(void (^)(FIRDataSnapshot * _Nullable value, NSError * _Nullable error))block;
- (void)dropWithType:(FEZDatabaseEvent)type;

- (void)send:(NSDictionary *)message withCompletionBlock:(void(^)(NSError * _Nullable error))completionBlock;
- (void)updateValues:(NSDictionary *)values withCompletionBlock:(void(^)(NSError * _Nullable error))completionBlock;
- (void)remove;

- (void)queryByValue:(NSString *)value;
- (void)queryByValue:(NSString *)value startingAtValue:(NSString *)startValue;
@end
NS_ASSUME_NONNULL_END
