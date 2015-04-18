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

using Gee;

/**
 * A widget for displaying and modifying all tasks.
 */
class OverviewView : Gtk.ScrolledWindow {

    private LinkedList<OverviewTask> tasks;
    private Gtk.ListBox layout;
    private OverviewTask previous_task;
    private Gtk.Window? mainwindow;
    private PlaceholderWidget placeholder;
    
    public signal void marked_task (Task task);
    public signal void removed_task (Task task);
    public signal void changed_task (Task task);
    
    /**
     * Constructor of the OverviewView class.
     */
    public OverviewView (Gtk.Window? parent) {
        this.mainwindow = parent;
        layout = new Gtk.ListBox ();
        layout.expand = true;
        
        layout.set_sort_func(sort_func);
        
        placeholder = new PlaceholderWidget ("Add some tasks!", "You don't seem to have any tasks.");
        layout.set_placeholder (placeholder);
        
        tasks = new LinkedList<OverviewTask> ();
        
        layout.row_activated.connect ( (row) => {
            ((OverviewTask) row).toggle_show ();
            if (previous_task != null && previous_task != row) {
                previous_task.show_options (false);
            }
            previous_task = ((OverviewTask) row);
        });
        
        this.add (layout);
    }
    
    /**
     * Adds a new task represented as OverviewTask to this.
     */
    public void add_task (Task task) {
        OverviewTask new_task = new OverviewTask (task);
    
        tasks.add(new_task);
        layout.add(tasks.last());
        new_task.task_marked.connect ( (done) => {
            marked_task (new_task.task);
        });
        new_task.clicked_remove.connect ( () => {
            ask_remove (new_task);
        });
        new_task.clicked_edit.connect ( () => {
            changed_task (new_task.task);
        });
        new_task.show ();
    }
    
    private void ask_remove (OverviewTask task) {
        Gtk.MessageDialog msg = new Gtk.MessageDialog (mainwindow,
            Gtk.DialogFlags.MODAL, Gtk.MessageType.QUESTION, Gtk.ButtonsType.OK_CANCEL, "Are you sure?");
        msg.response.connect ((response_id) => {
            switch (response_id) {
                case Gtk.ResponseType.OK:
                    removed_task (task.task);
                    tasks.remove (task);
                    task.destroy ();
                    break;
                default:
                    break;
            }

            msg.destroy();
        });
        msg.show ();
    }
    
    private int sort_func (Gtk.ListBoxRow row1, Gtk.ListBoxRow row2) {
        return ((OverviewTask) row1).compare ((OverviewTask) row2);
    }
    
    /**
     * Removes all tasks from this OverviewView.
     */
    public void reset () {
        foreach (OverviewTask task in tasks) {
            task.destroy ();
        }
        tasks.clear ();
    }
}
