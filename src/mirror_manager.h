#ifndef MIRROR_MANAGER_H
#define MIRROR_MANAGER_H

#include <glib.h>

typedef struct {
    const char *name;
    const char *url;
    const char *region;
    const char *location;
    int tier;
} MirrorInfo;

GList *get_all_mirrors(void);
/* Per-libc mirror list. Mirror roots serve both libcs (xmirror resolves
 * current/ vs current/musl/ on each host), so both tables share the same
 * entries today; the split exists so a musl-less mirror can be dropped
 * without touching callers. */
GList *get_mirrors_for_libc(gboolean musl);

#endif
