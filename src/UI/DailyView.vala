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
 * A widget for displaying all tasks that need to be completed today.
 */
class DailyView : Gtk.ScrolledWindow {

    private LinkedList<DailyTask> tasks;
    private Gtk.ListBox layout;
    private PlaceholderWidget placeholder;
    
    public signal void marked_task ();
    
    /**
     * Constructor of the DailyView class.
     */
    public DailyView () {
        layout = new Gtk.ListBox ();
        layout.set_sort_func(sort_func);
        layout.expand = true;
        
        placeholder = new PlaceholderWidget ("Good job!", "You seem to be done for today!");
        layout.set_placeholder (placeholder);
        
        tasks = new LinkedList<DailyTask> ();
        
        this.add (layout);
    }
    
    /**
     * Adds a task.
     */
    public void add_task (Task task) {
        
        DailyTask new_task = new DailyTask (task);
    
        tasks.add(new_task);
        layout.add(tasks.last());
        new_task.clicked.connect ( () => {
            //tasks.remove (new_task);
            new_task.strike ();
            marked_task ();
        });
        new_task.irrelevant.connect ( () => {
            tasks.remove (new_task);
            new_task.destroy ();
        });
        new_task.show ();
    }
    
    /**
     * Removes all tasks.
     */
    public void reset () {
        foreach (DailyTask task in tasks) {
            task.destroy ();
        }
        tasks.clear ();
    }
    
    private int sort_func (Gtk.ListBoxRow row1, Gtk.ListBoxRow row2) {
        return ((DailyTask) row1).compare ((DailyTask) row2);
    }
}
