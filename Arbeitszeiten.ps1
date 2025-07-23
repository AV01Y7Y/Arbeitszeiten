Param(
    [switch]$RoundTimes = $False
)


# Setze Culture zu DE
[System.Threading.Thread]::CurrentThread.CurrentCulture = [System.Globalization.CultureInfo]::GetCultureInfo('de-DE')
[System.Threading.Thread]::CurrentThread.CurrentUICulture = [System.Globalization.CultureInfo]::GetCultureInfo('de-DE')

$startDate = (Get-Date -Day 1).Date                 # Erster Tag des aktuellen Monats
$endDate = $startDate.AddMonths(1).AddSeconds(-1)   # Letzter Tag 23:59:59 des aktuellen Monats

# Funktion um die Zeitstempel auf 5-Minuten-Werte zu runden.
# 7:31 -> 7:30
# 16:04 -> 16:05
function Round-Time{
    param([datetime]$time)
    $minutes = [math]::Round($time.Minute / 5) * 5
    return $time.Date.AddHours($time.Hour).AddMinutes($minutes)
}


# Lade die Systemprotokolle für den aktuellen Monat
Write-Host "Lade Systemprotokolle für den Monat, bitte warten..."
$allEvents = Get-WinEvent -FilterHashtable @{LogName='System';StartTime=$startDate;EndTime=$endDate} |
             Sort-Object TimeCreated

# Array für die Ergebnisse initialisieren
$eventData = @()

for ($day = $startDate; $day -le $endDate; $day = $day.AddDays(1)) {
    # Wochenenden auslassen
    if ($day.DayOfWeek -eq 'Saturday') { continue }
    
    if ($day.DayOfWeek -eq 'Sunday') { 
        $eventData += [PSCustomObject]@{
            Datum = "=========="
            Wochentag = "=========="
            'Erstes Ereignis' = "==============="
            'Letztes Ereignis' ="==============="
        }
        continue
    }

    #Write-Host "Verarbeite: $($day.Date.ToString('dddd')) - $($day.Date.ToString('dd. MMM'))"

    $dayEvents = $allEvents | Where-Object { $_.TimeCreated -ge $day -and $_.TimeCreated -lt $day.AddDays(1) }

    $firstEvent = $dayEvents | Select-Object -First 1
    $lastEvent = $dayEvents | Select-Object -Last 1

    $firstTime = if ($firstEvent) { if ($RoundTimes) { (Round-Time $firstEvent.TimeCreated).ToString('HH:mm') } else { $firstEvent.TimeCreated.ToString('HH:mm') } } else { 'N/A' }
    $lastTime =  if ($lastEvent)  { if ($RoundTimes) { (Round-Time $lastEvent.TimeCreated).ToString('HH:mm')  } else { $lastEvent.TimeCreated.ToString('HH:mm')  } } else { 'N/A' }

    $eventData += [PSCustomObject]@{
        Datum = $day.ToString('dd.MM.yyyy')
        Wochentag = $day.ToString('dddd')
        'Erstes Ereignis' = $firstTime
        'Letztes Ereignis' = $lastTime
    }
}

$eventData | Format-Table -AutoSize