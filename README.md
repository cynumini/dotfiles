# dotfiles

These are **my personal dotfiles**, made **only for my machine**.

> [!CAUTION]
> DO NOT RUN THIS UNLESS YOU KNOW EXACTLY WHAT YOU ARE DOING.

`deploy.scm` may:
- overwrite your files
- destroy your configuration
- break your system

There are **no safeguards** and **no guarantees**.

## Installation
- Guile (Scheme)

```sh
git clone git@github.com:cynumini/dotfiles.git
cd dotfiles
./deploy.scm
```

## Contents

- `lib/` — Scheme modules for my system  
- `bin/` — Scheme scripts  
  - `wallpaper.scm` — generates a 1920×1080 wallpaper from any image
- `generators/` — Scheme scripts that generate configuration files
  - `bash.scm` — generates `~/.bash_profile` and `~/.bashrc`
- `configs/` — configuration files that are symlinked (not generated)
- `deploy.scm` — deploys all configurations to the system
