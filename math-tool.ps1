[CmdletBinding()]
param(
    [ValidateScript({
        $parsed = 0
        [int]::TryParse([string]$_, [ref]$parsed) -and $parsed -ge 0
    }, ErrorMessage = 'N must be a non-negative Int32 integer.')]
    [object]$N,

    [ValidateSet('fibonacci', 'factorial')]
    [string]$Operation = 'fibonacci'
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

<#
.SYNOPSIS
Returns the Fibonacci value for a non-negative integer.

.PARAMETER N
The non-negative Int32 Fibonacci index.

.OUTPUTS
System.Numerics.BigInteger
#>
function Get-Fibonacci {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidateScript({
            $parsed = 0
            [int]::TryParse([string]$_, [ref]$parsed) -and $parsed -ge 0
        }, ErrorMessage = 'N must be a non-negative Int32 integer.')]
        [object]$N
    )

    $indexValue = [int]$N

    if ($indexValue -lt 2) {
        return [System.Numerics.BigInteger]$indexValue
    }

    [System.Numerics.BigInteger]$previous = 0
    [System.Numerics.BigInteger]$current = 1

    for ($index = 2; $index -le $indexValue; $index++) {
        $next = $previous + $current
        $previous = $current
        $current = $next
    }

    return $current
}

<#
.SYNOPSIS
Returns the factorial value for a non-negative integer.

.PARAMETER N
The non-negative Int32 factorial input.

.OUTPUTS
System.Numerics.BigInteger
#>
function Get-Factorial {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidateScript({
            $parsed = 0
            [int]::TryParse([string]$_, [ref]$parsed) -and $parsed -ge 0
        }, ErrorMessage = 'N must be a non-negative Int32 integer.')]
        [object]$N
    )

    $inputValue = [int]$N

    [System.Numerics.BigInteger]$result = 1
    for ($factor = 2; $factor -le $inputValue; $factor++) {
        $result *= $factor
    }

    return $result
}

# PowerShell sets InvocationName to '.' when a script is dot-sourced.
$isDotSourced = $MyInvocation.InvocationName -eq '.'
if (-not $isDotSourced) {
    if (-not $PSBoundParameters.ContainsKey('N')) {
        throw 'Parameter N is required for direct execution. Invoke as math-tool.ps1 -N <non-negative integer> [-Operation fibonacci|factorial].'
    }

    $indexValue = [int]$N

    switch ($Operation) {
        'fibonacci' {
            $value = Get-Fibonacci -N $indexValue
            Write-Output "Fibonacci($indexValue) = $value"
        }
        'factorial' {
            $value = Get-Factorial -N $indexValue
            Write-Output "Factorial($indexValue) = $value"
        }
        default {
            # Unreachable via normal parameter binding due to ValidateSet above;
            # retained as defense-in-depth against unexpected Operation values.
            throw "Unsupported Operation '$Operation'. Supported operations are 'fibonacci' and 'factorial'."
        }
    }
}
