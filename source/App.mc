import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;

class App extends Application.AppBase {
    private var _mainView as View;

    function initialize() {
        AppBase.initialize();
        _mainView = new DataFieldView();
    }

    // onStart() is called on application start up
    function onStart(state as Dictionary?) as Void {
    }

    // onStop() is called when your application is exiting
    function onStop(state as Dictionary?) as Void {
    }

    function onSettingsChanged() { 
        _mainView.handleSettingUpdate();
        WatchUi.requestUpdate();   
    }

    function onStorageChanged() {
        _mainView.handleSettingUpdate();
        WatchUi.requestUpdate(); 
    }

    // Return the initial view of your application here
    function getInitialView() as Array<Views or InputDelegates>? {
        return [ _mainView ] as Array<Views or InputDelegates>;
    }

    //! Return the settings view and delegate for the app
    //! @return Array Pair [View, Delegate]
    public function getSettingsView() as Array<Views or InputDelegates>? {
        return [new $.DataFieldSettingsView(_mainView), new $.DataFieldSettingsDelegate()] as Array<Views or InputDelegates>;
    }

}

function getApp() as App {
    return Application.getApp() as App;
}