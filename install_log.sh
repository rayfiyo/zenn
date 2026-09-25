#!/bin/bash

shelly install standard \
  vivaldi wezterm chezmoi \ # Required for initial setup.
  fcitx5 fcitx5-configtool fcitx5-mozc

# その他のツール
shelly install standard \
  7zip tree \
  neovim

# z
shelly install standard z
mkdir .config/z
touch .config/z/data
fisher install jethrokuan/z
