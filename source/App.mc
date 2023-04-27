import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;

class App extends Application.AppBase {
    private var _mainView as DataFieldView;

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
}

function getApp() as App {
    return Application.getApp() as App;
}