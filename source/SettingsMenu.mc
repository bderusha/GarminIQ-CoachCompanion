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
    private var _parentView as DataFieldView;

    //! Constructor
    public function initialize(view as DataFieldView) {
        Menu2InputDelegate.initialize();
        _parentView = view;
    }

    //! Handle a menu item selection
    //! @param menuItem The selected menu item
    public function onSelect(menuItem as ToggleMenuItem or MenuItem) as Void {
        var id = menuItem.getId();

        if (id == :intervalVibrate || id == :intervalTones){
            Properties.setValue(id.toString(), menuItem.isEnabled());
            _parentView.handleSettingUpdate();
        }
    }

    //! Handle the back key being pressed
    public function onBack() as Void {
        WatchUi.popView(WatchUi.SLIDE_DOWN);
    }
}
