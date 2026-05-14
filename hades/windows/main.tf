# Windows 11 Desktop VM (VMID 202)
# This VM was created manually via Proxmox UI.
# This Terraform config documents its configuration but does not manage it.
#
# Hardware:
#   - UEFI/OVMF with TPM 2.0, Q35 machine
#   - 6 cores, 16GB RAM (balloon disabled)
#   - 128GB OS disk (ide0), 100GB data disk (sata1), 200GB ollama disk (sata2)
#   - NVIDIA GPU passthrough (hostpci0: 01:00, PCIe, x-vga)
#   - VirtIO networking
#
# GPU passthrough requires:
#   - vfio-pci bound to GPU at boot (see /etc/modprobe.d/vfio.conf on Hades)
#   - nvidia/nouveau blacklisted on host (see /etc/modprobe.d/blacklist-nvidia.conf)
#   - IOMMU enabled (AMD-Vi)
