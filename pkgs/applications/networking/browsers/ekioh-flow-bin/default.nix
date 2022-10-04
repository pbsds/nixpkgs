{ lib
, pkgs
, fetchzip
, stdenv
}:

stdenv.mkDerivation rec{
  pname = "flow";
  version = "6.5.0-20221004_r37742";

  src = fetchzip {
    url = "https://support.ekioh.com/download/binaries/ekioh_6.5.0_raspberry-pi64-flow_20221004_r37742.zip";
    hash = "sha256-YJlhOWEeZAzVGZAgC1AJEYZoFn0xWjpi3wKp5pUklTs=";
  };

  libPath = with pkgs; lib.makeLibraryPath [
    freetype
    mesa
    pango #libpangocairo-1.0 #libpango-1.0
    cairo #libcairo
    glib #libgio-2.0
    #glibc
    gtk3 #libgtk-3
    harfbuzz #libharfbuzz
    atk #libatk-1.0
    gdk-pixbuf #libgdk_pixbuf-2.0
    #libGLU
    libGL #libEGL
    xorg.libX11 #libX11
    fontconfig #libfontconfig
    gst_all_1.gst-plugins-base #libgstvideo-1.0
    gst_all_1.gstreamer #libgstbase-1.0
    stdenv.cc.cc #libstdc++

    #gst_all_1.gst-libav

    #libgstreamer-1.0
    #librt
    #libdl
    #libgdk-3
    #libcairo-gobject
    #libgobject-2.0
    #libglib-2.0
    #libGLESv2
    #libm
    #libgcc_s
    #libpthread
    #libc
    #libya
  ] + ":" + lib.makeSearchPathOutput "lib" "lib64" [
    #stdenv.cc.cc
    #mesa.drivers
  ];

  # "strip" after "patchelf" may break binaries.
  # See: https://github.com/NixOS/patchelf/issues/10
  dontStrip = true;
  dontPatchELF = true;

  #inherit (pkgs) gtk3;
  #buildInputs = with pkgs; [ wrapGAppsHook gtk3 ];



  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/doc
    cp EULA.html $out/share/doc/

    mkdir -p $out/bin
    cp flow $out/bin/

    mkdir -p $out/lib/ekio-flow-bin
    #cp *.dat $out/lib/ekio-flow-bin/
    cp *.dat $out/bin/

    patchelf $out/bin/flow \
      --interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
      --set-rpath "$libPath"

    runHook postInstall
  '';

  meta = with lib; {
    description = "Flow web browser, with multithreaded page layouts, drawn directly on the GPU";
    homepage = "https://www.ekioh.com/flow-browser/";
    license = licenses.unfree;
    platforms = [ "aarch64-linux" ];
    maintainers = with maintainers; [ pbsds ];
  };
}
