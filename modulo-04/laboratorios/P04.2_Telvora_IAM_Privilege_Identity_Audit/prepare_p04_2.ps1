#Requires -Version 5.1

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$TargetDomain = 'telvora.lab'
$TargetNetBIOS = 'TELVORA'
$TargetDC = 'ad01.telvora.lab'
$DomainDN = 'DC=telvora,DC=lab'
$UsersDN = "CN=Users,$DomainDN"

function Write-LabMessage {
    param([Parameter(Mandatory)][string]$Message)
    Write-Host "[P04.2] $Message"
}

function Stop-Lab {
    param([Parameter(Mandatory)][string]$Message)
    Write-Error "[P04.2] $Message"
    exit 1
}

function Test-IsAdministrator {
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = [Security.Principal.WindowsPrincipal]::new($identity)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Escape-LdapFilterValue {
    param([Parameter(Mandatory)][string]$Value)
    return $Value.Replace('\', '\5c').Replace('*', '\2a').Replace('(', '\28').Replace(')', '\29').Replace([char]0, '\00')
}

function New-LdapEntry {
    param([Parameter(Mandatory)][string]$DistinguishedName)

    return [System.DirectoryServices.DirectoryEntry]::new(
        "LDAP://$TargetDC/$DistinguishedName",
        $null,
        $null,
        [System.DirectoryServices.AuthenticationTypes]::Secure
    )
}

function Find-DirectoryObject {
    param([Parameter(Mandatory)][string]$SamAccountName)

    $escaped = Escape-LdapFilterValue $SamAccountName
    $searcher = [System.DirectoryServices.DirectorySearcher]::new($script:DomainRoot)
    $searcher.SearchScope = [System.DirectoryServices.SearchScope]::Subtree
    $searcher.PageSize = 1000
    $searcher.Filter = "(sAMAccountName=$escaped)"
    $null = $searcher.PropertiesToLoad.Add('distinguishedName')
    $null = $searcher.PropertiesToLoad.Add('userAccountControl')

    $result = $searcher.FindOne()
    if ($null -eq $result) {
        return $null
    }

    return $result.GetDirectoryEntry()
}

function New-RandomLabPassword {
    return ('Tlv!' + [Guid]::NewGuid().ToString('N') + 'aA1')
}

function Ensure-User {
    param(
        [Parameter(Mandatory)][string]$SamAccountName,
        [Parameter(Mandatory)][bool]$PasswordNeverExpires,
        [Parameter(Mandatory)][bool]$Disabled
    )

    $entry = Find-DirectoryObject $SamAccountName

    if ($null -eq $entry) {
        $entry = $script:UsersContainer.Children.Add("CN=$SamAccountName", 'user')
        $entry.Properties['sAMAccountName'].Value = $SamAccountName
        $entry.Properties['userPrincipalName'].Value = "$SamAccountName@$TargetDomain"
        $entry.CommitChanges()
        $entry.Invoke('SetPassword', (New-RandomLabPassword))
    }

    $uac = 512
    if ($entry.Properties['userAccountControl'].Count -gt 0) {
        $uac = [int]$entry.Properties['userAccountControl'][0]
        $uac = $uac -bor 0x0200
    }

    if ($PasswordNeverExpires) {
        $uac = $uac -bor 0x10000
    }
    else {
        $uac = $uac -band (-bnot 0x10000)
    }

    if ($Disabled) {
        $uac = $uac -bor 0x0002
    }
    else {
        $uac = $uac -band (-bnot 0x0002)
    }

    $entry.Properties['userAccountControl'].Value = $uac
    $entry.CommitChanges()
}

function Ensure-GlobalSecurityGroup {
    param([Parameter(Mandatory)][string]$SamAccountName)

    $entry = Find-DirectoryObject $SamAccountName
    if ($null -ne $entry) {
        return
    }

    $entry = $script:UsersContainer.Children.Add("CN=$SamAccountName", 'group')
    $entry.Properties['sAMAccountName'].Value = $SamAccountName
    $entry.Properties['groupType'].Value = [int]-2147483646
    $entry.CommitChanges()
}

function Ensure-Membership {
    param(
        [Parameter(Mandatory)][string]$GroupName,
        [Parameter(Mandatory)][string]$MemberName
    )

    $group = Find-DirectoryObject $GroupName
    $member = Find-DirectoryObject $MemberName

    if ($null -eq $group -or $null -eq $member) {
        throw 'No se encontró uno de los objetos necesarios para completar el escenario.'
    }

    $memberDN = [string]$member.Properties['distinguishedName'][0]
    $currentMembers = @($group.Properties['member'] | ForEach-Object { [string]$_ })

    if ($currentMembers -notcontains $memberDN) {
        $null = $group.Properties['member'].Add($memberDN)
        $group.CommitChanges()
    }
}

if (-not (Test-IsAdministrator)) {
    Stop-Lab 'Abre Windows PowerShell con la opción Ejecutar como administrador.'
}

Write-LabMessage 'Validando MEMBER01 y los componentes de administración...'

try {
    Import-Module ServerManager -ErrorAction Stop
    $rsat = Get-WindowsFeature -Name RSAT-AD-Tools

    if ($null -eq $rsat) {
        Stop-Lab 'No se encuentra la característica RSAT-AD-Tools en este sistema.'
    }

    if ($rsat.InstallState -ne 'Installed') {
        Write-LabMessage 'Instalando las herramientas de administración necesarias...'
        $result = Install-WindowsFeature -Name RSAT-AD-Tools -IncludeAllSubFeature
        if (-not $result.Success) {
            Stop-Lab 'No se pudieron instalar las herramientas RSAT de Active Directory.'
        }
    }
}
catch {
    Stop-Lab 'No se pudieron validar o instalar las herramientas RSAT de Active Directory.'
}

$computerSystem = Get-CimInstance Win32_ComputerSystem
if (-not $computerSystem.PartOfDomain -or $computerSystem.Domain.ToLowerInvariant() -ne $TargetDomain) {
    Stop-Lab 'MEMBER01 debe pertenecer al dominio TELVORA antes de ejecutar esta práctica.'
}

if ($env:USERDOMAIN.ToUpperInvariant() -ne $TargetNetBIOS) {
    Stop-Lab 'Inicia sesión en MEMBER01 con la cuenta administrativa del dominio TELVORA.'
}

if (-not (Test-NetConnection -ComputerName $TargetDC -Port 389 -InformationLevel Quiet)) {
    Stop-Lab 'No hay conectividad LDAP con el controlador de dominio del laboratorio.'
}

try {
    $script:DomainRoot = New-LdapEntry $DomainDN
    $null = $script:DomainRoot.NativeObject

    $script:UsersContainer = New-LdapEntry $UsersDN
    $null = $script:UsersContainer.NativeObject
}
catch {
    Stop-Lab 'No se pudo abrir una sesión LDAP autenticada con el dominio TELVORA.'
}

# Datos internos del escenario. El script no los muestra durante la ejecución.
$ScenarioUsers = @(
    @{ Sam = 'alice.admin';       NoExpire = $false; Disabled = $false },
    @{ Sam = 'bob.ops';           NoExpire = $false; Disabled = $false },
    @{ Sam = 'carla.net';         NoExpire = $false; Disabled = $false },
    @{ Sam = 'svc_backup';        NoExpire = $true;  Disabled = $false },
    @{ Sam = 'svc_legacy';        NoExpire = $true;  Disabled = $false },
    @{ Sam = 'vendor_noc';        NoExpire = $false; Disabled = $false },
    @{ Sam = 'breakglass01';      NoExpire = $true;  Disabled = $false },
    @{ Sam = 'former.contractor'; NoExpire = $false; Disabled = $true  }
)

$ScenarioGroups = @(
    'Server Admins',
    'Network Operators',
    'NOC Vendors',
    'Remote Access Users'
)

$ScenarioMemberships = @(
    @{ Group = 'Domain Admins';       Member = 'alice.admin' },
    @{ Group = 'Domain Admins';       Member = 'Server Admins' },
    @{ Group = 'Domain Admins';       Member = 'breakglass01' },
    @{ Group = 'Server Admins';       Member = 'bob.ops' },
    @{ Group = 'Server Admins';       Member = 'svc_legacy' },
    @{ Group = 'Network Operators';   Member = 'carla.net' },
    @{ Group = 'Backup Operators';    Member = 'svc_backup' },
    @{ Group = 'Remote Access Users'; Member = 'NOC Vendors' },
    @{ Group = 'NOC Vendors';         Member = 'vendor_noc' },
    @{ Group = 'NOC Vendors';         Member = 'former.contractor' }
)

Write-LabMessage 'Preparando escenario IAM...'

try {
    foreach ($record in $ScenarioUsers) {
        Ensure-User -SamAccountName $record.Sam -PasswordNeverExpires $record.NoExpire -Disabled $record.Disabled
    }

    foreach ($group in $ScenarioGroups) {
        Ensure-GlobalSecurityGroup -SamAccountName $group
    }

    foreach ($membership in $ScenarioMemberships) {
        Ensure-Membership -GroupName $membership.Group -MemberName $membership.Member
    }
}
catch {
    Stop-Lab 'No se pudo completar la preparación del escenario. Verifica que la sesión tenga permisos administrativos en TELVORA.'
}

if (-not (Test-Path "$env:SystemRoot\System32\dsa.msc")) {
    Stop-Lab 'RSAT se instaló, pero no se encuentra Active Directory Users and Computers (dsa.msc).'
}

Write-LabMessage 'Escenario preparado correctamente.'
Write-LabMessage 'Abre Active Directory Users and Computers (dsa.msc) y continúa con el enunciado.'
