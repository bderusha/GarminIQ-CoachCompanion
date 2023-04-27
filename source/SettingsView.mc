import Toybox.Application.Properties;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;

//! Initial view for the settings
class SettingsView extends WatchUi.View {

    //! Constructor
    public function initialize() {
        View.initialize();
    }

    public function onShow() as Void {
        var menu = new $.SettingsMenu();

        var intervalVibratePropKey = "intervalVibrate";
        var intervalVibrate = Properties.getValue(intervalVibratePropKey);
        var internalVibrateLabel = WatchUi.loadResource($.Rez.Strings.intervalVibrate_setting_title) as String;
        menu.addItem(new WatchUi.ToggleMenuItem(internalVibrateLabel, null, intervalVibratePropKey, intervalVibrate, null));
        
        var intervalTonesPropKey = "intervalTones";
        var intervalTones = Properties.getValue(intervalTonesPropKey);
        var internalTonesLabel = WatchUi.loadResource($.Rez.Strings.intervalTones_setting_title) as String;
        menu.addItem(new WatchUi.ToggleMenuItem(internalTonesLabel, null, intervalTonesPropKey, intervalTones, null));

        WatchUi.pushView(menu, new $.SettingsMenuDelegate(), WatchUi.SLIDE_IMMEDIATE);
    }
}

//! Handle opening the settings menu
class SettingsDelegate extends WatchUi.BehaviorDelegate {

    //! Constructor
    public function initialize() {
        BehaviorDelegate.initialize();
    }

    public function onBack() as Boolean {
        System.println("SettingsDelegate: onBack()");
        WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
        return false;
    }
}

