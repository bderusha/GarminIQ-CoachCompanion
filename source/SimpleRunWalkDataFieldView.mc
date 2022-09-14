import Toybox.Application.Properties;
import Toybox.Activity;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Time;
import Toybox.Math;
import Toybox.WatchUi;
import Toybox.Attention;

class DataFieldAlertView extends WatchUi.DataFieldAlert {
    private var _mainView as SimpleRunWalkDataFieldView;
    private var _counter as Number = 0;

    //! Constructor
    public function initialize(view as SimpleRunWalkDataFieldView) {
        DataFieldAlert.initialize();
        _mainView = view;
    }

    //! Update the view
    //! @param dc Device context
    public function onUpdate(dc as Dc) as Void {
        // var h = dc.getHeight();
        // var w = dc.getWidth();
        // var md_h = dc.getFontHeight(Graphics.FONT_MEDIUM);
        // dc.drawText(w / 2, (h/2 - md_h/2), Graphics.FONT_MEDIUM, message, Graphics.TEXT_JUSTIFY_CENTER);
        // WatchUi.requestUpdate();
        // if (_counter >= 10) {
        //     _mainView.onUpdate(dc);
        //     WatchUi.requestUpdate();
        // }
        // WatchUi.pushView(_mainView, null, WatchUi.SLIDE_IMMEDIATE);
    }
}

class SimpleRunWalkDataFieldView extends WatchUi.DataField {
    private enum RunWalkState
    {
        STATE_RUNNING,
        STATE_WALKING,
        STATE_INACTIVE
    }

    private const MILLISECONDS_TO_SECONDS = 0.001;

    private const MAGIC_MILE_DURATIONS = [
        [360, 30], // mm7_00
        [300, 30], // mm7_30
        [240, 30], // mm8_00a
        [120, 15], // mm8_00b
        [120, 15], // mm8_30a
        [180, 15], // mm8_30b
        [120, 30], // mm9_00a
        [80, 20],  // mm9_00b
        [90, 30],  // mm9_30a
        [60, 20],  // mm9_30b
        [45, 15],  // mm9_30c
        [60, 30],  // mm9_30d
        [40, 20],  // mm9_30e
        [60, 30],  // mm10_45a
        [40, 20],  // mm10_45b
        [30, 15],  // mm10_45c
        [30, 30],  // mm10_45d
        [20, 20],  // mm10_45e
        [30, 30],  // mm12_15a
        [20, 20],  // mm12_15b
        [15, 15],  // mm12_15c
        [15, 30],  // mm14_30
        [10, 30],  // mm15_45
        [8, 30],   // mm17_00a
        [5, 25],   // mm17_00b
        [10, 30],  // mm17_00c
        [5, 30],   // mm18_30a
        [5, 25],   // mm18_30b
        [4, 30]   // mm18_30c
    ];

    // Settings
    private var _manualRunWalk as Boolean;
    private var _magicMilePaceIndex as Number;
    private var _runDuration as Number;
    private var _walkDuration as Number;
    private var _vibrateEnabled as Boolean;
    private var _tonesEnabled as Boolean;
    private var _alertDisplayed as Boolean;

    // Debug only
    private var _debugMode as Boolean = false;

    // RunWalk Interval State 
    private var _intervalStartAt as Number = 0;
    private var _intervalEndAt as Number = 0;
    private var _timerSeconds as Number = 0;
    public var _runWalkState as RunWalkState = STATE_INACTIVE;

    // Display values
    private var _dataColor as Graphics.ColorType;
    private var _displayState as String;



    // Set the label of the data field here.
    public function initialize() {
        DataField.initialize();
        handleSettingUpdate();
    }

    public function handleSettingUpdate() as Void {
        _manualRunWalk = Properties.getValue("manualRunWalk");
        _magicMilePaceIndex = Properties.getValue("magicMilePace");
        if (_manualRunWalk) {
            _runDuration = Properties.getValue("runDuration");
            _walkDuration = Properties.getValue("walkDuration");
        } else {
            _runDuration = MAGIC_MILE_DURATIONS[_magicMilePaceIndex][0];
            _walkDuration = MAGIC_MILE_DURATIONS[_magicMilePaceIndex][1];
        }
        _vibrateEnabled = Properties.getValue("intervalVibrate");
        _tonesEnabled = Properties.getValue("intervalTones");
        _alertDisplayed = ! Properties.getValue("pushAlert");
    }

    public function compute(info as Info) as Void {
        var timerTime = info.timerTime;
        if (timerTime != null) {
            _timerSeconds = (timerTime *  MILLISECONDS_TO_SECONDS).toNumber();
            switch ( _runWalkState ) {
                case STATE_RUNNING: {
                    updateState(STATE_WALKING, _walkDuration);
                    break;
                }
                case STATE_WALKING: {
                    updateState(STATE_RUNNING, _runDuration);
                    break;
                }
                default: {
                    break;
                }
            }
        }
        // if ((WatchUi.DataField has :showAlert) && (_runWalkState != STATE_INACTIVE)
        //             && !_alertDisplayed) {
        //             WatchUi.DataField.showAlert(new $.DataFieldAlertView(self));
        //             _alertDisplayed = true;
        //         }
    }

    //! Update the view
    //! @param dc Device Context
    public function onUpdate(dc as Dc) as Void {
        // Draw
        switch ( _runWalkState ) {
            case STATE_RUNNING: {
                _dataColor = Graphics.COLOR_BLACK;
                _displayState = "Run";
                break;
            }
            case STATE_WALKING: {
                _dataColor = Graphics.COLOR_BLACK;
                _displayState = "Walk";
                break;
            }
            default: {
                _dataColor = Graphics.COLOR_BLACK;
                break;
            }
        }

        dc.setColor(_dataColor, Graphics.COLOR_WHITE);
        dc.clear();

        var h = dc.getHeight();
        var w = dc.getWidth();
        var thai_h = dc.getFontHeight(Graphics.FONT_NUMBER_THAI_HOT);
        var md_h = dc.getFontHeight(Graphics.FONT_MEDIUM);

        if (_runWalkState != STATE_INACTIVE){
            var secondsRemaining = getSecondsRemaining();
            var minutes = secondsRemaining / 60;
            var seconds = secondsRemaining % 60;
            var timeRemaining = Lang.format("$1$:$2$", [minutes.format("%02d"), seconds.format("%02d")]);

            dc.drawText(w / 2, (h/4 - md_h/2), Graphics.FONT_LARGE, _displayState, Graphics.TEXT_JUSTIFY_CENTER);
            dc.drawText(w / 2, (h/2 - thai_h/2), Graphics.FONT_NUMBER_THAI_HOT, timeRemaining, Graphics.TEXT_JUSTIFY_CENTER);
        } else {
            var message = "RunWalkRun\nNot Detected!";
            dc.drawText(w / 2, (h/2 - md_h/2), Graphics.FONT_MEDIUM, message, Graphics.TEXT_JUSTIFY_CENTER);
        }
    }

    public function onWorkoutStarted() as Void {
        System.print("onWorkoutStarted: ");
        manageRunWalkRunWorkout();
    }

    public function onTimerStart() as Void {
        if (_debugMode) {
            _intervalEndAt = _runDuration;
            _runWalkState = STATE_RUNNING;
        }
    }

    public function onWorkoutStepComplete() as Void {
        System.print("onWorkoutStepComplete: ");
        manageRunWalkRunWorkout();
    }

    private function manageRunWalkRunWorkout() as Void {
        var workout = Activity.getCurrentWorkoutStep();
        if (workout != null && workout.notes.find("Run Walk Run") == 0) {
            _intervalStartAt = _timerSeconds;
            _intervalEndAt = _intervalStartAt + _runDuration;
            _runWalkState = STATE_RUNNING;
        } else {
            _runWalkState = STATE_INACTIVE;
        }
    }

    private function updateState(nextState as RunWalkState, nextDuration as Number) as Void {

        var secondsRemaining = getSecondsRemaining();

        if (secondsRemaining <= 0) {
            _intervalStartAt = _timerSeconds;
            _intervalEndAt = _intervalStartAt + nextDuration;
            _runWalkState = nextState;
        }

        if (Attention has :playTone && _tonesEnabled) {
            switch (secondsRemaining) {
                case 3:
                case 2:
                case 1:
                Attention.playTone(Attention.TONE_LOUD_BEEP);
                break;
                case 0:
                Attention.playTone(Attention.TONE_INTERVAL_ALERT);
                break;
                default:
                break;
            }
        }

        if (Attention has :vibrate && _vibrateEnabled) {
            switch (secondsRemaining) {
                case 3:
                case 2:
                case 1:
                Attention.vibrate([new Attention.VibeProfile(50, 250)]);
                break;
                case 0:
                Attention.vibrate([
                    new Attention.VibeProfile(50, 125),
                    new Attention.VibeProfile(0, 125),
                    new Attention.VibeProfile(75, 125),
                    new Attention.VibeProfile(0, 125),
                    new Attention.VibeProfile(100, 500)
                ]);
                break;
                default:
                break;
            }
        }
    }

    private function getSecondsRemaining() as Number {
        return _intervalEndAt - _timerSeconds;
    }
}