//
// Copyright 2015-2021 by Garmin Ltd. or its subsidiaries.
// Subject to Garmin SDK License Agreement and Wearables
// Application Developer Agreement.
//

import Toybox.Application.Storage;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;

//! Draws a filled rectangle
class MinSec extends WatchUi.Drawable {

    private var _active as Symbol;
    private var _min as String;
    private var _sec as String;

    //! Constructor
    //! @param color Color of the rectangle
    public function initialize(active as Symbol, min as String, sec as String) {
        Drawable.initialize({});
        _active = active;
        _min = min;
        _sec = sec;
        if(Storage.getValue("buffer") == null){
            Storage.setValue("buffer", 0);
        }
    }

    //! @param dc Device context
    public function draw(dc as Dc) as Void {

        var h = dc.getHeight();
        var w = dc.getWidth();
        var minFont = Graphics.FONT_NUMBER_MILD;
        var secFont = Graphics.FONT_NUMBER_MILD;
        var minW = 0;
        var sepW = 0;
        var secW = 0;
        var buffer = Storage.getValue("buffer");
        var minDim = dc.getTextDimensions(_min, minFont);
        var secDim = dc.getTextDimensions(_sec, secFont);
        var sepDim = dc.getTextDimensions(":", Graphics.FONT_LARGE);

        if(_active == :min){
            minFont = Graphics.FONT_NUMBER_HOT;
            minDim = dc.getTextDimensions(_min, minFont);
            minW = w/2;
            sepW = minW + minDim[0]/2 + sepDim[0]/2 + buffer;
            secW = sepW + sepDim[0]/2 + secDim[0]/2 + buffer;
        }
        if(_active == :sec){
            secFont = Graphics.FONT_NUMBER_HOT;
            secDim = dc.getTextDimensions(_sec, secFont);
            secW = w/2;
            sepW = secW - secDim[0]/2 - sepDim[0]/2 - buffer;
            minW = sepW - sepDim[0]/2 - minDim[0]/2 - buffer;
        }


        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.clear();

        dc.drawText(minW, ((h/2) - (minDim[1]/2)), minFont, _min, Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawText(sepW, ((h/2) - (sepDim[1]/2)), Graphics.FONT_LARGE, ":", Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawText(secW, ((h/2) - (secDim[1]/2)), secFont, _sec, Graphics.TEXT_JUSTIFY_CENTER);

    }
}


//
// Copyright 2015-2021 by Garmin Ltd. or its subsidiaries.
// Subject to Garmin SDK License Agreement and Wearables
// Application Developer Agreement.
//

import Toybox.Application.Storage;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;

//! Factory that controls which numbers can be picked
class NumberFactory extends WatchUi.PickerFactory {
    private var _unselectedKeys as Array<Number>;
    private var _start as Number;
    private var _stop as Number;
    private var _increment as Number;
    private var _formatString as String;
    private var _font as FontDefinition;

    //! Constructor
    //! @param start Number to start with
    //! @param stop Number to end with
    //! @param increment How far apart the numbers should be
    //! @param options Dictionary of options
    //! @option options :font The font to use
    //! @option options :format The number format to display
    public function initialize(unselectedKeys as Array<String>, start as Number, stop as Number, increment as Number, options as {
        :font as FontDefinition,
        :format as String
    }) {
        PickerFactory.initialize();

        _unselectedKeys = unselectedKeys;
        _start = start;
        _stop = stop;
        _increment = increment;

        var format = options.get(:format);
        if (format != null) {
            _formatString = format;
        } else {
            _formatString = "%d";
        }

        var font = options.get(:font);
        if (font != null) {
            _font = font;
        } else {
            _font = Graphics.FONT_NUMBER_HOT;
        }
    }

    //! Get the index of a number item
    //! @param value The number to get the index of
    //! @return The index of the number
    public function getIndex(value as Number) as Number {
        return (value / _increment) - _start;
    }

    //! Generate a Drawable instance for an item
    //! @param index The item index
    //! @param selected true if the current item is selected, false otherwise
    //! @return Drawable for the item
    public function getDrawable(index as Number, selected as Boolean) as Drawable? {
        var value = getValue(index);
        var text = "";
        var active = :none;

        for (var i = 0; i < _unselectedKeys.size(); i++) {
            if(_unselectedKeys[i].equals("min")){
                var storedMin = Storage.getValue("min");
                active = :sec;
                if (value instanceof Number) {
                    Storage.setValue("sec", value);
                    text += storedMin.format(_formatString) + ":" + value.format(_formatString);
                }
            } else if(_unselectedKeys[i].equals("sec")){
                var storedSec = Storage.getValue("sec");
                active = :min;
                if (value instanceof Number) {
                    Storage.setValue("min", value);

                    text += value.format(_formatString) + ":" + storedSec.format(_formatString);
                }
            }
        }

        return new MinSec(active, Storage.getValue("min").format(_formatString), Storage.getValue("sec").format(_formatString));

        // return new WatchUi.Text({:text=>text, :color=>Graphics.COLOR_WHITE, :font=>_font,
        //     :locX=>WatchUi.LAYOUT_HALIGN_CENTER, :locY=>WatchUi.LAYOUT_VALIGN_CENTER});
    }

    //! Get the value of the item at the given index
    //! @param index Index of the item to get the value of
    //! @return Value of the item
    public function getValue(index as Number) as Object? {
        return _start + (index * _increment);
    }

    //! Get the number of picker items
    //! @return Number of items
    public function getSize() as Number {
        return (_stop - _start) / _increment + 1;
    }

}

//
// Copyright 2015-2021 by Garmin Ltd. or its subsidiaries.
// Subject to Garmin SDK License Agreement and Wearables
// Application Developer Agreement.
//

import Toybox.Application.Properties;
import Toybox.Application.Storage;
// import Toybox.Graphics;
// import Toybox.Lang;
import Toybox.System;
// import Toybox.WatchUi;

const MINUTE_FORMAT = "%02d";

//! Picker that allows the user to choose a time
class TimePicker extends WatchUi.Picker {
    private var _storageKey as String;

    //! Constructor
    public function initialize(storageKey as String) {
        _storageKey = storageKey;
        var title = new WatchUi.Text({:text=>storageKey, :locX=>WatchUi.LAYOUT_HALIGN_CENTER,
            :locY=>WatchUi.LAYOUT_VALIGN_BOTTOM, :color=>Graphics.COLOR_WHITE});
        var factories = new Array<PickerFactory or Text>[3];
        var minKey = new Array<Number>[1];
        minKey[0] = "min";
        var secKey = new Array<Number>[1];
        secKey[0] = "sec";

        var defaults = new Array<Number>[3];
        var time = Properties.getValue(_storageKey);
        var min = time / 60;
        var sec = time % 60;
        defaults[0] = min;
        defaults[2] = sec;

        Storage.setValue("min", min);
        Storage.setValue("sec", sec);

        factories[0] = new $.NumberFactory(secKey, 0, 59, 1, {:format=>$.MINUTE_FORMAT});
        factories[1] = new WatchUi.Text({:text=>":", :font=>Graphics.FONT_MEDIUM,
            :locX=>WatchUi.LAYOUT_HALIGN_CENTER, :locY=>WatchUi.LAYOUT_VALIGN_CENTER, :color=>Graphics.COLOR_WHITE});
        factories[2] = new $.NumberFactory(minKey, 0, 59, 1, {:format=>$.MINUTE_FORMAT});

        Picker.initialize({:title=>title, :pattern=>factories, :defaults=>defaults});
    }

    //! Update the view
    //! @param dc Device Context
    public function onUpdate(dc as Dc) as Void {
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();
        Picker.onUpdate(dc);
    }
}

//! Responds to a time picker selection or cancellation
class TimePickerDelegate extends WatchUi.PickerDelegate {
    private var _storageKey as String;
    private var _parentView as DataFieldView;

    //! Constructor
    public function initialize(storageKey as String, view as DataFieldView) {
        _storageKey = storageKey;
        _parentView = view;
        PickerDelegate.initialize();
    }

    //! Handle a cancel event from the picker
    //! @return true if handled, false otherwise
    public function onCancel() as Boolean {
        WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
        return true;
    }

    //! Handle a confirm event from the picker
    //! @param values The values chosen in the picker
    //! @return true if handled, false otherwise
    public function onAccept(values as Array<Number?>) as Boolean {
        var min = values[0];
        var sec = values[2];

        if ((min != null) && (sec != null)) {
            var totalTime = (min * 60) + sec;
            Properties.setValue(_storageKey, totalTime);
            _parentView.handleSettingUpdate();
        }

        WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
        return true;
    }

}
