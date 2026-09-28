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

    It 'rejects fractional input before integer coercion' {
        { Get-Fibonacci -N 1.5 } | Should -Throw
    }
}

Describe 'Get-Factorial' {
    It 'returns numeric 1 without incidental output for N=0' {
        $output = @(Get-Factorial -N 0)

        $output | Should -HaveCount 1
        $output[0] | Should -BeOfType ([System.Numerics.BigInteger])
        $output[0] | Should -Be 1
    }

    It 'returns numeric 1 without incidental output for N=1' {
        $output = @(Get-Factorial -N 1)

        $output | Should -HaveCount 1
        $output[0] | Should -BeOfType ([System.Numerics.BigInteger])
        $output[0] | Should -Be 1
    }

    It 'returns a representative numeric factorial value without incidental output' {
        $output = @(Get-Factorial -N 5)

        $output | Should -HaveCount 1
        $output[0] | Should -BeOfType ([System.Numerics.BigInteger])
        $output[0] | Should -Be 120
    }

    It 'rejects fractional input before integer coercion' {
        { Get-Factorial -N 1.5 } | Should -Throw
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

    It 'writes exactly one Fibonacci line when Operation is explicitly fibonacci' {
        $result = Invoke-MathToolCli -Arguments @('-N', '7', '-Operation', 'fibonacci')

        $result.ExitCode | Should -Be 0
        $result.Stderr | Should -Be ''
        Assert-SingleStdoutLine -Stdout $result.Stdout -ExpectedLine 'Fibonacci(7) = 13'
    }

    It 'writes exactly one Factorial line for N=0' {
        $result = Invoke-MathToolCli -Arguments @('-N', '0', '-Operation', 'factorial')

        $result.ExitCode | Should -Be 0
        $result.Stderr | Should -Be ''
        Assert-SingleStdoutLine -Stdout $result.Stdout -ExpectedLine 'Factorial(0) = 1'
    }

    It 'writes exactly one Factorial line for N=1' {
        $result = Invoke-MathToolCli -Arguments @('-N', '1', '-Operation', 'factorial')

        $result.ExitCode | Should -Be 0
        $result.Stderr | Should -Be ''
        Assert-SingleStdoutLine -Stdout $result.Stdout -ExpectedLine 'Factorial(1) = 1'
    }

    It 'writes exactly one Factorial line for a representative input' {
        $result = Invoke-MathToolCli -Arguments @('-N', '5', '-Operation', 'factorial')

        $result.ExitCode | Should -Be 0
        $result.Stderr | Should -Be ''
        Assert-SingleStdoutLine -Stdout $result.Stdout -ExpectedLine 'Factorial(5) = 120'
    }

    It 'does not emit the CLI result line when dot-sourced' {
        $output = @(. $script:MathToolPath)

        $output | Should -HaveCount 0
    }

    It 'exposes both Get-Fibonacci and Get-Factorial when dot-sourced' {
        (Get-Command Get-Fibonacci -ErrorAction SilentlyContinue) | Should -Not -BeNullOrEmpty
        (Get-Command Get-Factorial -ErrorAction SilentlyContinue) | Should -Not -BeNullOrEmpty
    }

    It 'rejects negative input without a success-shaped result' {
        $result = Invoke-MathToolCli -Arguments @('-N:-1')

        $result.ExitCode | Should -Not -Be 0
        $result.Stdout | Should -Not -Match '^Fibonacci\(-1\) = '
        $result.Stderr | Should -Not -Be ''
    }

    It 'rejects negative input for factorial without a success-shaped result' {
        $result = Invoke-MathToolCli -Arguments @('-N:-1', '-Operation', 'factorial')

        $result.ExitCode | Should -Not -Be 0
        $result.Stdout | Should -Not -Match '^Factorial\(-1\) = '
        $result.Stderr | Should -Not -Be ''
    }

    It 'rejects fractional input without a success-shaped result' {
        $result = Invoke-MathToolCli -Arguments @('-N', '1.5')

        $result.ExitCode | Should -Not -Be 0
        $result.Stdout | Should -Not -Match '^Fibonacci\('
        $result.Stderr | Should -Match 'N must be a non-negative Int32 integer\.'
    }

    It 'rejects an unsupported operation without a success-shaped result' {
        $result = Invoke-MathToolCli -Arguments @('-N', '5', '-Operation', 'nonsense')

        $result.ExitCode | Should -Not -Be 0
        $result.Stdout | Should -Not -Match '^(Fibonacci|Factorial)\('
        $result.Stderr | Should -Not -Be ''
    }

    It 'requires N for direct execution without a success-shaped result' {
        $result = Invoke-MathToolCli -Arguments @()

        $result.ExitCode | Should -Not -Be 0
        $result.Stdout | Should -Not -Match '^Fibonacci\(0\) = 0'
        $result.Stderr | Should -Match 'Parameter N is required for direct execution\.'
    }
}
