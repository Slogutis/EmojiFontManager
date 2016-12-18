#define USE_REAL_PATH
#define CHECK_TARGET
#define TWEAK
#import "Prefs.h"

CFStringRef emojiFontPath2x = CFSTR("/System/Library/Fonts/Core/AppleColorEmoji@2x.ttf");
CFStringRef emojiFontPath = CFSTR("/System/Library/Fonts/Core/AppleColorEmoji.ttf");
CFStringRef emojiFontFolder = isiOS83Up ? CFSTR("/System/Library/Fonts/Core") : CFSTR("/System/Library/Fonts/Cache");
CFStringRef newEmojiFontFolder = CFSTR("/Library/Themes/EmojiFontManager");
CFStringRef emojiFontPathPrefix = CFSTR("/System/Library/Fonts/Core/AppleColorEmoji");

NSString *getPath(NSString *font)
{
	return [NSString stringWithFormat:@"%@/%@/AppleColorEmoji@2x.ttf", (NSString *)newEmojiFontFolder, font];
}

extern "C" CFArrayRef CGFontCreateFontsWithPath(CFStringRef);
%hookf(CFArrayRef, CGFontCreateFontsWithPath, CFStringRef path)
{
	if (path && (CFEqual(emojiFontPath2x, path) || CFEqual(emojiFontPath, path))) {
		//NSString *newPath = [path stringByReplacingOccurrencesOfString:emojiFontFolder withString:newEmojiFontFolder];
		NSString *newPath = getPath(selectedFont);
		if (newPath && ![newPath isEqualToString:defaultName] && fileExist(newPath)) {
			path = (CFStringRef)newPath;
			HBLogDebug(@"New path: %@", path);
		}
	}
	return %orig(path);
}

%group iOS83Up

extern "C" CFURLRef CFURLCreateCopyAppendingPathExtension(CFAllocatorRef, CFURLRef, CFStringRef);
%hookf(CFURLRef, CFURLCreateCopyAppendingPathExtension, CFAllocatorRef allocator, CFURLRef url, CFStringRef extension)
{
	if (url && CFEqual(extension, CFSTR("ccf")) && ![selectedFont isEqualToString:defaultName]) {
		CFStringRef path = CFURLCopyPath(url);
		if (CFStringHasPrefix(path, emojiFontPathPrefix))
			extension = CFSTR("null");
		CFRelease(path);
	}
	return %orig(allocator, url, extension);
}

%end

%ctor
{
	if (isTarget(TargetTypeGUINoExtension)) {
		HaveObserver()
		callback();
		%init;
		if (isiOS83Up) {
			%init(iOS83Up);
		}
	}
}