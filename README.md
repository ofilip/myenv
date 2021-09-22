# myenv

## Troubleshooting

### Kernel does not boot with updated microcode

https://askubuntu.com/questions/1155634/intel-microcode-package-upgrade-in-ubuntu-18-04-leads-to-unbootable-system

- edit `/etc/default/grub`: `GRUB_CMDLINE_LINUX="nopti nospectre_v2 nospec"`
- `update-grub`

## What I hate about python

```
$ python -c 'import os; for x in dir(os): print(x)'
  File "<string>", line 1
    import os; for x in dir(os): print(x)
                 ^
SyntaxError: invalid syntax
```
