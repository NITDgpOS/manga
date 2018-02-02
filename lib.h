#ifndef MANGA_LIB_H
#define MANGA_LIB_H

int get_file_names_in_dir(const char *dir, char ***list);

char* get_path(const char *file);

void free_file_list(char ***list);

void sort_file_names(char **file_list);

#endif
