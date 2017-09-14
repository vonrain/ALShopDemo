/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License, Use at your own risk
 */

// Thanks to Emanuele Vulcano, Kevin Ballard/Eridius, Ryandjohnson, Matt Brown, etc.
// TTD:  - Bluetooth?  Screen pixels? Dot pitch? Accelerometer? GPS enabled/disabled

#include <sys/socket.h> // Per msqr
#include <sys/sysctl.h>
#include <net/if.h>
#include <net/if_dl.h>

#import "UIDevice-Hardware.h"

@implementation UIDevice (Hardware)

/*
 Platforms
 
 iFPGA ->		??

 iPhone1,1 ->	iPhone 1G
 iPhone1,2 ->	iPhone 3G
 iPhone2,1 ->	iPhone 3GS
 iPhone3,1 ->	iPhone 4G/AT&T
 iPhone3,2 ->	iPhone 4G/Other Carrier
 iPhone3,3 ->	iPhone 4G/Other Carrier

 iPod1,1   -> iPod touch 1G 
 iPod2,1   -> iPod touch 2G 
 iPod2,2   -> iPod touch 2.5G
 iPod3,1   -> iPod touch 3G
 iPod4,1   -> iPod touch 4G
 
 iPad1,1   -> iPad 1G, WiFi
 iPad1,?   -> iPad 1G, 3G <- needs 3G owner to test
 iPad2,1   -> iPad 2G

 i386 -> iPhone Simulator
*/


#pragma mark sysctlbyname utils
- (NSString *) getSysInfoByName:(char *)typeSpecifier
{
	size_t size;
    sysctlbyname(typeSpecifier, NULL, &size, NULL, 0);
    char *answer = malloc(size);
	sysctlbyname(typeSpecifier, answer, &size, NULL, 0);
	NSString *results = [NSString stringWithCString:answer encoding: NSUTF8StringEncoding];
	free(answer);
	return results;
}

- (NSString *) platform
{
	return [self getSysInfoByName:"hw.machine"];
}


#pragma mark sysctl utils
- (NSUInteger) getSysInfo: (uint) typeSpecifier
{
	size_t size = sizeof(int);
	int results;
	int mib[2] = {CTL_HW, typeSpecifier};
	sysctl(mib, 2, &results, &size, NULL, 0);
	return (NSUInteger) results;
}

- (NSUInteger) cpuFrequency
{
    NSString* platformStr = [self platformString];
    if ([platformStr hasSuffix:@"4G"]) {
        // 通过测试4代以上的系统，这个数值取不到，但是4代都是800MHz
        return 800000000;
    }
    
	return [self getSysInfo:HW_CPU_FREQ];
}

- (NSUInteger) busFrequency
{
	return [self getSysInfo:HW_BUS_FREQ];
}

- (NSUInteger) totalMemory
{
	return [self getSysInfo:HW_PHYSMEM];
}

- (NSUInteger) userMemory
{
	return [self getSysInfo:HW_USERMEM];
}

- (NSUInteger) maxSocketBufferSize
{
	return [self getSysInfo:KIPC_MAXSOCKBUF];
}

#pragma mark file system -- Thanks Joachim Bean!

- (NSNumber *) totalDiskSpace
{
	NSDictionary *fattributes = [[NSFileManager defaultManager] attributesOfFileSystemForPath:NSHomeDirectory() error:nil];
	return [fattributes objectForKey:NSFileSystemSize];
}

- (NSNumber *) freeDiskSpace
{
	NSDictionary *fattributes = [[NSFileManager defaultManager] attributesOfFileSystemForPath:NSHomeDirectory() error:nil];
	return [fattributes objectForKey:NSFileSystemFreeSize];
}

#pragma mark platform type and name utils
- (NSUInteger) platformType
{
	NSString *platform = [self platform];
	if ([platform isEqualToString:@"iFPGA"])		return UIDeviceIFPGA;
    if ([platform isEqualToString:@"i386"])         return UIDeviceiPhoneSimulator;
    if ([platform isEqualToString:@"x86_64"])		return UIDeviceiPhoneSimulator;
	if ([platform isEqualToString:@"iPhone1,1"])	return UIDevice1GiPhone;
	if ([platform isEqualToString:@"iPhone1,2"])	return UIDevice3GiPhone;
	if ([platform isEqualToString:@"iPhone2,1"])	return UIDevice3GSiPhone;
	if ([platform isEqualToString:@"iPhone3,1"])	return UIDevice4GiPhone;
    if ([platform isEqualToString:@"iPhone4,1"])    return UIDevice4SiPhone;
    if ([platform isEqualToString:@"iPhone5,1"])    return UIDevice5iPhone;
    if ([platform isEqualToString:@"iPhone5,2"])    return UIDevice5iPhone;
    if ([platform isEqualToString:@"iPhone5,3"])    return UIDevice5CiPhone;
    if ([platform isEqualToString:@"iPhone5,4"])    return UIDevice5CiPhone;
    if ([platform isEqualToString:@"iPhone6,1"])    return UIDevice5SiPhone;
    if ([platform isEqualToString:@"iPhone6,2"])    return UIDevice5SiPhone;
    if ([platform isEqualToString:@"iPhone7,2"])    return UIDevice6PiPhone;
    if ([platform isEqualToString:@"iPhone7,1"])    return UIDevice6PiPhone;
	
	if ([platform isEqualToString:@"iPod1,1"])   return UIDevice1GiPod;
	if ([platform isEqualToString:@"iPod2,1"])   return UIDevice2GiPod;
	if ([platform isEqualToString:@"iPod2,2"])   return UIDevice2GPlusiPod;
	if ([platform isEqualToString:@"iPod3,1"])   return UIDevice3GiPod;
	if ([platform isEqualToString:@"iPod4,1"])   return UIDevice4GiPod;
		
	if ([platform isEqualToString:@"iPad1,1"])   return UIDevice1GiPad;
	/*
	 MISSING A SOLUTION HERE TO DATE TO DIFFERENTIATE iPAD and iPAD 3G.... SORRY!
	 */

	if ([platform hasPrefix:@"iPhone"]) return UIDeviceUnknowniPhone;
	if ([platform hasPrefix:@"iPod"]) return UIDeviceUnknowniPod;
	return UIDeviceUnknown;
}

- (NSString *) platformString
{
	switch ([self platformType])
	{
		case UIDevice1GiPhone: return IPHONE_1G_NAMESTRING;
		case UIDevice3GiPhone: return IPHONE_3G_NAMESTRING;
		case UIDevice3GSiPhone:	return IPHONE_3GS_NAMESTRING;
		case UIDevice4GiPhone:	return IPHONE_4G_NAMESTRING;
        case UIDevice4SiPhone:  return IPHONE_4S_NAMESTRING;
        case UIDevice5iPhone:   return IPHONE_5_NAMESTRING;
        case UIDevice5CiPhone:   return IPHONE_5C_NAMESTRING;
        case UIDevice5SiPhone:   return IPHONE_5S_NAMESTRING;
        case UIDevice6iPhone:   return IPHONE_6_NAMESTRING;
        case UIDevice6PiPhone:   return IPHONE_6P_NAMESTRING;
		case UIDeviceUnknowniPhone: return IPHONE_UNKNOWN_NAMESTRING;
		
		case UIDevice1GiPod: return IPOD_1G_NAMESTRING;
		case UIDevice2GiPod: return IPOD_2G_NAMESTRING;
		case UIDevice3GiPod: return IPOD_3G_NAMESTRING;
		case UIDevice4GiPod: return IPOD_4G_NAMESTRING;
		case UIDeviceUnknowniPod: return IPOD_UNKNOWN_NAMESTRING;
			
		case UIDevice1GiPad : return IPAD_1G_NAMESTRING;
		case UIDevice1GiPad3G : return IPAD3G_1G_NAMESTRING;
			
		case UIDeviceiPhoneSimulator: return IPHONE_SIMULATOR_NAMESTRING;
		case UIDeviceiPhoneSimulatoriPhone: return IPHONE_SIMULATOR_IPHONE_NAMESTRING;
		case UIDeviceiPhoneSimulatoriPad: return IPHONE_SIMULATOR_IPAD_NAMESTRING;
			
		case UIDeviceIFPGA: return IFPGA_NAMESTRING;
			
		default: return IPOD_FAMILY_UNKNOWN_DEVICE;
	}
}

#pragma mark  platform capabilities
- (NSUInteger) platformCapabilities
{
	switch ([self platformType])
	{
		case UIDevice1GiPhone: 
			return 
			(UIDeviceSupportsTelephony  |
			 UIDeviceSupportsSMS  |
			 UIDeviceSupportsStillCamera  |
			 // UIDeviceSupportsAutofocusCamera |
			 // UIDeviceSupportsVideoCamera  |
			 UIDeviceSupportsWifi  |
			 UIDeviceSupportsAccelerometer  |
			 UIDeviceSupportsLocationServices  |
			 // UIDeviceSupportsGPS  |
			 // UIDeviceSupportsMagnetometer  |
			 UIDeviceSupportsBuiltInMicrophone  |
			 UIDeviceSupportsExternalMicrophone  |
			 UIDeviceSupportsOPENGLES1_1  |
			 // UIDeviceSupportsOPENGLES2  |
			 UIDeviceSupportsBuiltInSpeaker  |
			 UIDeviceSupportsVibration  |
			 UIDeviceSupportsBuiltInProximitySensor  |
			 // UIDeviceSupportsAccessibility  |
			 // UIDeviceSupportsVoiceOver |
			 // UIDeviceSupportsVoiceControl |
			 // UIDeviceSupportsPeerToPeer |
			 // UIDeviceSupportsARMV7 |
			 UIDeviceSupportsBrightnessSensor |
			 UIDeviceSupportsEncodeAAC |
			 UIDeviceSupportsBluetooth | // M68.plist says YES for this
			 // UIDeviceSupportsNike |
			 // UIDeviceSupportsPiezoClicker |
			 UIDeviceSupportsVolumeButtons
			 );
			
		case UIDevice3GiPhone: 
			return
			(UIDeviceSupportsTelephony  |
			 UIDeviceSupportsSMS  |
			 UIDeviceSupportsStillCamera  |
			 // UIDeviceSupportsAutofocusCamera |
			 // UIDeviceSupportsVideoCamera  |
			 UIDeviceSupportsWifi  |
			 UIDeviceSupportsAccelerometer  |
			 UIDeviceSupportsLocationServices  |
			 UIDeviceSupportsGPS  |
			 // UIDeviceSupportsMagnetometer  |
			 UIDeviceSupportsBuiltInMicrophone  |
			 UIDeviceSupportsExternalMicrophone  |
			 UIDeviceSupportsOPENGLES1_1  |
			 // UIDeviceSupportsOPENGLES2  |
			 UIDeviceSupportsBuiltInSpeaker  |
			 UIDeviceSupportsVibration  |
			 UIDeviceSupportsBuiltInProximitySensor  |
			 // UIDeviceSupportsAccessibility  |
			 // UIDeviceSupportsVoiceOver |
			 // UIDeviceSupportsVoiceControl |
			 UIDeviceSupportsPeerToPeer |
			 // UIDeviceSupportsARMV7 |
			 UIDeviceSupportsBrightnessSensor |
			 UIDeviceSupportsEncodeAAC |
			 UIDeviceSupportsBluetooth |
			 // UIDeviceSupportsNike |
			 // UIDeviceSupportsPiezoClicker |
			 UIDeviceSupportsVolumeButtons
			 );
			
		case UIDevice3GSiPhone: 
			return
			(UIDeviceSupportsTelephony  |
			 UIDeviceSupportsSMS  |
			 UIDeviceSupportsStillCamera  |
			 UIDeviceSupportsAutofocusCamera |
			 UIDeviceSupportsVideoCamera  |
			 UIDeviceSupportsWifi  |
			 UIDeviceSupportsAccelerometer  |
			 UIDeviceSupportsLocationServices  |
			 UIDeviceSupportsGPS  |
			 UIDeviceSupportsMagnetometer  |
			 UIDeviceSupportsBuiltInMicrophone  |
			 UIDeviceSupportsExternalMicrophone  |
			 UIDeviceSupportsOPENGLES1_1  |
			 UIDeviceSupportsOPENGLES2  |
			 UIDeviceSupportsBuiltInSpeaker  |
			 UIDeviceSupportsVibration  |
			 UIDeviceSupportsBuiltInProximitySensor  |
			 UIDeviceSupportsAccessibility  |
			 UIDeviceSupportsVoiceOver |
			 UIDeviceSupportsVoiceControl |
			 UIDeviceSupportsPeerToPeer |
			 UIDeviceSupportsARMV7 |
			 UIDeviceSupportsBrightnessSensor |
			 UIDeviceSupportsEncodeAAC |
			 UIDeviceSupportsBluetooth |
			 UIDeviceSupportsNike |
			 // UIDeviceSupportsPiezoClicker |
			 UIDeviceSupportsVolumeButtons
			 );			
		case UIDeviceUnknowniPhone: return 0;
			
		case UIDevice1GiPod: 
			return
			(// UIDeviceSupportsTelephony  |
			 // UIDeviceSupportsSMS  |
			 // UIDeviceSupportsStillCamera  |
			 // UIDeviceSupportsAutofocusCamera |
			 // UIDeviceSupportsVideoCamera  |
			 UIDeviceSupportsWifi  |
			 UIDeviceSupportsAccelerometer  |
			 UIDeviceSupportsLocationServices  |
			 // UIDeviceSupportsGPS  |
			 // UIDeviceSupportsMagnetometer  |
			 // UIDeviceSupportsBuiltInMicrophone  |
			 UIDeviceSupportsExternalMicrophone  |
			 UIDeviceSupportsOPENGLES1_1  |
			 // UIDeviceSupportsOPENGLES2  |
			 // UIDeviceSupportsBuiltInSpeaker  |
			 // UIDeviceSupportsVibration  |
			 // UIDeviceSupportsBuiltInProximitySensor  |
			 // UIDeviceSupportsAccessibility  |
			 // UIDeviceSupportsVoiceOver |
			 // UIDeviceSupportsVoiceControl |
			 UIDeviceSupportsBrightnessSensor |
			 // UIDeviceSupportsEncodeAAC |
			 // UIDeviceSupportsBluetooth |
			 // UIDeviceSupportsNike |
			 UIDeviceSupportsPiezoClicker
			 // UIDeviceSupportsVolumeButtons
			 );
			
		case UIDevice2GiPod: 
		case UIDevice2GPlusiPod:
			return
			(// UIDeviceSupportsTelephony  |
			 // UIDeviceSupportsSMS  |
			 // UIDeviceSupportsStillCamera  |
			 // UIDeviceSupportsAutofocusCamera |
			 // UIDeviceSupportsVideoCamera  |
			 UIDeviceSupportsWifi  |
			 UIDeviceSupportsAccelerometer  |
			 UIDeviceSupportsLocationServices  |
			 // UIDeviceSupportsGPS  |
			 // UIDeviceSupportsMagnetometer  |
			 // UIDeviceSupportsBuiltInMicrophone  |
			 UIDeviceSupportsExternalMicrophone  |
			 UIDeviceSupportsOPENGLES1_1  |
			 // UIDeviceSupportsOPENGLES2  |
			 UIDeviceSupportsBuiltInSpeaker  |
			 // UIDeviceSupportsVibration  |
			 // UIDeviceSupportsBuiltInProximitySensor  |
			 // UIDeviceSupportsAccessibility  |
			 // UIDeviceSupportsVoiceOver |
			 // UIDeviceSupportsVoiceControl |
			 UIDeviceSupportsPeerToPeer |
			 // UIDeviceSupportsARMV7 |
			 UIDeviceSupportsBrightnessSensor |
			UIDeviceSupportsEncodeAAC |
			UIDeviceSupportsBluetooth |
			UIDeviceSupportsNike |
			// UIDeviceSupportsPiezoClicker |
			UIDeviceSupportsVolumeButtons
			 );
			
			
		case UIDevice3GiPod: 
			return
			(// UIDeviceSupportsTelephony  |
			 // UIDeviceSupportsSMS  |
			 // UIDeviceSupportsStillCamera  |
			 // UIDeviceSupportsAutofocusCamera |
			 // UIDeviceSupportsVideoCamera  |
			 UIDeviceSupportsWifi  |
			 UIDeviceSupportsAccelerometer  |
			 UIDeviceSupportsLocationServices  |
			 // UIDeviceSupportsGPS  |
			 // UIDeviceSupportsMagnetometer  |
			 // UIDeviceSupportsBuiltInMicrophone  |
			 UIDeviceSupportsExternalMicrophone  |
			 UIDeviceSupportsOPENGLES1_1  |
			 UIDeviceSupportsOPENGLES2  |
			 UIDeviceSupportsBuiltInSpeaker  |
			 // UIDeviceSupportsVibration  |
			 // UIDeviceSupportsBuiltInProximitySensor  |
			 UIDeviceSupportsAccessibility  |
			 UIDeviceSupportsVoiceOver |
			 UIDeviceSupportsVoiceControl |
			 UIDeviceSupportsPeerToPeer |
			 UIDeviceSupportsARMV7 |
			 UIDeviceSupportsBrightnessSensor |
			 UIDeviceSupportsEncodeAAC |
			 UIDeviceSupportsBluetooth |
			 UIDeviceSupportsNike |
			 // UIDeviceSupportsPiezoClicker |
			 UIDeviceSupportsVolumeButtons
			 );			
		case UIDeviceUnknowniPod:  return 0;
			
		case UIDevice1GiPad:
			return
			(// UIDeviceSupportsTelephony  |
			 // UIDeviceSupportsSMS  |
			 // UIDeviceSupportsStillCamera  |
			 // UIDeviceSupportsAutofocusCamera |
			 // UIDeviceSupportsVideoCamera  |
			 UIDeviceSupportsWifi  |
			 UIDeviceSupportsAccelerometer  |
			 UIDeviceSupportsLocationServices  |
			 // UIDeviceSupportsGPS  |
			 // UIDeviceSupportsMagnetometer  |
			 UIDeviceSupportsBuiltInMicrophone  |
			 UIDeviceSupportsExternalMicrophone  |
			 UIDeviceSupportsOPENGLES1_1  |
			 UIDeviceSupportsOPENGLES2  |
			 UIDeviceSupportsBuiltInSpeaker  |
			 // UIDeviceSupportsVibration  |
			 // UIDeviceSupportsBuiltInProximitySensor  |
			 UIDeviceSupportsAccessibility  |
			 UIDeviceSupportsVoiceOver |
			 UIDeviceSupportsVoiceControl |
			 UIDeviceSupportsPeerToPeer |
			 UIDeviceSupportsARMV7 |
			 UIDeviceSupportsBrightnessSensor |
			 UIDeviceSupportsEncodeAAC |
			 UIDeviceSupportsBluetooth |
			 UIDeviceSupportsNike |
			 // UIDeviceSupportsPiezoClicker |
			 UIDeviceSupportsVolumeButtons |
			 UIDeviceSupportsEnhancedMultitouch
			 );	
			
		case UIDevice1GiPad3G:
			return
			(// UIDeviceSupportsTelephony  |
			 UIDeviceSupportsSMS  |
			 // UIDeviceSupportsStillCamera  |
			 // UIDeviceSupportsAutofocusCamera |
			 // UIDeviceSupportsVideoCamera  |
			 UIDeviceSupportsWifi  |
			 UIDeviceSupportsAccelerometer  |
			 UIDeviceSupportsLocationServices  |
			 UIDeviceSupportsGPS  |
			 // UIDeviceSupportsMagnetometer  |
			 UIDeviceSupportsBuiltInMicrophone  |
			 UIDeviceSupportsExternalMicrophone  |
			 UIDeviceSupportsOPENGLES1_1  |
			 UIDeviceSupportsOPENGLES2  |
			 UIDeviceSupportsBuiltInSpeaker  |
			 // UIDeviceSupportsVibration  |
			 // UIDeviceSupportsBuiltInProximitySensor  |
			 UIDeviceSupportsAccessibility  |
			 UIDeviceSupportsVoiceOver |
			 UIDeviceSupportsVoiceControl |
			 UIDeviceSupportsPeerToPeer |
			 UIDeviceSupportsARMV7 |
			 UIDeviceSupportsBrightnessSensor |
			 UIDeviceSupportsEncodeAAC |
			 UIDeviceSupportsBluetooth |
			 UIDeviceSupportsNike |
			 // UIDeviceSupportsPiezoClicker |
			 UIDeviceSupportsVolumeButtons |
			 UIDeviceSupportsEnhancedMultitouch
			 );				
			
		case UIDeviceiPhoneSimulator: 
			return
			(// UIDeviceSupportsTelephony  |
			 // UIDeviceSupportsSMS  |
			 // UIDeviceSupportsStillCamera  |
			 // UIDeviceSupportsAutofocusCamera |
			 // UIDeviceSupportsVideoCamera  |
			 UIDeviceSupportsWifi  |
			 // UIDeviceSupportsAccelerometer  |
			 UIDeviceSupportsLocationServices  |
			 // UIDeviceSupportsGPS  |
			 // UIDeviceSupportsMagnetometer  |
			 // UIDeviceSupportsBuiltInMicrophone  |
			 // UIDeviceSupportsExternalMicrophone  |
			 UIDeviceSupportsOPENGLES1_1  |
			 // UIDeviceSupportsOPENGLES2  |
			 UIDeviceSupportsAccessibility  | // with limitations
			 UIDeviceSupportsVoiceOver | // with limitations
			 UIDeviceSupportsBuiltInSpeaker
			// UIDeviceSupportsVibration  |
			// UIDeviceSupportsBuiltInProximitySensor  |
			// UIDeviceSupportsVoiceControl |
			// UIDeviceSupportsPeerToPeer |
			// UIDeviceSupportsARMV7 |
			// UIDeviceSupportsBrightnessSensor |
			// UIDeviceSupportsEncodeAAC |
			// UIDeviceSupportsBluetooth |
			// UIDeviceSupportsNike |
			// UIDeviceSupportsPiezoClicker |
			// UIDeviceSupportsVolumeButtons
			);
		default: return 0;
	}
}

// Courtesy of Danny Sung <dannys@mail.com>
- (BOOL) platformHasCapability:(NSUInteger)capability 
{
    if( ([self platformCapabilities] & capability) == capability )
        return YES;
    return NO;
}

- (NSArray *) capabilityArray
{
	NSUInteger flags = [self platformCapabilities];
	NSMutableArray *array = [NSMutableArray array];
	
	if (flags & UIDeviceSupportsTelephony) [array addObject:@"Telephony"];
	if (flags & UIDeviceSupportsSMS) [array addObject:@"SMS"];
	if (flags & UIDeviceSupportsStillCamera) [array addObject:@"Still Camera"];
	if (flags & UIDeviceSupportsAutofocusCamera) [array addObject:@"AutoFocus Camera"];
	if (flags & UIDeviceSupportsVideoCamera) [array addObject:@"Video Camera"];

	if (flags & UIDeviceSupportsWifi) [array addObject:@"WiFi"];
	if (flags & UIDeviceSupportsAccelerometer) [array addObject:@"Accelerometer"];
	if (flags & UIDeviceSupportsLocationServices) [array addObject:@"Location Services"];
	if (flags & UIDeviceSupportsGPS) [array addObject:@"GPS"];
	if (flags & UIDeviceSupportsMagnetometer) [array addObject:@"Magnetometer"];

	if (flags & UIDeviceSupportsBuiltInMicrophone) [array addObject:@"Built-in Microphone"];
	if (flags & UIDeviceSupportsExternalMicrophone) [array addObject:@"External Microphone Support"];
	if (flags & UIDeviceSupportsOPENGLES1_1) [array addObject:@"OpenGL ES 1.1"];
	if (flags & UIDeviceSupportsOPENGLES2) [array addObject:@"OpenGL ES 2.x"];
	if (flags & UIDeviceSupportsBuiltInSpeaker) [array addObject:@"Built-in Speaker"];

	if (flags & UIDeviceSupportsVibration) [array addObject:@"Vibration"];
	if (flags & UIDeviceSupportsBuiltInProximitySensor) [array addObject:@"Proximity Sensor"];
	if (flags & UIDeviceSupportsAccessibility) [array addObject:@"Accessibility"];
	if (flags & UIDeviceSupportsVoiceOver) [array addObject:@"VoiceOver"];
	if (flags & UIDeviceSupportsVoiceControl) [array addObject:@"Voice Control"];

	if (flags & UIDeviceSupportsBrightnessSensor) [array addObject:@"Brightness Sensor"];
	if (flags & UIDeviceSupportsPeerToPeer) [array addObject:@"Peer to Peer Bluetooth"];
	if (flags & UIDeviceSupportsARMV7) [array addObject:@"The armv7 instruction set"];
	if (flags & UIDeviceSupportsEncodeAAC) [array addObject:@"AAC Encoding"];
	if (flags & UIDeviceSupportsBluetooth) [array addObject:@"Basic Bluetooth"];

	if (flags & UIDeviceSupportsNike) [array addObject:@"Nike"];
	if (flags & UIDeviceSupportsPiezoClicker) [array addObject:@"Piezo clicker"];
	if (flags & UIDeviceSupportsVolumeButtons) [array addObject:@"Physical volume rocker"];
	
	if (flags & UIDeviceSupportsEnhancedMultitouch) [array addObject:@"Enhanced Multitouch"];
	
	return array;
}

#pragma mark MAC addy
// Return the local MAC addy
// Courtesy of FreeBSD hackers email list
// Accidentally munged during previous update. Fixed thanks to mlamb.
- (NSString *) macaddress
{
	int					mib[6];
	size_t				len;
	char				*buf;
	unsigned char		*ptr;
	struct if_msghdr	*ifm;
	struct sockaddr_dl	*sdl;
	
	mib[0] = CTL_NET;
	mib[1] = AF_ROUTE;
	mib[2] = 0;
	mib[3] = AF_LINK;
	mib[4] = NET_RT_IFLIST;
	
	if ((mib[5] = if_nametoindex("en0")) == 0) {
		printf("Error: if_nametoindex error\n");
		return @"mac";
	}
	
	if (sysctl(mib, 6, NULL, &len, NULL, 0) < 0) {
		printf("Error: sysctl, take 1\n");
		return @"mac";
	}
	
	if ((buf = malloc(len)) == NULL) {
		printf("Could not allocate memory. error!\n");
		return @"mac";
	}
	
	if (sysctl(mib, 6, buf, &len, NULL, 0) < 0) {
		printf("Error: sysctl, take 2");
		return @"mac";
	}
	
	ifm = (struct if_msghdr *)buf;
	sdl = (struct sockaddr_dl *)(ifm + 1);
	ptr = (unsigned char *)LLADDR(sdl);
	// NSString *outstring = [NSString stringWithFormat:@"%02x:%02x:%02x:%02x:%02x:%02x", *ptr, *(ptr+1), *(ptr+2), *(ptr+3), *(ptr+4), *(ptr+5)];
	NSString *outstring = [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x", *ptr, *(ptr+1), *(ptr+2), *(ptr+3), *(ptr+4), *(ptr+5)];
	free(buf);
    NSString* macaddr = [outstring uppercaseString];
    if (macaddr == nil || [macaddr length]==0) {
        return @"mac";
    }
	return macaddr;
}

- (NSString *) platformCode
{
	switch ([self platformType])
	{
		case UIDevice1GiPhone: return @"M68";
		case UIDevice3GiPhone: return @"N82";
		case UIDevice3GSiPhone:	return @"N88";
		case UIDevice4GiPhone: return @"N89";
		case UIDeviceUnknowniPhone: return IPHONE_UNKNOWN_NAMESTRING;
			
		case UIDevice1GiPod: return @"N45";
		case UIDevice2GiPod: return @"N72";
		case UIDevice3GiPod: return @"N18"; 
		case UIDevice4GiPod: return @"N80";
		case UIDeviceUnknowniPod: return IPOD_UNKNOWN_NAMESTRING;
			
		case UIDevice1GiPad: return @"K48";
		case UIDevice1GiPad3G: return @"K48";  // placeholder
			
		case UIDeviceiPhoneSimulator: return IPHONE_SIMULATOR_NAMESTRING;
			
		default: return IPOD_FAMILY_UNKNOWN_DEVICE;
	}
}


- (NSString *) batteryLevelStr
{
    NSMutableString* batteryStr = [[NSMutableString alloc] initWithCapacity:0];
    
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setNumberStyle:NSNumberFormatterPercentStyle];
    [numberFormatter setMaximumFractionDigits:1];
    
    [UIDevice currentDevice].batteryMonitoringEnabled = YES;
    float batteryLevel = [UIDevice currentDevice].batteryLevel;
    if (batteryLevel < 0.0)
    {
        [batteryStr setString:@"Unknown"];
    }
    else {
        NSNumber *levelObj = [NSNumber numberWithFloat:batteryLevel]; 
        [batteryStr setString:[numberFormatter stringFromNumber:levelObj]];
    }
    return batteryStr;
}


- (NSArray *)runningProcesses {
    
    int mib[4] = {CTL_KERN, KERN_PROC, KERN_PROC_ALL, 0};
    size_t miblen = 4;
    
    size_t size;
    int st = sysctl(mib, miblen, NULL, &size, NULL, 0);
    
    struct kinfo_proc * process = NULL;
    struct kinfo_proc * newprocess = NULL;
    
    do {
        
        size += size / 10;
        newprocess = realloc(process, size);
        
        if (!newprocess){
            
            if (process){
                free(process);
            }
            
            return nil;
        }
        
        process = newprocess;
        st = sysctl(mib, miblen, process, &size, NULL, 0);
        
    } while (st == -1 && errno == ENOMEM);
    
    if (st == 0){
        
        if (size % sizeof(struct kinfo_proc) == 0){
            int nprocess = size / sizeof(struct kinfo_proc);
            
            if (nprocess){
                
                NSMutableArray * array = [[NSMutableArray alloc] init];
                
                for (int i = nprocess - 1; i >= 0; i--){
                    
                    struct kinfo_proc processT = process[i];
                    
                    NSString * processID = [[NSString alloc] initWithFormat:@"%d", processT.kp_proc.p_pid];
                    NSString * processName = [[NSString alloc] initWithFormat:@"%s", processT.kp_proc.p_comm];
                    
                    long timel = processT.kp_proc.p_starttime.tv_sec;
                    NSDate* dateT = [[NSDate alloc] init];
                    [dateT initWithTimeIntervalSince1970:timel];
                    NSDate* dateN = [NSDate dateWithTimeInterval:8*60*60 sinceDate:dateT];
                    NSString* dateStr = [dateN description];
                    NSString* dateStrSub = [dateStr substringToIndex:19];
                    
                    NSMutableDictionary * dict = [[NSMutableDictionary alloc] initWithCapacity:0];
                    [dict setObject:processName forKey:@"name"];
                    [dict setObject:processID forKey:@"id"];
                    [dict setObject:dateStrSub forKey:@"time"];
                    [array addObject:dict];
                }
                
                free(process);
                return array ;
            }
        }
    }
    
    return nil;
}


- (NSString*) systemVersionStr
{    
    return [[UIDevice currentDevice] systemVersion];
}

- (NSString*) uniqueIdentifierStr
{    
//    return [[UIDevice currentDevice] uniqueIdentifier];
//    return @"";
    return nil;
}

- (NSString*) clientVersingStr
{
    NSString* BundleVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
	return [NSString stringWithFormat:@"V%@",BundleVersion];
}



@end
