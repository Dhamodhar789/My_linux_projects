#include <stdio.h> //For printf()...
#include <unistd.h> //For system calls like fork()...
#include <stdlib.h> //For exit()...
#include <sys/wait.h> //For waitpid()...
#include <time.h> //For time() and ctime()...
#include <sys/stat.h> //For umask...
#include <fcntl.h> //For O_RDWR...
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
        printf("!!!After setsid setsid_ret:%d\n", setsid_ret);
        if(setsid_ret < 0)
        {
            perror("Error in setsid");
            exit(EXIT_FAILURE);  // don't continue if setsid fails
        }
        umask(0);
        printf("!!!After umask");
        chdir("/");
        printf("!!!After chdir");
        /*"We closed stdin, stdout, and stderr to detach the daemon from the terminal.
        But to avoid those FDs being reused by accident, we open /dev/null and redirect all three standard FDs to it.
        That way, even if some code tries to read or write to them, it won’t cause any harm."*/
        close(STDIN_FILENO);
        close(STDOUT_FILENO);
        close(STDERR_FILENO);
        int devnull = open("/dev/null", O_RDWR);
        if(devnull != -1) 
        {
            dup2(devnull, STDIN_FILENO);
            dup2(devnull, STDOUT_FILENO);
            dup2(devnull, STDERR_FILENO);
            if (devnull > 2) close(devnull);
        }
        while(1)
        {
            // count++;
            // // Get the current time
            // currentTime = time(NULL);
            // char str[100];
            // //Writes log with timestamp in a variable. ctime() already returns with \n. So no need of \n in the string...
            // int ret = snprintf(str, sizeof(str), "LOG-%d | Timestamp:%s", count, ctime(&currentTime));
            // if(ret < 0)
            // {
            //     perror("Error in snprintf");
            //     exit(EXIT_FAILURE);
            // }
            //  = count_logs(log_file);
            // if(count == MAX_LOGS)
            // {
            //     if(!max_log_flag) 
            //     {
            //         max_log_flag = 1;
            //     }
            // }
            // fp = fopen(log_file, "a");
            // if(fp == NULL)
            // {
            //     perror("Error opening file");
            //     exit(EXIT_FAILURE);
            // }
            // fputs(str, fp);
            // fclose(fp);
            // sleep(5);
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
