import Toybox.Application;
import Toybox.Application.Properties;
import Toybox.Lang;
import Toybox.WatchUi;

//! The settings menu
class SettingsMenu extends WatchUi.Menu2 {

    //! Constructor
    public function initialize() {
        Menu2.initialize({:title=>"Settings"});
    }
}

//! Handles menu input and stores the menu data
class SettingsMenuDelegate extends WatchUi.Menu2InputDelegate {
    //! Constructor
    public function initialize() {
        Menu2InputDelegate.initialize();
    }

    //! Handle a menu item selection
    //! @param menuItem The selected menu item
    public function onSelect(menuItem as ToggleMenuItem or MenuItem) as Void {
        var id = menuItem.getId();

        System.println("SELECT: " + id);
        if (id.equals("intervalVibrate") || id.equals("intervalTones")){
            var key = id;
            var val = menuItem.isEnabled();
            Properties.setValue(key, val);
            System.println(key + " : " + val);
            Application.getApp().onSettingsChanged();
        }
    }

    //! Handle the back key being pressed
    public function onBack() as Void {
        System.println("SettingsMenu.mc: onBack()");
        WatchUi.popView(WatchUi.SLIDE_DOWN);
    }

    //! Handle the done item being selected
    public function onDone() as Void {
        System.println("SettingsMenu.mc: onDone()");
        WatchUi.popView(WatchUi.SLIDE_DOWN);
    }
}
