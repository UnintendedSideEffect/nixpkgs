{ stdenv, lib, fetchurl, rpmextract, autoPatchelfHook, wrapGAppsHook

# Dynamic libraries
, alsaLib, atk, at-spi2-atk, at-spi2-core, cairo, dbus, cups, expat
, gdk-pixbuf, glib, gtk3, libX11, libXScrnSaver, libXcomposite, libXcursor
, libXdamage, libXext, libXfixes, libXi, libXrandr, libXrender, libXtst
, libxcb, libuuid, nspr, nss, pango

, systemd
}:

stdenv.mkDerivation rec {
  pname = "drawio";
  version = "13.5.7";

  src = fetchurl {
    url = "https://github.com/jgraph/drawio-desktop/releases/download/v${version}/draw.io-x86_64-${version}.rpm";
    sha256 = "1b2sb44zsa6g5nnsa7drn4fn61jfz3a3g3bisai85fyjff746ipc";
  };

  nativeBuildInputs = [
    autoPatchelfHook
    rpmextract
    wrapGAppsHook
  ];

  buildInputs = [
    alsaLib
    atk
    at-spi2-atk
    at-spi2-core
    cairo
    cups
    dbus
    expat
    gdk-pixbuf
    glib
    gtk3
    libX11
    libXScrnSaver
    libXcomposite
    libXcursor
    libXdamage
    libXext
    libXfixes
    libXi
    libXrandr
    libXrender
    libXtst
    libxcb
    libuuid
    nspr
    nss
    pango
    systemd
  ];

  runtimeDependencies = [
    systemd.lib
  ];

  dontBuild = true;
  dontConfigure = true;

  unpackPhase = "rpmextract ${src}";

  installPhase = ''
    mkdir -p $out/share
    cp -r opt/draw.io $out/share/

    # Application icon
    mkdir -p $out/share/icons/hicolor
    cp -r usr/share/icons/hicolor/* $out/share/icons/hicolor/

    # XDG desktop item
    cp -r usr/share/applications $out/share/applications

    # Symlink wrapper
    mkdir -p $out/bin
    ln -s $out/share/draw.io/drawio $out/bin/drawio

    # Update binary path
    substituteInPlace $out/share/applications/drawio.desktop \
      --replace /opt/draw.io/drawio $out/bin/drawio
  '';

  meta = with stdenv.lib; {
    description = "A desktop application for creating diagrams";
    homepage = "https://about.draw.io/";
    license = licenses.asl20;
    changelog = "https://github.com/jgraph/drawio-desktop/releases/tag/v${version}";
    maintainers = with maintainers; [ danieldk ];
    platforms = [ "x86_64-linux" ];
  };
}
