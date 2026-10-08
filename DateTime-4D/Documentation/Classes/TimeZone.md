## Description

`TimeZone` resolves a time zone from the system or from a Microsoft time zone ID / IANA name. It exposes the selected zone's standard and daylight offsets, formats date/time values with an offset, and converts date/time values to UTC.

## Construction

```4d
// Detect the system time zone
var $local := cs.TimeZone.new()

// Resolve a time zone by its IANA identifier
var $paris := cs.TimeZone.new("Europe/Paris")

// Resolve a time zone by its Microsoft identifier
var $eastern := cs.TimeZone.new("Eastern Standard Time")
```

The constructor accepts an optional identifier. Without one, it attempts to detect the system time zone (using PowerShell on Windows and `/etc/localtime` on macOS). An unrecognized identifier, or an unavailable match, falls back to UTC. Supported identifiers and offsets are loaded from `Resources/TimeZone.json`.

## Properties

| Property | Type | Description |
| --- | --- | --- |
| `current` | `Object` | Resolved time zone data, or the UTC fallback. Fields are `MicrosoftTimeZone` (`Text`), `IANA` (`Collection` of identifiers), `SDT` (`Text` standard offset), and `DST` (`Text` daylight offset). |
| `UTC` | `Object` | UTC fallback value: Microsoft ID `UTC`, IANA ID `Etc/UTC`, and both offsets `Z`. |

Offsets in the mapping are text values such as `-05:00` and `-04:00`; UTC uses `Z` in the fallback object. The `current` value is selected at construction and is not a live system-time-zone monitor.

## Methods

| Method | Return type | Description |
| --- | --- | --- |
| `getOffset($date)` | `Text` | Returns the configured standard or daylight offset for the date, based on the class's DST calculation. |
| `dateTimeWithOffset($date; $time)` | `Text` | Formats a date/time in ISO form and appends the offset returned by `getOffset`. |
| `toUTC($date; $time)` | `cs.DateTime` | Converts the date/time using the selected offset and returns a `DateTime` in UTC. |

```4d
var $zone := cs.TimeZone.new("Europe/Paris")
var $date := !2025-11-05!
var $time := ?14:30:00?

var $offset : Text := $zone.getOffset($date)
var $iso : Text := $zone.dateTimeWithOffset($date; $time)
var $utc : cs.DateTime := $zone.toUTC($date; $time)
```

`dateTimeWithOffset` includes a numeric offset when the mapping supplies one, for example `+01:00`; it does not append the time zone's name. `toUTC` returns a `DateTime` whose time zone is UTC.

## Daylight-saving calculation

The selected zone's standard-time (`SDT`) and daylight-saving (`DST`) offsets are read from its entry in `Resources/TimeZone.json`. `getOffset($date)` chooses between those two zone-specific values according to whether the date falls within the daylight-saving period.

The current implementation identifies the daylight-saving period as starting on the last Sunday in March (inclusive) and ending on the last Sunday in October (exclusive). The offsets vary by selected zone, while this transition-date rule is shared by all zones; the JSON file does not supply per-zone transition dates or historical transition rules.

System time-zone detection is implemented only for Windows and macOS. On other platforms, or if detection does not find a mapping, `current` falls back to UTC.
