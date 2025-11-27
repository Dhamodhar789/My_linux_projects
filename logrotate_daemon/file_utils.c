#include <stdio.h>
#include <syslog.h>
#include <errno.h>
#include <string.h>
#include <stdlib.h>
FILE *safe_fopen(const char *path, const char *mode)
{
    FILE *fp = fopen(path, mode);
    if (!fp)
    {
        syslog(LOG_ERR,
            "fopen('%s','%s') failed: %s (errno=%d)",
                path, mode, strerror(errno), errno);
        syslog(LOG_CRIT, "Fatal error. Daemon exiting.");
        closelog();
        exit(EXIT_FAILURE);
    }
    return fp;
}
