#include <stdio.h> //For printf()...
#include <unistd.h> //For system calls like fork()...
#include <stdlib.h> //For exit()...
#include <sys/wait.h> //For waitpid()...
#include <time.h> //For time() and ctime()...
#include <sys/stat.h> //For umask...
#include <fcntl.h> //For O_RDWR...
#include <syslog.h>
#include <errno.h>
#include <string.h> //For syslog error logging when daemon dies silently
#include "logrotate.h"

void log_daemon()
{
    pid_t pid;
    int count = 0;
    char* log_file = "/tmp/logd.log";
    FILE *fp;
    time_t currentTime;
    pid = fork();
    int max_log_flag = 0;
    if(pid == 0)
    {
        printf("In child process\n");
        // Create new session and detach from terminal
        pid_t setsid_ret = setsid();
        if(setsid_ret < 0)
        {
            perror("Error in setsid");
            exit(EXIT_FAILURE);  // don't continue if setsid fails
        }
        openlog("logd", LOG_PID | LOG_NDELAY, LOG_DAEMON); //Iniialize syslog in daemon startup
        syslog(LOG_INFO, "logd daemon started");
        umask(0);
        chdir("/");
        /*"We closed stdin, stdout, and stderr to detach the daemon from the terminal.
        But to avoid those FDs being reused by accident, we open /dev/null and redirect all three standard FDs to it.
        That way, even if some code tries to read or write to them, it won’t cause any harm."*/
        close(STDIN_FILENO);
        close(STDOUT_FILENO);
        int devnull = open("/dev/null", O_RDWR);
        if(devnull != -1) 
        {
            dup2(devnull, STDIN_FILENO);
            dup2(devnull, STDOUT_FILENO);
            if (devnull > 2) close(devnull);
        }
        while(1)
        {
            logrotate(log_file);
            sleep(1);
        }
    }
    else if(pid > 0)
    {
        printf("In parent process, child pid:%d\n", pid);
        exit(EXIT_SUCCESS);
    }
    else if(pid < 0)
    {
        printf("Fork failed");
        exit(EXIT_FAILURE);
    }
}

int main()
{
    log_daemon();
    return 0;
}
