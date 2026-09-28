[CmdletBinding()]
param(
    [ValidateRange('NonNegative')]
    [int]$N
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

<#
.SYNOPSIS
Returns the Fibonacci value for a non-negative integer.

.PARAMETER N
The non-negative integer Fibonacci index.

.OUTPUTS
System.Numerics.BigInteger
#>
function Get-Fibonacci {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidateRange('NonNegative')]
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

$isDotSourced = $MyInvocation.InvocationName -eq '.'
if (-not $isDotSourced) {
    if (-not $PSBoundParameters.ContainsKey('N')) {
        throw 'Parameter N is required for direct execution.'
    }

    $value = Get-Fibonacci -N $N
    Write-Output "Fibonacci($N) = $value"
}
