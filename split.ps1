$file = 'F:\Project\kasirku\kasirku_sembako\lib\features\transaction\presentation\widgets\report_widgets.dart'
$lines = Get-Content $file

function Extract-Class {
    param($className, $startPattern)
    $start = $lines.FindIndex({$_ -match $startPattern})
    if ($start -eq -1) { return }
    $openBraces = 0
    $end = $start
    for ($i = $start; $i -lt $lines.Count; $i++) {
        $openBraces += ($lines[$i].ToCharArray() | Where-Object { $_ -eq '{' }).Count
        $openBraces -= ($lines[$i].ToCharArray() | Where-Object { $_ -eq '}' }).Count
        if ($openBraces -eq 0 -and $lines[$i].Contains('}')) {
            $end = $i
            break
        }
    }
    return $lines[$start..$end] -join "
"
}

Write-Output 'Done'
