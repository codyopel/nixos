{ config, lib, pkgs, ... }:
with lib;
{
  imports = [
    ./base/firewall.nix
    ./base/dnsmasq.nix
    ./base/networking.nix
    ./base/ntpd.nix
  ];
  boot.kernel.sysctl = {
      "net.ipv6.conf.all.use_tempaddr" = 2;
      "net.ipv6.conf.default.use_tempaddr" = 2;
  };
  networking.domain = calculated.myDomain;
}
