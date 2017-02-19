//
//  FEZAuth.h
//  FirebaseEZ
//
//  Created by Joan Molinas Ramon on 27/12/16.
//  Copyright © 2016 NSBeard. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FEZManager.h"

NS_ASSUME_NONNULL_BEGIN

typedef FIRAuthResultCallback FEZAuthCallback;
typedef void(^FEZAuthSignInSuccessfulCallback)(FIRUser *_Nullable user);
typedef void(^FEZAuthSignOutSuccessfulCallback)();
typedef void(^FEZAuthFailureCallback)(NSError *_Nullable error);

@interface FEZAuth : NSObject

+ (void)signInWithEmail:(NSString *)email
               password:(NSString *)password
        successCallback:(nullable FEZAuthSignInSuccessfulCallback)successCallback
        failureCallback:(nullable FEZAuthFailureCallback)failureCallback;

+ (void)signOutWithSuccessCallback:(nullable FEZAuthSignOutSuccessfulCallback)successCallback
                   failureCallback:(nullable FEZAuthFailureCallback)failureCallback;

+ (void)signUpWithEmail:(NSString *)email
               password:(NSString *)password
        successCallback:(nullable FEZAuthSignInSuccessfulCallback)successCallback
        failureCallback:(nullable FEZAuthFailureCallback)failureCallback;

+ (void)signInWithFacebook:(NSString *)facebookAccessToken
           successCallback:(nullable FEZAuthSignInSuccessfulCallback)successCallback
           failureCallback:(nullable FEZAuthFailureCallback)failureCallback;

+ (nullable FIRUser *)currentUser;

@end

NS_ASSUME_NONNULL_END
