/*


*/

#import <Cocoa/Cocoa.h>

#include <u.h>
#include <libc.h>

AUTOFRAMEWORK(Cocoa)

void
main(int argc, char **argv)
{
	NSScreen *screen = [NSScreen mainScreen];
	float backing = [screen backingScaleFactor];
	fprint(1, "%0.0f\n", backing);
}

/*
	NSDictionary *description = [screen deviceDescription];
	NSSize displayPixelSize = [[description objectForKey:NSDeviceSize] sizeValue];
	CGSize displayPhysicalSize = CGDisplayScreenSize(
		[[description objectForKey:@"NSScreenNumber"] unsignedIntValue]);
	fprint(1, "%0.0f\n", (displayPixelSize.width / displayPhysicalSize.width) * 25.4f); 
*/
