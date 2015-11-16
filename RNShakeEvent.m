#import "RNShakeEvent.h"

#import "RCTBridge.h"
#import "RCTEventDispatcher.h"
#import "RCTLog.h"
#import "RCTUtils.h"

static NSString *const RCTShowDevMenuNotification = @"RCTShowDevMenuNotification";

#if !RCT_DEV

@implementation UIWindow (RNShakeEvent)

- (void)handleShakeEvent:(__unused UIEventSubtype)motion withEvent:(UIEvent *)event
{
    if (event.subtype == UIEventSubtypeMotionShake) {
        [[NSNotificationCenter defaultCenter] postNotificationName:RCTShowDevMenuNotification object:nil];
    }
}

@end

@implementation RNShakeEvent

@synthesize bridge = _bridge;

RCT_EXPORT_MODULE();

+ (void)initialize
{
    RCTSwapInstanceMethods([UIWindow class], @selector(motionEnded:withEvent:), @selector(handleShakeEvent:withEvent:));
}

- (instancetype)init
{
    if ((self = [super init])) {
        RCTLogInfo(@"RNShakeEvent: init in debug mode");
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(motionEnded:)
                                                     name:RCTShowDevMenuNotification
                                                   object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)motionEnded:(NSNotification *)notification
{
    [_bridge.eventDispatcher sendDeviceEventWithName:@"ShakeEvent"
                                                body:nil];
}

@end

#else

@implementation RNShakeEvent

@synthesize bridge = _bridge;

RCT_EXPORT_MODULE();

- (instancetype)init
{
    if ((self = [super init])) {
        RCTLogInfo(@"Shake event init");
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(motionEnded:)
                                                     name:RCTShowDevMenuNotification
                                                   object:nil];
    }
    return self;
}

- (void)dealloc
{
    RCTLogInfo(@"Shake event stop");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)motionEnded:(NSNotification *)notification
{
    RCTLogInfo(@"Shake event dispatched");
    [_bridge.eventDispatcher sendDeviceEventWithName:@"ShakeEvent"
                                                body:nil];
}

@end

#endif