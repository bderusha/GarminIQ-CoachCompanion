import Toybox.Application.Properties;
import Toybox.Activity;
import Toybox.Attention;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Math;
import Toybox.Time;
import Toybox.WatchUi;
import Toybox.System;

class DataFieldView extends WatchUi.DataField {
    // Settings
    private var _manualRunWalk as Boolean?;
    private var _walkFirst as Boolean?;
    private var _enableLongRun as Boolean?;
    private var _rwrPaceIndex as Number?;
    private var _longRunPaceIndex as Number?;
    private var _runDuration as Number?;
    private var _walkDuration as Number?;
    private var _vibrateEnabled as Boolean?;
    private var _tonesEnabled as Boolean?;
    private var _distanceUnits as UnitsSystem?;

    // RunWalk Interval State 
    private var _intervalStartAt as Number = 0;
    private var _intervalEndAt as Number = 0;
    private var _timerSeconds as Number = 0;
    private var _workoutTargetDistance as Float = 0.0;
    private var _distanceToGo as Float = 0.0;
    public var _runWalkState as Constants.RunWalkState = Constants.STATE_INACTIVE;

    // Display values
    private var _dataColor as Graphics.ColorType = Graphics.COLOR_LT_GRAY;
    private var _displayState as String = "Run";

    // Set the label of the data field here.
    public function initialize() {
        DataField.initialize();
        handleSettingUpdate();
        manageRunWalkRunWorkout();
    }

    public function handleSettingUpdate() as Void {
        _manualRunWalk = Properties.getValue("manualRunWalk");
        _enableLongRun = Properties.getValue("enableLongRun");
        _walkFirst = Properties.getValue("walkFirst");
        _rwrPaceIndex = Properties.getValue("rwrMagicMilePace");
        _longRunPaceIndex = Properties.getValue("longRunMagicMilePace");

        _vibrateEnabled = Properties.getValue("intervalVibrate");
        _tonesEnabled = Properties.getValue("intervalTones");

        if (_manualRunWalk) {
            _runDuration = Properties.getValue("runDuration");
            _walkDuration = Properties.getValue("walkDuration");
        } else {
            _runDuration = Constants.MAGIC_MILE_DURATIONS[_rwrPaceIndex][0];
            _walkDuration = Constants.MAGIC_MILE_DURATIONS[_rwrPaceIndex][1];
        }

        var mySettings = System.getDeviceSettings();
        _distanceUnits = mySettings.distanceUnits;
    }

    public function compute(info as Info) as Void {
        var timerTime = info.timerTime;
        if (timerTime != null) {
            _timerSeconds = (timerTime *  Constants.MILLISECONDS_TO_SECONDS).toNumber();
            switch ( _runWalkState ) {
                case Constants.STATE_RUNNING: {
                    updateState(Constants.STATE_WALKING, _walkDuration, "Walk", Graphics.COLOR_ORANGE);
                    break;
                }
                case Constants.STATE_WALKING: {
                    updateState(Constants.STATE_RUNNING, _runDuration, "Run", Graphics.COLOR_DK_GREEN);
                    break;
                }
                default: {
                    _dataColor = Graphics.COLOR_LT_GRAY;
                    break;
                }
            }
        }
        var distance = info.elapsedDistance;
        if (distance != null) {
            var metersToGo = _workoutTargetDistance - distance;
            if (_distanceUnits == System.UNIT_METRIC){
                _distanceToGo = Constants.METERS_TO_KM *  metersToGo;
            } else if (_distanceUnits == System.UNIT_STATUTE){
                _distanceToGo = Constants.METERS_TO_MILES * metersToGo;
            }
        }
    }

    //! Update the view
    //! @param dc Device Context
    public function onUpdate(dc as Dc) as Void {
        // Draw
        var h = dc.getHeight();
        var w = dc.getWidth();
        var num_thai_h = dc.getFontHeight(Graphics.FONT_NUMBER_THAI_HOT);
        var num_hot_h = dc.getFontHeight(Graphics.FONT_NUMBER_HOT);
        var num_med_h = dc.getFontHeight(Graphics.FONT_NUMBER_MEDIUM);
        var num_mild_h = dc.getFontHeight(Graphics.FONT_NUMBER_MILD);
        var md_h = dc.getFontHeight(Graphics.FONT_MEDIUM);
        var sm_h = dc.getFontHeight(Graphics.FONT_SMALL);

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_WHITE);
        dc.clear();
        // Draw Border
        dc.setColor(_dataColor, _dataColor);
        dc.setPenWidth(8);
        dc.drawCircle(w / 2, h / 2, (w/2)-3);
        // Reset
        dc.setPenWidth(1);
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_WHITE);
        if (_runWalkState != Constants.STATE_INACTIVE){
            var secondsRemaining = getSecondsRemaining();
            var minutes = secondsRemaining / 60;
            var seconds = secondsRemaining % 60;
            var timeRemaining = Lang.format("$1$:$2$", [minutes.format("%d"), seconds.format("%02d")]);
            var distanceRemaining = _distanceToGo.format("%.2f");

            // dc.drawText(w / 2, (md_h/2), Graphics.FONT_LARGE, _displayState, Graphics.TEXT_JUSTIFY_CENTER);
            dc.drawText(w / 2, (h/2 - num_thai_h/2), Graphics.FONT_NUMBER_THAI_HOT, distanceRemaining, Graphics.TEXT_JUSTIFY_CENTER);
            dc.drawText(w / 2, (h/4 - md_h/2), Graphics.FONT_LARGE, _displayState, Graphics.TEXT_JUSTIFY_CENTER);
            dc.drawText(w / 2, ((h*3/4) - num_med_h/2), Graphics.FONT_NUMBER_MEDIUM, timeRemaining, Graphics.TEXT_JUSTIFY_CENTER);
        } else {
            var minutes = _timerSeconds / 60;
            var seconds = _timerSeconds % 60;
            var totalTime = Lang.format("$1$:$2$", [minutes.format("%d"), seconds.format("%02d")]);
            dc.drawText(w / 2, (h/2 - num_thai_h/2), Graphics.FONT_NUMBER_THAI_HOT, totalTime, Graphics.TEXT_JUSTIFY_CENTER);
            dc.drawText(w / 2, (h/4 - sm_h/2), Graphics.FONT_SMALL, "Waiting for", Graphics.TEXT_JUSTIFY_CENTER);
            dc.drawText(w / 2, ((h*3/4) - sm_h/2), Graphics.FONT_SMALL, "RunWalkRun", Graphics.TEXT_JUSTIFY_CENTER);
        }
    }

    public function onWorkoutStarted() as Void {
        manageRunWalkRunWorkout();
    }

    public function debug() as Void {
        _intervalStartAt = 0;
        _workoutTargetDistance = 4000.0;
        _runDuration = Constants.MAGIC_MILE_DURATIONS[_rwrPaceIndex][0];
        _walkDuration = Constants.MAGIC_MILE_DURATIONS[_rwrPaceIndex][1];
        if (_walkFirst) {
            _intervalEndAt = _intervalStartAt + _walkDuration;
            _runWalkState = Constants.STATE_WALKING;
            _displayState = "Walk";
            _dataColor = Graphics.COLOR_ORANGE;
        } else {
            _intervalEndAt = _intervalStartAt + _runDuration;
            _runWalkState = Constants.STATE_RUNNING;
            _displayState = "Run";
            _dataColor = Graphics.COLOR_DK_GREEN;
        }
    }

    public function onWorkoutStepComplete() as Void {
        manageRunWalkRunWorkout();
    }

    private function manageRunWalkRunWorkout() as Void {
        var workout = Activity.getCurrentWorkoutStep();
        var info = Activity.getActivityInfo();
        if (workout != null){
            System.println("Workout name: "+workout.name);
            System.println("Workout notes: "+workout.notes);
        }
        if (workout != null){
            var startRunWalk = false;
            if(workout.notes.find("Run Walk Run") == 0){
                startRunWalk = true;
                if (!_manualRunWalk) {
                    _runDuration = Constants.MAGIC_MILE_DURATIONS[_rwrPaceIndex][0];
                    _walkDuration = Constants.MAGIC_MILE_DURATIONS[_rwrPaceIndex][1];
                }
            } else if(_enableLongRun && workout.notes.find("Run at an easy pace") == 0){
                startRunWalk = true;
                if (!_manualRunWalk) {
                    _runDuration = Constants.MAGIC_MILE_DURATIONS[_longRunPaceIndex][0];
                    _walkDuration = Constants.MAGIC_MILE_DURATIONS[_longRunPaceIndex][1];
                }
            }
            if (startRunWalk) {
                System.println("RUN WALK RUN started");
                _intervalStartAt = _timerSeconds;
                _workoutTargetDistance = info.elapsedDistance + workout.step.durationValue;
                if (_walkFirst) {
                    _intervalEndAt = _intervalStartAt + _walkDuration;
                    _runWalkState = Constants.STATE_WALKING;
                    _displayState = "Walk";
                    _dataColor = Graphics.COLOR_ORANGE;
                } else {
                    _intervalEndAt = _intervalStartAt + _runDuration;
                    _runWalkState = Constants.STATE_RUNNING;
                    _displayState = "Run";
                    _dataColor = Graphics.COLOR_DK_GREEN;
                }
            } else {
            _runWalkState = Constants.STATE_INACTIVE;
            }
        } 
    }

    private function updateState(nextState as Constants.RunWalkState, nextDuration as Number, displayName as String, color as Graphics.ColorValue) as Void {
        var secondsRemaining = getSecondsRemaining();

        if (secondsRemaining <= 0) {
            _intervalStartAt = _timerSeconds;
            _intervalEndAt = _intervalStartAt + nextDuration;
            _runWalkState = nextState;
            _displayState = displayName;
            _dataColor = color;
        }

        if (Attention has :playTone && _tonesEnabled && _runWalkState != Constants.STATE_INACTIVE) {
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

        if (Attention has :vibrate && _vibrateEnabled && _runWalkState != Constants.STATE_INACTIVE) {
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