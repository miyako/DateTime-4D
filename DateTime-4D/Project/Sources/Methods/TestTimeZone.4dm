//%attributes = {}
// 1 Create an instance without parameters → should detect the system time zone
var $tz1:=cs.TimeZone.new()
ALERT("Detected current time zone: "+String($tz1.current.MicrosoftTimeZone))

// 2️ Create an instance with parameter "UTC" → force UTC
var $tzUTC:=cs.TimeZone.new("America/Metlakatla")
ALERT("UTC time zone: "+String($tzUTC.current.MicrosoftTimeZone))

// 3️ Test offset calculation for a summer date (DST)
var $summerDate:=!2025-07-15!
var $offsetSummer:=$tz1.getOffset($summerDate)
ALERT("DST offset for July 15, 2025: "+$offsetSummer)

// 4️ Test offset calculation for a winter date (standard time)
var $winterDate:=!2025-01-15!
var $offsetWinter:=$tz1.getOffset($winterDate)
ALERT("Standard time offset for January 15, 2025: "+$offsetWinter)

// 5️ Test the dateTimeWithOffset method
var $testDate:=!2025-11-05!
var $testTime:=?14:30:00?
var $isoString:=$tz1.dateTimeWithOffset($testDate; $testTime)
ALERT("ISO DateTime with offset: "+$isoString)

// 6️ Test fallback to UTC if _current is not set or unknown
var $tzFallback:=cs.TimeZone.new("NonExistent")
ALERT("Fallback UTC: "+String($tzFallback.current.MicrosoftTimeZone))