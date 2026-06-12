<div align="center">

# Zygisk Vector 2.0

[![build](https://img.shields.io/github/actions/workflow/status/Kuchta2100/Vector-PL/core.yml?branch=PL&event=push&logo=github&label=Build)](https://github.com/Kuchta2100/Vector-PL/actions/workflows/core.yml?query=event%3Apush+branch%3APL+is%3Acompleted)
[![Crowdin](https://img.shields.io/badge/Localization-Crowdin-blueviolet?logo=Crowdin)](https://crowdin.com/project/lsposed_jingmatrix)
[![Pobierz](https://img.shields.io/github/v/release/Kuchta2100/Vector-PL?color=orange&logoColor=orange&label=Download&logo=DocuSign)](https://github.com/Kuchta2100/Vector-PL/releases/latest)
</div>

---

### Wprowadzenie

Mój fork ma pełne i dokładniejsze polskie tłumaczenie. 
Naprawiłem też problem z nieładującą się listą modułów.

Vector to moduł zygisk, który zapewnia strukturę do tworzenia zaczepów, zachowując spójność API z oryginalnym xposed. Został on opracowany na bazie [LSPlant](https://github.com/JingMatrix/LSPlant), aby zapewnić stabilne środowisko instrumentacji na poziomie natywnym.

Vector umożliwia modułom modyfikację działania systemu i aplikacji w pamięci. Ponieważ pliki APK nie są modyfikowane, zmiany są nieniszczące, łatwo odwracalne poprzez ponowne uruchomienie i kompatybilne z różnymi ROM-ami i wersjami Androida.

---

### Zgodność

Vector obsługuje urządzenia z systemem **Android 8.1 do Androida 17 Beta**.

> [!TIP]
> Vector wymaga zainstalowania najnowszej wersji Magisk lub KernelSU z włączonym zygiskiem.

---

### Instalacja

1. Pobierz najnowszą wersję jako moduł systemowy.
2. Zainstaluj moduł za pomocą menedżera root (magisk/kernelsu).
3. Upewnij się, że środowisko zygisk (np. [Nyazygisk](https://github.com/HSSkyBoy/NyaZygisk/releases/tag/v2.3).
4. Zrestartuj urządzenie.
5. Uzyskaj dostęp do ustawień zarządzania za pomocą powiadomienia systemowego.

--

### Pobieranie

| Kanał | Źródło |
| :--- | :--- |
| **Wersje stabilne** | [Wersje GitHub](https://github.com/Kuchta2100/Vector-PL/releases/tag/2.0) |
| **Wersje testowe** | [Akcje GitHub](https://github.com/Kuchta2100/Vector-PL/actions/workflows/core.yml?query=branch%3APL) |

> [!NOTE]
> Wersje debugowe są zalecane użytkownikom napotykającym problemy lub rozwiązującym problemy.
> Zachęcamy użytkowników do testowania wersji testowej, aby pomóc nam identyfikować błędy i przyspieszać rozwój.

> [!CAUTION]
> GitHub wymaga od użytkowników **zalogowania się**, aby mogli pobrać artefakty CI.
>
> Powyższy link jest filtrowany i wyświetla tylko kompilacje z gałęzi `PL`.
> Należy pamiętać, że kompilacje z żądań ściągnięcia (PR) są często niestabilne i potencjalnie niebezpieczne (w zależności od autorów); zalecamy pozostanie na gałęzi `PL` w przypadku zweryfikowanych kompilacji, chyba że zostaniesz poproszony o pomoc w naszych sesjach debugowania.

---

### Wsparcie i wkład

Jeśli napotkasz problemy lub chcesz pomóc w ulepszeniu projektu, zapoznaj się z poniższymi zasobami.

* **Rozwiązywanie problemów:** Przed zgłoszeniem błędów zapoznaj się z [poradnikiem](https://github.com/JingMatrix/Vector/issues/123).
* **Dyskusje:** Dołącz do naszej społeczności w [Dyskusjach GitHub](https://github.com/JingMatrix/Vector/discussions).
* **Lokalizacja:** Pomóż w tłumaczeniu projektu za pośrednictwem [Crowdin](https://crowdin.com/project/lsposed_jingmatrix)

### Zasoby dla programistów

Vector obsługuje zarówno starsze, jak i nowsze standardy przechwytywania, aby zapewnić szeroką kompatybilność modułów.

* [Nowoczesne API libxposed](https://libxposed.github.io/api/)
* [Repozytorium modułów Xposed](https://github.com/Xposed-Modules-Repo)

> [!NOTE]
>Vector obsługuje API `libxposed` za pośrednictwem dwóch podmodułów Git: [API modułów](./xposed/) i [API usług](./services/).
>
> Udana kompilacja gałęzi [master](https://github.com/JingMatrix/Vector/tree/master) w GitHub Actions wskazuje, że Vector w pełni obsługuje te API w tych konkretnych commitach.
> Zaleca się, aby programiści sprawdzili te same commity, co Vector.

---

### Podziękowania

Ten projekt jest możliwy dzięki następującym wkładom open source:

* [Magisk](https://github.com/topjohnwu/Magisk/): Podstawa personalizacji Androida.
* [LSPlant](https://github.com/JingMatrix/LSPlant): Główny silnik przechwytywania ART.
 * [XposedBridge](https://github.com/rovo89/XposedBridge): Standardowe API Xposed.
* [Dobby](https://github.com/JingMatrix/Dobby): Implementacja przechwytywania inline.
* [LSPosed](https://github.com/LSPosed/LSPosed): Źródło źródłowe.
* [xz-embedded](https://github.com/tukaani-project/xz-embedded): Narzędzia do dekompresji bibliotek.

---

### Licencja

Vector jest licencjonowany na podstawie [Ogólnej Licencji Publicznej v3](http://www.gnu.org/copyleft/gpl.html).
