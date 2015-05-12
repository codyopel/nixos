{ lib, ... }:
with lib;
let
  constants = (import ./constants.nix { inherit lib; });
in {
  boot.kernel.sysctl = {
    "net.ipv4.conf.all.forwarding" = true;
    "net.ipv4.conf.default.forwarding" = true;
    "net.ipv6.conf.all.forwarding" = true;
    "net.ipv6.conf.default.forwarding" = true;
  };
  networking.firewall = {
    enable = true;
    rejectPackets = true;
    allowPing = true;
    logRefusedConnections = false;
    extraCommands = mkMerge [
      (mkOrder 1 ''
        # Default Policy
        ip46tables -P INPUT DROP
        ip46tables -P FORWARD DROP
        ip46tables -P OUTPUT DROP

        # Flush Old Rules
        ip46tables -F INPUT
        ip46tables -F OUTPUT
        ip46tables -F FORWARD
        ip46tables -t nat -F
        ip46tables -t nat -X
        ip46tables -t mangle -F
        ip46tables -t mangle -X

        # Remove old ipsets
        ipset destroy || true

        # Create an ipset for private ip4 addresses
        ipset create private hash:net family inet
        ${flip concatMapStrings constants.privateIp4 (i: ''
          ipset add private "${i}"
        '')}
        ipset create private6 hash:net family inet6
        ${flip concatMapStrings constants.privateIp6 (i: ''
          ipset add private6 "${i}"
        '')}

        # Allow Established Connnections
        ip46tables -A FORWARD -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
        ip46tables -A OUTPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

        # Allow root to make local connections
        ip46tables -A OUTPUT -m owner --uid-owner root -j ACCEPT

        # Allow ping
        iptables -A OUTPUT -p icmp --icmp-type echo-request -j ACCEPT
        ip6tables -A OUTPUT -p icmpv6 --icmpv6-type echo-request -j ACCEPT

        # Allow ssh
        ip46tables -A OUTPUT -p tcp --dport 22 -j ACCEPT
      '')
      (mkAfter ''
        # Allow everything to make external connections
        ip46tables -A OUTPUT -o lo -j REJECT
        iptables -A OUTPUT -m set --match-set private dst -j REJECT
        ip6tables -A OUTPUT -m set --match-set private6 dst -j REJECT
        ip46tables -A OUTPUT -j ACCEPT

        ip46tables -A FORWARD -j REJECT
      '')
    ];
    extraStopCommands = mkAfter ''
      # Flush Old Rules
      ip46tables -F INPUT || true
      ip46tables -F OUTPUT || true
      ip46tables -F FORWARD || true
      ip46tables -t nat -F || true
      ip46tables -t nat -X || true
      ip46tables -t mangle -F || true
      ip46tables -t mangle -X || true

      # Undo Default Policy
      ip46tables -P INPUT ACCEPT || true
      ip46tables -P FORWARD ACCEPT || true
      ip46tables -P OUTPUT ACCEPT || true

      # Remove old ipsets
      ipset destroy || true
    '';
  };
}
