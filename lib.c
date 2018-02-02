//#define PORTABLE

#ifndef PORTABLE
#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>
#include <dirent.h>
#endif

#include <stdio.h>
#include <stdlib.h>
#include <malloc.h>
#include <string.h>

#include "lib.h"

#define SWAP(a, b, type)  {                     \
        type c = a;                             \
        a = b, b = c;                           \
    }

char* get_path(const char *file)
{
    FILE *fp;
    char cmd[5000];
    char result[4096];
    char *path;
    int len;

    sprintf(cmd, "readlink -f '%s'", file);

    fp = popen(cmd, "r");

    if (fp == NULL)
    {
        printf("Failed to run command %s\n", cmd);
        exit(1);
    }

    fgets(result, 4095, fp);

    len = strlen(result);

    result[len - 1] = '\0';

    path = (char *)malloc(len);
    strcpy(path, result);

    return path;
}


int get_file_names_in_dir(const char *dir, char ***list)
{
    FILE *fp;
    int files_in_dir, i = 0;
    char result[4096];
    char cmd[5000];

    sprintf(cmd, "ls -l '%s' | wc -l", dir);

    fp = popen(cmd, "r");
    if (fp == NULL)
    {
        printf("Failed to run command %s\n", cmd);
        exit(1);
    }

    fgets(result, sizeof(result) - 1, fp);
    files_in_dir = atol(result) - 1;

    pclose(fp);

    *list = (char **)malloc((files_in_dir + 1) * sizeof(char **));

#ifdef PORTABLE
    int j = 0, ch;

    sprintf(cmd,
            "ls -l '%s' | sed -e '1d' | "
            "awk '{$1=$2=$3=$4=$5=$6=$7=$8=\"\"; print $0}' | "
            "sed -e 's/^ \\{1,\\}//'", dir);

    fp = popen(cmd, "r");

    if (fp == NULL)
    {
        printf("Failed to run command %s\n", cmd);
        exit(1);
    }

    while (i < files_in_dir && !feof(fp))
    {
        ch = fgetc(fp);
        if (ch < 32 || ch > 126)
        {
            if (j != 0)
            {
                result[j] = '\0';
                (*list)[i] = (char *)malloc(j + 1);
                strcpy((*list)[i], result);
                j = 0;
                ++i;
            }
            continue;
        }
        result[j] = ch;
        ++j;
    }

    pclose(fp);

    (*list)[i] = NULL;

#else

    DIR *mydir;
    struct dirent *myfile;
    mydir = opendir(dir);
    while ((myfile = readdir(mydir)) != NULL)
    {
        if (myfile->d_name[0] != '.')
        {
            (*list)[i] = (char *)malloc(strlen(myfile->d_name) + 1);
            strcpy((*list)[i], myfile->d_name);
            ++i;
        }
    }
    closedir(mydir);

    (*list)[i] = NULL;

    sort_file_names(*list);

#endif

    return files_in_dir;
}

void free_file_list(char ***list)
{
    int i = 0;
    while ((*list)[i])
        free((*list)[i++]);
    free(*list);
}

void sort_file_names(char **file_list)
{
    size_t i;

    for (i = 0; file_list[i + 1]; ++i)
    {
        size_t j = i;
        while (strcasecmp(file_list[j + 1], file_list[j]) < 0)
        {
            SWAP(file_list[j + 1], file_list[j], char *);
            if (j-- == 0)
                break;
        }
    }
}
