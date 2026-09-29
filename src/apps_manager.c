#define _GNU_SOURCE /* confstr(_CS_GNU_LIBC_VERSION) below */
#include "apps_manager.h"
#include <stddef.h>
#include <unistd.h>

/* Neko-Wizard installs everything through a single remote installer script
 * (download/install.sh in this repo). Same pattern used by the drivers:
 * download it and run it with the app-id of what we want to install.
 * It stays up to date after every push to main, no rebuild needed. */
#define NEKO_SCRIPT_URL "https://raw.githubusercontent.com/Neko-Void-Linux/Neko-Wizard/main/download/install.sh"
#define INSTALL_APP(id) "curl -fsSL -o /tmp/neko-install.sh " NEKO_SCRIPT_URL " && bash /tmp/neko-install.sh " id
/* Single repo, two libcs: same app-ids, musl recipe ships in
 * download/install-musl.sh of this same repo. */
#define NEKO_SCRIPT_URL_MUSL "https://raw.githubusercontent.com/SrDicov/Neko-Wizard/main/download/install-musl.sh"
#define INSTALL_APP_MUSL(id) "curl -fsSL -o /tmp/neko-install.sh " NEKO_SCRIPT_URL_MUSL " && bash /tmp/neko-install.sh " id

gboolean
neko_is_musl(void)
{
    static int cached = -1;
    if (cached < 0) {
#ifdef _CS_GNU_LIBC_VERSION
        char buf[64];
        cached = (confstr(_CS_GNU_LIBC_VERSION, buf, sizeof buf) == 0);
#else
        /* No GNU confstr on this libc (musl): not glibc. */
        cached = 1;
#endif
    }
    return cached;
}

const char *
neko_app_command(const AppInfo *info)
{
    if (neko_is_musl() && info->install_command_musl)
        return info->install_command_musl;
    return info->install_command;
}

static AppInfo apps[] = {
    // Gaming
    {"Steam", "steam.png", INSTALL_APP("steam"), INSTALL_APP_MUSL("steam"), GROUP_GAMING, FALSE, FALSE},
    {"PortProton", "portproton.png", INSTALL_APP("portproton"), INSTALL_APP_MUSL("portproton"), GROUP_GAMING, FALSE, FALSE},
    {"Heroic Games Launcher", "heroic.png", INSTALL_APP("heroic"), INSTALL_APP_MUSL("heroic"), GROUP_GAMING, FALSE, FALSE},
    {"Lutris", "lutris.png", INSTALL_APP("lutris"), INSTALL_APP_MUSL("lutris"), GROUP_GAMING, FALSE, FALSE},
    {"Hytale", "hytale.png", INSTALL_APP("hytale"), INSTALL_APP_MUSL("hytale"), GROUP_GAMING, FALSE, FALSE},
    {"Trinity Launcher", "trinity.png", INSTALL_APP("trinity"), INSTALL_APP_MUSL("trinity"), GROUP_GAMING, FALSE, FALSE},
    {"PrismLauncher", "prismlauncher.png", INSTALL_APP("prismlauncher"), INSTALL_APP_MUSL("prismlauncher"), GROUP_GAMING, FALSE, FALSE},
    {"PineconeMC", "elyprismlauncher.png", INSTALL_APP("pineconemc"), INSTALL_APP_MUSL("pineconemc"), GROUP_GAMING, FALSE, FALSE},
    {"ProtonUp-Qt", "protonup-qt.png", INSTALL_APP("protonup"), INSTALL_APP_MUSL("protonup"), GROUP_GAMING, FALSE, FALSE},
    {"Faugus Launcher", "faugus.png", INSTALL_APP("faugus"), INSTALL_APP_MUSL("faugus"), GROUP_GAMING, FALSE, FALSE},
    // Audio and Video editing
    {"Reaper", "reaper.png", INSTALL_APP("reaper"), INSTALL_APP_MUSL("reaper"), GROUP_AUDIO_VIDEO, FALSE, FALSE},
    {"OBS Studio", "obs.png", INSTALL_APP("obs"), INSTALL_APP_MUSL("obs"), GROUP_AUDIO_VIDEO, FALSE, FALSE},
    {"Kdenlive", "kdenlive.png", INSTALL_APP("kdenlive"), INSTALL_APP_MUSL("kdenlive"), GROUP_AUDIO_VIDEO, FALSE, FALSE},
    {"OpenShot", "org.openshot.OpenShot.png", INSTALL_APP("openshot"), INSTALL_APP_MUSL("openshot"), GROUP_AUDIO_VIDEO, FALSE, FALSE},
    {"VLC", "vlc.png", INSTALL_APP("vlc"), INSTALL_APP_MUSL("vlc"), GROUP_AUDIO_VIDEO, FALSE, FALSE},
    {"Audacity", "audacity-logo.png", INSTALL_APP("audacity"), INSTALL_APP_MUSL("audacity"), GROUP_AUDIO_VIDEO, FALSE, FALSE},
    {"Ardour", "ardour.png", INSTALL_APP("ardour"), INSTALL_APP_MUSL("ardour"), GROUP_AUDIO_VIDEO, FALSE, FALSE},
    {"Blender", "Blender.png", INSTALL_APP("blender"), INSTALL_APP_MUSL("blender"), GROUP_AUDIO_VIDEO, FALSE, FALSE},

    // Drawing and Image Editing
    {"Krita", "krita.png", INSTALL_APP("krita"), INSTALL_APP_MUSL("krita"), GROUP_DRAWING_IMAGE, FALSE, FALSE},
    {"GIMP", "gimp.png", INSTALL_APP("gimp"), INSTALL_APP_MUSL("gimp"), GROUP_DRAWING_IMAGE, FALSE, FALSE},
    {"Inkscape", "Inkscape.png", INSTALL_APP("inkscape"), INSTALL_APP_MUSL("inkscape"), GROUP_DRAWING_IMAGE, FALSE, FALSE},

    // Social Apps
    {"Spotify", "Spotify_icon.svg.png", INSTALL_APP("spotify"), INSTALL_APP_MUSL("spotify"), GROUP_SOCIAL, FALSE, FALSE},
    {"Vesktop", "vesktop.png", INSTALL_APP("vesktop"), INSTALL_APP_MUSL("vesktop"), GROUP_SOCIAL, FALSE, FALSE},
    {"Waterfox", "waterfox.png", INSTALL_APP("waterfox"), INSTALL_APP_MUSL("waterfox"), GROUP_SOCIAL, FALSE, FALSE},
    {"Brave", "brave.png", INSTALL_APP("brave"), INSTALL_APP_MUSL("brave"), GROUP_SOCIAL, FALSE, FALSE},
    {"Zerotierone", "zerotierone.png", INSTALL_APP("zerotierone"), INSTALL_APP_MUSL("zerotierone"), GROUP_SOCIAL, FALSE, FALSE},
    {"Telegram", "telegram.png", INSTALL_APP("telegram"), INSTALL_APP_MUSL("telegram"), GROUP_SOCIAL, FALSE, FALSE},
    {"Vivaldi", "vivaldi.png", INSTALL_APP("vivaldi"), INSTALL_APP_MUSL("vivaldi"), GROUP_SOCIAL, FALSE, FALSE},
    {"Chromium", "chromium.png", INSTALL_APP("chromium"), INSTALL_APP_MUSL("chromium"), GROUP_SOCIAL, FALSE, FALSE},

    // Text editing and documents
    {"OnlyOffice", "onlyoffice.png", INSTALL_APP("onlyoffice"), INSTALL_APP_MUSL("onlyoffice"), GROUP_TEXT_DOCUMENTS, FALSE, FALSE},
    {"Kate", "org.kde.kate.desktop.png", INSTALL_APP("kate"), INSTALL_APP_MUSL("kate"), GROUP_TEXT_DOCUMENTS, FALSE, FALSE},
    {"LibreOffice", "Libre-Office.png", INSTALL_APP("libreoffice"), INSTALL_APP_MUSL("libreoffice"), GROUP_TEXT_DOCUMENTS, FALSE, FALSE},

    // Drivers (grouped - each slot installs all related packages)
    {"Bluetooth","bluetooth.png", INSTALL_APP("bluetooth"), INSTALL_APP_MUSL("bluetooth"), GROUP_DRIVERS, FALSE, FALSE},
    {"Printer Support", "print.png", INSTALL_APP("printer"), INSTALL_APP_MUSL("printer"), GROUP_DRIVERS, FALSE, FALSE},
    {"AMD Drivers", "amd.png", INSTALL_APP("amd"), INSTALL_APP_MUSL("amd"), GROUP_DRIVERS, FALSE, FALSE},
    {"Intel Drivers", "intel.png", INSTALL_APP("intel"), INSTALL_APP_MUSL("intel"), GROUP_DRIVERS, FALSE, FALSE},
    {"Nvidia Open", "nvidia.png", INSTALL_APP("nvidia-open"), NULL, GROUP_DRIVERS, FALSE, FALSE},
    {"Nvidia Proprietary Lastest", "nvidia.png", INSTALL_APP("nvidia-latest"), NULL, GROUP_DRIVERS, FALSE, FALSE},
    {"Nvidia Proprietary 580", "nvidia.png", INSTALL_APP("nvidia-580"), NULL, GROUP_DRIVERS, FALSE, FALSE},
    {"Nvidia Proprietary 470", "nvidia.png", INSTALL_APP("nvidia-470"), NULL, GROUP_DRIVERS, FALSE, FALSE},
    {"Nvidia Proprietary 390", "nvidia.png", INSTALL_APP("nvidia-390"), NULL, GROUP_DRIVERS, FALSE, FALSE},

    //SECURITY SECTION
    {"GUFW (FIREWALL)", "firewall.png", INSTALL_APP("gufw"), INSTALL_APP_MUSL("gufw"), GROUP_SECURITY, FALSE, FALSE}
};

GList *get_all_apps(void) {
    GList *list = NULL;
    int num_apps = sizeof(apps) / sizeof(apps[0]);
    gboolean musl = neko_is_musl();
    for (int i = 0; i < num_apps; i++) {
        /* One catalog, two libcs: hide rows with no method for this host
         * (today: the 5 Nvidia entries on musl). */
        if (musl && apps[i].install_command_musl == NULL)
            continue;
        list = g_list_append(list, &apps[i]);
    }
    return list;
}

gchar *get_resource_path(const char *rel_path) {
    gchar *exe_path = g_file_read_link("/proc/self/exe", NULL);
    gchar *exe_dir = NULL;

    if (exe_path) {
        exe_dir = g_path_get_dirname(exe_path);
        g_free(exe_path);
    } else {
        exe_dir = g_get_current_dir();
    }

    gchar *path1 = g_build_filename(exe_dir, rel_path, NULL);
    gchar *path2 = g_build_filename(exe_dir, "..", rel_path, NULL);
    gchar *path3 = g_build_filename("/usr/share/neko-store", rel_path, NULL);
    gchar *path4 = g_build_filename("/opt/neko-store", rel_path, NULL);

    g_free(exe_dir);

    if (g_file_test(path1, G_FILE_TEST_EXISTS)) {
        g_free(path2); g_free(path3); g_free(path4);
        return path1;
    }
    if (g_file_test(path2, G_FILE_TEST_EXISTS)) {
        g_free(path1); g_free(path3); g_free(path4);
        return path2;
    }
    if (g_file_test(path3, G_FILE_TEST_EXISTS)) {
        g_free(path1); g_free(path2); g_free(path4);
        return path3;
    }
    if (g_file_test(path4, G_FILE_TEST_EXISTS)) {
        g_free(path1); g_free(path2); g_free(path3);
        return path4;
    }

    g_free(path2); g_free(path3); g_free(path4);

    gchar *path5 = g_build_filename("/home/javierc/Documentos/server/dev/Neko Store", rel_path, NULL);
    if (g_file_test(path5, G_FILE_TEST_EXISTS)) {
        g_free(path1);
        return path5;
    }
    g_free(path5);

    return path1;
}
