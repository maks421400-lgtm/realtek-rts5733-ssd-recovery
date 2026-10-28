# SSDMP и прошивка

[Скачать SSDMP с профилем Intel B17A на 120 ГБ](https://github.com/maks421400-lgtm/realtek-rts5733-ssd-recovery/raw/refs/heads/main/tools/SSDMP-RTS5733DLQ-Intel-B17A-120GB.zip)

В ZIP лежат SSDMP 2.74.0.0, её DLL, прошивка `B17A_GLU_DL-RS10S1C9_VA001CC9` и подготовленный `intel120_id.ini`. Запускать **`X64_Debug/SSDMP.exe`**. Профиль уже выбран, автоматический Start выключен. Проверки Flash ID включены. Скрипт Prepare-Profile в этой папке повторно запускать не нужно.

Перед Start прочитайте [инструкцию](../README.md#пошаговая-инструкция), сверьте накопитель и прочитайте NAND ID. Прошивка сотрёт данные выбранного SSD.

Пакет собран из файлов архива владельца `RTS5733DLQ_B17A_RS10S1C9_VA001CC9(20230718).rar`. EXE, DLL и бинарные файлы прошивки не менялись. Изменены профиль и его выбор в Setting.dat; убраны журналы и резервная копия настроек. Это не официальный выпуск Realtek. Хеши позволяют сверить файлы, но не служат проверкой безопасности программы.

Внутри ZIP: `START-HERE.txt`, хеши компонентов `PACKAGE-SHA256.txt` и папка `scripts`:

- `Prepare-Profile.ps1` — подготовка профиля из исходного пакета;
- `Exit-Llf.ps1` и `ExitLlf.cs` — команда выхода из сервисного режима, по умолчанию без отправки команды.

Для полной проверки через файловую систему: [H2testw, страница издателя Heise](https://www.heise.de/download/product/h2testw-50539). Выбрать `all available space` → `Write + Verify` на пустом разделе восстановленного SSD.

SHA-256 ZIP:

```text
226e9fdf2acc6ac5ceb5441b7adbd5508495677d56208ba6b34037620130a16c
```

[Файл контрольной суммы](SHA256SUMS.txt)
