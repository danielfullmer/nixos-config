{ config, lib, pkgs, ... }:

# See https://github.com/nakato/nixos-bpir3-example for reference, and for uboot firmware
let
  kernelPatches = [
#    {
    # The arm64 defconfig now sets CONFIG_HSR=m by default, but we want to
    # disable HSR below since it forces us to have CONFIG_DSA=m as well (and
    # therefore others). Apparently using structuredExtraConfig doesn't
    # properly override settings in defconfig... ?
    { patch = ./disable-hsr-defconfig.patch; }
  ];

  linux_bpir3 = pkgs.linux_6_15.override {
    inherit kernelPatches;

    #autoModules = false;

    ignoreConfigErrors = true;

    # This will take ~22GB to build.  /tmp better be big.
    structuredExtraConfig = with lib.kernel; {
      # Disable extremely unlikely features to reduce build time and storage requirements
      # DRM takes a substantual amount of storage during build
      DRM = lib.mkForce no;
      SOUND = lib.mkForce no;
      # Where would you attach an IB interface?
      INFINIBAND = lib.mkForce no;

      # Build-in BPiR3 support, many misbehave when compiled as modules.
      # Known problematic drivers are MT7530/DSA and PCIe.

      # PCIe
      PCIE_MEDIATEK = yes;
      PCIE_MEDIATEK_GEN3 = yes;
      # SD/eMMC
      MTD_NAND_ECC_MEDIATEK = yes;
      # Net
      BRIDGE = yes;
      HSR = no;
      NET_DSA = yes;
      NET_DSA_TAG_MTK = yes;
      NET_DSA_MT7530 = yes;
      NET_VENDOR_MEDIATEK = yes;
      PCS_MTK_LYNXI = yes;
      NET_MEDIATEK_SOC_WED = yes;
      NET_MEDIATEK_SOC = yes;
      NET_MEDIATEK_STAR_EMAC = yes;
      MEDIATEK_GE_PHY = yes;
      # WLAN
      WLAN = yes;
      WLAN_VENDOR_MEDIATEK = yes;
      MT76_CORE  = module;
      MT76_LEDS = yes;
      MT76_CONNAC_LIB = module;
      MT7915E = module;
      MT798X_WMAC = yes;
      # Pinctrl
      EINT_MTK = yes;
      PINCTRL_MTK = yes;
      PINCTRL_MT7986 = yes;
      # Thermal
      MTK_THERMAL = yes;
      MTK_SOC_THERMAL = yes;
      MTK_LVTS_THERMAL = yes;
      # Clk
      COMMON_CLK_MEDIATEK = yes;
      COMMON_CLK_MEDIATEK_FHCTL = yes;
      COMMON_CLK_MT7986 = yes;
      COMMON_CLK_MT7986_ETHSYS = yes;
      # other
      MEDIATEK_WATCHDOG = yes;
      REGULATOR_MT6380 = yes;
    };
  };
  linuxPackages_bpir3 = pkgs.linuxKernel.packagesFor linux_bpir3;
in
{
  boot.kernelPackages = linuxPackages_bpir3;
  # We exclude a number of modules included in the default list. A non-insignificant amount do
  # not apply to embedded hardware like this, so simply skip the defaults.
  #
  # Custom kernel is required as a lot of MTK components misbehave when built as modules.
  # They fail to load properly, leaving the system without working ethernet, they'll oops on
  # remove. MTK-DSA parts and PCIe were observed to do this.
  boot.initrd.includeDefaultModules = false;
  boot.initrd.kernelModules = [ "rfkill" "cfg80211" "mt7915e" "mii" "nvme" ];
  boot.kernelParams = [ "console=ttyS0,115200" ];
  hardware.enableRedistributableFirmware = true;
  # Wireless hardware exists, regulatory database is essential.
  hardware.wirelessRegulatoryDatabase = true;

  boot.loader.grub.enable = false;
  boot.loader.generic-extlinux-compatible.enable = true;
  hardware.deviceTree.filter = "mt7986a-bananapi-bpi-r3.dtb";

  hardware.deviceTree.overlays = [
    {
      name = "bpir3-sd-enable";
      dtsFile = ./bpir3-dts/mt7986a-bananapi-bpi-r3-sd.dts;
    }
    {
      name = "bpir3-nand-enable";
      dtsFile = ./bpir3-dts/mt7986a-bananapi-bpi-r3-nand.dts;
    }
    {
      name = "bpi-r3 wifi training data";
      dtsFile = ./bpir3-dts/mt7986a-bananapi-bpi-r3-wirless.dts;
    }
    {
      name = "reset button disable";
      dtsFile = ./bpir3-dts/mt7986a-bananapi-bpi-r3-pcie-button.dts;
    }
    {
      name = "mt7986a efuses";
      dtsFile = ./bpir3-dts/mt7986a-efuse-device-tree-node.dts;
    }
  ];

  boot.initrd.preDeviceCommands = ''
    if [ ! -d /sys/bus/pci/devices/0000:01:00.0 ]; then
      if [ -d /sys/bus/pci/devices/0000:00:00.0 ]; then
        # Remove PCI bridge, then rescan.  NVMe init crashes if PCI bridge not removed first
        echo 1 > /sys/bus/pci/devices/0000:00:00.0/remove
        # Rescan brings PCI root back and brings the NVMe device in.
        echo 1 > /sys/bus/pci/rescan
      else
        info "PCIe bridge missing"
      fi
    fi
  '';
} 
