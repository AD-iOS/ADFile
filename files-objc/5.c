// 5.c - 完整修復版本
#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <spawn.h>
#include <sys/wait.h>
#include <stdlib.h>

int execute_zip(int is_directory, const char* source, const char* dest) {
    pid_t pid;
    
    // 构建命令
    char command[2048];
    if (is_directory) {
        snprintf(command, sizeof(command), "zip -r \"%s\" \"%s\"", dest, source);
    } else {
        snprintf(command, sizeof(command), "zip \"%s\" \"%s\"", dest, source);
    }
    
    printf("Executing command: %s\n", command);
    
    // 使用越獄環境的 bash
    char *argv[] = {"/var/jb/bin/bash", "-c", command, NULL};
    posix_spawn_file_actions_t actions;
    posix_spawn_file_actions_init(&actions);
    
    int status;
    int result = posix_spawn(&pid, "/var/jb/bin/bash", &actions, NULL, argv, NULL);
    posix_spawn_file_actions_destroy(&actions);
    
    if (result == 0) {
        if (waitpid(pid, &status, 0) != -1) {
            if (WIFEXITED(status)) {
                return WEXITSTATUS(status);
            }
        }
    }
    return -1;
}

int execute_unzip(const char* zip_path, const char* extract_path) {
    pid_t pid;
    
    // 构建解压命令
    char command[2048];
    snprintf(command, sizeof(command), "unzip -o \"%s\" -d \"%s\"", zip_path, extract_path);
    
    printf("Executing command: %s\n", command);
    
    // 使用越獄環境的 bash
    char *argv[] = {"/var/jb/bin/bash", "-c", command, NULL};
    posix_spawn_file_actions_t actions;
    posix_spawn_file_actions_init(&actions);
    
    int status;
    int result = posix_spawn(&pid, "/var/jb/bin/bash", &actions, NULL, argv, NULL);
    posix_spawn_file_actions_destroy(&actions);
    
    if (result == 0) {
        if (waitpid(pid, &status, 0) != -1) {
            if (WIFEXITED(status)) {
                return WEXITSTATUS(status);
            }
        }
    }
    return -1;
}

int execute_chmod(const char* mode, const char* path) {
    pid_t pid;
    
    char command[1024];
    snprintf(command, sizeof(command), "chmod %s \"%s\"", mode, path);
    
    printf("Executing command: %s\n", command);
    
    char *argv[] = {"/var/jb/bin/bash", "-c", command, NULL};
    posix_spawn_file_actions_t actions;
    posix_spawn_file_actions_init(&actions);
    
    int status;
    int result = posix_spawn(&pid, "/var/jb/bin/bash", &actions, NULL, argv, NULL);
    posix_spawn_file_actions_destroy(&actions);
    
    if (result == 0) {
        if (waitpid(pid, &status, 0) != -1) {
            if (WIFEXITED(status)) {
                return WEXITSTATUS(status);
            }
        }
    }
    return -1;
}

int execute_chown(const char* owner_group, const char* path) {
    pid_t pid;
    
    char command[1024];
    snprintf(command, sizeof(command), "chown %s \"%s\"", owner_group, path);
    
    printf("Executing command: %s\n", command);
    
    char *argv[] = {"/var/jb/bin/bash", "-c", command, NULL};
    posix_spawn_file_actions_t actions;
    posix_spawn_file_actions_init(&actions);
    
    int status;
    int result = posix_spawn(&pid, "/var/jb/bin/bash", &actions, NULL, argv, NULL);
    posix_spawn_file_actions_destroy(&actions);
    
    if (result == 0) {
        if (waitpid(pid, &status, 0) != -1) {
            if (WIFEXITED(status)) {
                return WEXITSTATUS(status);
            }
        }
    }
    return -1;
}

// 新增：文件操作函数
int execute_mkdir(const char* path) {
    pid_t pid;
    
    char command[1024];
    snprintf(command, sizeof(command), "mkdir -p \"%s\"", path);
    
    printf("Executing command: %s\n", command);
    
    char *argv[] = {"/var/jb/bin/bash", "-c", command, NULL};
    posix_spawn_file_actions_t actions;
    posix_spawn_file_actions_init(&actions);
    
    int status;
    int result = posix_spawn(&pid, "/var/jb/bin/bash", &actions, NULL, argv, NULL);
    posix_spawn_file_actions_destroy(&actions);
    
    if (result == 0) {
        if (waitpid(pid, &status, 0) != -1) {
            if (WIFEXITED(status)) {
                return WEXITSTATUS(status);
            }
        }
    }
    return -1;
}

int execute_touch(const char* path) {
    pid_t pid;
    
    char command[1024];
    snprintf(command, sizeof(command), "touch \"%s\"", path);
    
    printf("Executing command: %s\n", command);
    
    char *argv[] = {"/var/jb/bin/bash", "-c", command, NULL};
    posix_spawn_file_actions_t actions;
    posix_spawn_file_actions_init(&actions);
    
    int status;
    int result = posix_spawn(&pid, "/var/jb/bin/bash", &actions, NULL, argv, NULL);
    posix_spawn_file_actions_destroy(&actions);
    
    if (result == 0) {
        if (waitpid(pid, &status, 0) != -1) {
            if (WIFEXITED(status)) {
                return WEXITSTATUS(status);
            }
        }
    }
    return -1;
}

int execute_rm(const char* path) {
    pid_t pid;
    
    char command[1024];
    snprintf(command, sizeof(command), "rm -rf \"%s\"", path);
    
    printf("Executing command: %s\n", command);
    
    char *argv[] = {"/var/jb/bin/bash", "-c", command, NULL};
    posix_spawn_file_actions_t actions;
    posix_spawn_file_actions_init(&actions);
    
    int status;
    int result = posix_spawn(&pid, "/var/jb/bin/bash", &actions, NULL, argv, NULL);
    posix_spawn_file_actions_destroy(&actions);
    
    if (result == 0) {
        if (waitpid(pid, &status, 0) != -1) {
            if (WIFEXITED(status)) {
                return WEXITSTATUS(status);
            }
        }
    }
    return -1;
}

int execute_mv(const char* source, const char* dest) {
    pid_t pid;
    
    char command[1024];
    snprintf(command, sizeof(command), "mv \"%s\" \"%s\"", source, dest);
    
    printf("Executing command: %s\n", command);
    
    char *argv[] = {"/var/jb/bin/bash", "-c", command, NULL};
    posix_spawn_file_actions_t actions;
    posix_spawn_file_actions_init(&actions);
    
    int status;
    int result = posix_spawn(&pid, "/var/jb/bin/bash", &actions, NULL, argv, NULL);
    posix_spawn_file_actions_destroy(&actions);
    
    if (result == 0) {
        if (waitpid(pid, &status, 0) != -1) {
            if (WIFEXITED(status)) {
                return WEXITSTATUS(status);
            }
        }
    }
    return -1;
}