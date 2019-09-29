#include <glib.h>
#include <glib/gprintf.h>
#include <gmodule.h>
#include <errno.h>


// Sort helper function to sort filenames in ascending order
gint compare_filenames(gconstpointer a, gconstpointer b) {
  return strcasecmp((const char *)a, (const char *)b);
}


// Returns true if filename is a dotfile i.e. filename has a leading dot
int check_hidden(const gchar *filename) {
  return filename != NULL && filename[0] == '.';
}


// Returns true if filename matches any one of the extensions.
int check_extension(const gchar *filename, const gchar **extensions) {
  const gsize filename_len = strlen(filename);
  while (*extensions != NULL) {
    const gchar *ext = *extensions;
    const gsize ext_len = strlen(ext);
    if (ext_len == 0) {
      return 0;
    }
    gsize i = filename_len - 1;
    int f = 1;
    while (i > 0 && filename[i] != '.') {
      if (filename[i] != ext[ext_len - (filename_len - i)]) {
        f = 0;
        break;
      }
      i--;
    }
    if (i != 0 && f == 1) {
      return 1;
    }
    extensions++;
  }
  return 0;
}


// Returns true if filename is a directory
gboolean g_file_isdir(const gchar *filename) {
  GFileTest test = G_FILE_TEST_IS_DIR;
  return g_file_test(filename, test);
}


// Returns a singly linked list of file names in the given directory.
//   dir_name: The name of the directory in the file system
//   extensions: Array of extensions to filter without the leading dot
//   skip_hidden: Skip hidden files if non-zero
// Returns NULL if directory specified in dir_name was not found.
GSList * get_file_names_in_dir(const gchar *dir_name,
                               const gchar **extensions,
                               gint skip_hidden) {
  GDir *dir;
  GError *error = NULL;
  const gchar *filename;
  GSList *filenames = NULL;

  dir = g_dir_open(dir_name, 0, &error);
  if (dir == NULL) {
    g_fprintf(stderr, "%s\n", error->message);
    g_error_free(error);
    return NULL;
  }

  // Get each file name from the directory
  while ((filename = g_dir_read_name(dir))) {
    // Skip hidden files and extensions that don't match
    if ((skip_hidden != 0 && check_hidden(filename)) ||
        (extensions != NULL && !check_extension(filename, extensions))) {
      continue;
    }
    filenames = g_slist_append (filenames, (gpointer)filename);
  }

  // Sort the filenames in ascending order
  filenames = g_slist_sort(filenames, compare_filenames);

  return filenames;
}
