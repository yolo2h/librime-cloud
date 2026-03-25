CC = gcc
CC_mingw = i686-w64-mingw32-gcc
CC_mingw64 = x86_64-w64-mingw32-gcc

LUAV ?= 5.5
LUAINC = thirdparty/lua${LUAV}
LUAHEADERS = lauxlib.h lua.h lua.hpp luaconf.h lualib.h
LUAARCHIVE = lua-${LUAV}.0.tar.gz
LUAURL = https://www.lua.org/ftp/${LUAARCHIVE}
LUAMIRROR = https://github.com/Mhatxotic/Lua/archive/refs/tags/${LUAV}.tar.gz
LUASRC = thirdparty/lua-src-${LUAV}
LUA_SO = liblua${LUAV}.so
LUALIB = -Llibrime-lua${LUAV}/dist/lib -lrime
LUALIB64 = -Llibrime-lua${LUAV}-x64/dist/lib -lrime

CURLV ?= 8.11.1
CURLINC = curl-${CURLV}/include
CURLLIB = -Lcurl-${CURLV}/build32/lib/.libs -lcurl -lws2_32 -lcrypt32 -lbcrypt
CURLLIB64 = -Lcurl-${CURLV}/build64/lib/.libs -lcurl -lws2_32 -lcrypt32 -lbcrypt

RIMEV ?= 1.16.1
RIMEASSET ?= de4700e

PLAT ?= linux
LDFLAGS_linux = -Wl,--gc-sections -Wl,-s
LDFLAGS_macos = -Wl,-bundle -Wl,-undefined,dynamic_lookup
LDFLAGS = ${LDFLAGS_${PLAT}}
LUADEP_linux = ${LUA_SO}
LUADEP_macos =
LUADEP = ${LUADEP_${PLAT}}
LUALINK_linux = -Wl,-rpath,'$$ORIGIN' -L. -l:${LUA_SO}
LUALINK_macos =
LUALINK = ${LUALINK_${PLAT}}

all: simplehttp.so simplehttp.dll simplehttpx64.dll

librime-lua${LUAV}:
	curl -L -O https://github.com/rime/librime/releases/download/${RIMEV}/rime-${RIMEASSET}-Windows-msvc-x86.7z
	7z x -olibrime-lua${LUAV} rime-${RIMEASSET}-Windows-msvc-x86.7z

librime-lua${LUAV}-x64:
	curl -L -O https://github.com/rime/librime/releases/download/${RIMEV}/rime-${RIMEASSET}-Windows-msvc-x64.7z
	7z x -olibrime-lua${LUAV}-x64 rime-${RIMEASSET}-Windows-msvc-x64.7z

${LUASRC}/src/lua.h:
	tmpdir=$$(mktemp -d) && \
	if ! curl -L -o $$tmpdir/${LUAARCHIVE} ${LUAURL}; then \
		curl -L -o $$tmpdir/${LUAARCHIVE} ${LUAMIRROR}; \
	fi && \
	tar xzf $$tmpdir/${LUAARCHIVE} -C $$tmpdir && \
	srcdir=$$(find $$tmpdir -path '*/src/lua.h' -printf '%h\n' -quit) && \
	rm -rf ${LUASRC} && \
	mkdir -p $$(dirname ${LUASRC}) && \
	cp -a $$(dirname $$srcdir) ${LUASRC}

${LUAINC}/lua.h: ${LUASRC}/src/lua.h
	srcdir=${LUASRC}/src && \
	mkdir -p ${LUAINC} && \
	for f in ${LUAHEADERS}; do \
		cp $$srcdir/$$f ${LUAINC}/$$f; \
	done

curl-${CURLV}:
	curl -L -O https://curl.se/download/curl-${CURLV}.tar.gz
	tar xvf curl-${CURLV}.tar.gz

prepare: librime-lua${LUAV} librime-lua${LUAV}-x64 ${LUAINC}/lua.h curl-${CURLV}

curl-${CURLV}/build32/lib/.libs:
	cd curl-${CURLV} && sh ../tinycurl.sh

curl-${CURLV}/build64/lib/.libs:
	cd curl-${CURLV} && sh ../tinycurlx64.sh

${LUA_SO}: ${LUASRC}/src/lua.h
	${CC} -I${LUASRC}/src -Os -fPIC -shared ${LDFLAGS_linux} -Wl,-soname,${LUA_SO} -o $@ \
		$$(find ${LUASRC}/src -maxdepth 1 -name '*.c' ! -name 'lua.c' ! -name 'luac.c' | sort) \
		-lm -ldl

simplehttp.so: main.c ${LUAINC}/lua.h curl-${CURLV} ${LUADEP}
	${CC} -I${LUAINC} -I${CURLINC} -Os -fPIC -shared ${LDFLAGS} -o $@ $< ${LUALINK}

simplehttp.dll: main.c librime-lua${LUAV} ${LUAINC}/lua.h curl-${CURLV}/build32/lib/.libs
	${CC_mingw} -I${LUAINC} -I${CURLINC} -Os -shared -o $@ $< -Wl,--gc-sections -Wl,-s -static-libgcc ${LUALIB} ${CURLLIB}

simplehttpx64.dll: main.c librime-lua${LUAV}-x64 ${LUAINC}/lua.h curl-${CURLV}/build64/lib/.libs
	${CC_mingw64} -I${LUAINC} -I${CURLINC} -Os -shared -o $@ $< -Wl,--gc-sections -Wl,-s -static-libgcc ${LUALIB64} ${CURLLIB64}

clean:
	rm -f simplehttp.so simplehttp.dll simplehttpx64.dll ${LUA_SO}
