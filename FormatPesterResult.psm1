foreach($file in (Get-ChildItem -Path $PSScriptRoot\Functions -Recurse -Filter *.ps1))
{
    . $file.FullName
}