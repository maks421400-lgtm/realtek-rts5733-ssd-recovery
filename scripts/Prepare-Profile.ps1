param([Parameter(Mandatory=$true)][string]$PackageRoot)
$ErrorActionPreference='Stop'
$root=(Resolve-Path -LiteralPath $PackageRoot).Path
$fw=Join-Path $root 'B17A_GLU_DL-RS10S1C9_VA001CC9'
$exe=Join-Path $root 'X64_Debug\SSDMP.exe'
$settings=Join-Path $root 'X64_Debug\Setting.dat'
$source=Join-Path $fw 'config_6531.ini'
$dest=Join-Path $fw 'intel120_id.ini'
if(Get-Process SSDMP -ErrorAction SilentlyContinue){throw 'Close SSDMP first.'}
if((Get-FileHash -LiteralPath $exe -Algorithm SHA256).Hash -ne '59533152D17EAA93B11798127DEBBF584388D6382D8FB20E91F970DF4C411F74'){throw 'SSDMP.exe hash differs from the documented package.'}
if((Test-Path -LiteralPath $dest) -or (Test-Path -LiteralPath "$settings.article-backup")){throw 'Use a fresh copy of the package; output/backup already exists.'}
$text=[IO.File]::ReadAllText($source,[Text.Encoding]::ASCII)
$map=[ordered]@{
 'DEVICE_COUNT'='1'; 'DEBUG_MODE'='1'; 'AUTO_LOCK'='0';
 'DUT0'='1'; 'DUT1'='0'; 'DUT2'='0'; 'DUT3'='0'; 'DUT4'='0'; 'DUT5'='0';
 'FLASH_VENDOR'='intel'; 'FLASH_INFO'='PF29R01T2AMCTH1 (B17A)';
 'FLASH_TYPE'='0x0c000045'; 'MAPPING_VALUE'='0x01304146';
 '0x074_4_FLASHTYPE'='0x0c000045'; '0x078_4_SYS_BANKMAPPING'='0x01304146';
 '0x790_4_FC_DIE_MAPPING_CE0'='0x08060402'; '0x794_4_FC_DIE_MAPPING_CE1'='0x0E0C0A00';
 '0x798_4_FC_DIE_MAPPING_CE2'='0x09070503'; '0x79c_4_FC_DIE_MAPPING_CE3'='0x0F0D0B01';
 '0xc51_1_CENum'='1'; '0xc58_2_BankNum'='2'; '0xc70_8_MaxCapacity'='120';
 '0xc78_4_FlashVendorNum'='0x041d4006'; '0xc9a_2_SharedPageNum'='96'
}
foreach($key in $map.Keys){
 $rx=[regex]::new('(?m)^'+[regex]::Escape($key)+'=[^\r\n]*')
 if($rx.Matches($text).Count -ne 1){throw "Expected exactly one key: $key"}
 $text=$rx.Replace($text,($key+'='+$map[$key]))
}
# Add these only inside TEST_PARAMETER; reject duplicate or unexpected keys.
$extra=[ordered]@{'PAR_1'='ID: 89 C4 08 32 A6 00 00 00';'AUTO_START_TEST'='0';'CHECK_FLASH_ID'='1';'CHECK_FLASH_ID_LEN'='6';'DUT_FROM0'='1'}
foreach($key in $extra.Keys){
 $rx=[regex]::new('(?m)^'+[regex]::Escape($key)+'=[^\r\n]*')
 if($rx.Matches($text).Count -gt 1){throw "Duplicate key: $key"}
 if($rx.IsMatch($text)){$text=$rx.Replace($text,($key+'='+$extra[$key]))}
 else{$text=$text.Replace('[TEST_PARAMETER]',('[TEST_PARAMETER]'+"`r`n"+$key+'='+$extra[$key]))}
}
foreach($required in @('DL_MODE=1','FW_UPDATE=0','PROGRAM_EFUSE=0','0xc00_1_LLFMode=1','0xc50_1_CHNum=2','0xc53_1_PlaneNumPerLun=4')){
 if(-not [regex]::IsMatch($text,'(?m)^'+[regex]::Escape($required)+'\r?$')){throw "Unexpected baseline: $required"}
}
# In this exact version the filename is ASCII in a binary settings record.
# The two filenames have equal length; no record offsets are changed.
$bytes=[IO.File]::ReadAllBytes($settings)
$encoded=[Text.Encoding]::GetEncoding(28591).GetString($bytes)
if(([regex]::Matches($encoded,'config_6531\.ini')).Count -ne 1){throw 'Unexpected Setting.dat layout.'}
$newBytes=[Text.Encoding]::GetEncoding(28591).GetBytes($encoded.Replace('config_6531.ini','intel120_id.ini'))
Copy-Item -LiteralPath $settings -Destination "$settings.article-backup"
[IO.File]::WriteAllText($dest,$text,[Text.Encoding]::ASCII)
[IO.File]::WriteAllBytes($settings,$newBytes)
Write-Output "Prepared $dest. AUTO_START_TEST=0. No device was accessed. Verify the target in SSDMP before Start."
