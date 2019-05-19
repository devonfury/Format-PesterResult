# test the module manifest - exports the right functions, processes the right formats, and is generally correct
$path = $MyInvocation.MyCommand.Path
$ModulePath = (Split-Path -Path $path -Parent) | Split-Path -Parent #Split-Path -Parent $MyInvocation.MyCommand.Path
$ModuleName = Split-Path -Path $ModulePath -Leaf #(Split-Path -Leaf $MyInvocation.MyCommand.Path) -Replace ".Tests.ps1"
$ManifestPath   = "$ModulePath\$ModuleName.psd1"
$ManifestHash = Invoke-Expression (Get-Content $ManifestPath -Raw)

Describe "Manifest" {			
	It "has a valid manifest" {
		{
			$null = Test-ModuleManifest -Path $ManifestPath -ErrorAction Stop -WarningAction SilentlyContinue
		} | Should Not Throw
    }

    It "has a valid name" {
        $ManifestHash.Name | Should Be $ModuleName
    }

	It "has a valid root module" {
        $ManifestHash.RootModule | Should Be "$ModuleName.psm1"
    }

	It "has a valid Description" {
        $ManifestHash.Description | Should Not BeNullOrEmpty
    }

    It "has a valid guid" {
        [Guid]::Parse($ManifestHash.Guid) | Should Not BeNullOrEmpty
    }

	<#
	It "has a valid prefix" {
		$Script:Manifest.Prefix | Should Not BeNullOrEmpty
	}
	#>

	It "has a valid copyright" {
		$ManifestHash.CopyRight | Should Not BeNullOrEmpty
	}

	It 'exports all public functions' {
		$ExFunctions = $ManifestHash.FunctionsToExport
		$FunctionFiles = Get-ChildItem "$ModulePath\Functions\Public" -Filter *.ps1 | Select-Object -ExpandProperty BaseName
		$FunctionNames = $FunctionFiles #| foreach {$_ -replace '-', "-$($Script:Manifest.Prefix)"}
		
		foreach ($FunctionName in $FunctionNames)
		{
			$ExFunctions -contains $FunctionName | Should Be $true
		}
	}
}