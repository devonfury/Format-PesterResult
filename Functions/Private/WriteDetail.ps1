[CmdletBinding()]
param
(
    [int]$TestCount
)

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