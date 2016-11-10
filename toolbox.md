# Toolbox

## Bash commands

**Getting used to:**
- paste
- **tmux**
- nl
- awk (get more into the lang)
- perl (oneliners)
- sed (more than just s/x/y/g)
- du, df

**Already using:** nvidia-smi (together with export CUDA\_VISIBLE\_DEVICES=)
**Queue to check:** nvim

**Tips and tricks**

- `for i in {01..10}; do echo $i; done`
- `xargs -P n` - parallel xargs
-  iterate over dates in bash
```bash
d=2015-01-01
while [ "$d" != 2015-02-20 ]; do 
    echo $d
    d=$(date -I -d "$d + 1 day")
done
```

## Python

**Getting used to:**
- tqdm (progress bar)
**Already using:** argparse
**Queue to check:**
- bokeh (data visualization)


## Other stuff

**Getting used to:**
**Already using:** 
- ParaView (big data visualization tool)
**Queue to ckeck:** d3.js
