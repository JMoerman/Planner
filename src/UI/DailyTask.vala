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

/**
 * A single row in DailyView.
 */
class DailyTask : Gtk.ListBoxRow {
    
    private Task data;
    
    private Gtk.Box layout;
    
    private Gtk.Label taskname_label;
    private Gtk.CheckButton done_button;
    private Gtk.Image important_image;
    
    public signal void clicked ();
    public signal void irrelevant ();

    public DailyTask (Task task) {
        data = task;
        setup_layout ();
        connect_signals ();
        
        this.show_all ();
    }
    
    /**
     * Initializes
     */
    private void setup_layout () {
        layout = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
        
        done_button = new Gtk.CheckButton ();
        
        taskname_label = new Gtk.Label (data.taskname);
        taskname_label.get_style_context().add_class("task_title");
        
        if (data.important)
            important_image = new Gtk.Image.from_icon_name("remove", Gtk.IconSize.BUTTON);
        else
            important_image = new Gtk.Image ();
        
        layout.pack_start (done_button);
        layout.set_center_widget (taskname_label);
        layout.set_child_packing (taskname_label, true, true, 0, Gtk.PackType.START);
        layout.pack_end (important_image);
        
        this.add (layout);
    }
    
    /**
     * Updates the label and icon.
     */
    public void update () {
        taskname_label.set_text (data.taskname);
        if (data.important)
            important_image.set_from_icon_name("remove", Gtk.IconSize.BUTTON);
        else
            important_image.clear ();
        changed ();
    }
    
    private void connect_signals () {
        done_button.toggled.connect ( () => {
            clicked ();
        });
        
        data.changed.connect ( () => {
            if (data.done || !data.show)
                irrelevant ();
            else 
                update ();
        });
    }
    
    public void strike () {
        data.done = true;
    }
    
    public int compare (DailyTask othertask) {
        return othertask.task.compare (data);
    }
    
    public Task task {
        get { return data; }
    }
}
