<#
.SYNOPSIS
    Creates a list of all Group Policies which define a WSUS server. This makes it easy to find clients with wrong WSUS configuration through GPOs

.PARAMETER DomainName
    The name of the domain to check

.NOTES
    Author: Fabian Bader (fabian.bader@toolsection.info)
#>
#requires -Modules GPO
param(
    [Parameter(Mandatory = $true)]
    [string]$DomainName
)
$AllGPOs = Get-GPO -All -Server $DomainName
foreach ($GPO in $AllGPOs) {
    $GPRegistryValue = Get-GPRegistryValue -Name $GPO.DisplayName -Key "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" -ValueName "WUServer" -Domain $GPO.DomainName -ErrorAction SilentlyContinue
    if ($GPRegistryValue) {
        [pscustomobject]@{
            DisplayName = $GPO.DisplayName
            ValueName   = $GPRegistryValue.ValueName
            Hive        = $GPRegistryValue.Hive
            PolicyState = $GPRegistryValue.PolicyState
            Value       = $GPRegistryValue.Value
            Type        = $GPRegistryValue.Type
        }
    }
}