# Changelog

## [4.8.2](https://github.com/thnaylor/BaboViolent2/compare/v4.8.1...v4.8.2) (2026-08-02)


### Bug Fixes

* **net:** stop full server shutdown on a single client send failure ([deac677](https://github.com/thnaylor/BaboViolent2/commit/deac677f259994e24770da0f006bd9bf2e3f68c2))

## [4.8.1](https://github.com/thnaylor/BaboViolent2/compare/v4.8.0...v4.8.1) (2026-07-11)


### Bug Fixes

* **server:** stop kicking real spectators via handshake-timeout watchdog ([0feafb1](https://github.com/thnaylor/BaboViolent2/commit/0feafb12faf678dac9146e36f8196986a9499f91))

## [4.8.0](https://github.com/thnaylor/BaboViolent2/compare/v4.7.1...v4.8.0) (2026-07-11)


### Features

* **discord-bot:** make the bot multi-server via /setup ([69b9f90](https://github.com/thnaylor/BaboViolent2/commit/69b9f907952b0012540d17c625f7500b20e43688))

## [4.7.1](https://github.com/thnaylor/BaboViolent2/compare/v4.7.0...v4.7.1) (2026-07-11)


### Bug Fixes

* **master:** strip inline color codes from status endpoint names ([08baf64](https://github.com/thnaylor/BaboViolent2/commit/08baf647cfb2798d8006ea7c5249ac380fa9e234))

## [4.7.0](https://github.com/thnaylor/BaboViolent2/compare/v4.6.0...v4.7.0) (2026-07-10)


### Features

* **docker:** publish and compose the status bot image ([665e948](https://github.com/thnaylor/BaboViolent2/commit/665e948c41e892448a857e0f8073761fe4d1ff3f))

## [4.6.0](https://github.com/thnaylor/BaboViolent2/compare/v4.5.8...v4.6.0) (2026-07-10)


### Features

* add Discord status bot ([086803a](https://github.com/thnaylor/BaboViolent2/commit/086803ae34a845c747b377e036f0e18af68c6d85))
* **master:** add JSON status endpoint for external tooling ([92a8e5c](https://github.com/thnaylor/BaboViolent2/commit/92a8e5cf75aca2011f51442ac7ec9ca2539a9ad2))

## [4.5.8](https://github.com/thnaylor/BaboViolent2/compare/v4.5.7...v4.5.8) (2026-07-10)


### Bug Fixes

* **ctf:** stop flag-event feed forcing player names to team color ([8136bbf](https://github.com/thnaylor/BaboViolent2/commit/8136bbf16e710247d959249d195caf2afaec119b))
* **master:** remove hardcoded ban-list password ([d19b0cd](https://github.com/thnaylor/BaboViolent2/commit/d19b0cd858c296c8a26de8ea45b62872a107d07a))

## [4.5.7](https://github.com/thnaylor/BaboViolent2/compare/v4.5.6...v4.5.7) (2026-07-10)


### Bug Fixes

* **server:** reap connections stuck in PLAYER_STATUS_LOADING ([9d9cd73](https://github.com/thnaylor/BaboViolent2/commit/9d9cd7388055841aeda524b386d127018b4fbc3c))

## [4.5.6](https://github.com/thnaylor/BaboViolent2/compare/v4.5.5...v4.5.6) (2026-07-09)


### Bug Fixes

* **scoreboard:** stop TDM/CTF scoreboard forcing player names to team color ([dbc3a80](https://github.com/thnaylor/BaboViolent2/commit/dbc3a80a0da9e2fb6d78393f712f4b68730ef957))

## [4.5.5](https://github.com/thnaylor/BaboViolent2/compare/v4.5.4...v4.5.5) (2026-07-08)


### Bug Fixes

* **config:** fix eof-loop bug that blanked whatever setting was last in the file ([72bf36d](https://github.com/thnaylor/BaboViolent2/commit/72bf36dcfd5609409c397f4b72c169079b5379f4))

## [4.5.4](https://github.com/thnaylor/BaboViolent2/compare/v4.5.3...v4.5.4) (2026-07-08)


### Bug Fixes

* **config:** fix static-init-order bug that emptied bv2.cfg on MinGW builds ([9e8d269](https://github.com/thnaylor/BaboViolent2/commit/9e8d2696ac8c7f55493eabe04a02295d8ca8c9a2))

## [4.5.3](https://github.com/thnaylor/BaboViolent2/compare/v4.5.2...v4.5.3) (2026-07-08)


### Bug Fixes

* **config:** trigger release for a184d69 ([d7dacf2](https://github.com/thnaylor/BaboViolent2/commit/d7dacf2766c321c7facfc927b32c8815ead802f1))

## [4.5.2](https://github.com/thnaylor/BaboViolent2/compare/v4.5.1...v4.5.2) (2026-07-08)


### Bug Fixes

* **config:** stop player name and other string settings reverting on restart ([ee4214a](https://github.com/thnaylor/BaboViolent2/commit/ee4214a95d4a46bc45797882456e4f935122461b))

## [4.5.1](https://github.com/thnaylor/BaboViolent2/compare/v4.5.0...v4.5.1) (2026-07-08)


### Bug Fixes

* **docker:** mount master data volume at /app/data so image updates take effect ([3eb8079](https://github.com/thnaylor/BaboViolent2/commit/3eb80796b8effd998c20a97c638c7b24732304fd))
* **master:** repair public-IP auto-detect and log IP listing decisions ([660821d](https://github.com/thnaylor/BaboViolent2/commit/660821d0cb29670390b26bff02743bdc9486956a))

## [4.5.0](https://github.com/thnaylor/BaboViolent2/compare/v4.4.1...v4.5.0) (2026-07-08)


### Features

* **master:** MASTER_HOST/MASTER_PORT env override for self-hosted masters ([98a12ba](https://github.com/thnaylor/BaboViolent2/commit/98a12ba98ace8a9becfa73923008f173bdbd46df))

## [4.4.1](https://github.com/thnaylor/BaboViolent2/compare/v4.4.0...v4.4.1) (2026-07-07)


### Bug Fixes

* **docker:** drop build: section from master service, image-only ([901160e](https://github.com/thnaylor/BaboViolent2/commit/901160e34a6b73388e04a3ec54b41703f2e6acff))
* **master:** honor SV_IP override on all platforms, not just Linux ([8e732df](https://github.com/thnaylor/BaboViolent2/commit/8e732df0a570389f5c9ce0e87e5b283c6ba51780))
* **master:** restore public-peer auto-detection; harden container IP detect ([da72364](https://github.com/thnaylor/BaboViolent2/commit/da72364c7d9d0846839429ff8854771c8de1776f))

## [4.4.0](https://github.com/thnaylor/BaboViolent2/compare/v4.3.4...v4.4.0) (2026-07-07)


### Features

* **docker:** publish a prebuilt master server image to ghcr.io ([648c56c](https://github.com/thnaylor/BaboViolent2/commit/648c56ca32fced4ae018eb1db40b339869befdae))

## [4.3.4](https://github.com/thnaylor/BaboViolent2/compare/v4.3.3...v4.3.4) (2026-07-07)


### Bug Fixes

* **master:** dedicated servers announce their real IP, not the Docker peer address ([12ec0e6](https://github.com/thnaylor/BaboViolent2/commit/12ec0e61fa1cbdd555b2e57b2943d47122c39b51))

## [4.3.3](https://github.com/thnaylor/BaboViolent2/compare/v4.3.2...v4.3.3) (2026-07-07)


### Bug Fixes

* **master:** dedicated server now uses the hostfrog/soh.re fallback list ([ab15cb0](https://github.com/thnaylor/BaboViolent2/commit/ab15cb0e21e833811b11a78a472070a33a5f6131))

## [4.3.2](https://github.com/thnaylor/BaboViolent2/compare/v4.3.1...v4.3.2) (2026-07-07)


### Bug Fixes

* **net:** correctly reassemble TCP key/header split across multiple recv() calls ([340a66f](https://github.com/thnaylor/BaboViolent2/commit/340a66f266989b7567ac97e2d59164a5540055d9))
* **perf:** stop the frame-delta cap from halving game speed ([db7659f](https://github.com/thnaylor/BaboViolent2/commit/db7659fd436ab9e82b054fd603aa48f5c9a7bac2))
* **ui:** enlarge resolution list box so all entries fit ([d5fd613](https://github.com/thnaylor/BaboViolent2/commit/d5fd613e068591cfeff92258ef0e10fa04874577))

## [4.3.1](https://github.com/thnaylor/BaboViolent2/compare/v4.3.0...v4.3.1) (2026-07-07)


### Bug Fixes

* **net:** reduce master timeout, fix blocking send, add master Dockerfile ([1ce6b3f](https://github.com/thnaylor/BaboViolent2/commit/1ce6b3f83d4452f69fd09c566f05f71dfa5e1987))

## [4.3.0](https://github.com/thnaylor/BaboViolent2/compare/v4.2.0...v4.3.0) (2026-07-06)


### Features

* **master:** add babo.hostfrog.co.za as fallback master server ([7d8c5e0](https://github.com/thnaylor/BaboViolent2/commit/7d8c5e04a6e96f3d9faf6fd1b0f82fddd76d00b7))

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
