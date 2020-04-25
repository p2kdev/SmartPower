#import <Preferences/Preferences.h>

#define tweakPrefPath @"/User/Library/Preferences/com.p2kdev.smartpower.plist"

@interface PrefRootListController : PSListController
@end

@implementation PrefRootListController
- (id)specifiers {
	if(_specifiers == nil) {
		_specifiers = [[self loadSpecifiersFromPlistName:@"Root" target:self] retain];
	}
	return _specifiers;
}

-(id) readPreferenceValue:(PSSpecifier*)specifier {
	NSDictionary *tweakSettings = [NSDictionary dictionaryWithContentsOfFile:tweakPrefPath];

	NSString *key = [specifier propertyForKey:@"key"];
	id defaultValue = [specifier propertyForKey:@"default"];
	id plistValue = [tweakSettings objectForKey:key];
	if (!plistValue) plistValue = defaultValue;

	return plistValue;
}

-(void) setPreferenceValue:(id)value specifier:(PSSpecifier*)specifier {
	NSMutableDictionary *defaults = [NSMutableDictionary dictionary];
	[defaults addEntriesFromDictionary:[NSDictionary dictionaryWithContentsOfFile:tweakPrefPath]];
	[defaults setObject:value forKey:specifier.properties[@"key"]];
	[defaults writeToFile:tweakPrefPath atomically:YES];

	CFStringRef toPost = (CFStringRef)specifier.properties[@"PostNotification"];
	if(toPost) CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), toPost, NULL, NULL, YES);
}

- (void)visitTwitter {
  [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://twitter.com/p2kdev"]];
}

@end
