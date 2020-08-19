<#
  .SYNOPSIS
  Lists all the permissions for a list of folders and includes the SIDs
  .DESCRIPTION
  Takes a CSV list of UNC paths and lists out the NTFS Permissions for them and translates the SIDs for
  the Identity Reference too
  .PARAMETER
  None
  .EXAMPLE
  None
  .INPUTS
  None
  .OUTPUTS
  Sourcepermissions_.xlsx
  .NOTES
  Author:        Patrick Horne
  Creation Date: 18/08/20
  Requires:      
  Change Log:
  V1.0:         Initial Development
  V1.1:         Added Open File Box
#>

# Add Type and Load the Systems Forms
Add-Type -AssemblyName System.Windows.Forms
$csvpath = New-Object System.Windows.Forms.OpenFileDialog -Property @{ 
    InitialDirectory = [Environment]::GetFolderPath('Desktop')
    Filter = 'CSV (*.csv)| *.csv' 
}

# Show the Dialog
$null = $csvpath.ShowDialog()

# Try and Import the CSV File
try {
    # Always Use -LiteralPath
    $fileShareList = Import-CSV -LiteralPath $csvpath.FileName

} catch {
    # An error occured.
Write-Host "error"
    Throw $_
}

$OutputFile = ("SourcePermissions_" + $fileShare.SiteName + "_" + $fileShare.ShareName + ".csv")

if (Test-Path $OutputFile) {
    $NewName = $OutputFile + "_old"
    Rename-Item -Path $OutputFile -NewName $NewName
    
    }
$i = 1
foreach ($fileShare in $fileShareList) {
    
    Write-Progress -Activity "Getting permissions for top level Unc Paths" -Status "Unc Path $i of $($fileShareList.count)" -PercentComplete (($i / $fileShareList.count) * 100)  
    $i++
    $FolderPath = Get-ChildItem -Directory -Path $fileShare.FileSharePath  -Recurse -Force
    if ($folderPath) { 
    
    # Get permissions for the root folder.
    $Acl = Get-Acl -Path $fileShare.FileSharePath
        foreach ($Access in $acl.Access) {
            $objUser = New-Object System.Security.Principal.NTAccount($Access.IdentityReference)
            $strSID = $objUser.Translate([System.Security.Principal.SecurityIdentifier])
                $PermDetailHash = [Ordered] @{
                    FolderName         = $fileShare.FileSharePath
                    'AD Group or User' = $Access.IdentityReference
                    SID                = $strSID.Value
                    Permissions        = $Access.FileSystemRights
                    Inherited          = $Access.IsInherited
        }
   
    $PermDetail = New-Object -TypeName PSObject -Property $PermDetailHash
    $PermDetail | Export-Csv -path $OutputFile -NoTypeInformation -Append
    
}

    # For sub folders
    $a = 1
    Foreach ($Folder in $FolderPath) {
        $TLFolderName = $fileShare.filesharepath
        Write-Progress -Activity "Getting permissions for Sub Folders of $TLFolderName" -Status "Folder $a of $($folderpath.count)" -PercentComplete (($a / $FolderPath.count) * 100) -Id 1 
        $a++
        $Acl = Get-Acl -Path $Folder.FullName
            foreach ($Access in $acl.Access) {
                $objUser = New-Object System.Security.Principal.NTAccount($Access.IdentityReference)
                $strSID = $objUser.Translate([System.Security.Principal.SecurityIdentifier])
                    $PermDetailHash = [Ordered] @{
                    FolderName         = $Folder.FullName
                    'AD Group or User' = $Access.IdentityReference
                    SID                = $strSID.Value
                    Permissions        = $Access.FileSystemRights
                    Inherited          = $Access.IsInherited
            }
       
        $PermDetail = New-Object -TypeName PSObject -Property $PermDetailHash
        $PermDetail | Export-Csv -Path $OutputFile -NoTypeInformation -Append
        
    }
}

}

else {
    
    $PermDetailHash = [Ordered] @{
        FolderName         = $fileShare.FileSharePath
        'AD Group or User' = "Folder not Found"
        SID                = "Folder not Found"
        Permissions        = "Folder not Found"
        Inherited          = "Folder not Found"
}

$PermDetail = New-Object -TypeName PSObject -Property $PermDetailHash
$PermDetail | Export-Csv -Path $OutputFile -NoTypeInformation -Append

}

}