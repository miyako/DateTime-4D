// ----------------------------------------------------------------------
// Class: DateTime
// Description: Gestion de date et heure séparément
// ----------------------------------------------------------------------
property date : Date
property time : Time
property timeZone : cs.TimeZone

Class constructor($date : Date; $time : Time; $timeZone : cs.TimeZone)
	
	Case of 
		: (Count parameters=1)
			This.date:=$date
			This.time:=?00:00:00?
			
		: (Count parameters>=2)
			This.date:=$date
			This.time:=$time
			
		Else 
			This.date:=Current date
			This.time:=Current time
			
	End case 
	
	This.timeZone:=$timeZone=Null ? cs.TimeZone.new() : $timeZone
	
	
	// ----------------------------------------------------------------------
	// 🕒 Méthodes statiques
	// ----------------------------------------------------------------------
	
Function now() : Object
	
	return cs.DateTime.new()
	
	
	// ----------------------------------------------------------------------
	// 📅 Propriétés
	// ----------------------------------------------------------------------
	
Function get year : Integer
	return Year of(This.date)
	
	
Function get month : Integer
	return Month of(This.date)
	
	
Function get day : Integer
	return Day of(This.date)
	
	
Function get hour : Integer
	return Num(String(Time(This.time); "hh"))
	
	
Function get minute : Integer
	return Num(String(Time(This.time); "m"))
	
	
Function get second : Integer
	return Num(String(Time(This.time); "s"))
	
	
Function get dayOfWeek : Integer
	return Day number(This.date)
	
	
	
	// ----------------------------------------------------------------------
	// 🔧 Formattage
	// ----------------------------------------------------------------------
	
Function toISO() : Text
	return This.timeZone.dateTimeWithOffset(This.date; This.time)
	
Function toUTC() : Text
	var $utcDate:=This.timeZone.toUTC(This.date; This.time)
	return $utcDate.timeZone.dateTimeWithOffset($utcDate.date; $utcDate.time)
	
	
Function toShortDateString() : Text
	return String(This.date; Internal date short)
	
	
Function toLongDateString() : Text
	return String(This.date; Internal date long)
	
	
Function toShortTimeString() : Text
	return String(Time(This.time); "HH:MM")
	
	
Function toLongTimeString() : Text
	return String(Time(This.time); "HH:MM:SS")
	
	// ----------------------------------------------------------------------
	// 🧮 Opérations temporelles
	// ----------------------------------------------------------------------
	
Function addDays($days : Integer)
	This.date:=Add to date(This.date; 0; 0; $days)
	
Function addMonths($months : Integer)
	This.date:=Add to date(This.date; 0; $months; 0)
	
Function addYears($years : Integer)
	This.date:=Add to date(This.date; $years; 0; 0)
	
	
Function addHours($hours : Integer)
	// Delegates to _addSeconds, converting hours to seconds
	This._addSeconds($hours*60*60)
	
	
Function addMinutes($minutes : Integer)
	// Delegates to _addSeconds, converting minutes to seconds
	This._addSeconds($minutes*60)
	
	
Function addSeconds($seconds : Integer)
	// Delegates to _addSeconds, which also handles carrying over to the date
	This._addSeconds($seconds)
	
	
Function _addSeconds($deltaSeconds : Integer)
	// Total seconds after adding the delta
	var $totalSeconds : Integer
	$totalSeconds:=This.time+$deltaSeconds
	// Number of full days to carry over to the date (truncated division)
	var $daysOffset : Integer
	$daysOffset:=$totalSeconds\86400
	// Remaining seconds within the day (can be negative if $totalSeconds<0)
	var $remainder : Integer
	$remainder:=$totalSeconds%86400
	// Fixes a negative remainder to stay within [0;86400[
	If ($remainder<0)
		$remainder:=$remainder+86400
		$daysOffset:=$daysOffset-1
	End if 
	// Carries the computed days over to the date
	This.date:=Add to date(This.date; 0; 0; $daysOffset)
	// Assigns the remainder as the new time
	This.time:=$remainder
	
	
	
	// ----------------------------------------------------------------------
	// 🔧 Utilitaires
	// ----------------------------------------------------------------------
	
Function get IsLeapYear : Boolean
	var $y : Integer
	$y:=This.year
	return (($y%4=0) & (($y%100#0) | ($y%400=0)))
	
	
Function get isDaylightSavingTime : Boolean
	return This.timeZone.current.SDT#This.timeZone.current.DST
	
	
Function get maxDate : Date
	return !9999-12-31!
	
	
Function get minDate : Date
	return !00-00-00!
	
	
Function get unixEpoch : Date
	return !1970-01-01!
	
Function get startAndEndOfWeek : Object
	
	// Get the day of the week
	var $dayOfWeek:=Day number(This.date)
	
	// Calculate the first day of the current week (Sunday)
	var $startOfWeek:=This.date-($dayOfWeek-1)
	
	// Calculate the last day of the current week (Saturday)
	var $endOfWeek:=$startOfWeek+6
	
	return {start: cs.DateTime.new($startOfWeek; ?00:00:00?; This.timeZone); end: cs.DateTime.new($endOfWeek; ?23:59:59?; This.timeZone)}
	
	