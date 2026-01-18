$computers = Get-Content -Path "C:\Users\Harvansh\Desktop\Defender Automation\Get Virus Definition Status Report\ComputerList.txt" 

$Output = @() 
$Count = 0
 
foreach ($Computer in $computers) { 
    try { 
        $Count++ 

        Write-Host ("{0}. Checking {1}" -f $Count, $Computer) -ForegroundColor Green 

        $MPStatus = Get-MpComputerStatus -CimSession $Computer -ErrorAction SilentlyContinue | Select-Object AntivirusEnabled, AMEngineVersion, AMProductVersion, AntivirusSignatureAge, AntivirusSignatureLastUpdated, PSComputerName, RealTimeProtectionEnabled, FullScanAge, IsTamperProtected, QuickScanAge 
        
        $MPPre = Get-MpPreference -CimSession $Computer -ErrorAction SilentlyContinue | Select-Object SignatureFallbackOrder, SignatureScheduleTime, SignatureUpdateCatchupInterval 
    
    $DStatus = [PSCustomObject]@{ 
        "S.No" = $Count 
        "ComputerName" = $MPStatus.PSComputerName 
        "AntivirusEnabled" = $MPStatus.AntivirusEnabled 
        "AMEngineVersion" = $MPStatus.AMEngineVersion 
        "AMProductVersion" = $MPStatus.AMProductVersion 
        "AntivirusSignatureAge" = $MPStatus.AntivirusSignatureAge 
        "AntivirusSignatureLastUpdated" = $MPStatus.AntivirusSignatureLastUpdated 
        "IsTamperProtected" = $MPStatus.IsTamperProtected 
        "QuickScanAge" = $MPStatus.QuickScanAge 
        "FullScanAge" = $MPStatus.FullScanAge 
        "RealTimeProtectionEnabled" = $MPStatus.RealTimeProtectionEnabled 
        "SignatureFallbackOrder" = $MPPre.SignatureFallbackOrder 
        "SignatureScheduleTime" = "$($MPPre.SignatureScheduleTime.Hours):$($MPPre.SignatureScheduleTime.Minutes)" 
        "SignatureUpdateCatchupInterval" = $MPPre.SignatureUpdateCatchupInterval 
     } 
        $Output += $DStatus 
   } 
    catch { 
        Write-Host ("{0}. Failed to check {1}" -f $Count, $Computer) -ForegroundColor Red 
    
    $DStatus = [PSCustomObject]@{ 
        "S.No" = $Count 
        "ComputerName" = $Computer 
        "AntivirusEnabled" = "Offline" 
        "AMEngineVersion" = "Offline" 
        "AMProductVersion" = "Offline" 
        "AntivirusSignatureAge" = "Offline" 
        "AntivirusSignatureLastUpdated" = "Offline" 
        "IsTamperProtected" = "Offline" 
        "QuickScanAge" = "Offline" 
        "FullScanAge" = "Offline" 
        "RealTimeProtectionEnabled" = "Offline" 
        "SignatureFallbackOrder" = "Offline" 
        "SignatureScheduleTime" = "Offline" 
        "SignatureUpdateCatchupInterval" = "Offline" 
    } 

   $Output += $DStatus 
  
  } 

 }  

#Define CSS style 

$style = @" 
<style> 
    body { 
        font-family: Arial, Helvetica, sans-serif; 
        margin: 20px; 
        background-color: #f4f6f9; 
    } 
    h1 { 
        text-align: center; 
        color: #2c3e50; 
    } 
    table { 
        border-collapse: 
        collapse; 
        width: 100%; 
        margin-top: 20px; 
        box-shadow: 0 2px 8px rgba(0,0,0,0.1); 
    } 
    th { 
        background-color: #34495e; 
        color: white; 
        padding: 10px; 
        text-align: left; 
    } 
    td { 
        border: 1px solid #ddd; 
        padding: 8px; 
    } 
    tr:nth-child(even){ 
        background-color: #ecf0f1; 
    } 
    tr:hover { 
        background-color: #d6eaf8; 
    } 
</style> 
"@

$FormattedOutput = $Output | ForEach-Object { 
    $row = $_ | Select-Object * 
    foreach ($prop in $row.PSObject.Properties) { 
        if ($prop.Value -eq "Offline" -or $prop.Value -eq $false) { 
            $prop.Value = "<span class='bad'>$($prop.Value)</span>" 
        } 
        elseif ($prop.Value -eq "Enabled" -or $prop.Value -eq $true) { 
            $prop.Value = "<span class='ok'>$($prop.Value)</span>" 
        } 
    } 
    $row
 }

$Output | ConvertTo-Html -Head $style -Title "Defender Health Status Report" |
    Out-File "C:\Users\Harvansh\Desktop\Defender Automation\Get Virus Definition Status Report\DefenderHealthStatus.htm"
