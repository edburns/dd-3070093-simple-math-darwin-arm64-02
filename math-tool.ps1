[CmdletBinding()]
param(
    [ValidateRange(0, [int]::MaxValue)]
    [int]$N
)

Set-StrictMode -Version Latest

function Get-Fibonacci {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidateRange(0, [int]::MaxValue)]
        [int]$N
    )

    if ($N -lt 2) {
        return [System.Numerics.BigInteger]$N
    }

    [System.Numerics.BigInteger]$previous = 0
    [System.Numerics.BigInteger]$current = 1

    for ($index = 2; $index -le $N; $index++) {
        [System.Numerics.BigInteger]$next = $previous + $current
        $previous = $current
        $current = $next
    }

    return $current
}

if ($MyInvocation.InvocationName -ne '.') {
    if (-not $PSBoundParameters.ContainsKey('N')) {
        throw 'Parameter N is required for direct execution.'
    }

    $value = Get-Fibonacci -N $N
    Write-Output "Fibonacci($N) = $value"
}
