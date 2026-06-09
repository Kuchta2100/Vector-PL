# Moduł Zygisk Vector i moduł ładujący strukturę
Vector nie zapisuje kodu struktury do partycji /data.

1. Dostarczanie zasobów: Główny Deamon udostępnia strukturze DEX za pośrednictwem deskryptora pliku `SharedMemory`, używając `kDexTransactionCode`. Warstwa C++ opakowuje ten deskryptor pliku w `java.nio.DirectByteBuffer` i inicjuje `dalvik.system.InMemoryDexClassLoader`.
2. Dynamiczne ponowne linkowanie: Deamon losuje nazwy klas struktury przy każdym uruchomieniu. Moduł natywny pobiera serializowany słownik przez IPC, używając `kObfuscationMapTransactionCode`. `SetupEntryClass` używa tej mapy do lokalizowania losowego punktu wejścia (`org.matrix.vector.core.Main`) i usługi BridgeService, umożliwiając frameworkowi poprawne linkowanie w czasie wykonywania.

 ## Menedżer pasożytniczy i transplantacja tożsamości

Aplikacja menedżera Vector nie jest instalowana jako standardowy pakiet. Działa poprzez wydrążenie procesu hosta (np. `com.android.shell`) przy użyciu pasożytniczego modelu wykonywania.

### Przekierowanie intencji serwera systemowego
W ramach `system_server`, `ParasiticManagerSystemHooker` przechwytuje `ActivityTaskSupervisor.resolveActivity`. Po wykryciu intencji oznaczonej kategorią `LAUNCH_MANAGER` dynamicznie modyfikuje zwrócone dane ActivityInfo. Wymusza na systemie uruchomienie pakietu hosta, ustawiając parametr processName na nazwę pakietu Menedżera i dostosowując flagi motywu i ostatnich zdarzeń, aby naśladować samodzielną aplikację.

 ### Przejęcie hosta aplikacji
Gdy moduł natywny wykryje identyfikator UID pakietu hosta i nazwę procesu menedżera podczas procedury `preAppSpecialize`, wstrzykuje `GID_INET` (3003) do tablicy identyfikatorów GID procesu, aby zapewnić dostęp do sieci. Kontrola jest następnie przekazywana do `ParasiticManagerHooker.kt`, który przeprowadza transplantację tożsamości:
1. Wstrzyknięcie kodu: Przechwytuje `LoadedApk.getClassLoader` i `ActivityThread.handleBindApplication`, zamieniając obiekt ApplicationInfo hosta na obiekt hybrydowy skonstruowany z pliku APK menedżera (dostarczonego za pośrednictwem deskryptora pliku). DEX menedżera jest wstrzyknięty do `PathClassLoader` hosta.
2. Fałszowanie stanu: Systemowy menedżer aktywności nie jest świadomy podrobionych aktywności menedżera.  Aby zapobiec utracie danych podczas zmian w cyklu życia (np. obrotu ekranu), hooker przechwytuje `performStopActivityInner`, aby ręcznie przechwycić stany Bundle i PersistableBundle do statycznych map współbieżnych. Stany te są ponownie wstrzykiwane podczas `scheduleLaunchActivity`.
3. Podszywanie się pod kontekst: Przechwytuje `ActivityThread.installProvider` i `WebViewFactory.getProvider`, aby skonstruować fałszywe instancje `ContextImpl`, omijając wewnętrzne kontrole poprawności nazw pakietów Androida i Chromium.
