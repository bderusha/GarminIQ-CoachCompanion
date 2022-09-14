//
// Copyright 2016-2021 by Garmin Ltd. or its subsidiaries.
// Subject to Garmin SDK License Agreement and Wearables
// Application Developer Agreement.
//

import Toybox.Application.Properties;
import Toybox.Lang;
import Toybox.WatchUi;

//! The settings menu
class DataFieldSettingsMenu extends WatchUi.Menu2 {

    //! Constructor
    public function initialize() {
        Menu2.initialize({:title=>"Settings"});
    }
}

//! Handles menu input and stores the menu data
class DataFieldSettingsMenuDelegate extends WatchUi.Menu2InputDelegate {
    private var _parentView as SimpleRunWalkDataFieldView;

    //! Constructor
    public function initialize(view as SimpleRunWalkDataFieldView) {
        Menu2InputDelegate.initialize();
        _parentView = view;
    }

    //! Handle a menu item selection
    //! @param menuItem The selected menu item
    public function onSelect(menuItem as ToggleMenuItem or MenuItem) as Void {
        var id = menuItem.getId();

        if (id == :run) {
            WatchUi.pushView(new $.TimePicker("runDuration"), new $.TimePickerDelegate("runDuration", _parentView), WatchUi.SLIDE_IMMEDIATE);
        } else if (id == :walk) {
            WatchUi.pushView(new $.TimePicker("walkDuration"), new $.TimePickerDelegate("walkDuration", _parentView), WatchUi.SLIDE_IMMEDIATE);
        // } else if (id.equals("intervalVibrate") || id.equals("intervalTones")) {
        //     Properties.setValue(id, menuItem.isEnabled());
        //     _parentView.handleSettingUpdate();
        // }
        } else if (id == :intervalVibrate || id == :intervalTones){
            Properties.setValue(id.toString(), menuItem.isEnabled());
            _parentView.handleSettingUpdate();
        }

    }

    //! Handle the back key being pressed
    public function onBack() as Void {
        WatchUi.popView(WatchUi.SLIDE_DOWN);
    }
}
