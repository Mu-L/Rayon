//
//  NSLocalForward.h
//  
//
//  Created by Lakr Aream on 2022/3/9.
//

#import "GenericHeaders.h"
#import "GenericNetworking.h"
#import "NSRemoteShell.h"
#import "NSRemoteChannelSocketPair.h"

NS_ASSUME_NONNULL_BEGIN

@interface NSLocalForward : NSObject <NSRemoteOperableObject>

typedef BOOL (^NSRemoteChannelContinuationBlock)(void);

- (instancetype)initWithRepresentedSession:(LIBSSH2_SESSION*)representedSession
                     withRepresentedSocket:(int)socketDescriptor
                            withTargetHost:(NSString*)withTargetHost
                            withTargetPort:(NSNumber*)withTargetPort
                             withLocalPort:(NSNumber*)withLocalPort
                               withTimeout:(NSNumber*)withTimeout;

- (void)onTermination:(dispatch_block_t)terminationHandler;
- (void)setContinuationChain:(NSRemoteChannelContinuationBlock)continuation;

- (void)uncheckedConcurrencyCallNonblockingOperations;
- (BOOL)uncheckedConcurrencyInsanityCheckAndReturnDidSuccess;
- (void)uncheckedConcurrencyDisconnectAndPrepareForRelease;

@end

NS_ASSUME_NONNULL_END
