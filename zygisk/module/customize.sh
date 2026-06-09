SKIPUNZIP=1

# =================================================================================
# Funkcje narzędzi umożliwiające wyodrębnienie i sprawdzenie pakietu instalacyjnego

TMPDIR_FOR_VERIFY="$TMPDIR/.vunzip"
mkdir "$TMPDIR_FOR_VERIFY"

abort_verify() {
  ui_print "************************************************************"
  ui_print "! $1"
  ui_print "! Ten plik zip może być uszkodzony. Spróbuj pobrać ponownie."
  abort    "************************************************************"
}

# Zastosowanie: wypakuj <zip> <file> <target dir> [junk_paths: true|false]
extract() {
  local zip="$1"
  local file="$2"
  local dir="$3"
  local junk_paths="${4:-false}" # Domyślnie fałsz, jeśli nie podano
  local opts="-o"
  local file_path hash_path file_basename

  file_basename=$(basename "$file")

  if [ "$junk_paths" = "true" ]; then
    opts="-oj"
    file_path="$dir/$file_basename"
    hash_path="${TMPDIR_FOR_VERIFY}/$file_basename.sha256"
  else
    file_path="$dir/$file"
    hash_path="${TMPDIR_FOR_VERIFY}/$file.sha256"
  fi

  # Extract the file and its hash
  unzip $opts "$zip" "$file" -d "$dir" >/dev/null 2>&1
  [ -f "$file_path" ] || abort_verify "Wyodrębniony plik $file nie istnieje"

  unzip $opts "$zip" "$file.sha256" -d "${TMPDIR_FOR_VERIFY}" >/dev/null 2>&1
  [ -f "$hash_path" ] || abort_verify "Plik skrótu $file.sha256 nie istnieje"

  # Read the expected hash and verify it
  local expected_hash
  read -r expected_hash < "$hash_path"
  expected_hash="${expected_hash%% *}" # Usuń wszystko po rzeczywistym ciągu skrótu
  if ! echo "$expected_hash  $file_path" | sha256sum -c -s -; then
    abort_verify "Nie udało się zweryfikować $file"
  fi

  ui_print "- Zweryfikowany $file"
}
# =========================================================

VERSION=$(grep_prop version "${TMPDIR}/module.prop")
ui_print "- Vector wersja ${VERSION}"

# Disable existing LSPosed installation
LSPOSED_DIR="/data/adb/modules/zygisk_lsposed"
if [ -d "$LSPOSED_DIR" ]; then
    ui_print "***************************************************"
    ui_print "Wykryto instalację LSPosed, wyłączono ją dla Vector"
    touch "$LSPOSED_DIR/disable"
    ui_print "***************************************************"
fi

# 1. Map architecture to standard ABI paths, eliminating duplicate logic
case "$ARCH" in
    arm|arm64)
        ABI32="armeabi-v7a"
        ABI64="arm64-v8a"
        ;;
    x86|x64)
        ABI32="x86"
        ABI64="x86_64"
        ;;
    *)
        abort "! Nieobsługiwana platforma: $ARCH"
        ;;
esac
ui_print "- Platforma urządzenia: $ARCH ($ABI32 / $ABI64)"

ui_print "- Wyodrębnianie plików modułu głównego"
for file in module.prop action.sh service.sh uninstall.sh sepolicy.rule framework/lspd.dex cli daemon.apk daemon manager.apk; do
    extract "$ZIPFILE" "$file" "$MODPATH"
done

ui_print "- Wyodrębnianie bibliotek zygisk"
mkdir -p "$MODPATH/zygisk"

# Wyodrębnij bibliotekę 32-bitową
extract "$ZIPFILE" "lib/$ABI32/libzygisk.so" "$MODPATH/zygisk" true
mv "$MODPATH/zygisk/libzygisk.so" "$MODPATH/zygisk/${ABI32}.so"

# Wypakuj bibliotekę 64-bitową, jeśli jest obsługiwana
if [ "$IS64BIT" = true ]; then
    extract "$ZIPFILE" "lib/$ABI64/libzygisk.so" "$MODPATH/zygisk" true
    mv "$MODPATH/zygisk/libzygisk.so" "$MODPATH/zygisk/${ABI64}.so"
fi

if [ "$API" -ge 29 ]; then
    ui_print "- Wyodrębnianie plików binarnych dex2oat"
    mkdir -p "$MODPATH/bin"

    # Wyodrębnij 32-bitowe pliki binarne
    extract "$ZIPFILE" "bin/$ABI32/dex2oat" "$MODPATH/bin" true
    extract "$ZIPFILE" "bin/$ABI32/liboat_hook.so" "$MODPATH/bin" true
    mv "$MODPATH/bin/dex2oat" "$MODPATH/bin/dex2oat32"
    mv "$MODPATH/bin/liboat_hook.so" "$MODPATH/bin/liboat_hook32.so"

    # Wyodrębnij 64-bitowe pliki binarne
    if [ "$IS64BIT" = true ]; then
        extract "$ZIPFILE" "bin/$ABI64/dex2oat" "$MODPATH/bin" true
        extract "$ZIPFILE" "bin/$ABI64/liboat_hook.so" "$MODPATH/bin" true
        mv "$MODPATH/bin/dex2oat" "$MODPATH/bin/dex2oat64"
        mv "$MODPATH/bin/liboat_hook.so" "$MODPATH/bin/liboat_hook64.so"
    fi

    ui_print "- Łatanie plików binarnych w celu zapobiegania wykryciu"
    DEV_PATH=$(tr -dc 'a-z0-9' </dev/urandom | head -c 32)
    # Zastosuj poprawkę tylko w przypadku, gdy istnieje prawidłowy plik
    [ -f "$MODPATH/daemon.apk" ] && sed -i "s/5291374ceda0aef7c5d86cd2a4f6a3ac/$DEV_PATH/g" "$MODPATH/daemon.apk"
    [ -f "$MODPATH/bin/dex2oat32" ] && sed -i "s/5291374ceda0aef7c5d86cd2a4f6a3ac/$DEV_PATH/" "$MODPATH/bin/dex2oat32"
    [ -f "$MODPATH/bin/dex2oat64" ] && sed -i "s/5291374ceda0aef7c5d86cd2a4f6a3ac/$DEV_PATH/" "$MODPATH/bin/dex2oat64"
else
    extract "$ZIPFILE" 'system.prop' "$MODPATH"
fi

ui_print "- Ustawianie uprawnień"
set_perm_recursive "$MODPATH" 0 0 0755 0644
[ -d "$MODPATH/bin" ] && set_perm_recursive "$MODPATH/bin" 0 2000 0755 0755 u:object_r:xposed_file:s0

set_perm "$MODPATH/daemon" 0 0 0744
set_perm "$MODPATH/cli" 0 0 0744

if [ "$(grep_prop ro.maple.enable)" = "1" ]; then
    ui_print "- Dodaj ro.maple.enable=0"
    echo "ro.maple.enable=0" >>"$MODPATH/system.prop"
fi

ui_print "- Witaj w Vector!"
