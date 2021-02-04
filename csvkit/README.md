# csvkit

## 1. Add unofficial user repository

https://wiki.archlinux.org/index.php/Unofficial_user_repositories#alerque

Add this to `/etc/pacman.conf`:

```
[alerque]
Server = https://arch.alerque.com/$arch
```

## 2. Add signing keys for repo

```bash
sudo pacman-key --recv-keys 63CC496475267693
sudo pacman-key --lsign-key 63CC496475267693
```

## 3. Just install

Install with `pamac install csvkit`
