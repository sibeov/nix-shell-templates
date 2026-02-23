{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  zlib,
  libxcrypt-legacy,
  python3,
  bash,
  system,
  version ? "2026-01-26",
  dateVersion ? "20260126",
}:

let
  # Source URLs and hashes per system
  sources = {
    x86_64-linux = {
      url = "https://github.com/YosysHQ/oss-cad-suite-build/releases/download/${version}/oss-cad-suite-linux-x64-${dateVersion}.tgz";
      sha256 = "sha256-jkei60pexQ52rfwWr1bD4e+nlw9LWd8gt2y6fDtQvYw=";
    };
    aarch64-linux = {
      url = "https://github.com/YosysHQ/oss-cad-suite-build/releases/download/${version}/oss-cad-suite-linux-arm64-${dateVersion}.tgz";
      sha256 = ""; # Will be filled when building on aarch64-linux
    };
    x86_64-darwin = {
      url = "https://github.com/YosysHQ/oss-cad-suite-build/releases/download/${version}/oss-cad-suite-darwin-x64-${dateVersion}.tgz";
      sha256 = ""; # Will be filled when building on x86_64-darwin
    };
    aarch64-darwin = {
      url = "https://github.com/YosysHQ/oss-cad-suite-build/releases/download/${version}/oss-cad-suite-darwin-arm64-${dateVersion}.tgz";
      sha256 = ""; # Will be filled when building on aarch64-darwin
    };
  };

  # Get source for current system
  src = fetchurl {
    inherit (sources.${system}) url sha256;
  };

in
stdenv.mkDerivation {
  pname = "oss-cad-suite";
  inherit version src;

  nativeBuildInputs = [
    autoPatchelfHook
  ]
  ++ lib.optionals stdenv.isLinux [
    # Additional build inputs for Linux
  ];

  buildInputs = [
    stdenv.cc.cc.lib
    zlib
  ]
  ++ lib.optionals stdenv.isLinux [
    # Linux-specific runtime dependencies
    libxcrypt-legacy
  ];

  dontBuild = true;
  dontConfigure = true;

  unpackPhase = ''
    runHook preUnpack
    mkdir -p $out
    tar -xzf $src -C $out --strip-components=1
    runHook postUnpack
  '';

  installPhase = ''
        runHook preInstall

        # The suite is already extracted to $out
        # Fix shebangs for scripts
        find $out -type f -executable -exec \
          sed -i "1s|^#!/.*python.*|#!${python3}/bin/python3|" {} \; 2>/dev/null || true

        # Create a wrapper script for environment setup
        mkdir -p $out/bin-wrapped
        for binary in $out/bin/*; do
          if [ -f "$binary" ] && [ -x "$binary" ]; then
            binary_name=$(basename "$binary")
            cat > "$out/bin-wrapped/$binary_name" <<EOF
    #!${bash}/bin/bash
    export OSS_CAD_SUITE_ROOT="$out"
    exec "$out/bin/$binary_name" "\$@"
    EOF
            chmod +x "$out/bin-wrapped/$binary_name"
          fi
        done

        runHook postInstall
  '';

  meta = with lib; {
    description = "Open source FPGA toolchain including Yosys, nextpnr, icestorm, and more";
    homepage = "https://github.com/YosysHQ/oss-cad-suite-build";
    license = with licenses; [
      isc
      mit
    ];
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
      "x86_64-darwin"
      "aarch64-darwin"
    ];
    maintainers = [ ];
  };
}
