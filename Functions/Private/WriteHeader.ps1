[CmdletBinding()]
param
(
    [pscustomobject] $headerArray,
    [string[]]$CustomArray
)
#Create-Header
if($null -eq $CustomArray)
{
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
}
else
{               
    $count = $CustomArray.Length - 1       
    for($index=0;$index -le $count;$index++)
    {                          
        if($index -lt $count)
        {               
            $header = -join($header,"""$($CustomArray[$index])""",",")
        }
        else
        {
            $header = -join($header,"""$($CustomArray[$index])""","`n")
        }
        #$index +=1                           
    }   
}

#write-warning $header
Write-Output $header