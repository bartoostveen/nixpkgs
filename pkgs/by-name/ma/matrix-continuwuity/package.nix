{
  lib,
  rustPlatform,
  fetchFromGitea,
  pkg-config,
  bzip2,
  zstd,
  stdenv,
  callPackage,
  nix-update-script,
  testers,
  matrix-continuwuity,
  rust-jemalloc-sys-unprefixed,
  liburing,
  nixosTests,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "matrix-continuwuity";
  version = "26.9.4-unstable-2026-11-14";

  src = fetchFromGitea {
    domain = "forgejo.ellis.link";
    owner = "continuwuation";
    repo = "continuwuity";
    rev = "c5cd82a6a3c004b9651dc3e86eef30e172053119";
    hash = "sha256-gcGBWk6okgi+I/r+28sF/bwQIpX11drj7keXK1OSoow=";
  };

  cargoHash = "sha256-t9gYT8LT2xjTWjARvBZqtU2kTN152an6sInl3q2yFx4=";

  nativeBuildInputs = [
    pkg-config
    rustPlatform.bindgenHook
  ];

  buildInputs = [
    bzip2
    zstd
    rust-jemalloc-sys-unprefixed
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    liburing
  ];

  env = {
    ZSTD_SYS_USE_PKG_CONFIG = true;
    ROCKSDB_INCLUDE_DIR = "${finalAttrs.rocksdb}/include";
    ROCKSDB_LIB_DIR = "${finalAttrs.rocksdb}/lib";
  };

  rocksdb = callPackage ./rocksdb.nix { }; # make used rocksdb version available (e.g., for backup scripts)

  passthru = {
    updateScript = nix-update-script { };
    tests = {
      version = testers.testVersion {
        inherit (finalAttrs) version;
        package = matrix-continuwuity;
      };
    }
    // lib.optionalAttrs stdenv.hostPlatform.isLinux {
      inherit (nixosTests) matrix-continuwuity;
    };
  };

  meta = {
    description = "Matrix homeserver written in Rust, forked from conduwuit";
    homepage = "https://continuwuity.org/";
    changelog = "https://forgejo.ellis.link/continuwuation/continuwuity/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [
      bartoostveen
      nyabinary
      snaki
      logn
    ];
    # Not a typo, continuwuity is a drop-in replacement for conduwuit.
    mainProgram = "conduwuit";
  };
})
