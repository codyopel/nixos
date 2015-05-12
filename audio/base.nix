{ lib, pkgs, ... }:

with lib;

{
  environment.systemPackages = with pkgs; [
    beets
    mpd
    ncmpcpp
  ];

  hardware.pulseaudio.enable = mkDefault false;

  sound.enable = mkDefault false;
}
