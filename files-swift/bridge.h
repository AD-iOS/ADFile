int execute_zip(int is_directory, const char* source, const char* dest);
int execute_unzip(const char* zip_path, const char* extract_path);

int execute_chmod(const char* mode, const char* path);
int execute_chown(const char* owner_group, const char* path);