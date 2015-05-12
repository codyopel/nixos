{ config, pkgs, ... }:
{
  boot = {
    initrd.kernelModules = [ "fbcon" ];
    loader = {
      efi.canTouchEfiVariables = true;
      grub.enable = false;
      gummiboot = {
        enable = true;
        timeout = 3;
      };
    };
  };
}
