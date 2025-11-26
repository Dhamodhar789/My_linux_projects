#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <sys/wait.h>
#include <stdbool.h>
#include <signal.h>
#include <fcntl.h>
#define MAX_INPUT 1024
#define MAX_ARGS 64

void handle_sigint(int sig) {
    write(STDOUT_FILENO, "\n", 1);
}

void handle_sigtstp(int sig) {
    write(STDOUT_FILENO, "\n", 1);
}
void parse_input(char* input, char** args, bool* run_in_background, char** output_file, bool* append, char** input_file)
{
    int i=0;
    args[i] = strtok(input, " \t\n");
    while((args[i]!=NULL) && (i<MAX_ARGS-1))
    {
        if((strcmp(args[i], ">")==0) || (strcmp(args[i], ">>")==0))
        {
            bool append_mode = (strcmp(args[i], ">>")==0);
            args[i] = strtok(NULL, " \t\n");
            if(args[i] != NULL)
            {
                *output_file = args[i];
                *append = append_mode;
            }
            break; //Don't need to parse further...
        }
        if((strcmp(args[i], "<")==0))
        {
            args[i] = strtok(NULL, " \t\n");
            if(args[i] != NULL)
            {
                *input_file = args[i];
            }
            break; //Don't need to parse further...
        }
        i++;
        args[i] = strtok(NULL, " \t\n");
    }
    args[i]=NULL;
    if((i>0) && (strcmp(args[i-1], "&")==0))
    {
        *run_in_background = true;
        args[i-1] = NULL;
    }
    else
    {
        //printf("In setting run in background = false\n");
        *run_in_background = false;
    }
} 
int main()
{
    char input[MAX_INPUT];
    char* args[MAX_ARGS];
    bool run_in_background, append;
    char current_working_directory[1024];
    char* output_file = NULL;
    char* input_file = NULL;
    signal(SIGINT, handle_sigint);
    signal(SIGTSTP, handle_sigtstp);
    while(1)
    {
        getcwd(current_working_directory, sizeof(current_working_directory));

        printf("minishell:%s$ ", current_working_directory);
        if(fgets(input, MAX_INPUT, stdin) == NULL)
        {
            break;
        }
        if(strcmp(input, "\n")==0)
        {
            continue;
        }
        parse_input(input, args, &run_in_background, &output_file, &append, &input_file);
        // printf("run_in_background::%d\n", run_in_background);
        // for (int j = 0; args[j] != NULL; j++) {
        //     printf("args[%d] = '%s'\n", j, args[j]);
        // }
        if(strcmp(args[0], "exit")==0)
        {
            break;
        }

        if(strcmp(args[0], "cd")==0)
        {
            if(args[1] == NULL)
            {
                fprintf(stderr, "cd argument missing\n");
            }
            else
            {
                if(chdir(args[1]) != 0)
                {
                    perror("cd failed");
                }
            }
            continue;
        }

        //this works in execvp also but optional implementation if pwd is not supported in execvp. Here this is not required...
        if(strcmp(args[0], "pwd")==0)
        {
            if(getcwd(current_working_directory, sizeof(current_working_directory)) != NULL)
            {
                printf("%s\n", current_working_directory);
            }
            else
            {
                perror("pwd failed");
            }
            continue;
        }
        pid_t pid = fork();
        if(pid==0)
        {
            if(output_file != NULL)
            {
                int flags = O_WRONLY | O_CREAT;
                flags |= append ? O_APPEND : O_TRUNC;
                int fd = open(output_file, flags, 0644);
                if(fd < 0)
                {
                    perror("open failed");
                    exit(EXIT_FAILURE);
                }
                dup2(fd, STDOUT_FILENO);
                close(fd);
            }
            if(input_file != NULL)
            {
                int fd = open(input_file, O_RDONLY);
                if(fd<0)
                {
                    perror("open failed");
                    exit(EXIT_FAILURE);
                }
                dup2(fd, STDIN_FILENO);
                close(fd);
            }
            if(execvp(args[0], args) == -1)
            {
                fprintf(stderr, "%s: command not found\n", args[0]);
                exit(EXIT_FAILURE);
            }
        }
        else if(pid > 0)
        {

            if(!run_in_background)
            {
                // printf("Before waitpid in parent\n");
                waitpid(pid, NULL, 0);
                // printf("After waitpid in parent\n");
            }
            else
            {
                printf("[Running in background] pid:%d\n", pid);
            }
            output_file = NULL;
            append = false;
            input_file = NULL;
        }
        else if(pid < 0)
        {
            perror("Fork failed");
        }
    }
    return 0;
}