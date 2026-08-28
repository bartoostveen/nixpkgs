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
  version = "26.8.1-unstable-2026-09-16";

  src = fetchFromGitea {
    domain = "forgejo.ellis.link";
    owner = "continuwuation";
    repo = "continuwuity";
    rev = "ffcf152016c2d73af0e3218dbe34c4352c69fa33";
    hash = "sha256-4BKZEp8T2XKtLNjqkT74rFNoVsejWCEXvnaUrExU6Yw=";
  };

  cargoHash = "sha256-oa2U3UXfm8WLqrcMl+oyTS1hxx14xYw8sQ1GCNNG6Oc=";

  nativeBuildInputs = [
    pkg-config
    rustPlatform.bindgenHook
  ];

  buildInputs = [
    bzip2
    zstd
    rust-jemalloc-sys-unprefixed
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
    ];
    # Not a typo, continuwuity is a drop-in replacement for conduwuit.
    mainProgram = "conduwuit";
  };
})
