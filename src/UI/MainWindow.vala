/* Copyright 2015 Jonathan Moerman
*
* This file is part of Planner.
*
* Planner is free software: you can redistribute it
* and/or modify it under the terms of the GNU General Public License as
* published by the Free Software Foundation, either version 3 of the
* License, or (at your option) any later version.
*
* Planner is distributed in the hope that it will be
* useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General
* Public License for more details.
*
* You should have received a copy of the GNU General Public License along
* with Planner. If not, see http://www.gnu.org/licenses/.
*/

using Gtk;

/**
 * The main window of this application.
 */
class MainWindow : Gtk.ApplicationWindow {

    private Gtk.Grid main_layout;
    private Gtk.ActionBar bottombar;
    private Gtk.HeaderBar headerbar;
    private Gtk.StackSwitcher view_switcher;
    private Gtk.Stack view_stack;
    
    private DailyView today;
    private OverviewView overview;
    
    private Gtk.Button hb_newtask; // is now placed in the ActionBar, will rename when I'm sure of its new location
    private Gtk.Button hb_settings;
    private Gtk.Button bb_sync;
    
    private TaskController controller;
    
    /**
     * Constructor of the MainWindow class.
     */
    public MainWindow (Gtk.Application app_context) {
        Object (application: app_context); // no idea, have to look this up...
        controller = new TaskController ();
        setup_window ();
        setup_widgets ();
        connect_signals ();
        load_css ();
        fill ();
    }
    
    /**
     * Reloads all tasks.
     */
    public void reset () {
        today.reset ();
        overview.reset ();
        controller.reset ();
        fill ();
    }
    
    /**
     * Sets window size and place.
     * Doesn't do much right now...
     */
    private void setup_window () {
        this.set_default_size (400, 500);
    }
    
    /**
     * 
     */
    private void setup_widgets () {
        main_layout = new Gtk.Grid ();
        view_switcher = new Gtk.StackSwitcher ();
        view_stack = new Gtk.Stack ();
        
        setup_headerbar ();
        setup_bottombar ();
        
        today = new DailyView ();
        overview = new OverviewView (this);
        
        view_switcher.set_stack (view_stack);
        view_switcher.halign = Gtk.Align.CENTER;
        view_stack.add_titled (today, "daily", "Today");
        view_stack.add_titled (overview, "overview", "Overview");
        view_stack.set_transition_type (StackTransitionType.SLIDE_LEFT_RIGHT);
        view_switcher.margin = 6;

        main_layout.orientation = Gtk.Orientation.VERTICAL;
        main_layout.set_column_homogeneous (true);
        main_layout.add (view_switcher);
        main_layout.add (view_stack);
        main_layout.add (bottombar);
        
        this.add (main_layout);
    }
    
    /**
     * 
     */
    private void setup_headerbar () {
        headerbar = new Gtk.HeaderBar ();
        hb_newtask = new Gtk.MenuButton();
        //hb_newtask = new Gtk.Button.from_icon_name ("add", Gtk.IconSize.LARGE_TOOLBAR);
        hb_settings = new Gtk.Button.from_icon_name ("document-properties", Gtk.IconSize.LARGE_TOOLBAR);

        string windowtitle = "Planner";

        headerbar.title = windowtitle;
        headerbar.pack_end (hb_settings);
        //headerbar.pack_end (hb_newtask);
        headerbar.set_show_close_button (true);
        
        this.set_titlebar (headerbar);
    }
    
    private void setup_bottombar () {
        bottombar = new Gtk.ActionBar ();
        bb_sync = new Gtk.Button.from_icon_name ("view-refresh", Gtk.IconSize.SMALL_TOOLBAR);
        bb_sync.set_relief (Gtk.ReliefStyle.NONE);
        bb_sync.can_focus = false;
        hb_newtask = new Gtk.Button.from_icon_name ("list-add-symbolic", Gtk.IconSize.SMALL_TOOLBAR);
        hb_newtask.set_relief (Gtk.ReliefStyle.NONE);
        hb_newtask.can_focus = false;
        bottombar.pack_start (bb_sync);
        bottombar.pack_end (hb_newtask);
    }
    
    /**
     * Adds the tasks to the views.
     */
    private void fill () {
        int i = 0;
        Task task;
        while (controller.get_task (ref i, out task)) {
            overview.add_task(task);
            if (task.show && !task.done)
                today.add_task(task);
        }
    }
    
    /**
     * Adds a task to the views and controller.
     */
    private bool add_task (Task newtask) {
        if (controller.add_task(newtask)) {
            overview.add_task (newtask);
            if (newtask.show && !newtask.done)
                today.add_task (newtask);
            return true;
        }
        return false;
    }
    
    /**
     * Replaces a task with another task and adds the task to the DailyView if neccesary.
     */
    private void edit_task (Task origtask, Task newtask) {
        bool add = (!origtask.show && newtask.show);
        controller.edit_task (origtask, newtask); 
        if (add) {
            today.add_task (origtask);
        }
    }
    
    /**
     * Loads and applies some css theming, needs some more work as a verbatim string is not the way to go.
     */
    private void load_css () {
        var css_provider = new Gtk.CssProvider();
        try {
            css_provider.load_from_data ("""
GtkLabel.days_text {
    font-size: small;
    color: grey;
}

GtkLabel.task_title {
    font-size: large;
    color: black;
}

OverviewTask:focused GtkLabel.task_title {
    font-size: large;
    color: black;
}

.list-row:selected {
    background: rgb(240,240,240);
}

.list-row {
    background: white;
}""", -1);
            Gtk.StyleContext.add_provider_for_screen(Gdk.Screen.get_default(),css_provider, Gtk.STYLE_PROVIDER_PRIORITY_USER);
        } catch (Error e) {
            error ("Cannot load CSS stylesheet: %s", e.message);
        }
    }
    
    /**
     * Connects the signals of the views and the buttons to their respective actions.
     */
    private void connect_signals () {
        today.marked_task.connect ( () => {
            controller.write ();
        });
        
        overview.marked_task.connect ( (task) => {
            controller.write ();
            if (!task.done) {
                today.add_task (task);
            }
        });
        
        overview.removed_task.connect ( (task) => {
            controller.delete_task (task);
            task.show = false;
        });
        
        overview.changed_task.connect ( (task) => {
            TaskDialog dial = new TaskDialog (this, task);
            dial.show_all ();
            dial.clicked_apply.connect ( (origtask, newtask) => {
                edit_task (origtask, newtask);
                dial.destroy ();
            });
        });
        
        hb_newtask.clicked.connect ( () => {
            TaskDialog dial = new TaskDialog (this, null);
            dial.show_all ();
            dial.clicked_apply.connect ( (origtask, newtask) => {
                add_task (newtask);
                dial.destroy ();
            });
        });
        
        bb_sync.clicked.connect ( () => {
            reset ();
        });
    }
}
