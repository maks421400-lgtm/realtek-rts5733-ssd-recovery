# Realtek RTS5733DLQ fake SSD recovery: 2 TB to verified 120 GB

This repository documents one successful recovery, with board photos, an offline INI preparation script, sanitized logs and a Russian step-by-step guide.

Hardware: M.2 2280 **SATA**, Realtek **RTS5733DLQ**, Intel B17A NAND marked **29F01T2AMCTH1**. The SSDMP database calls the package `PF29R01T2AMCTH1`. NAND ID: **89 C4 08 32 A6 00 00 00**, responding at **CH0/CE4 and CH1/CE4**.

The supplied tool was SSDMP **2.74.0.0_20230414_D_X64**, package `RTS5733DLQ_B17A_RS10S1C9_VA001CC9(20230718).rar`. Firmware binaries are not distributed here; no verified official download URL is available.

The original Micron/240 GB profile had the wrong bank mapping. A matching Intel/120 GB profile, an expected-ID `PAR_1` entry and a separate `intel120_id.ini` filename resolved the configuration mismatch without disabling checks. The USB enclosure could read NAND IDs but did not complete recovery. Direct SATA in a compatible M.2 slot completed MP with **Pass (120G)**.

The device initially remained **REALTEK_RL6531, firmware 3.AAE, 1,179,136 bytes**. A verified SetFWMode(0) command was accepted but did not immediately change its state. After physical M.2 reconnection the SSD reported **120,034,123,776 bytes**. The command's necessity versus the power cycle was not isolated in a controlled test.

All **120,034,123,776 bytes** were written, then read and compared byte-for-byte: **PASS**, 2863.7 seconds. Creating a filesystem was left to the owner. This does not establish remaining NAND endurance or long-term reliability.

Do not copy this profile to different NAND or a different channel/CE arrangement. The procedure destroys target-drive data. Never remove or insert M.2 with power connected; disconnect the battery according to the laptop manufacturer's instructions.

[Full guide and photographs](../README.md) · [Exact parameters and caveats](TECHNICAL.md) · [Verification log](../evidence/verification.txt)

Search terms: RTS5733DLQ, RTS5733DL, REALTEK_RL6531 1MB, Intel B17A, 29F01T2AMCTH1, PF29R01T2AMCTH1, SSDMP Check flash id Fail, LLF mode, fake SSD capacity repair, M.2 SATA recovery.
