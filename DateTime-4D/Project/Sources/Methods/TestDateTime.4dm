//%attributes = {}
// Method: TestDateTimeClass

// Create a DateTime object with specific date and time
var $dt:=cs.DateTime.new(!2026-03-15!; ?01:30:15?)
ALERT("Specific DateTime: "+$dt.toISO())
ALERT("UTC DateTime: "+$dt.toUTC())

// Create a DateTime object without parameters (current date and time)
var $dt1:=cs.DateTime.new()
ALERT("Current DateTime: "+$dt1.toISO())
ALERT("Is Daylight Saving Time: "+String($dt1.isDaylightSavingTime))
ALERT("Is leap year: "+String($dt1.IsLeapYear))

// Create a DateTime object with specific date and time
var $myDate:=!2025-11-05!
var $myTime:=?14:30:15?
var $dt2:=cs.DateTime.new($myDate; $myTime; cs.TimeZone.new("Europe/Paris"))
ALERT("Specific DateTime: "+$dt2.toISO())
ALERT("UTC DateTime: "+$dt2.toUTC())

// properties
ALERT("Year: "+String($dt2.year))
ALERT("Month: "+String($dt2.month))
ALERT("Day: "+String($dt2.day))
ALERT("Hour: "+String($dt2.hour))
ALERT("Minute: "+String($dt2.minute))
ALERT("Second: "+String($dt2.second))
ALERT("Day of the week: "+String($dt2.dayOfWeek))

// Formatting methods
ALERT("Short date: "+$dt2.toShortDateString())
ALERT("Long date: "+$dt2.toLongDateString())
ALERT("Short time: "+$dt2.toShortTimeString())
ALERT("Long time: "+$dt2.toLongTimeString())

// Temporal operations
$dt2.addDays(3)
ALERT("After +3 days: "+$dt2.toISO())
$dt2.addHours(2)
ALERT("After +2 hours: "+$dt2.toISO())
$dt2.addMinutes(15)
ALERT("After +15 minutes: "+$dt2.toISO())
$dt2.addSeconds(30)
ALERT("After +30 seconds: "+$dt2.toISO())

// 6️ Test time rollover across the date boundary (addHours/addMinutes/addSeconds)
var $results : Collection
$results:=[]

// Forward rollover: addHours crosses into the next month
var $rollDate1:=!2025-01-31!
var $rollTime1:=?23:00:00?
var $rollDt1:=cs.DateTime.new($rollDate1; $rollTime1)
$rollDt1.addHours(2)
$results.push(($rollDt1.year=2025) && ($rollDt1.month=2) && ($rollDt1.day=1) && ($rollDt1.hour=1))

// Backward rollover: negative addHours crosses into the previous year
var $rollDate2:=!2025-01-01!
var $rollTime2:=?00:30:00?
var $rollDt2:=cs.DateTime.new($rollDate2; $rollTime2)
$rollDt2.addHours(-1)
$results.push(($rollDt2.year=2024) && ($rollDt2.month=12) && ($rollDt2.day=31) && ($rollDt2.hour=23))

// Forward rollover: addMinutes crosses midnight
var $rollDate3:=!2025-06-15!
var $rollTime3:=?23:59:00?
var $rollDt3:=cs.DateTime.new($rollDate3; $rollTime3)
$rollDt3.addMinutes(2)
$results.push(($rollDt3.day=16) && ($rollDt3.hour=0) && ($rollDt3.minute=1))

// Forward rollover: addSeconds crosses midnight
var $rollDate4:=!2025-06-15!
var $rollTime4:=?23:59:59?
var $rollDt4:=cs.DateTime.new($rollDate4; $rollTime4)
$rollDt4.addSeconds(2)
$results.push(($rollDt4.day=16) && ($rollDt4.hour=0) && ($rollDt4.second=1))

// Backward rollover: negative addSeconds crosses back to the previous day
var $rollDate5:=!2025-06-15!
var $rollTime5:=?00:00:00?
var $rollDt5:=cs.DateTime.new($rollDate5; $rollTime5)
$rollDt5.addSeconds(-1)
$results.push(($rollDt5.day=14) && ($rollDt5.hour=23) && ($rollDt5.minute=59) && ($rollDt5.second=59))

ALERT("Rollover tests all passed: "+String($results.query("false = :1"; False).length=0))

// 6️ Test utility methods
ALERT("Is leap year: "+String($dt2.IsLeapYear))
ALERT("Is Daylight Saving Time: "+String($dt2.isDaylightSavingTime))
ALERT("Unix epoch: "+String($dt2.unixEpoch))
