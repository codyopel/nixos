{ pkgs, lib, ... }:
with lib;
{
  # Undo minimalistic settings
  fonts.fontconfig.enable = true;
  hardware.pulseaudio.enable = true;
  security.pam.services.su.forwardXAuth = true;
  sound.enable = true;
  environment.systemPackages = [ pkgs.slock ];
  harware.opengl = {
    enable = true;
    dirsupport = true;
    dirSupport32Bit = true;
  };
  services = {
    kmscon.hwRender = true;
    pcscd.enable = true;
    xserver = {
      enable = true;
      windowManager.default = "none";
      desktopManager.default = "none";
      displayManager.lightdm.enable = true;
    };
    synaptics = {
      enable = true;
      tapButtons = false;
      twoFingerScroll = true;
      additionalOptions = ''
        Option "RTCornerButton" "2"
      '';
    };
  };
  security.setuidPrograms = [ "slock" ];
}
