@interface FBSystemService : NSObject
  +(id)sharedInstance;
  -(void)exitAndRelaunch:(BOOL)arg1;
@end

@interface _CDBatterySaver
  +(id)sharedInstance;
  +(id)batterySaver;
  -(id)init;
  -(void)dealloc;
  -(long long)setMode:(long long)arg1 ;
  -(void)setPowerMode:(long long)arg1 fromSource:(id)arg2 withCompletion:(/*^block*/id)arg3 ;
  -(BOOL)setPowerMode:(long long)arg1 fromSource:(id)arg2 ;
  -(void)setPowerMode:(long long)arg1 withCompletion:(/*^block*/id)arg2 ;
  -(BOOL)setPowerMode:(long long)arg1 error:(id*)arg2 ;
  -(long long)getPowerMode;
@end

static bool lpmThresholdEnabled = YES;
static int lpmThreshold = 40;
static bool lpmChargingEnabled = YES;
static bool wasLPMAutoTurnedOn = NO;

%hook SpringBoard

-(void)applicationDidFinishLaunching:(id)application
{
  %orig;
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_batteryStateChanged) name:UIDeviceBatteryStateDidChangeNotification object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_batteryLevelChanged) name:UIDeviceBatteryLevelDidChangeNotification object:nil];
}

%new
-(void)_batteryStateChanged
{
  if (lpmChargingEnabled)
  {
    UIDevice *device = [UIDevice currentDevice]; // Get current device
    [device setBatteryMonitoringEnabled:YES]; // Set this to true to grab battery percentage
    UIDeviceBatteryState deviceBatteryState = [UIDevice currentDevice].batteryState;

    if (deviceBatteryState == UIDeviceBatteryStateFull)
      [[%c(_CDBatterySaver) batterySaver] setMode:0];
    else if (deviceBatteryState == UIDeviceBatteryStateCharging)
      [[%c(_CDBatterySaver) batterySaver] setMode:1];
    else if (deviceBatteryState == UIDeviceBatteryStateUnplugged)
        [[%c(_CDBatterySaver) batterySaver] setMode:0];
  }

}

%new
-(void)_batteryLevelChanged
{
  if (lpmThresholdEnabled)
  {
    UIDevice *device = [UIDevice currentDevice]; // Get current device
    [device setBatteryMonitoringEnabled:YES]; // Set this to true to grab battery percentage

    int currentbat = (int)([device batteryLevel] * 100);

    if (currentbat <= lpmThreshold && !wasLPMAutoTurnedOn)
    {
      [[%c(_CDBatterySaver) batterySaver] setMode:1];
      wasLPMAutoTurnedOn = YES;
    }

    if (currentbat > lpmThreshold)
      wasLPMAutoTurnedOn = NO;
  }
}

%end

static void reloadSettings() {

	NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/com.p2kdev.smartpower.plist"];
	if(prefs)
	{
		lpmThreshold = [prefs objectForKey:@"lpmThreshold"] ? [[prefs objectForKey:@"lpmThreshold"] intValue] : lpmThreshold;
		lpmThresholdEnabled = [prefs objectForKey:@"lpmOnThreshold"] ? [[prefs objectForKey:@"lpmOnThreshold"] boolValue] : lpmThresholdEnabled;
    lpmChargingEnabled = [prefs objectForKey:@"lpmOnCharging"] ? [[prefs objectForKey:@"lpmOnCharging"] boolValue] : lpmChargingEnabled;
	}
}

%ctor {
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)reloadSettings, CFSTR("com.p2kdev.smartpower.settingschanged"), NULL, CFNotificationSuspensionBehaviorCoalesce);
	reloadSettings();
}

  // static void respring(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
  //   [[%c(FBSystemService) sharedInstance] exitAndRelaunch:YES];
  // }
