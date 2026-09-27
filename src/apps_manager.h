#ifndef APPS_MANAGER_H
#define APPS_MANAGER_H

#include <glib.h>

typedef enum {
    GROUP_GAMING,
    GROUP_AUDIO_VIDEO,
    GROUP_DRAWING_IMAGE,
    GROUP_SOCIAL,
    GROUP_TEXT_DOCUMENTS,
    GROUP_DRIVERS,
    GROUP_SECURITY
} AppGroup;

typedef struct {
    const char *name;
    const char *icon_path;
    const char *install_command;       /* glibc method */
    const char *install_command_musl;  /* musl method, NULL = not available on musl */
    AppGroup group;
    gboolean selected;
    gboolean install_success;
} AppInfo;

GList *get_all_apps(void);   /* already filtered for the running libc */
gchar *get_resource_path(const char *rel_path);

/* Runtime libc detection (confstr fails on musl). Memoized. */
gboolean neko_is_musl(void);
/* Effective install command for this host (musl column when musl, else glibc). */
const char *neko_app_command(const AppInfo *info);

#endif
