function Write-Header
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