# SNAKE en PowerShell | Flechas = moverte, Esc = salir
$W = 30; $H = 15; $dx = 1; $dy = 0; $pts = 0; $fin = $false
$cola = New-Object System.Collections.ArrayList
[void]$cola.Add(@(5, 5))
$comida = @((Get-Random -Maximum $W), (Get-Random -Maximum $H))
[Console]::CursorVisible = $false; Clear-Host

while ($true) {
    while ([Console]::KeyAvailable) {
        switch ([Console]::ReadKey($true).Key) {
            'UpArrow'    { if ($dy -ne 1)  { $dx = 0;  $dy = -1 } }
            'DownArrow'  { if ($dy -ne -1) { $dx = 0;  $dy = 1 } }
            'LeftArrow'  { if ($dx -ne 1)  { $dx = -1; $dy = 0 } }
            'RightArrow' { if ($dx -ne -1) { $dx = 1;  $dy = 0 } }
            'Escape'     { $fin = $true }
        }
    }
    if ($fin) { break }

    # Nueva cabeza
    $x = $cola[0][0] + $dx; $y = $cola[0][1] + $dy
    $choca = $x -lt 0 -or $x -ge $W -or $y -lt 0 -or $y -ge $H -or
             ($cola | Where-Object { $_[0] -eq $x -and $_[1] -eq $y })
    if ($choca) { break }
    $cola.Insert(0, @($x, $y))

    # Si come, crece; si no, se quita la cola
    if ($x -eq $comida[0] -and $y -eq $comida[1]) {
        $pts += 10
        $comida = @((Get-Random -Maximum $W), (Get-Random -Maximum $H))
    } else { $cola.RemoveAt($cola.Count - 1) }

    # Dibujar
    $g = 0..($H - 1) | ForEach-Object { , ([char[]](' ' * $W)) }
    $g[$comida[1]][$comida[0]] = '*'
    foreach ($p in $cola) { $g[$p[1]][$p[0]] = 'o' }
    $g[$y][$x] = '@'
    $borde = '#' * ($W + 2)
    [Console]::SetCursorPosition(0, 0)
    [Console]::Write($borde + "`n" + (($g | ForEach-Object { '#' + (-join $_) + '#' }) -join "`n") + "`n" + $borde + "`n Puntos: $pts  ")
    Start-Sleep -Milliseconds 120
}
[Console]::CursorVisible = $true
Write-Host "`n Fin del juego - Puntos: $pts"