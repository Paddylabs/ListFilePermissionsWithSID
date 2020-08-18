<#
  .SYNOPSIS
  Lists all the permissions for a list of folders and gets SIDs from AD
  .DESCRIPTION
  Takes a CSV list of UNC paths and lists out the NTFS Permissions for them and retrieves the SIDs for
  the Identity Reference from Active Directory
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
#>

$csvFile = "fileShares_List.csv"
$OutputFile = ("SourcePermissions_" + $fileShare.SiteName + "_" + $fileShare.ShareName + ".csv")
$fileShareList = Import-CSV $csvFile -Delimiter ","

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
            $PermDetailHash = [Ordered] @{
                FolderName         = $fileShare.FileSharePath
                'AD Group or User' = $Access.IdentityReference
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
                $PermDetailHash = [Ordered] @{
                    FolderName         = $Folder.FullName
                    'AD Group or User' = $Access.IdentityReference
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
        Permissions        = "Folder not Found"
        Inherited          = "Folder not Found"
}

$PermDetail = New-Object -TypeName PSObject -Property $PermDetailHash
$PermDetail | Export-Csv -Path $OutputFile -NoTypeInformation -Append

}

}
 # Test