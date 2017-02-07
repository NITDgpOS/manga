#include <string.h>
#include <gtk/gtk.h>

#include "lib.h"

#define TITLE_TEXT      "Manga GUI"

#define DOWNLOADS_PATH  "./Downloads/"

#define DEFAULT_WIDTH   1024
#define DEFAULT_HEIGHT  680

#define MIN_TREE_WIDTH  250
#define MIN_TREE_HEIGHT 400

#define MIN_PDF_WIDTH   700
#define MIN_PDF_HEIGHT  400

#define TREE_TITLE      "Manga List"

enum
{
    MANGA_NAME = 0,
    MANGA_PATH,
    NUM_COLS
};


GtkBuilder *builder;


static void manga_tree_selection_changed(GtkTreeSelection *selection,
                                         gpointer data)
{
        GtkTreeIter iter;
        GtkTreeModel *model;
        gchar *path;

        if (gtk_tree_selection_get_selected(selection, &model, &iter))
        {
                gtk_tree_model_get(model, &iter, MANGA_PATH, &path, -1);

                gtk_label_set_text(GTK_LABEL(data), path);

                g_free(path);
        }
}


static GtkTreeModel *create_and_fill_manga_tree()
{
    GtkTreeStore  *treestore;
    GtkTreeIter    toplevel, child;
    gchar        **manga_file_list;
    gchar        **chap_file_list;
    gchar          manga_name[4096];
    gint           i, j;

    treestore = gtk_tree_store_new(NUM_COLS, G_TYPE_STRING, G_TYPE_STRING);

    /* Getting manga file names */
    get_file_names_in_dir(DOWNLOADS_PATH, (char ***)&manga_file_list);

    /* Iterating through all mangas */
    for (i = 0; manga_file_list[i]; ++i)
    {
        gtk_tree_store_append(treestore, &toplevel, NULL);
        gtk_tree_store_set(treestore, &toplevel,
                           MANGA_NAME, manga_file_list[i],
                           MANGA_PATH, NULL, -1);

        /* Concatinating the manga name to the directory */
        strcpy(manga_name, DOWNLOADS_PATH);
        strcat(manga_name, manga_file_list[i]);

        /* Getting chapters of a manga */
        get_file_names_in_dir(manga_name, (char ***)&chap_file_list);

        /* Storing all manga chapters in tree model */
        for (j = 0; chap_file_list[j]; ++j)
        {
            gtk_tree_store_append(treestore, &child, &toplevel);
            gtk_tree_store_set(treestore, &child,
                               MANGA_NAME, chap_file_list[j],
                               MANGA_PATH, get_path((char *)chap_file_list[j]),
                               -1);
        }

        /* Freeing the chapter file names */
        free_file_list((char ***)&chap_file_list);
    }

    /* Freeing manga file names */
    free_file_list((char ***)&manga_file_list);

    /* Return the tree model data */
    return GTK_TREE_MODEL(treestore);
}


static GtkWidget *create_manga_tree_view()
{
    GtkTreeViewColumn   *col;
    GtkCellRenderer     *renderer;
    GtkWidget           *view;
    GtkTreeModel        *model;

    /* Initialize the manga tree data */
    model = create_and_fill_manga_tree();

    /* Initialize the view */
    view = gtk_tree_view_new_with_model(model);

    renderer = gtk_cell_renderer_text_new();

    /* Populate the managa names and chapters into the Name column */
    col = gtk_tree_view_column_new_with_attributes(TREE_TITLE,
                                                   renderer,
                                                   "text", MANGA_NAME,
                                                   NULL);

    /* Add the column into the view */
    gtk_tree_view_append_column(GTK_TREE_VIEW(view), col);

    /* destroy model automatically with view */
    g_object_unref(model);

    return view;
}


int main(int argc, char **argv)
{
    GtkWidget *window;
    GtkWidget *view;
    GtkWidget *scrollWindow;
    GtkWidget *box, *content_box;
    GtkWidget *label;
    GtkWidget *header;
    GtkWidget *quit_button;
    GtkTreeSelection *select;

    gtk_init(&argc, &argv);

    builder = gtk_builder_new();
    gtk_builder_add_from_file(builder, "gui.glade", NULL);

    window = (GtkWidget *)gtk_builder_get_object(builder, "window");
    gtk_window_set_title(GTK_WINDOW(window), TITLE_TEXT);

    g_signal_connect(window, "delete_event", gtk_main_quit, NULL);
    gtk_window_set_default_size(GTK_WINDOW(window),
                                DEFAULT_WIDTH, DEFAULT_HEIGHT);

    box = gtk_box_new(GTK_ORIENTATION_HORIZONTAL, 0);

    label = gtk_label_new("Manga PDF will be viewed here");

    view = create_manga_tree_view();

    select = gtk_tree_view_get_selection(GTK_TREE_VIEW(view));
    gtk_tree_selection_set_mode(select, GTK_SELECTION_SINGLE);
    g_signal_connect(select, "changed",
                     G_CALLBACK(manga_tree_selection_changed),
                     label);

    scrollWindow = gtk_scrolled_window_new(NULL, NULL);
    gtk_container_add(GTK_CONTAINER(scrollWindow), view);
    gtk_widget_set_size_request(scrollWindow, MIN_TREE_WIDTH, MIN_TREE_HEIGHT);
    gtk_box_pack_start(GTK_BOX(box), scrollWindow, FALSE, TRUE, 0);

    gtk_widget_show(scrollWindow);

    scrollWindow = gtk_scrolled_window_new(NULL, NULL);
    gtk_container_add(GTK_CONTAINER(scrollWindow), label);
    gtk_widget_set_size_request(scrollWindow, MIN_PDF_WIDTH, MIN_PDF_HEIGHT);
    gtk_box_pack_start(GTK_BOX(box), scrollWindow, TRUE, TRUE, 0);

    header = (GtkWidget *)gtk_builder_get_object(builder, "header");
    quit_button = gtk_button_new_with_label("Quit");
    g_signal_connect(quit_button, "clicked",
                     G_CALLBACK(gtk_main_quit), NULL);
    gtk_header_bar_pack_end(GTK_HEADER_BAR(header), quit_button);

    content_box = (GtkWidget *)gtk_builder_get_object(builder, "content_box");
    gtk_box_pack_start(GTK_BOX(content_box), box, TRUE, TRUE, 0);

    gtk_widget_show_all(window);

    gtk_main();

    return 0;
}
