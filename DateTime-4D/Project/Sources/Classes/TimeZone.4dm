property UTC:={MicrosoftTimeZone: "UTC"; IANA: "Etc/UTC"; SDT: "Z"; DST: "Z"}  // Default UTC time zone fallback
property _current : Object  // Will store the currently detected time zone object

// Class constructor, called on instantiation
Class constructor($zone : Text)
	
	If (Count parameters=0)
		This._get()  // Attempt to detect and set the current system time zone
	Else 
		This._searchTimeZone($zone)
	End if 
	
	// Getter function that returns the current time zone object, or UTC as fallback
	// return {MicrosoftTimeZone : Text;IANA : Collection;SDT : Text;DST : Text}
Function get current() : Object
	return This._current || This.UTC
	
	// Internal method to detect the system's current time zone and store it in This._current
Function _get()
	var $myWinWorker : Object  // SystemWorker for executing shell commands
	var $timeZones:=This._loadTimeZones()  // Load the full time zone mapping
	
	Try
		// If running on Windows
		If (Is Windows)
			// Use PowerShell to get current time zone in JSON format
			$myWinWorker:=4D.SystemWorker.new("powershell -Command \"Get-TimeZone | ConvertTo-Json\"")
			var $currentTZ:=JSON Parse($myWinWorker.wait(1).response)  // Parse result
			$myWinWorker.terminate()
			
			// Match the returned time zone ID to the Microsoft time zone mapping
			This._current:=$timeZones.query("MicrosoftTimeZone=:1"; $currentTZ.Id).first()
		End if 
		
		// If running on macOS
		If (Is macOS)
			// Use shell to resolve the /etc/localtime symlink (which points to the time zone)
			$myWinWorker:=4D.SystemWorker.new("readlink /etc/localtime")
			var $zoneInfo : Text:=$myWinWorker.wait(1).response
			$myWinWorker.terminate()
			
			// Extract the last two components (e.g., "Europe/Paris")
			var $split:=Split string($zoneInfo; "/")
			var $current : Text:=$split[$split.length-2]+"/"+$split[$split.length-1]
			$current:=Replace string($current; "\n"; "")
			
			
			// Match it to the IANA time zone mapping
			This._current:=$timeZones.query("IANA[]=:1"; $current).first()
		End if 
	End try
	
	// Formats a date and time in ISO format and appends the time zone offset
Function dateTimeWithOffset($date : Date; $time : Time) : Text
	var $timeZones:=This.current  // Get current time zone
	var $utc:=String($date; ISO date; $time)  // Format as ISO string
	return $utc+This.getOffset($date)  // Append offset (e.g., "+02:00")
	
	// Returns the appropriate time zone offset for a given date
Function getOffset($date : Date) : Text
	If (This._isDST($date))
		// Return daylight saving time offset (DST)
		return String(This.current.DST)
	Else 
		// Return standard time offset (SDT)
		return String(This.current.SDT)
	End if 
	
	// Determines whether a given date is in the Daylight Saving Time (DST) period
Function _isDST($date : Date) : Boolean
	var $DSTStart:=Add to date(!00-00-00!; Year of($date); 3; 31)  // Start with March 31 of the year
	var $DSTEnd:=Add to date(!00-00-00!; Year of($date); 10; 31)  // Start with October 31 of the year
	
	// Move backwards to find the last Sunday in March
	While (Day number($DSTStart)#1)
		$DSTStart-=1
	End while 
	
	// Move backwards to find the last Sunday in October
	While (Day number($DSTEnd)#1)
		$DSTEnd-=1
	End while 
	
	// Return true if date is within the DST range
	return (($DSTStart<=$date) && ($date<$DSTEnd))
	
	// Convert a date/time to UTC based on the current timezone offset.
	// Returns a cs.DateTime object with UTC values.
Function toUTC($date : Date; $time : Time) : cs.DateTime
	var $offset : Text:=This.getOffset($date)  // Get current offset (SDT or DST).
	var $sign : Integer  // Sign of the offset (+1 or -1).
	var $utcTime : Time  // Converted UTC time.
	var $utcDate : Date  // Converted UTC date.
	var $dateSeconds : Real  // Input time in seconds since midnight.
	var $utcSeconds : Real  // UTC time in seconds.
	var $firstChar : Text  // First character of offset string.
	var $utcDateTime : cs.DateTime  // DateTime object to return.
	
	// Parse sign from offset (first character: "-" or "+").
	$firstChar:=Substring($offset; 1; 1)
	If ($firstChar="-")
		$sign:=-1
	Else 
		$sign:=1
	End if 
	
	// Extract offset without sign (e.g., "02:00" from "-02:00").
	var $numOffset : Text:=Substring($offset; 2)
	var $parts:=Split string($numOffset; ":")
	var $offsetSeconds : Real:=((Num($parts[0])*3600)+(Num($parts[1])*60))*$sign
	
	// Convert input time to seconds since midnight.
	$dateSeconds:=$time
	
	// Subtract offset to get UTC time.
	$utcSeconds:=$dateSeconds-$offsetSeconds
	
	// Adjust date if UTC seconds go negative or exceed one day.
	$utcDate:=$date
	If ($utcSeconds<0)
		// Previous day in UTC.
		$utcDate:=$date-1
		$utcSeconds+=86400
	Else 
		If ($utcSeconds>=86400)
			// Next day in UTC.
			$utcDate:=$date+1
			$utcSeconds-=86400
		End if 
	End if 
	
	// Convert UTC seconds back to Time format.
	$utcTime:=$utcSeconds
	
	// Create and return a cs.DateTime object with UTC values.
	$utcDateTime:=cs.DateTime.new($utcDate; $utcTime; cs.TimeZone.new("UTC"))
	
	return $utcDateTime
	
Function _searchTimeZone($zone : Text) : Object
	var $timeZones:=This._loadTimeZones()
	var $found : Object
	
	// Default to UTC when no match is found.
	This._current:=This.UTC
	
	// 1) Try Microsoft time zone name (e.g. "Romance Standard Time").
	$found:=$timeZones.query("MicrosoftTimeZone=:1"; $zone).first()
	
	// 2) If needed, try IANA value (e.g. "Europe/Paris").
	If ($found=Null)
		$found:=$timeZones.query("IANA[]=:1"; $zone).first()
	End if 
	
	// 3) Keep the matched object, otherwise keep UTC fallback.
	This._current:=$found || This.UTC
	
	return This._current
	
	// Loads the list of time zones from a JSON file stored in the Resources folder
Function _loadTimeZones() : Collection
	var $myDoc:=Document to text(Folder(fk resources folder).file("TimeZone.json").platformPath)  // Load file content
	return JSON Parse($myDoc)  // Parse JSON into collection
	