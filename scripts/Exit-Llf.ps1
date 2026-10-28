param(
 [Parameter(Mandatory=$true)][ValidateRange(0,255)][int]$DiskNumber,
 [Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()][string]$ExpectedSerial,
 [switch]$Apply
)
$ErrorActionPreference='Stop'
if(-not [Environment]::Is64BitProcess){throw 'Use 64-bit Windows PowerShell.'}
if(Get-Process SSDMP,VerifySsd -ErrorAction SilentlyContinue){throw 'Close SSDMP and finish any disk test first.'}
$d=Get-Disk -Number $DiskNumber
if($d.SerialNumber.Trim() -ne $ExpectedSerial.Trim() -or $d.BusType -ne 'SATA' -or $d.Size -ne 1179136 -or $d.FriendlyName.Trim() -ne 'REALTEK_RL6531' -or $d.IsBoot -or $d.IsSystem){throw 'Target does not match the documented service state.'}
$d | Format-List Number,FriendlyName,SerialNumber,BusType,Size,IsBoot,IsSystem
if(-not $Apply){Write-Output 'Dry run only. No command sent. Use -Apply only after successful MP and target verification.';return}
Add-Type -Path (Join-Path $PSScriptRoot 'ExitLlf.cs')
[RealtekExitLlf]::Run($DiskNumber,$ExpectedSerial.Trim())
Write-Output 'Command completion is not proof of recovery. Recheck device identity and capacity after a safe power cycle.'
