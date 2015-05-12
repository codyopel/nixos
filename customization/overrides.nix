{ config, pkgs, ... }:
{
  nixpkgs.config.packageOverrides = self : rec {
    chromium = self.chromium.override {
      enableNaCl = false;
      useOpenSSL = false;
      gnomeSupport = true;
      gnomeKeyringSupport = false;
      enablePepperFlash = true;
      enableWideVine = true;
      proprietaryCodecs = true;
      cupsSupport = true;
      pulseSupport = true;
      hiDPISupport = false;
    };
    nvidia = self.nvidia_x11.override {
      gtk3Support = true;
    };
    rtorrent-git = self.rtorrent-git.override {
      colorSupport = true;
    };
    #samba = self.samba.override {
    #  libceph = null;
    #};
    x265 = self.x265.override {
      highBitDepth = true;
    };
  };
}
