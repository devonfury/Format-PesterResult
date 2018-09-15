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
        .EXAMPLE
        Format-PesterResult -PesterResult $myTestResult -ReportPath 'c:\myreport.csv'
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
        [string] $ReportPath   
    )
 
    function CreateHeaderArray
    {   
        $myArray = @()
 
        if($PesterResult -is [Array])
        {     
            $testResults = $PesterResult[0]   
        }
        else
        {
            $testResults = $PesterResult
        }
 
        $describe = $testResults.TestResult[0].Describe
        foreach($result in $testResults.TestResult)
        {
            if($describe -ne $result.Describe)
            {
                break
            }
            else
            {
                $myArray += $result
            }
        }
        write-output $myArray
    }
 
    function WriteHeader
    {
        param([pscustomobject] $headerArray)
        #Create-Header
        $index = 0
        $count = $headerArray.Count - 1   
        $header = -join($header,"""ComputerName""",",")    
        foreach($result in $headerArray)
        {              
            if($index -lt $count)
            {               
                $header = -join($header,"""$($result.Name)""",",")
            }
            else
            {
                $header = -join($header,"""$($result.Name)""","`n")
            }
            $index +=1                           
        }
 
        #write-warning $header
        Write-Output $header
    }
 
    function WriteDetail
    {                  
        param
        ([int]$TestCount)
 
        #Create-Detail   
        $index = 1          
        foreach($testResult in $PesterResult)
        {
            foreach($result in $testResult.TestResult)
            {                   
                if($TestCount -eq 0)
                {
                    $serverName = $result.Describe
                    $detail = -join($detail,"""$($serverName)""")
                    $detail = -join($detail,",","""$($result.Passed)""","`n")
                }
                else
                {
                    if($index -lt $TestCount)       
                    {       
                        if($index -eq 1)
                        {
                            $serverName = $result.Describe
                            $detail = -join($detail,"""$($serverName)""")
                        }
                        $detail = -join($detail,",","""$($result.Passed)""")
                        $index ++       
                    }
                    else
                    {
                        $detail = -join($detail,",","""$($result.Passed)""","`n")
                        $index = 1           
                    }
                }                       
            }
        }   
 
        #write-warning $detail
        Write-Output $detail
    }
 
    try
    {   
        $headerArray = CreateHeaderArray       
        $header = WriteHeader -headerArray $headerArray        
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
 
function Run-PesterTest
{
    <#
        .Synopsis
        Runs specfied Pester test.
        .DESCRIPTION
        Runs specfied Pester test.
        .PARAMETER FilePath
        The path to the location of the Pester test.
        .PARAMETER Parameters
        Hashtable of the parameters for the Pester test.
        .PARAMETER Display
        Specifies what statistics to display. [None | Summary | Failed | Passed | All]
        .PARAMETER PassThru
        Return the TestResult object from the specifed Pester test
        .EXAMPLE
        Run-PesterTest -FilePath 'c:\MyPesterTest.tests.ps1' -Parameters @{} -Display Summary -PassThru
        .INPUTS
        None
        .OUTPUTS
        None
    #>
 
    [CmdletBinding()]
    param
    (
        [parameter(Mandatory=$true)]
        [string] $FilePath,
        [parameter(Mandatory=$true)]
        [hashtable] $Parameters,   
        [parameter(Mandatory=$false)]
        [ValidateSet("None","Summary","Failed","Passed","Fails","All")]
        [string]$Display = "Summary",
        [parameter(Mandatory=$false)]
        [switch] $PassThru
    )
 
    $params = @{
        Script = @{
            Path = $FilePath;
            Parameters = $Parameters
        };
        Show = $Display      
    }
 
    if($PSBoundParameters.ContainsKey('PassThru'))
    {
        $params.Add('PassThru',$true)
    }
 
    Invoke-Pester @params   
}

