_build/default/bin/main.exe | tee out/default.csv
GC_MAJOR=1 _build/default/bin/main.exe | tee out/full_major.csv
GC_COMPACT=1 _build/default/bin/main.exe | tee out/compact.csv
GC_MAJOR=1 GC_COMPACT=1 _build/default/bin/main.exe | tee out/full_compact.csv
