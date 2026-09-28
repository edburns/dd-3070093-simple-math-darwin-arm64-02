Set-StrictMode -Version Latest

BeforeAll {
    $script:MathToolPath = Join-Path $PSScriptRoot 'math-tool.ps1'
    . $script:MathToolPath

    function Invoke-MathToolCli {
        param(
            [Parameter(Mandatory)]
            [AllowEmptyCollection()]
            [string[]]$Arguments
        )

        $startInfo = [System.Diagnostics.ProcessStartInfo]::new()
        $startInfo.FileName = (Get-Process -Id $PID).Path
        foreach ($argument in @('-NoLogo', '-NoProfile', '-File', $script:MathToolPath) + $Arguments) {
            [void]$startInfo.ArgumentList.Add($argument)
        }
        $startInfo.RedirectStandardOutput = $true
        $startInfo.RedirectStandardError = $true
        $startInfo.UseShellExecute = $false

        $process = [System.Diagnostics.Process]::Start($startInfo)
        try {
            $stdoutTask = $process.StandardOutput.ReadToEndAsync()
            $stderrTask = $process.StandardError.ReadToEndAsync()
            $process.WaitForExit()
            $stdout = $stdoutTask.GetAwaiter().GetResult()
            $stderr = $stderrTask.GetAwaiter().GetResult()

            [pscustomobject]@{
                ExitCode = $process.ExitCode
                Stdout = $stdout
                Stderr = $stderr
            }
        } finally {
            $process.Dispose()
        }
    }

    function Assert-SingleStdoutLine {
        param(
            [Parameter(Mandatory)]
            [string]$Stdout,

            [Parameter(Mandatory)]
            [string]$ExpectedLine
        )

        $Stdout.EndsWith("`n") | Should -BeTrue
        if ($Stdout.EndsWith("`r`n")) {
            $content = $Stdout.Substring(0, $Stdout.Length - 2)
        } else {
            $content = $Stdout.Substring(0, $Stdout.Length - 1)
        }

        $content | Should -Be $ExpectedLine
    }
}

Describe 'Get-Fibonacci' {
    It 'returns numeric 0 without incidental output for N=0' {
        $output = @(Get-Fibonacci -N 0)

        $output | Should -HaveCount 1
        $output[0] | Should -BeOfType ([System.Numerics.BigInteger])
        $output[0] | Should -Be 0
    }

    It 'returns numeric 1 without incidental output for N=1' {
        $output = @(Get-Fibonacci -N 1)

        $output | Should -HaveCount 1
        $output[0] | Should -BeOfType ([System.Numerics.BigInteger])
        $output[0] | Should -Be 1
    }

    It 'returns a representative numeric Fibonacci value without incidental output' {
        $output = @(Get-Fibonacci -N 7)

        $output | Should -HaveCount 1
        $output[0] | Should -BeOfType ([System.Numerics.BigInteger])
        $output[0] | Should -Be 13
    }
}

Describe 'math-tool.ps1 CLI' {
    It 'writes exactly one Fibonacci line for N=0' {
        $result = Invoke-MathToolCli -Arguments @('-N', '0')

        $result.ExitCode | Should -Be 0
        $result.Stderr | Should -Be ''
        Assert-SingleStdoutLine -Stdout $result.Stdout -ExpectedLine 'Fibonacci(0) = 0'
    }

    It 'writes exactly one Fibonacci line for N=1' {
        $result = Invoke-MathToolCli -Arguments @('-N', '1')

        $result.ExitCode | Should -Be 0
        $result.Stderr | Should -Be ''
        Assert-SingleStdoutLine -Stdout $result.Stdout -ExpectedLine 'Fibonacci(1) = 1'
    }

    It 'writes exactly one Fibonacci line for a representative input' {
        $result = Invoke-MathToolCli -Arguments @('-N', '7')

        $result.ExitCode | Should -Be 0
        $result.Stderr | Should -Be ''
        Assert-SingleStdoutLine -Stdout $result.Stdout -ExpectedLine 'Fibonacci(7) = 13'
    }

    It 'does not emit the CLI result line when dot-sourced' {
        $output = @(. $script:MathToolPath)

        $output | Should -HaveCount 0
    }

    It 'rejects negative input without a success-shaped result' {
        $result = Invoke-MathToolCli -Arguments @('-N:-1')

        $result.ExitCode | Should -Not -Be 0
        $result.Stdout | Should -Not -Match '^Fibonacci\(-1\) = '
        $result.Stderr | Should -Not -Be ''
    }

    It 'requires N for direct execution without a success-shaped result' {
        $result = Invoke-MathToolCli -Arguments @()

        $result.ExitCode | Should -Not -Be 0
        $result.Stdout | Should -Not -Match '^Fibonacci\(0\) = 0'
        $result.Stderr | Should -Match 'Parameter N is required for direct execution\.'
    }
}
