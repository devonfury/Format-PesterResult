$ModulePath = Split-Path -Parent $MyInvocation.MyCommand.Path
$ModuleName = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -Replace ".Tests.ps1"

$ManifestPath   = "$ModulePath\$ModuleName.psd1"

# test the module manifest - exports the right functions, processes the right formats, and is generally correct
Describe "Manifest" {
    $Manifest = $null
    It "has a valid manifest" {
        {
            $Script:Manifest = Test-ModuleManifest -Path $ManifestPath -ErrorAction Stop -WarningAction SilentlyContinue
        } | Should Not Throw
    }

    It "has a valid name" {
        $Script:Manifest.Name | Should Be $ModuleName
    }

	It "has a valid root module" {
        $Script:Manifest.RootModule | Should Be "$ModuleName.psm1"
    }

	It "has a valid Description" {
        $Script:Manifest.Description | Should Not BeNullOrEmpty
    }

    It "has a valid guid" {
        $Script:Manifest.Guid | Should Be '9dd7e9a4-8525-4fd1-aa13-3a063df4b264'
    }

	It "has a valid prefix" {
		$Script:Manifest.Prefix | Should Not BeNullOrEmpty
	}

	It "has a valid copyright" {
		$Script:Manifest.CopyRight | Should Not BeNullOrEmpty
	}

	It 'exports all public functions' {
		$FunctionFiles = Get-ChildItem "$ModulePath\Scripts\Public" -Filter *.ps1 | Select -ExpandProperty BaseName
		$FunctionNames = $FunctionFiles | foreach {$_ -replace '-', "-$($Script:Manifest.Prefix)"}
		$ExFunctions = $Script:Manifest.ExportedFunctions.Values.Name
		foreach ($FunctionName in $FunctionNames)
		{
			$ExFunctions -contains $FunctionName | Should Be $true
		}
	}
}