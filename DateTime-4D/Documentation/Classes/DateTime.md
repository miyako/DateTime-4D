## Description

`DateTime` represents a calendar date and a time of day, with an associated `TimeZone`. It provides date/time components, formatting helpers, UTC conversion, and in-place arithmetic.

## Construction

```4d
// Current local date and time, using the detected system time zone
var $now := cs.DateTime.new()

// A date with midnight as the time
var $dateOnly := cs.DateTime.new(!2025-11-05!)

// A date and time with the detected system time zone
var $local := cs.DateTime.new(!2025-11-05!; ?14:30:15?)

// A date and time with an explicit time zone
var $paris := cs.DateTime.new(!2025-11-05!; ?14:30:15?; cs.TimeZone.new("Europe/Paris"))
```

The constructor accepts no arguments, a date, a date and time, or a date, time, and time zone. When the time zone is omitted or `Null`, a new `TimeZone` is created to detect the system time zone. `DateTime.now()` is a static convenience method equivalent to `DateTime.new()`.

## Properties

| Property | Type | Description |
| --- | --- | --- |
| `date` | `Date` | Calendar date held by the instance. |
| `time` | `Time` | Time of day held by the instance. |
| `timeZone` | `cs.TimeZone` | Time zone used for offset formatting and UTC conversion. |
| `year` | `Integer` | Year component of `date`. |
| `month` | `Integer` | Month component of `date` (1-12). |
| `day` | `Integer` | Day of the month. |
| `hour` | `Integer` | Hour component (0-23). |
| `minute` | `Integer` | Minute component (0-59). |
| `second` | `Integer` | Second component (0-59). |
| `dayOfWeek` | `Integer` | 4D day number for the date; Sunday is 1 and Saturday is 7. |
| `IsLeapYear` | `Boolean` | Whether the instance's year is a leap year. |
| `isDaylightSavingTime` | `Boolean` | Whether the configured time zone has different standard and daylight offsets. This checks the zone's offsets, not whether this instance's date falls within daylight time. |
| `maxDate` | `Date` | Maximum date constant: `9999-12-31`. |
| `minDate` | `Date` | Minimum date constant: `00-00-00`. |
| `unixEpoch` | `Date` | Unix epoch date: `1970-01-01`. |
| `startAndEndOfWeek` | `Object` | Object with `start` and `end` `DateTime` values for the containing Sunday-to-Saturday week. The start is midnight Sunday and the end is 23:59:59 Saturday. |

## Formatting and conversion

| Method | Return type | Description |
| --- | --- | --- |
| `toISO()` | `Text` | ISO date/time string with the configured time zone's UTC offset, for example `2025-11-05T14:30:15-05:00`. |
| `toUTC()` | `Text` | Converts the instance using its time zone offset and returns the resulting UTC date/time string. |
| `toShortDateString()` | `Text` | Formats the date using 4D's internal short-date format. |
| `toLongDateString()` | `Text` | Formats the date using 4D's internal long-date format. |
| `toShortTimeString()` | `Text` | Formats the time as `HH:MM`. |
| `toLongTimeString()` | `Text` | Formats the time as `HH:MM:SS`. |

The short and long date formats depend on the 4D environment's regional settings. `toISO()` and `toUTC()` return text; they do not change the instance's `date` or `time`.

```4d
var $meeting := cs.DateTime.new(!2025-11-05!; ?14:30:15?; cs.TimeZone.new("Europe/Paris"))
var $localISO : Text := $meeting.toISO()
var $utcISO : Text := $meeting.toUTC()
```

## Date and time arithmetic

| Method | Argument | Description |
| --- | --- | --- |
| `addDays($days)` | `Integer` | Adds days to the date. |
| `addMonths($months)` | `Integer` | Adds months to the date. |
| `addYears($years)` | `Integer` | Adds years to the date. |
| `addHours($hours)` | `Integer` | Adds hours to the time, carrying across date boundaries. |
| `addMinutes($minutes)` | `Integer` | Adds minutes to the time, carrying across date boundaries. |
| `addSeconds($seconds)` | `Integer` | Adds seconds to the time, carrying across date boundaries. |

These methods mutate the instance and do not return a new `DateTime`. Negative values subtract time. Hour, minute, and second arithmetic adjusts the date when the result crosses midnight, including when moving backwards.

```4d
var $dt := cs.DateTime.new(!2025-06-15!; ?23:59:00?)
$dt.addMinutes(2)
// $dt now represents 2025-06-16 00:01:00
```

## Week boundaries

`startAndEndOfWeek` returns an object with two `DateTime` properties:

```4d
var $weekExample := cs.DateTime.new(!2025-06-16!; ?12:00:00?; cs.TimeZone.new("UTC"))
var $week := $weekExample.startAndEndOfWeek
var $weekStart : Text := $week.start.toISO()
var $weekEnd : Text := $week.end.toISO()
// $weekStart: 2025-06-15T00:00:00+00:00
// $weekEnd: 2025-06-21T23:59:59+00:00
```

The example date is a Monday. The returned range runs from Sunday through Saturday, and both values retain the instance's UTC time zone.

## Time zone and DST behavior

Offset formatting and UTC conversion delegate to the instance's `TimeZone`. The current implementation uses a simplified daylight-saving period from the last Sunday in March (inclusive) to the last Sunday in October (exclusive). This does not model each region's historical or current DST rules, and may be incorrect for zones with different transition dates or southern-hemisphere seasons. Do not rely on it for rule-accurate conversions across regions or historical dates.

