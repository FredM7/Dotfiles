# Dotfiles

#### Fred's Dotfiles

## Stow

> It's very important to note that this `Dotfiles` direcotry must be in your $HOME directory. Otherwise stow will just not do anything.

I use GNU Stow to manage my dotfiles.

If you don't have it already, install it. I use Arch, BTW.

```
sudo pacman -Sy stow
```

Once it is installed, it's as simple as running this inside the `Dotfiles` directory.

```
stow .
```

This tells `stow` to move any of the conflicting files into the `Dotfiles` directory, allowing it to create conflicting symbolic links. Be CAREFUL though, this OVERRIDES.

```
stow --adopt .
```

It's important to NOTE that the structure in this `Dotfiles` directory MUST be layed out as your HOME directory would ahve been layed out.

## Git

Obviously I also use `git` to store my files. If you don't already have it installed, run this:

```
sudo pacman -Sy git
```
