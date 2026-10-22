#Requires -Version 5.1

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$TargetDomain = 'telvora.lab'
$TargetNetBIOS = 'TELVORA'

function Write-LabMessage {
    param([Parameter(Mandatory)][string]$Message)
    Write-Host "[P04.2] $Message"
}

function Stop-Lab {
    param([Parameter(Mandatory)][string]$Message)
    Write-Error "[P04.2] $Message"
    exit 1
}

function Require-Command {
    param([Parameter(Mandatory)][string]$Name)
    if (-not (Get-Command $Name -ErrorAction SilentlyContinue)) {
        Stop-Lab "Falta la herramienta requerida: $Name. Utiliza la imagen MEMBER01 preparada para el laboratorio."
    }
}

function Invoke-External {
    param(
        [Parameter(Mandatory)][string]$Command,
        [Parameter(Mandatory)][string[]]$Arguments
    )

    $output = & $Command @Arguments 2>&1
    if ($LASTEXITCODE -ne 0) {
        throw "$Command fallo: $($output -join ' ')"
    }
    return $output
}

function Get-UserDN {
    param([Parameter(Mandatory)][string]$Sam)

    $output = & dsquery.exe user -samid $Sam 2>$null
    if ($LASTEXITCODE -eq 0 -and $output) {
        return ([string]($output | Select-Object -First 1)).Trim().Trim('"')
    }
    return $null
}

function Get-GroupDN {
    param([Parameter(Mandatory)][string]$Sam)

    $output = & dsquery.exe group -samid $Sam 2>$null
    if ($LASTEXITCODE -eq 0 -and $output) {
        return ([string]($output | Select-Object -First 1)).Trim().Trim('"')
    }
    return $null
}

function New-RandomLabPassword {
    return ('Tlv!' + [Guid]::NewGuid().ToString('N') + 'aA1')
}

function Ensure-User {
    param(
        [Parameter(Mandatory)][string]$Sam,
        [Parameter(Mandatory)][bool]$PasswordNeverExpires,
        [Parameter(Mandatory)][bool]$Disabled
    )

    $dn = Get-UserDN $Sam
    if (-not $dn) {
        $pwd = New-RandomLabPassword
        Invoke-External 'net.exe' @('user', $Sam, $pwd, '/add', '/domain', '/active:yes') | Out-Null
        $dn = Get-UserDN $Sam
        if (-not $dn) {
            throw "No se pudo localizar el usuario $Sam despues de crearlo."
        }
    }

    Invoke-External 'dsmod.exe' @('user', $dn, '-pwdneverexpires', $(if ($PasswordNeverExpires) { 'yes' } else { 'no' })) | Out-Null
    Invoke-External 'dsmod.exe' @('user', $dn, '-disabled', $(if ($Disabled) { 'yes' } else { 'no' })) | Out-Null
}

function Ensure-Group {
    param([Parameter(Mandatory)][string]$Sam)

    $dn = Get-GroupDN $Sam
    if (-not $dn) {
        Invoke-External 'net.exe' @('group', $Sam, '/add', '/domain') | Out-Null
        $dn = Get-GroupDN $Sam
        if (-not $dn) {
            throw "No se pudo localizar el grupo $Sam despues de crearlo."
        }
    }
}

function Ensure-Membership {
    param(
        [Parameter(Mandatory)][string]$GroupSam,
        [Parameter(Mandatory)][string]$MemberSam,
        [Parameter(Mandatory)][ValidateSet('user','group')][string]$MemberType
    )

    $groupDN = Get-GroupDN $GroupSam
    $memberDN = if ($MemberType -eq 'user') { Get-UserDN $MemberSam } else { Get-GroupDN $MemberSam }

    if (-not $groupDN -or -not $memberDN) {
        throw 'No se encontro uno de los objetos necesarios para completar el escenario.'
    }

    $members = & dsget.exe group $groupDN -members 2>$null
    if ($LASTEXITCODE -ne 0) {
        throw "No se pudieron consultar los miembros del grupo $GroupSam."
    }

    $normalized = @($members | ForEach-Object { ([string]$_).Trim().Trim('"') })
    if ($normalized -notcontains $memberDN) {
        Invoke-External 'dsmod.exe' @('group', $groupDN, '-addmbr', $memberDN) | Out-Null
    }
}

Write-LabMessage 'Validando MEMBER01 y los componentes de administracion...'

if (-not (Test-Path "$env:SystemRoot\System32\dsa.msc")) {
    Stop-Lab 'Active Directory Users and Computers (dsa.msc) no esta instalado.'
}

Require-Command 'net.exe'
Require-Command 'dsquery.exe'
Require-Command 'dsmod.exe'
Require-Command 'dsget.exe'

$computerSystem = Get-CimInstance Win32_ComputerSystem
if (-not $computerSystem.PartOfDomain -or $computerSystem.Domain.ToLowerInvariant() -ne $TargetDomain) {
    Stop-Lab 'MEMBER01 debe pertenecer al dominio TELVORA antes de ejecutar esta practica.'
}

if ($env:USERDOMAIN.ToUpperInvariant() -ne $TargetNetBIOS) {
    Stop-Lab 'Inicia sesion en MEMBER01 con la cuenta administrativa del dominio TELVORA.'
}

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
    @{ Group = 'Domain Admins';       Member = 'alice.admin';       Type = 'user'  },
    @{ Group = 'Domain Admins';       Member = 'Server Admins';     Type = 'group' },
    @{ Group = 'Domain Admins';       Member = 'breakglass01';      Type = 'user'  },
    @{ Group = 'Server Admins';       Member = 'bob.ops';           Type = 'user'  },
    @{ Group = 'Server Admins';       Member = 'svc_legacy';        Type = 'user'  },
    @{ Group = 'Network Operators';   Member = 'carla.net';         Type = 'user'  },
    @{ Group = 'Backup Operators';    Member = 'svc_backup';        Type = 'user'  },
    @{ Group = 'Remote Access Users'; Member = 'NOC Vendors';       Type = 'group' },
    @{ Group = 'NOC Vendors';         Member = 'vendor_noc';        Type = 'user'  },
    @{ Group = 'NOC Vendors';         Member = 'former.contractor'; Type = 'user'  }
)

Write-LabMessage 'Preparando escenario IAM...'

try {
    foreach ($record in $ScenarioUsers) {
        Ensure-User -Sam $record.Sam -PasswordNeverExpires $record.NoExpire -Disabled $record.Disabled
    }

    foreach ($group in $ScenarioGroups) {
        Ensure-Group -Sam $group
    }

    foreach ($membership in $ScenarioMemberships) {
        Ensure-Membership -GroupSam $membership.Group -MemberSam $membership.Member -MemberType $membership.Type
    }
}
catch {
    Stop-Lab ("No se pudo completar la preparacion del escenario: " + $_.Exception.Message)
}

Write-LabMessage 'Escenario preparado correctamente.'
Write-LabMessage 'Abre Active Directory Users and Computers (dsa.msc) y continua con el enunciado.'
