🎉 **Wydanie: Vector 2.0** 🎉

Witamy w Vector 2.0! W ramach trwającej transformacji, projekt oficjalnie zmienił nazwę z LSPosed na Vector. Chociaż gruntowna refaktoryzacja wewnętrzna wciąż trwa, udostępniamy wersję 2.0, aby zapewnić stabilne, kompletne środowisko dla użytkowników korzystających ze starszych interfejsów API libxposed.

### 📚 libxposed API 100 i 101
Wraz z niedawną publikacją libxposed API 101, ekosystem zmierza w kierunku nowego standardu, który wprowadza znaczące zmiany. Ponieważ API 100 nigdy nie zostało oficjalnie opublikowane, **Vector 2.0 stanowi ostateczną implementację ery API 100**, zbudowaną na podstawie zatwierdzenia sprzed przejścia na API 101.

### 🏗️ Aktualizacje architektury i API
* **Przebudowa wektorów i Zygisk:** Oficjalnie zmieniono nazwę i zmodularyzowano projekt, wprowadzając całkowicie przepisaną, nowoczesną architekturę Zygisk.
* **Zakończenie prac nad API 100:** Ukończono wszystkie pozostałe funkcje libxposed API 100, w tym kompleksową obsługę inicjatorów statycznych, podłączanie konstruktorów i scentralizowane logowanie.


### ⚙️ Ulepszenia silnika i systemu
* 🔓 **ominięto ograniczenia bionicznego `ld_preload`:** Rozwiązano krytyczne błędy przestrzeni nazw w systemie Android 10 poprzez załadowanie biblioteki hooków `dex2oat` za pomocą deskryptora pliku `memfd_create` opartego na systemie plików tmpfs, omijając sprawdzanie przestrzeni nazw przez linker.
* 🛡️ **Przebudowa parzystości odbicia:** Całkowicie przebudowano zaplecze `invokeSpecialMethod` w celu poprawy wydajności, zwiększenia niezawodności i odzwierciedlenia standardowego zachowania odbicia w Javie.
* ⏱️ **Autonomiczne uruchomienie z późnym wstrzykiwaniem:** Dodano natywną obsługę ręcznego późnego wstrzykiwania (wyzwalanego przez NeoZygisk), bez polegania na fazie wczesnego inicjowania Magiska — bardzo przydatne w kompilacjach debugowania AOSP.