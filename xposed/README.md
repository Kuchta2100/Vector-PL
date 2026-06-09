# Implementacja API Xposed dla struktury Vector

Ten moduł implementuje API [libxposed](https://github.com/libxposed/api) dla struktury Vector. Służy jako główny pomost między natywnym mechanizmem przechwytywania ART (`lsplant`) a programistami modułów, zapewniając bezpieczną pod względem typów architekturę łańcucha przechwytującego w stylu OkHttp.

## Przegląd architektury

Moduł `xposed` został zaprojektowany z uwzględnieniem ścisłych ograniczeń, aby zapewnić stabilność podczas rozruchu systemu Android i cyklu życia aplikacji. Jest on w całości napisany w języku Kotlin i działa niezależnie od starszego API Xposed (`de.robv.android.xposed`).
Definiuje kontrakt wstrzykiwania zależności (DI) (`LegacyFrameworkDelegate`), który moduł `legacy` musi zaimplementować i wstrzyknąć podczas uruchamiania.

 ## Główne komponenty

### 1. Silnik hookowania

* **`VectorHookBuilder`**: Implementuje API `HookBuilder`. Sprawdza poprawność docelowego `Executable`, pakuje `Hooker`, `priority` i `ExceptionMode` modułu do `VectorHookRecord` i rejestruje go natywnie przez JNI.
* **`VectorNativeHooker`**: Docelowa trampolina JNI. Po wykonaniu metody hookowanej, warstwa C++ wywołuje `callback(Array<Any?>)` w tej klasie. Pobiera aktywne hooki (zarówno nowoczesne, jak i starsze) z rejestru natywnego jako globalne referencje `jobject`, konstruuje główny `VectorChain` i inicjuje wykonanie.
* **`VectorChain`**: Implementuje rekurencyjną maszynę stanów `proceed()`.
 * **Obsługa wyjątków**: Implementuje logikę dla `ExceptionMode`. W trybie `PROTECTIVE`, jeśli interceptor zgłosi wyjątek *przed* wywołaniem `proceed()`, łańcuch pomija interceptor. Jeśli zgłosi wyjątek *po* wywołaniu `proceed()`, łańcuch przechwytuje wyjątek i przywraca zbuforowany wynik/zmienną throwable, aby chronić proces hosta.

### 2. System wywołań

System `Invoker` umożliwia modułom wykonywanie metod z pominięciem standardowych kontroli dostępu JVM, z precyzyjną kontrolą nad wykonywaniem hooków.

* **`Type.Origin`**: Wysyła bezpośrednio do JNI (`HookBridge.invokeOriginalMethod`), pomijając wszystkie aktywne hooki.
 * **`Type.Chain`**: Konstruuje zlokalizowany `VectorChain` zawierający wyłącznie hooki o priorytecie mniejszym lub równym żądanemu `maxPriority`, umożliwiając modułom wykonywanie częściowych łańcuchów hooków.

* **`VectorCtorInvoker`**: Obsługuje wywołanie konstruktora. Oddziela alokację pamięci (`HookBridge.allocateObject`) od inicjalizacji (`invokeOriginalMethod` / `invokeSpecialMethod`), aby zapewnić bezpieczną logikę `newInstanceSpecial`.

### 3. Kontrakt wstrzykiwania zależności

Aby zachować separację zadań, moduł `xposed` komunikuje się ze starszym ekosystemem Xposed za pośrednictwem `VectorBootstrap` i `LegacyFrameworkDelegate`.

 Gdy `xposed` przechwytuje zdarzenie cyklu życia Androida (np. `LoadedApk.createClassLoader`), wywołuje je wewnętrznie za pomocą `VectorLifecycleManager`, a następnie deleguje surowe parametry do `LegacyFrameworkDelegate`, aby moduł `legacy` mógł skonstruować i wywołać starsze wywołania zwrotne `XC_LoadPackage`.

### 4. Ładowanie klas w pamięci i izolacja

Moduły są wykonywane wyłącznie z pamięci za pomocą izolowanego modułu ClassLoader, co zapewnia zerowe obciążenie dysku i maksymalną ochronę przed mechanizmami antyoszustwami.
* Plik APK modułu jest ładowany do `SharedMemory` (ashmem), aby ominąć ograniczenia sterty Java. Po pobraniu buforów DEX przez środowisko wykonawcze Androida (ART), ashmem jest natychmiast demapowany, co zapobiega wyciekom pamięci i nie pozostawia żadnych deskryptorów plików.  * `VectorModuleClassLoader` jest dołączony wyłącznie do gałęzi classloader platformy Xposed Framework, uniemożliwiając aplikacji docelowej wykrycie modułu poprzez refleksję lub przeglądanie łańcucha `ClassLoader.getParent()`.
* `VectorURLStreamHandler` przechwytuje standardowe żądania `jar:`, odczytując zasoby i zasoby natywnie ze ścieżki modułu bez uruchamiania globalnej pamięci podręcznej `JarFile` systemu Android, zapobiegając blokadom plików na poziomie systemu operacyjnego.