[CmdletBinding()]
param
(    
)

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