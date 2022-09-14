import Toybox.Application.Properties;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;

//! Initial view for the settings
class SettingsView extends WatchUi.View {
    private var _parentView as DataFieldView;


    //! Constructor
    public function initialize(view as DataFieldView) {
        _parentView = view;
        View.initialize();
    }

    public function onShow() as Void {
        var menu = new $.SettingsMenu();

        var intervalVibrate = Properties.getValue("intervalVibrate");
        var internalVibrateLabel = WatchUi.loadResource($.Rez.Strings.intervalVibrate_setting_title) as String;
        menu.addItem(new WatchUi.ToggleMenuItem(internalVibrateLabel, null, :intervalVibrate, intervalVibrate, null));
        
        var intervalTones = Properties.getValue("intervalTones");
        var internalTonesLabel = WatchUi.loadResource($.Rez.Strings.intervalTones_setting_title) as String;
        menu.addItem(new WatchUi.ToggleMenuItem(internalTonesLabel, null, :intervalTones, intervalTones, null));

        WatchUi.pushView(menu, new $.SettingsMenuDelegate(_parentView), WatchUi.SLIDE_IMMEDIATE);
    }
}

//! Handle opening the settings menu
class SettingsDelegate extends WatchUi.BehaviorDelegate {

    //! Constructor
    public function initialize() {
        BehaviorDelegate.initialize();
    }
}

