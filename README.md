# myenv

## Troubleshooting

### Kernel does not boot with updated microcode

https://askubuntu.com/questions/1155634/intel-microcode-package-upgrade-in-ubuntu-18-04-leads-to-unbootable-system

- edit `/etc/default/grub`: `GRUB_CMDLINE_LINUX="nopti nospectre_v2 nospec"`
- `update-grub`

