# ListFilePermissionsWithSID.ps1

My current client had a requirement to migrate some data. To facilitate the planning
of how to structure the data in the target environment we needed to see what the current 
permissions looked like. We werent able to utilise a 3rd party tool so I've created 
this script that will interogate file shares (defined in a csv file) and output the 
NTFS permissions assigned to those folders to a CSV file, including the object SID of
the Security Identitfiers and whether the rights are inherited or not.

As a minimum your input csv file must have a 'FileSharePath' header with the UNC
Path of your shares.  Mine also had 'ShareName' and 'SiteName' which are used in the
output file name as we had multiple physical sites to analyse.