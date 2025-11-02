# AppImage Issues on Manjaro/Arch

**Last Updated:** 2025-10-27

## Problem Summary

AppImages frequently fail on Manjaro/Arch-based systems with the error:
```
This doesn't look like a squashfs image.
Failed to open squashfs image
```

This is a **known, widespread issue** affecting many AppImage applications on Arch-based distributions, not specific to any single application.

---

## Root Causes

### 1. **AppImageLauncher Conflicts**
The `appimagelauncher` package can interfere with AppImage extraction and execution.

**Check if installed:**
```bash
pacman -Q appimagelauncher
```

**Fix: Remove it**
```bash
yay -R appimagelauncher
```

Then retry your AppImage.

---

### 2. **Binary Stripping During Packaging**
When building AppImage-based AUR packages with `makepkg`, the default behavior strips binaries, which **corrupts the embedded squashfs payload** inside AppImages.

**Why it happens:**
- AppImage = ELF executable wrapper + embedded squashfs filesystem
- `strip` command removes what it thinks is "debug info"
- But it can't distinguish wrapper from payload
- Result: corrupted squashfs that can't be mounted

**Fix for PKGBUILD:**
Ensure the PKGBUILD includes:
```bash
options=(!strip)
```

Check your `/etc/makepkg.conf` doesn't override this globally.

---

### 3. **Squashfuse Version Incompatibility**
Different AppImages use different compression algorithms (gzip, xz, zstd). Older squashfuse versions don't support all formats.

**Known problematic versions:**
- `squashfuse 0.3.0-1` - had major regressions
- Fixed in `squashfuse 0.3.0-2` and later

**Check your version:**
```bash
pacman -Q squashfuse
```

Current stable: `squashfuse 0.6.1-1` (should work)

**If still broken, try downgrading:**
```bash
sudo pacman -U /var/cache/pacman/pkg/squashfuse-0.3.0-2-x86_64.pkg.tar.zst
```

---

### 4. **Compression Format Incompatibility**
AppImages built with newer compression (especially **zstd**) may not work with older squashfuse.

**Error signature:**
```
Squashfs image uses (null) compression, this version supports only xz, zlib
```

**Fix:** Upgrade squashfuse to latest version, or use older AppImage variant (e.g., Ubuntu 22.04 instead of 24.04).

---

### 5. **FUSE Configuration Issues**
AppImages require FUSE to mount the internal filesystem.

**Check FUSE is loaded:**
```bash
lsmod | grep fuse
```

**Check /dev/fuse permissions:**
```bash
ls -la /dev/fuse
```

Should show permissions allowing user access.

**Reload FUSE module if needed:**
```bash
sudo modprobe -r fuse
sudo modprobe fuse
```

---

## Specific Case: OrcaSlicer on Manjaro

### Known Issues

1. **Compilation from source crashes/freezes system** (confirmed even with 64GB RAM)
   - Users report RAM filling up completely during `makepkg`
   - System becomes unresponsive
   - **Solution:** Don't compile from source, use alternatives

2. **AppImage extraction fails** with squashfs errors
   - Both Ubuntu 24.04 and 22.04 variants affected
   - Manual extraction with `--appimage-extract` also fails
   - **Solution:** Use Flatpak or Docker instead

3. **Segmentation faults after system updates**
   - Caused by font package conflicts
   - **Fix:**
     ```bash
     yay -Rdd ttf-harmonyos-sans
     # or
     yay -R ttf-nanum
     ```

4. **Webkit library issues**
   - AppImage requires `libwebkit2gtk-4.0.so.37`
   - Manjaro ships `webkit2gtk-4.1`
   - Device tab (web browser) in OrcaSlicer doesn't work

### Recommended Solutions for OrcaSlicer

**Option 1: Flatpak (Easiest)**
```bash
flatpak install flathub com.orcaslicer.OrcaSlicer
flatpak run com.orcaslicer.OrcaSlicer
```

**Pros:**
- Simple installation
- Sandboxed
- Well-maintained

**Cons:**
- Larger disk space (~1-2GB with runtime)
- Sandboxing may require permission adjustments (use Flatseal)
- USB printer access needs explicit permission
- File access outside home directory needs configuration

**Option 2: Docker (Most Reliable)**
```bash
docker pull lscr.io/linuxserver/orcaslicer:latest

docker run -d \
  --name=orcaslicer \
  -e PUID=1000 \
  -e PGID=1000 \
  -e TZ=Europe/Warsaw \
  -p 6080:6080 \
  -v ~/orcaslicer-config:/config \
  -v ~/3d-models:/models \
  --restart unless-stopped \
  lscr.io/linuxserver/orcaslicer:latest

# Access via browser
firefox http://localhost:6080
```

**Pros:**
- Guaranteed compatibility
- No sandbox limitations
- Easy to remove
- Officially maintained by LinuxServer.io

**Cons:**
- Runs in browser (not native feeling)
- Requires Docker installed
- Network-based access

**Option 3: Manual AppImage with Extraction Workaround**

If AppImage fails to run but can extract:
```bash
# Download AppImage
wget https://github.com/SoftFever/OrcaSlicer/releases/download/v2.3.1/OrcaSlicer_Linux_AppImage_Ubuntu2204_V2.3.1.AppImage

# Extract contents
chmod +x OrcaSlicer_Linux_AppImage_Ubuntu2204_V2.3.1.AppImage
./OrcaSlicer_Linux_AppImage_Ubuntu2204_V2.3.1.AppImage --appimage-extract

# Run from extracted directory
cd squashfs-root
./AppRun
```

---

## General AppImage Troubleshooting

### Diagnostic Commands

**1. Check FUSE setup:**
```bash
lsmod | grep fuse
ls -la /dev/fuse
pacman -Q fuse2 fuse3 squashfuse
```

**2. Test AppImage file integrity:**
```bash
file your-app.AppImage
# Should show: ELF 64-bit LSB pie executable

sha256sum your-app.AppImage
# Compare with upstream checksum
```

**3. Try different extraction methods:**
```bash
# Method 1: Standard extraction
./app.AppImage --appimage-extract

# Method 2: Extract and run
./app.AppImage --appimage-extract-and-run

# Method 3: Mount (requires FUSE)
./app.AppImage --appimage-mount
```

**4. Check for conflicting packages:**
```bash
pacman -Q appimagelauncher
pacman -Q appimaged
```

---

## Alternative Solutions When AppImages Fail

### 1. Flatpak
```bash
# Search for app
flatpak search <app-name>

# Install from Flathub
flatpak install flathub com.example.App

# Manage permissions
flatpak install flathub com.github.tchx84.Flatseal
```

### 2. Docker/Podman
Many applications provide official Docker images, especially for GUI apps via:
- VNC (web browser access)
- X11 forwarding (native window)

### 3. AUR Source Packages
Instead of `-bin` packages (which use AppImages), try source-based packages:
```bash
# Example: orca-slicer vs orca-slicer-bin
yay -S orca-slicer  # Compiles from source (may be slow/broken)
yay -S orca-slicer-bin  # Uses AppImage (may fail on Arch)
yay -S orca-slicer-git  # Latest git version
```

### 4. Manual Binary Installation
Some projects provide raw binaries (not AppImages):
```bash
# Download and extract
tar xzf app-linux-x86_64.tar.gz

# Run directly
cd app-linux-x86_64
./app
```

---

## Prevention: Building AppImage-based AUR Packages Correctly

If you maintain or modify PKGBUILDs that use AppImages:

### Required PKGBUILD Settings

```bash
# At the top of PKGBUILD
options=(!strip)  # CRITICAL: Prevents corrupting AppImage

prepare() {
  chmod +x "${srcdir}/${appimage}"

  # Extract the AppImage
  "${srcdir}/${appimage}" --appimage-extract
}

package() {
  # Install extracted contents
  install -d "${pkgdir}/opt/${pkgname}"
  cp -av squashfs-root/* "${pkgdir}/opt/${pkgname}/"

  # Create launcher script
  install -Dm755 /dev/stdin "${pkgdir}/usr/bin/${pkgname%-bin}" <<EOF
#!/bin/sh
exec /opt/${pkgname}/AppRun "\$@"
EOF

  # Install desktop file, icons, etc.
  # ...
}
```

### Common Mistakes

❌ **Don't do this:**
```bash
# Installing the AppImage directly
install -Dm755 "${srcdir}/${appimage}" "${pkgdir}/opt/${pkgname}/"
# This often gets stripped by makepkg, corrupting it
```

❌ **Don't do this:**
```bash
# Forgetting options=(!strip)
# Default makepkg behavior will strip the AppImage
```

✅ **Do this:**
```bash
options=(!strip)  # Always set this
# Extract AppImage during prepare()
# Install extracted contents in package()
```

---

## When AppImages Work Fine

AppImages are **not fundamentally broken** on Arch. They work when:
- ✅ Your squashfuse version supports the compression format
- ✅ No conflicting packages (appimagelauncher) installed
- ✅ FUSE is properly configured
- ✅ AppImage wasn't corrupted during download/packaging
- ✅ AppImage uses libraries compatible with your system

Many AppImages work perfectly on Manjaro/Arch without any issues.

---

## Resources

### Official Documentation
- [AppImage Troubleshooting - FUSE](https://docs.appimage.org/user-guide/troubleshooting/fuse.html)
- [Arch Wiki - AppImage Package Guidelines](https://wiki.archlinux.org/title/User:SergeyK/AppImage_package_guidelines)
- [AppImage Wiki - FUSE](https://github.com/AppImage/AppImageKit/wiki/FUSE)

### Known Issues
- [Arch Forums - AppImage PKGBUILD Issues](https://bbs.archlinux.org/viewtopic.php?id=265937)
- [Arch Forums - squashfuse 0.3.0 Regression](https://bbs.archlinux.org/viewtopic.php?id=287597)
- [OrcaSlicer #6520 - Segfault on Arch](https://github.com/SoftFever/OrcaSlicer/issues/6520)
- [OrcaSlicer AUR Comments](https://aur.archlinux.org/packages/orca-slicer-bin)

### Alternative Package Formats
- [Flathub](https://flathub.org/)
- [LinuxServer.io Docker Images](https://docs.linuxserver.io/)
- [Arch User Repository](https://aur.archlinux.org/)

---

## Summary

**AppImage issues on Arch/Manjaro are common but solvable.**

**Quick fixes to try first:**
1. Remove `appimagelauncher` if installed
2. Ensure `squashfuse` is up to date
3. Check FUSE module is loaded
4. Try extraction method: `--appimage-extract`

**If AppImages consistently fail:**
1. Use Flatpak for GUI apps
2. Use Docker for server/web apps
3. Build from source (if compilation works)
4. Use native packages when available

**For OrcaSlicer specifically on Manjaro:**
- ❌ Don't: Compile from source (crashes system)
- ❌ Don't: Use AppImage (extraction broken)
- ✅ Do: Use Flatpak (simple, works)
- ✅ Do: Use Docker (guaranteed compatibility)

---

**Generated:** 2025-10-27
**System:** Manjaro Linux 25.0.8 (Zetar), Kernel 6.15.11-2-MANJARO
**Context:** OrcaSlicer v2.3.1 installation failure investigation
