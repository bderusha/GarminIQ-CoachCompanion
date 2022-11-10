import Toybox.Lang;

class Constants {
    public static enum RunWalkState
    {
        STATE_RUNNING,
        STATE_WALKING,
        STATE_INACTIVE
    }

    public static const MILLISECONDS_TO_SECONDS = 0.001;

    public static const METERS_TO_MILES = 0.000621371;
    public static const METERS_TO_KM = 0.001;

    public static const MAGIC_MILE_DURATIONS = [
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
}