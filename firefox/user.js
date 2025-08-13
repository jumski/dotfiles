// Firefox custom settings
// Symlink this to ~/.mozilla/firefox/[profile]/user.js

// Hardware video acceleration
user_pref("media.ffmpeg.vaapi.enabled", true);
user_pref("media.hardware-video-decoding.enabled", true);
user_pref("media.ffvpx.enabled", false);
user_pref("media.rdd-ffmpeg.enabled", true);
user_pref("media.av1.enabled", true);

// GPU acceleration
user_pref("gfx.webrender.all", true);
user_pref("gfx.x11-egl.force-enabled", true);
user_pref("widget.dmabuf.force-enabled", true);