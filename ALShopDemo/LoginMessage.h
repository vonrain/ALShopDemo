//
//  LoginMessage.h


#import "message.h"

#define LOGIN_BIZCODE    @"cg0001"

#define USER_IMSI		@""
#define USER_BRAND      @"APPLE"
#define USER_SVC        @""
#define USER_OS         @"IOS"

@interface LoginMessage : message<MessageDelegate>
{
}

+ (NSString*)getBizCode;

@end
