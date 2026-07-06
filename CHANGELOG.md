# Changelog

## [4.2.0](https://github.com/thnaylor/BaboViolent2/compare/v4.1.0...v4.2.0) (2026-07-06)


### Features

* **master:** multi-master fallback support ([c47127a](https://github.com/thnaylor/BaboViolent2/commit/c47127aee628ed829f9cc5f8400dd38313ff4184))

## [4.1.0](https://github.com/thnaylor/BaboViolent2/compare/v4.0.1...v4.1.0) (2026-06-11)


### Features

* **docker:** multi-stage build, rename GAMETYPE_LIST to GAMETYPE_ROTATION ([4884adc](https://github.com/thnaylor/BaboViolent2/commit/4884adcd3677412e0308ba3578c9c9eef457063f))
* **server:** add sv_gametypeList gametype rotation ([6be16a2](https://github.com/thnaylor/BaboViolent2/commit/6be16a25a8565063d4271a891d2cff2bb2750541))

## [4.0.1](https://github.com/thnaylor/BaboViolent2/compare/v4.0.0...v4.0.1) (2026-06-08)


### Bug Fixes

* **net:** UINT4 wrong size on 64-bit Linux breaks ping handshake ([474c579](https://github.com/thnaylor/BaboViolent2/commit/474c579de2a9784f546add033d511a91c4c455d7))
* **packaging:** Windows CI release now uses flat layout matching package-windows.ps1 ([c09a375](https://github.com/thnaylor/BaboViolent2/commit/c09a375d278cb503014e4fb1846efadfdacff572))

## [4.0.0](https://github.com/thnaylor/BaboViolent2/compare/v3.1.1...v4.0.0) (2026-06-06)


### ⚠ BREAKING CHANGES

* Cross compile releases

### Features

* add distro server CI/releases and babo.soh.re launch scripts ([b5200ed](https://github.com/thnaylor/BaboViolent2/commit/b5200ed1b4f90ee9dc65b455ab6debd982f55e2d))
* add Dockerfile and .dockerignore for containerised dedicated server ([643e559](https://github.com/thnaylor/BaboViolent2/commit/643e55993e22020cb00f340dc657cea4fa45693a))
* auto-detect screen resolution, expand resolution list ([043833f](https://github.com/thnaylor/BaboViolent2/commit/043833fb041c877ef3ce9c0f89e0a80ee80425da))
* Cross compile releases ([4105a00](https://github.com/thnaylor/BaboViolent2/commit/4105a001c620966e86cfa17f28c62d4a5d2b03af))
* **docker:** professional dedicated server image with full env var configuration ([d9a4247](https://github.com/thnaylor/BaboViolent2/commit/d9a424768d932de8073e4866b84469835d786df8))
* publish dedicated server Docker image to ghcr.io ([e9b6f5f](https://github.com/thnaylor/BaboViolent2/commit/e9b6f5fe961d6a07fe01f4dd9b1190bbefc22eca))
* **windows:** add package-windows.ps1 release packager ([2d2e14f](https://github.com/thnaylor/BaboViolent2/commit/2d2e14fbaa46bbbf5843a5e4558a1eac276a0dc1))
* **windows:** add sound and OGG music support ([2477f21](https://github.com/thnaylor/BaboViolent2/commit/2477f214a9d01253a34d69f6514375333e4de1ea))
* **windows:** fix Windows build with MSVC 2022 ([a9b12d1](https://github.com/thnaylor/BaboViolent2/commit/a9b12d197bd194378bcba260fe5be1916555c4f7))


### Bug Fixes

* **build:** link libdl and pthread on Linux client/dedicated targets ([15396a2](https://github.com/thnaylor/BaboViolent2/commit/15396a2e63453d4741a028c680699c5a2b65536f))
* **ci:** support older SDL_mixer and upgrade checkout action ([6bd994f](https://github.com/thnaylor/BaboViolent2/commit/6bd994fd64705b305706c06f1b0934621eb0a91c))
* **ci:** use bash shell in distro container jobs ([8855502](https://github.com/thnaylor/BaboViolent2/commit/8855502bf17e9a4acc459f13d47fce15e370bfd5))
* **cmake:** guard MSVC linker flags behind if(MSVC) ([0ccdc81](https://github.com/thnaylor/BaboViolent2/commit/0ccdc81d3b72341085e2b7e8725253431d5edfe5))
* **docker:** use github.repository so forks push to their own ghcr.io ([f541b9d](https://github.com/thnaylor/BaboViolent2/commit/f541b9dbb2c3579d1d28be0c415f4fc293131c12))
* **linux:** prevent dedicated server freeze and CPU saturation ([48de4b5](https://github.com/thnaylor/BaboViolent2/commit/48de4b5bd32f54debff43e8a3b897de9829ec602))
* **master:** reliable browser refresh and distro-native server builds ([1d608a6](https://github.com/thnaylor/BaboViolent2/commit/1d608a6544cbfa7fe2928ce8f7799750b291d67a))
* **release:** align dedicated version and release tag builds ([dacab05](https://github.com/thnaylor/BaboViolent2/commit/dacab05cb432b15a31c4c00e1bc6ffeab7033821))
* restore SDL submodule to clean upstream commit ([2fb9751](https://github.com/thnaylor/BaboViolent2/commit/2fb9751ff44463fd15823d2fbbfba913b08d5cf4))
* use portable std::sin/cos/sqrt in dkgl ([7362a2b](https://github.com/thnaylor/BaboViolent2/commit/7362a2b4586603a5e35510753f1942eb5ada8562))
* **windows:** double-click exe works without a wrapper .bat ([31e2960](https://github.com/thnaylor/BaboViolent2/commit/31e2960b4dc4a6f4da1af2739f52e0b098db7706))
* **windows:** flat package layout, git-tracked files only ([016ba3c](https://github.com/thnaylor/BaboViolent2/commit/016ba3cb047f5455542be18617de9b456271b01f))
* **windows:** package exe inside Content/ so it finds bv2.cfg immediately ([6e99302](https://github.com/thnaylor/BaboViolent2/commit/6e99302ba96211fd889c4e8c614159dea3ff5286))

## [3.1.1](https://github.com/Jmainguy/BaboViolent2/compare/v3.1.0...v3.1.1) (2026-06-02)


### Bug Fixes

* **master:** reliable browser refresh and distro-native server builds ([ac302e9](https://github.com/Jmainguy/BaboViolent2/commit/ac302e90d744e105e43e4fea4d59f0c84aeae48d))

## [3.1.0](https://github.com/Jmainguy/BaboViolent2/compare/v3.0.1...v3.1.0) (2026-06-01)


### Features

* add distro server CI/releases and babo.soh.re launch scripts ([e3963dc](https://github.com/Jmainguy/BaboViolent2/commit/e3963dc5e5680a95a8f46239ff9c3484de74c832))


### Bug Fixes

* **build:** link libdl and pthread on Linux client/dedicated targets ([e880722](https://github.com/Jmainguy/BaboViolent2/commit/e880722ace94d4e82f4b773512c2d16ade8d8b54))
* **ci:** use bash shell in distro container jobs ([a4d6a78](https://github.com/Jmainguy/BaboViolent2/commit/a4d6a78804a90408c9e84ed3495ed5d3f28062f5))
* **release:** align dedicated version and release tag builds ([b328a92](https://github.com/Jmainguy/BaboViolent2/commit/b328a92131179397973c18e4fe7fb3d387e276d0))

## [3.0.1](https://github.com/Jmainguy/BaboViolent2/compare/v3.0.0...v3.0.1) (2026-05-30)


### Bug Fixes

* **ci:** support older SDL_mixer and upgrade checkout action ([5770a00](https://github.com/Jmainguy/BaboViolent2/commit/5770a000c9c18f65c2ca19de520045502f6fefb2))

## [3.0.0](https://github.com/Jmainguy/BaboViolent2/compare/v2.11.0...v3.0.0) (2026-05-30)


### ⚠ BREAKING CHANGES

* Cross compile releases

### Features

* Cross compile releases ([4105a00](https://github.com/Jmainguy/BaboViolent2/commit/4105a001c620966e86cfa17f28c62d4a5d2b03af))


### Bug Fixes

* use portable std::sin/cos/sqrt in dkgl ([7362a2b](https://github.com/Jmainguy/BaboViolent2/commit/7362a2b4586603a5e35510753f1942eb5ada8562))
