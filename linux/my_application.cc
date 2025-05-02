#include "my_application.h"

#include <flutter_linux/flutter_linux.h>
#include <bitsdojo_window_linux/bitsdojo_window_plugin.h>

#ifdef GDK_WINDOWING_X11
#include <gdk/gdkx.h>
#endif

#define MY_APPLICATION(my_application) \
    G_TYPE_CHECK_INSTANCE_CAST((my_application), my_application_get_type(), \
                              MyApplication)

struct _MyApplication {
  GtkApplication parent_instance;
  char** dart_entrypoint_arguments;
};

G_DEFINE_TYPE(MyApplication, my_application, GTK_TYPE_APPLICATION)

static void my_application_activate(GApplication* application) {
  MyApplication* self = MY_APPLICATION(application);
  GtkWindow* window =
      GTK_WINDOW(gtk_application_window_new(GTK_APPLICATION(application)));

  g_autoptr(BitsdojoWindowPlugin) bdw_plugin = bitsdojo_window_plugin_register();
  bitsdojo_window_plugin_configure(bdw_plugin, window);

  g_autoptr(FlDartProject) project = fl_dart_project_new();
  fl_dart_project_set_dart_entrypoint_arguments(project, self->dart_entrypoint_arguments);

  FlView* view = fl_view_new(project);
  gtk_widget_show(GTK_WIDGET(view));
  gtk_container_add(GTK_CONTAINER(window), GTK_WIDGET(view));

  fl_register_plugins(FL_PLUGIN_REGISTRY(view));

  gtk_widget_show(GTK_WIDGET(window));
  gtk_widget_grab_focus(GTK_WIDGET(view));
}

static void my_application_class_init(MyApplicationClass* klass) {
  G_APPLICATION_CLASS(klass)->activate = my_application_activate;
}

static void my_application_init(MyApplication* self) {}

void my_application_set_dart_entrypoint_arguments(MyApplication* self, char** arguments) {
  self->dart_entrypoint_arguments = g_strdupv(arguments);
}

MyApplication* my_application_new() {
  return MY_APPLICATION(g_object_new(my_application_get_type(),
                                    "application-id", "com.example.sticky_note_app",
                                    "flags", G_APPLICATION_NON_UNIQUE,
                                    nullptr));
}