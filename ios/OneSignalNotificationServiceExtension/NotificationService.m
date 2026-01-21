//
//  NotificationService.m
//  OneSignalNotificationServiceExtension
//
//  Created by Berkay Can on 12/26/25.
//

#import "NotificationService.h"
#import <OneSignalExtension/OneSignalExtension.h>

@interface NotificationService ()

@property (nonatomic, strong) void (^contentHandler)(UNNotificationContent *contentToDeliver);
@property (nonatomic, strong) UNNotificationRequest *receivedRequest;
@property (nonatomic, strong) UNMutableNotificationContent *bestAttemptContent;

@end

@implementation NotificationService

- (void)didReceiveNotificationRequest:(UNNotificationRequest *)request withContentHandler:(void (^)(UNNotificationContent * _Nonnull))contentHandler {
    self.receivedRequest = request;
    self.contentHandler = contentHandler;
    self.bestAttemptContent = [request.content mutableCopy];

    // IMPORTANT: Calling this in didReceive is required for:
    // - Confirmed delivery tracking
    // - Badge increment/decrement
    // - Rich media (images, action buttons)
    [OneSignalExtension didReceiveNotificationExtensionRequest:self.receivedRequest
                                       withMutableNotificationContent:self.bestAttemptContent
                                                   withContentHandler:self.contentHandler];
}

- (void)serviceExtensionTimeWillExpire {
    // Called just before the extension will be terminated by the system.
    // Use this as an opportunity to deliver your "best attempt" at modified content,
    // otherwise the original push payload will be used.
    [OneSignalExtension serviceExtensionTimeWillExpireRequest:self.receivedRequest
                                       withMutableNotificationContent:self.bestAttemptContent];
    self.contentHandler(self.bestAttemptContent);
}

@end
