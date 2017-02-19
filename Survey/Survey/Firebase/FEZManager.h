//
//  FEZManager.h
//  FirebaseEZ
//
//  Created by Joan Molinas Ramon on 27/12/16.
//  Copyright © 2016 NSBeard. All rights reserved.
//

#import <Foundation/Foundation.h>
@import Firebase;

@interface FEZManager : NSObject

@property (nonatomic, assign, readonly) BOOL configured;

+ (instancetype)sharedManager;
- (void)configure;
- (void)reset; //TODO: Implement
@end
