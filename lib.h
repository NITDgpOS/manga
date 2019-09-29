#ifndef MANGA_LIB_H
#define MANGA_LIB_H

#include <glib.h>
#include <glib/gprintf.h>
#include <gmodule.h>
#include <errno.h>


// Returns true if filename is a dotfile i.e. filename has a leading dot
int check_hidden(const gchar *filename);


// Returns true if filename matches any one of the extensions.
int check_extension(const gchar *filename, const gchar **extensions);


// Returns true if filename is a directory
gboolean g_file_isdir(const gchar *filename);


// Returns a singly linked list of file names in the given directory.
//   dir_name: The name of the directory in the file system
//   extensions: Array of extensions to filter without the leading dot
//   skip_hidden: Skip hidden files if non-zero
// Returns NULL if directory specified in dir_name was not found.
GSList * get_file_names_in_dir(const gchar *dir_name,
                               const gchar **extensions,
                               gint skip_hidden);


#endif
