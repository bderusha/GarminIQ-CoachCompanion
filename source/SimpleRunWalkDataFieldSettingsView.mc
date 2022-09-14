//
// Copyright 2016-2021 by Garmin Ltd. or its subsidiaries.
// Subject to Garmin SDK License Agreement and Wearables
// Application Developer Agreement.
//

import Toybox.Application.Properties;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;

//! Initial view for the settings
class DataFieldSettingsView extends WatchUi.View {
    private var _parentView as SimpleRunWalkDataFieldView;


    //! Constructor
    public function initialize(view as SimpleRunWalkDataFieldView) {
        _parentView = view;
        View.initialize();
    }

    public function onShow() as Void {
        var menu = new $.DataFieldSettingsMenu();

        menu.addItem(new WatchUi.MenuItem("Run Time", null, :run, null));
        menu.addItem(new WatchUi.MenuItem("Walk Time", null, :walk, null));
        
        var intervalVibrateKey = "intervalVibrate";
        var intervalVibrate = Properties.getValue(intervalVibrateKey);
        var internalVibrateLabel = WatchUi.loadResource($.Rez.Strings.intervalVibrate_setting_title) as String;
        menu.addItem(new WatchUi.ToggleMenuItem(internalVibrateLabel, null, :intervalVibrate, intervalVibrate, null));
        
        var intervalTonesKey = "intervalTones";
        var intervalTones = Properties.getValue(intervalTonesKey);
        var internalTonesLabel = WatchUi.loadResource($.Rez.Strings.intervalTones_setting_title) as String;
        menu.addItem(new WatchUi.ToggleMenuItem(internalTonesLabel, null, :intervalTones, intervalTones, null));

        WatchUi.pushView(menu, new $.DataFieldSettingsMenuDelegate(_parentView), WatchUi.SLIDE_IMMEDIATE);
    }
}

//! Handle opening the settings menu
class DataFieldSettingsDelegate extends WatchUi.BehaviorDelegate {

    //! Constructor
    public function initialize() {
        BehaviorDelegate.initialize();
    }
}

