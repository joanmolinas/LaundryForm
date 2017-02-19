//
//  FEZAuth.m
//  FirebaseEZ
//
//  Created by Joan Molinas Ramon on 27/12/16.
//  Copyright © 2016 NSBeard. All rights reserved.
//

#import "FEZAuth.h"

@implementation FEZAuth

#pragma mark - Sign Actions

+ (void)signInWithEmail:(NSString *)email
               password:(NSString *)password
        successCallback:(FEZAuthSignInSuccessfulCallback)successCallback
        failureCallback:(FEZAuthFailureCallback)failureCallback {
   
    NSAssert([FEZManager sharedManager].configured, @"Configure FEZManager first");

    [[FIRAuth auth] signInWithEmail:email
                           password:password
                         completion:^(FIRUser * _Nullable user, NSError * _Nullable error) {
                             if (error) {
                                 if(failureCallback) failureCallback(error);
                                 return;
                             }
                             if(successCallback) successCallback(user);
                         }];
}

+ (void)signOutWithSuccessCallback:(FEZAuthSignOutSuccessfulCallback)successCallback
                   failureCallback:(FEZAuthFailureCallback)failureCallback {
    
    NSAssert([FEZManager sharedManager].configured, @"Configure FEZManager first");
    
    NSError *signedOutError;
    BOOL status = [[FIRAuth auth] signOut:&signedOutError];
    if (!status) {
        failureCallback(signedOutError);
        return;
    }
    
    successCallback();
}

+ (void)signUpWithEmail:(NSString *)email
               password:(NSString *)password
        successCallback:(FEZAuthSignInSuccessfulCallback)successCallback
        failureCallback:(FEZAuthFailureCallback)failureCallback {
    [[FIRAuth auth] createUserWithEmail:email
                               password:password completion:^(FIRUser * _Nullable user, NSError * _Nullable error) {
                                   if (error) {
                                       if(failureCallback) failureCallback(error);
                                       return;
                                   }
                                   if(successCallback) successCallback(user);
                               }];
}

+ (void)signInWithFacebook:(NSString *)facebookAccessToken
           successCallback:(FEZAuthSignInSuccessfulCallback)successCallback
           failureCallback:(FEZAuthFailureCallback)failureCallback {
    FIRAuthCredential *credential = [FIRFacebookAuthProvider credentialWithAccessToken:facebookAccessToken];
    [[FIRAuth auth] signInWithCredential:credential
                              completion:^(FIRUser * _Nullable user, NSError * _Nullable error) {
                                  if (error) {
                                      if(failureCallback) failureCallback(error);
                                      return;
                                  }
                                  if(successCallback) successCallback(user);
                              }];
}

#pragma mark - Current properties

+ (nullable FIRUser *)currentUser {
    return [FIRAuth auth].currentUser;
}
@end
