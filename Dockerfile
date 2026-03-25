FROM ubuntu:16.04
RUN apt-get update && apt-get install -qq build-essential mingw-w64 zip curl ca-certificates --no-install-recommends \
 && tmpdir=$(mktemp -d) \
 && if ! curl -L -o $tmpdir/lua-5.5.0.tar.gz https://www.lua.org/ftp/lua-5.5.0.tar.gz; then \
      curl -L -o $tmpdir/lua-5.5.0.tar.gz https://github.com/Mhatxotic/Lua/archive/refs/tags/5.5.tar.gz; \
    fi \
 && tar xzf $tmpdir/lua-5.5.0.tar.gz -C $tmpdir \
 && srcdir=$(find $tmpdir -path '*/src/lua.h' -printf '%h\n' -quit) \
 && gcc -I$srcdir -Os -fPIC -shared -Wl,-soname,liblua.so -o /usr/local/lib/liblua.so \
    $(find $srcdir -maxdepth 1 -name '*.c' ! -name 'lua.c' ! -name 'luac.c' | sort) \
    -lm -ldl \
 && ldconfig \
 && rm -rf /var/lib/apt/lists/* $tmpdir
