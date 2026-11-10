{
  stdenv,
  fetchFromGitea,
  rocksdb,
  rust-jemalloc-sys-unprefixed,
}:

(rocksdb.override {
  # rocksdb does not support prefixed jemalloc, which is required on darwin
  enableJemalloc = !stdenv.hostPlatform.isDarwin;
  jemalloc = rust-jemalloc-sys-unprefixed;
}).overrideAttrs
  (
    final: old: {
      version = "11.12";
      src = fetchFromGitea {
        domain = "forgejo.ellis.link";
        owner = "continuwuation";
        repo = "rocksdb";
        rev = "722fa3219df4169610fda8962221a1ff74026fdb";
        hash = "sha256-ZuXXp83Hgj0B5v499CNxa9oNQUS/ZKYOAZEhmarUifc=";
      };

      patches = [ ];
    }
  )
