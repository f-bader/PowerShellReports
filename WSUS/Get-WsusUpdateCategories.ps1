<#
.SYNOPSIS
    List every product category a WSUS service is serving updates.

.PARAMETER ServerName
    FQDN of the WSUS server

.PARAMETER WSUSPort
    Port of the WSUS webservice. Default 8530

.NOTES
    Author: Fabian Bader (fabian.bader@toolsection.info)
#>
#requires -Modules WSUS
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true,
        ValueFromPipeline = $true,
        ValueFromPipelineByPropertyName = $true)]
    [string[]]$ServerName,

    [Parameter(Mandatory = $false)]
    $WSUSPort = 8530
)

Process {
    $WsusServerObject = Get-WsusServer -Name $ServerName -PortNumber $WSUSPort
    $WsusSubscription = $WSUSServerObject.GetSubscription()
    $wsusSubscription.GetUpdateCategories() | Add-Member -MemberType NoteProperty -Name "WsusServer" -Value $ServerName -PassThru
}