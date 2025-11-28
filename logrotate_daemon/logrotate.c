#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <time.h> //For time() and ctime()...
#include <syslog.h>
#include <errno.h>
#include "file_utils.h"
#define MAX_LOG 150
int overwrite_line = 0;
int count;
int log_number = 1;

void append(char* log_file, char* log)
{
    FILE* fp = safe_fopen(log_file, "a");
    fputs(log, fp);
    fclose(fp);
}
void add_nspace(char** current_log, int length_difference)
{
    char* ptr = *current_log;
    while(*ptr != '\n')
    {
        ptr++;
    }
    while(length_difference)
    {
        *ptr = ' ';
        ptr++;
        length_difference--;
    }
    *ptr = '\n';
    ptr++;
    *ptr = '\0';
}
void overwrite(char* log_file, char* current_log, int overwrite_line)
{
    char old_log[256];
    int line_number = 0;
    long offset = 0;
    FILE* fp = safe_fopen(log_file, "r+");
    fseek(fp, 0, SEEK_SET);
    while(fgets(old_log, sizeof(old_log), fp) != NULL)
    {
        if(line_number == overwrite_line)
        {
            break;
        }
        offset = ftell(fp);
        line_number++;
    } 
    int old_log_length = strlen(old_log);
    int current_log_length = strlen(current_log);
    if(old_log_length < current_log_length)
    { 
        line_number = 0;
        fseek(fp, 0, SEEK_SET);
        char* temp_file = "/tmp/temp.txt";
        FILE* temp_fp = safe_fopen(temp_file, "w");
        while(fgets(old_log, sizeof(old_log), fp) != NULL)
        {
            if(line_number == overwrite_line)
            {
                fputs(current_log, temp_fp);
            }
            else
            {
                fputs(old_log, temp_fp);
            }
            line_number++;
        }
        fsync(fileno(temp_fp));
        fclose(temp_fp);
        fflush(fp); 

        if (rename(temp_file, log_file) != 0) 
        {
            syslog(LOG_ERR, "rename failed: %s", strerror(errno));
            exit(EXIT_FAILURE);
        }

        int dirfd = open("/tmp", O_DIRECTORY | O_RDONLY);
        if (dirfd >= 0) 
        {
            fsync(dirfd);
            close(dirfd);
        }

    }
    else
    {
        if(old_log_length > current_log_length)
        {
            int length_difference = old_log_length - current_log_length;
            add_nspace(&current_log, length_difference);
        }
        fseek(fp, offset, SEEK_SET);
        fputs(current_log, fp);
        fflush(fp); 
        fclose(fp);
    }
}

int count_lines(char* log_file)
{
    FILE* fp = fopen(log_file, "r");
    if (!fp)
    {        
        syslog(LOG_WARNING,
               "log file %s does not exist yet, starting new file", log_file);
        return 0;
    }
    char chr;
    chr = fgetc(fp);
    int count = 0;
    while(chr != EOF)
    {
        if(chr == '\n')
        {
            count++;
        }
        chr = fgetc(fp);
    }
    fclose(fp);
    return count;
}
void logrotate(char* log_file)
{
    time_t currentTime;
    char log[100];
    overwrite_line %= MAX_LOG;
    count = count_lines(log_file);
    currentTime = time(NULL);
    int ret = snprintf(log, sizeof(log), "LOG: %d | Timestamp:%s", log_number, ctime(&currentTime));
    if(ret < 0)
    {
        perror("Error in snprintf");
        exit(EXIT_FAILURE);
    }
    if(count == MAX_LOG)
    {
        overwrite(log_file, log, overwrite_line);
        overwrite_line++;
    }
    else if(count < MAX_LOG)
    {
        append(log_file, log);
    }
    log_number++;
}
