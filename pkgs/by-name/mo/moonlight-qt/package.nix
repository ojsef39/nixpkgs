{
  stdenv,
  lib,
  fetchFromGitHub,
  qt6,
  pkg-config,
  vulkan-headers,
  SDL2,
  SDL2_ttf,
  ffmpeg,
  libopus,
  libplacebo,
  openssl,
  alsa-lib,
  libpulseaudio,
  libva,
  libvdpau,
  libxkbcommon,
  wayland,
  libdrm,
  apple-sdk_15 ? null,
  nix-update-script,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "moonlight-qt";
  version = "6.1.0-unstable-2026-04-10";

  src = fetchFromGitHub {
    owner = "moonlight-stream";
    repo = "moonlight-qt";
    rev = "af03f57e08a2c183ecd09b93f3a59964d473ffe6";
    hash = "sha256-CVtYb9TyRaSYmoO5+2YXSGv6KdntTsaYnz7RrOcwyKE=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    qt6.qmake
    qt6.wrapQtAppsHook
    pkg-config
    vulkan-headers
  ];

  buildInputs = [
    SDL2
    SDL2_ttf
    ffmpeg
    libopus
    libplacebo
    qt6.qtdeclarative
    qt6.qtsvg
    openssl
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    alsa-lib
    libpulseaudio
    libva
    libvdpau
    libxkbcommon
    qt6.qtwayland
    wayland
    libdrm
  ]
  ++ lib.optionals (stdenv.hostPlatform.isDarwin && apple-sdk_15 != null) [
    apple-sdk_15
  ];

  qmakeFlags = [ "CONFIG+=disable-prebuilts" ];

  postInstall = lib.optionalString stdenv.hostPlatform.isDarwin ''
    mkdir $out/Applications $out/bin
    mv app/Moonlight.app $out/Applications
    ln -s $out/Applications/Moonlight.app/Contents/MacOS/Moonlight $out/bin/moonlight
  '';

  # nix-update moonlight-qt --version branch=master --build --commit
  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version"
      "branch=master"
    ];
  };

  meta = {
    changelog = "https://github.com/moonlight-stream/moonlight-qt/commits/master";
    description = "Play your PC games on almost any device";
    homepage = "https://moonlight-stream.org";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [
      azuwis
      zmitchell
    ];
    platforms = lib.platforms.all;
    mainProgram = "moonlight";
  };
})
