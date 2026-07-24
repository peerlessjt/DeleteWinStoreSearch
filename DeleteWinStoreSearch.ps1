Install-PackageProvider -Name NuGet -Force -Scope CurrentUser
Set-PSRepository -Name 'PSGallery' -InstallationPolicy Trusted
Install-Module NTFSSecurity -Scope CurrentUser
Install-Module AdoSQLiteModule -Scope CurrentUser

Import-Module NTFSSecurity
Import-Module AdoSQLiteModule

$storedb = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsStore_8wekyb3d8bbwe\LocalState\store.db"

$perm = Get-NTFSAccess $storedb

If ($perm[0].AccessRights -eq 'FullControl') {
    Invoke-AdoSQLiteNonQuery -Database $storedb -Query 'DELETE FROM SearchProducts'

    Disable-NTFSAccessInheritance $storedb
    Get-NTFSAccess $storedb | ForEach-Object {
        Remove-NTFSAccess -Account $_.Account -Path $storedb -AccessRights Write,Modify  
        Add-NTFSAccess -Account $_.Account -Path $storedb -AccessRights Read
    }
}