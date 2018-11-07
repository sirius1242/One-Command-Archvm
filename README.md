# One-Command-Archvm

### Build Archlinux virtual machine with one command
## &#9888; Attention: Don't use it with your host system, it may clean the whole disk!

### Usage:

First of all, you need to create a new virtual machine, a new virtual disk and boot it with iso of Archlinux.

In the begining, I think I can clone it from github and run it. However, there is no `git` in iso of Archlinux, so you can download it directly or install a `git` in your iso and clone it.

To download it, you can use `wget -P ~/ https://github.com/sirius1242/One-Command-Archvm/archive/master.zip` and uncompress or directly download these files to the same directory. If `build.sh` have no execute permission, you can use `chmod +x build.sh`.

In the directory where you clone or put the files into, use `./build.sh` to execute it, and wait for install finished.

There are some configurations in the script, and the system installed will use [oh-my-zsh](https://github.com/robbyrussell/oh-my-zsh) and [vim-for-server](https://github.com/wklken/vim-for-server) (I did some modifications), you can change these configrations after downloaded it, or you can also fork the repo and modify, put the repo in your server (or other places) to clone or download in future also works.

It installed the guest additions, if you use vmware or you don't like it, set variable `vbox` to 'no' or others, vbox guest additions will be installed only when variable `vbox` is 'yes'.