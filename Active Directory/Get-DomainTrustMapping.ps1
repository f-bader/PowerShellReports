<#
.SYNOPSIS
    Create a report of every trust one can reach in an environment
    The output includes
    * primaryDomain
    * trustedDomain
    * NETBIOSName
    * trustType
    * trustDirection

    The complete code only relies on the default Active Directory PowerShell cmdlets and checks the trustedDomain objects within a domain for information

.NOTES
    Author: Fabian Bader (fabian.bader@toolsection.info)
#>
# https://msdn.microsoft.com/en-us/library/cc223768.aspx
$trustDirection = @{
    0 = "The trust relationship exists but has been disabled"
    1 = "The trusted domain trusts the primary domain to perform operations such as name lookups and authentication (InBound)"
    2 = "The primary domain trusts the trusted domain to perform operations such as name lookups and authentication (OutBound)"
    3 = "Both domains trust one another for operations such as name lookups and authentication"
}

# https://msdn.microsoft.com/en-us/library/cc223771.aspx
$trustType = @{
    1 = "The trusted domain is a Windows domain not running Active Directory"
    2 = "The trusted domain is a Windows domain running Active Directory"
    3 = "The trusted domain is running a non-Windows, RFC4120-compliant Kerberos distribution"
    4 = "Historical reference; this value is not used in Windows"
}

$RootDomain = Get-ADDomain
$TrustedDomains = Get-ADObject -Filter { ObjectClass -eq "trustedDomain" } -Properties * -Server $RootDomain.PDCEmulator
$AllDomains = @($RootDomain.DNSRoot)
$AllDomains += $($TrustedDomains.trustPartner)

foreach ($CurrentDomain in $AllDomains) {
    $TrustedDomains = Get-ADObject -Filter { ObjectClass -eq "trustedDomain" } -Properties * -Server $CurrentDomain
    $TrustedDomains | Select-Object @{L = 'primaryDomain'; E = { $CurrentDomain } }, @{L = 'trustedDomain'; E = { $_.trustPartner } }, @{L = 'NETBIOSName'; E = { $_.flatName } }, @{L = 'trustType'; E = { $trustType[$($_.trustType)] } }, @{L = 'trustDirection'; E = { $trustDirection[$($_.trustDirection)] } }
}