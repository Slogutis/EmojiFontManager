#import "../PS.h"
#import "../PSPrefs.x"

NSString *tweakIdentifier = @"com.PS.EmojiFontManager";
NSString *selectedFontKey = @"selectedFont";
NSString *defaultName = @"Default";

#ifdef TWEAK

NSString *selectedFont;

HaveCallback()
{
	GetPrefs()
	GetObject2(selectedFont, defaultName)
}

#endif