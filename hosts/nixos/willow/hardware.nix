# DRAFT: replace this entire file with Willow's generated hardware config.
# After mounting the intended root at /mnt and ESP at /mnt/boot:
#   nixos-generate-config --root /mnt --show-hardware-config > hardware.nix
# Review root/ESP UUIDs, swap and any encryption settings before installing.
{
  assertions = [
    {
      assertion = false;
      message = "Willow is a draft: replace hosts/nixos/willow/hardware.nix with hardware configuration generated on the Deck before building/installing.";
    }
  ];
}
