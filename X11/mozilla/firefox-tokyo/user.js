// Dedicated "Tokyo" profile: all traffic through SSH SOCKS proxy on host v.
// Launched only via `firefox-tokyo`. Requires: ssh -fN -D 1080 v
user_pref("network.proxy.type", 1);                 // manual proxy
user_pref("network.proxy.socks", "127.0.0.1");
user_pref("network.proxy.socks_port", 1080);
user_pref("network.proxy.socks_version", 5);
user_pref("network.proxy.socks_remote_dns", true);  // DNS through the tunnel (no ISP leak)
user_pref("media.peerconnection.enabled", false);   // disable WebRTC (no real-IP leak)

// Make this profile visually distinct + skip first-run noise
user_pref("browser.startup.homepage", "https://ifconfig.co/ip");
user_pref("browser.startup.page", 1);
user_pref("browser.aboutwelcome.enabled", false);
user_pref("browser.shell.checkDefaultBrowser", false);
user_pref("datareporting.policy.dataSubmissionEnabled", false);
user_pref("browser.uidensity", 1);
