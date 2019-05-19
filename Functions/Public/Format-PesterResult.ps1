#Requires -Modules Pester
function Format-PesterResult
{
    <#
        .Synopsis
        Formats Pester Results into CSV format
        .DESCRIPTION
        Formats Pester Results into CSV format
        .PARAMETER PesterResult
        The Pester TestResult object.
        .PARAMETER ReportPath
        The path that where the CSV should be saved.
        .PARAMETER CustomHeader
        Replace the Test Name in the Pester Result object with custom names.
        .EXAMPLE
        Format-PesterResult -PesterResult $myTestResult -ReportPath 'c:\myreport.csv'
        .EXAMPLE
        Format-PesterResult -PesterResult $myTestResult -CustomHeader @('Column1','Column2','Column3') -ReportPath 'c:\myreport.csv'
        .INPUTS
        None
        .OUTPUTS
        None
    #>
 
    [CmdletBinding()]
    param
    (
        [parameter(Mandatory=$true,ValueFromPipeline,Position=0)]
        [pscustomobject[]] $PesterResult,
        [parameter(Mandatory=$false)]   
        [string] $ReportPath,
        [parameter(Mandatory=$false)]   
        [string[]] $CustomHeader   
    )
 
    try
    {   
        $headerArray = CreateHeaderArray
 
        if($PSBoundParameters.ContainsKey('CustomHeader'))
        {
            $header = WriteHeader -headerArray $headerArray -CustomArray $CustomHeader        
        }
        else
        {       
            $header = WriteHeader -headerArray $headerArray       
        }                  
 
        $detail = WriteDetail -TestCount $headerArray.Count
        $report = -join($header,$detail)
        #write-warning $report
 
        if($PSBoundParameters.ContainsKey('ReportPath'))
        {
            New-Item -Path $ReportPath -ItemType File -Value $report -Force
        }
        else
        {
            $tempPath = -join($env:USERPROFILE,"\Documents\pester$((Get-Date).ToFileTimeUtc()).csv")   
            New-Item -Path $tempPath -ItemType File -Value $report -Force | Out-Null
            if(Test-Path -Path $tempPath)
            {
                [pscustomobject] $objReport = Import-Csv -Path $tempPath
                write-output $objReport       
                Remove-Item -Path $tempPath
            }
        }
    }
    catch
    {
        write-error $_
    }
}
 