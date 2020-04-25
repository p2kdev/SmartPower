#line 1 "Tweak.xm"
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
  -(void)setPowerMode:(long long)arg1 fromSource:(id)arg2 withCompletion:(id)arg3 ;
  -(BOOL)setPowerMode:(long long)arg1 fromSource:(id)arg2 ;
  -(void)setPowerMode:(long long)arg1 withCompletion:(id)arg2 ;
  -(BOOL)setPowerMode:(long long)arg1 error:(id*)arg2 ;
  -(long long)getPowerMode;
@end

static bool lpmThresholdEnabled = YES;
static int lpmThreshold = 40;
static bool lpmChargingEnabled = YES;
static bool wasLPMAutoTurnedOn = NO;


#include <substrate.h>
#if defined(__clang__)
#if __has_feature(objc_arc)
#define _LOGOS_SELF_TYPE_NORMAL __unsafe_unretained
#define _LOGOS_SELF_TYPE_INIT __attribute__((ns_consumed))
#define _LOGOS_SELF_CONST const
#define _LOGOS_RETURN_RETAINED __attribute__((ns_returns_retained))
#else
#define _LOGOS_SELF_TYPE_NORMAL
#define _LOGOS_SELF_TYPE_INIT
#define _LOGOS_SELF_CONST
#define _LOGOS_RETURN_RETAINED
#endif
#else
#define _LOGOS_SELF_TYPE_NORMAL
#define _LOGOS_SELF_TYPE_INIT
#define _LOGOS_SELF_CONST
#define _LOGOS_RETURN_RETAINED
#endif

@class SpringBoard; @class _CDBatterySaver; 
static void (*_logos_orig$_ungrouped$SpringBoard$applicationDidFinishLaunching$)(_LOGOS_SELF_TYPE_NORMAL SpringBoard* _LOGOS_SELF_CONST, SEL, id); static void _logos_method$_ungrouped$SpringBoard$applicationDidFinishLaunching$(_LOGOS_SELF_TYPE_NORMAL SpringBoard* _LOGOS_SELF_CONST, SEL, id); static void _logos_method$_ungrouped$SpringBoard$_batteryStateChanged(_LOGOS_SELF_TYPE_NORMAL SpringBoard* _LOGOS_SELF_CONST, SEL); static void _logos_method$_ungrouped$SpringBoard$_batteryLevelChanged(_LOGOS_SELF_TYPE_NORMAL SpringBoard* _LOGOS_SELF_CONST, SEL); 
static __inline__ __attribute__((always_inline)) __attribute__((unused)) Class _logos_static_class_lookup$_CDBatterySaver(void) { static Class _klass; if(!_klass) { _klass = objc_getClass("_CDBatterySaver"); } return _klass; }
#line 24 "Tweak.xm"



static void _logos_method$_ungrouped$SpringBoard$applicationDidFinishLaunching$(_LOGOS_SELF_TYPE_NORMAL SpringBoard* _LOGOS_SELF_CONST __unused self, SEL __unused _cmd, id application) {
  _logos_orig$_ungrouped$SpringBoard$applicationDidFinishLaunching$(self, _cmd, application);
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_batteryStateChanged) name:UIDeviceBatteryStateDidChangeNotification object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_batteryLevelChanged) name:UIDeviceBatteryLevelDidChangeNotification object:nil];
}



static void _logos_method$_ungrouped$SpringBoard$_batteryStateChanged(_LOGOS_SELF_TYPE_NORMAL SpringBoard* _LOGOS_SELF_CONST __unused self, SEL __unused _cmd) {
  if (lpmChargingEnabled)
  {
    UIDevice *device = [UIDevice currentDevice]; 
    [device setBatteryMonitoringEnabled:YES]; 
    UIDeviceBatteryState deviceBatteryState = [UIDevice currentDevice].batteryState;

    if (deviceBatteryState == UIDeviceBatteryStateFull)
      [[_logos_static_class_lookup$_CDBatterySaver() batterySaver] setMode:0];
    else if (deviceBatteryState == UIDeviceBatteryStateCharging)
      [[_logos_static_class_lookup$_CDBatterySaver() batterySaver] setMode:1];
    else if (deviceBatteryState == UIDeviceBatteryStateUnplugged)
        [[_logos_static_class_lookup$_CDBatterySaver() batterySaver] setMode:0];
  }

}



static void _logos_method$_ungrouped$SpringBoard$_batteryLevelChanged(_LOGOS_SELF_TYPE_NORMAL SpringBoard* _LOGOS_SELF_CONST __unused self, SEL __unused _cmd) {
  if (lpmThresholdEnabled)
  {
    UIDevice *device = [UIDevice currentDevice]; 
    [device setBatteryMonitoringEnabled:YES]; 

    int currentbat = (int)([device batteryLevel] * 100);

    if (currentbat <= lpmthreshold && !wasLPMAutoTurnedOn)
    {
      [[_logos_static_class_lookup$_CDBatterySaver() batterySaver] setMode:1];
      wasLPMAutoTurnedOn = YES;
    }

    if (lpmthreshold > lpmThreshold)
      wasLPMAutoTurnedOn = NO;
  }
}



static void reloadSettings() {

	NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/com.p2kdev.smartpower.plist"];
	if(prefs)
	{
		lpmThreshold = [prefs objectForKey:@"lpmThreshold"] ? [[prefs objectForKey:@"lpmThreshold"] intValue] : lpmThreshold;
		lpmThresholdEnabled = [prefs objectForKey:@"lpmOnThreshold"] ? [[prefs objectForKey:@"lpmOnThreshold"] boolValue] : lpmThresholdEnabled;
    lpmchargingEnabled = [prefs objectForKey:@"lpmOnCharging"] ? [[prefs objectForKey:@"lpmOnCharging"] boolValue] : lpmchargingEnabled;
	}
}

static __attribute__((constructor)) void _logosLocalCtor_a036efd8(int __unused argc, char __unused **argv, char __unused **envp) {
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)reloadSettings, CFSTR("com.p2kdev.sakal.settingschanged"), NULL, CFNotificationSuspensionBehaviorCoalesce);
	reloadSettings();
}

  
  
  
static __attribute__((constructor)) void _logosLocalInit() {
{Class _logos_class$_ungrouped$SpringBoard = objc_getClass("SpringBoard"); MSHookMessageEx(_logos_class$_ungrouped$SpringBoard, @selector(applicationDidFinishLaunching:), (IMP)&_logos_method$_ungrouped$SpringBoard$applicationDidFinishLaunching$, (IMP*)&_logos_orig$_ungrouped$SpringBoard$applicationDidFinishLaunching$);{ char _typeEncoding[1024]; unsigned int i = 0; _typeEncoding[i] = 'v'; i += 1; _typeEncoding[i] = '@'; i += 1; _typeEncoding[i] = ':'; i += 1; _typeEncoding[i] = '\0'; class_addMethod(_logos_class$_ungrouped$SpringBoard, @selector(_batteryStateChanged), (IMP)&_logos_method$_ungrouped$SpringBoard$_batteryStateChanged, _typeEncoding); }{ char _typeEncoding[1024]; unsigned int i = 0; _typeEncoding[i] = 'v'; i += 1; _typeEncoding[i] = '@'; i += 1; _typeEncoding[i] = ':'; i += 1; _typeEncoding[i] = '\0'; class_addMethod(_logos_class$_ungrouped$SpringBoard, @selector(_batteryLevelChanged), (IMP)&_logos_method$_ungrouped$SpringBoard$_batteryLevelChanged, _typeEncoding); }} }
#line 94 "Tweak.xm"
