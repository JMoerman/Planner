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
 * A single row in OverviewView.
 */
class OverviewTask : Gtk.ListBoxRow {

    private Task data;
    
    private Gtk.Box layout;
    private Gtk.Box main_layout;
    private Gtk.Box text_box;
    private Gtk.Box options_layout;
    
    private Gtk.Label days_label;
    private Gtk.Label taskname_label;
    private Gtk.CheckButton done_button;
    private Gtk.Button edit_button;
    private Gtk.Button delete_button;
    private Gtk.Image important_image;
    
    private Gtk.Revealer revealer;
    
    private bool external_toggle;
    
    private string[] weekdays = {"mon", "tue", "wed", "thu", "fri", "sat", "sun"};
    
    public signal void task_marked (bool done);
    public signal void clicked_remove ();
    public signal void clicked_edit (Task task);

    /**
     * Constructor of the OverviewTask class.
     */
    public OverviewTask (Task task) {
        data = task;
        external_toggle = false;
        
        layout = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
        
        setup_mainlayout ();
        setup_options ();
        connect_signals ();
        
        layout.pack_start (main_layout);
        layout.pack_end (revealer);
        
        this.add (layout);
        this.show_all();
    }
    
    /**
     * Initializes the widgets of 
     */
    private void setup_mainlayout () {
        main_layout = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
        
        done_button = new Gtk.CheckButton ();
        done_button.set_sensitive (data.show || data.lingering);
        done_button.set_active (data.done);
        
        text_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
        
        taskname_label = new Gtk.Label (data.taskname);
        taskname_label.get_style_context().add_class("task_title");
        days_label = new Gtk.Label (day_string ());
        days_label.get_style_context().add_class("days_text");
        
        text_box.add (taskname_label);
        text_box.add (days_label);
        
        if (data.important)
            important_image = new Gtk.Image.from_icon_name("remove", Gtk.IconSize.BUTTON);
        else
            important_image = new Gtk.Image ();
        
        main_layout.pack_start( done_button, false, false, 0 );
        main_layout.set_center_widget (text_box);
        main_layout.set_child_packing (text_box, true, true, 0, Gtk.PackType.START);
        main_layout.pack_end (important_image);
    }
    
    /**
     * Initializes the expandable part of this widget.
     */
    private void setup_options () {
        revealer = new Gtk.Revealer ();
        revealer.set_transition_type (Gtk.RevealerTransitionType.SLIDE_DOWN);
        
        options_layout = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
        
        edit_button = new Gtk.Button.from_icon_name ("edit", Gtk.IconSize.BUTTON);
        edit_button.set_relief(Gtk.ReliefStyle.NONE);
        
        delete_button = new Gtk.Button.from_icon_name ("edit-delete", Gtk.IconSize.BUTTON);
        delete_button.set_relief(Gtk.ReliefStyle.NONE);
        
        options_layout.pack_end (delete_button, false, false, 0);
        options_layout.pack_end (edit_button, false, false, 0);
        
        revealer.add (options_layout);
    }
    
    /**
     * Updates the text and icon.
     */
    public void update () {
        taskname_label.set_text (data.taskname);
        days_label.set_text (day_string ());
        if (data.important)
            important_image.set_from_icon_name("remove", Gtk.IconSize.BUTTON);
        else
            important_image.clear ();
        external_toggle = true;
        done_button.set_active (data.done);
        done_button.set_sensitive (data.show || data.lingering);
        changed ();
    }
    
    /**
     * Connects the signals to their respective actions.
     */
    private void connect_signals () {
        done_button.toggled.connect ( () => {
            if (external_toggle) {
                external_toggle = false;
            }
            else {
                data.done = !data.done;
                task_marked (data.done);
                external_toggle = false; // for some reason this is needed here, it shouldn't be.
            }
        });
        
        edit_button.clicked.connect ( () => {
            clicked_edit (data);
        });
        
        delete_button.clicked.connect ( () => {
            clicked_remove ();
        });
        
        data.changed.connect ( () => {
            update ();
        });
    }
    
    /**
     * Shows or hides the options area.
     */
    public void show_options (bool show) {
        revealer.reveal_child = show;
    }
    
    /**
     * Toggles whether or not the options area is shown.
     */
    public void toggle_show () {
        revealer.reveal_child = !revealer.get_reveal_child ();
    }
    
    /**
     * Compares this row with another row.
     */
    public int compare (OverviewTask othertask) {
        return othertask.task.compare (data);
    }
    
    public Task task {
        get { return data; }
    }
    
    /**
     * Returns a human readable string with the days of the week on which this task is displayed.
     */
    private string day_string () {
        string tempstr = "";
        int i = 0;
        for (; i < 7; i++) {
            if (data.days.get (i) == '1') {
                tempstr += weekdays[i];
                break;
            }
        }
        i++;
        for (; i < 7; i++) {
            if (data.days.get (i) == '1') {
                tempstr += " - " + weekdays[i];
            }
        }
        return tempstr;
    }
}
