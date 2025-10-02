// 5.c - 修复版本
#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <spawn.h>
#include <sys/wait.h>

int execute_zip(int is_directory, const char* source, const char* dest) {
    pid_t pid;
    
    char command[2048];
    if (is_directory) {
        snprintf(command, sizeof(command), "zip -r \"%s\" \"%s\"", dest, source);
    } else {
        snprintf(command, sizeof(command), "zip \"%s\" \"%s\"", dest, source);
    }
    
    printf("Executing command: %s\n", command);
    
    char *argv[] = {"bash", "-c", command, NULL};
    
    int status;
    int result = posix_spawn(&pid, "/var/jb/bin/bash", NULL, NULL, argv, NULL);
    
    if (result == 0) {
        if (waitpid(pid, &status, 0) != -1) {
            return WEXITSTATUS(status);
        }
    }
    return -1;
}

int execute_unzip(const char* zip_path, const char* extract_path) {
    pid_t pid;
    char command[2048];
    snprintf(command, sizeof(command), "unzip -o \"%s\" -d \"%s\"", zip_path, extract_path);
    
    char *argv[] = {"bash", "-c", command, NULL};
    
    int status;
    int result = posix_spawn(&pid, "/var/jb/bin/bash", NULL, NULL, argv, NULL);
    
    if (result == 0) {
        if (waitpid(pid, &status, 0) != -1) {
            return WEXITSTATUS(status);
        }
    }
    return -1;
}

int execute_chmod(const char* mode, const char* path) {
    pid_t pid;
    char command[1024];
    snprintf(command, sizeof(command), "chmod %s \"%s\"", mode, path);
    
    char *argv[] = {"bash", "-c", command, NULL};
    
    int status;
    int result = posix_spawn(&pid, "/var/jb/bin/bash", NULL, NULL, argv, NULL);
    
    if (result == 0) {
        if (waitpid(pid, &status, 0) != -1) {
            return WEXITSTATUS(status);
        }
    }
    return -1;
}

int execute_chown(const char* owner_group, const char* path) {
    pid_t pid;
    char command[1024];
    snprintf(command, sizeof(command), "chown %s \"%s\"", owner_group, path);
    
    char *argv[] = {"bash", "-c", command, NULL};
    
    int status;
    int result = posix_spawn(&pid, "/var/jb/bin/bash", NULL, NULL, argv, NULL);
    
    if (result == 0) {
        if (waitpid(pid, &status, 0) != -1) {
            return WEXITSTATUS(status);
        }
    }
    return -1;
}