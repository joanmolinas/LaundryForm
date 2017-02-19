//
//  FEZManager.m
//  FirebaseEZ
//
//  Created by Joan Molinas Ramon on 27/12/16.
//  Copyright © 2016 NSBeard. All rights reserved.
//

#import "FEZManager.h"

@implementation FEZManager

#pragma mark - Class functions
+ (instancetype)sharedManager {
    static dispatch_once_t onceToken;
    static FEZManager *manager = nil;
    dispatch_once(&onceToken, ^{
        manager = [FEZManager new];
    });
    
    return manager;
}

#pragma mark - Instance functions

- (void)configure {
    if (!_configured) {
        [FIRApp configure];
        _configured = YES;
    }
}

- (void)reset {
    //TODO: Implement
    _configured = NO;
}
@end
