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
 * A dialog for creating or editing tasks.
 */
public class TaskDialog : Gtk.Dialog {
    
    private Gtk.Grid layout;
    private Gtk.Box days_box;
    private Gtk.Box weeks_box;
    
    private Gtk.Entry name_field;
    
    private Gtk.Widget button_add;
    private Gtk.Widget button_cancel;
    
    private Gtk.ToggleButton mon_button;
    private Gtk.ToggleButton tue_button;
    private Gtk.ToggleButton wed_button;
    private Gtk.ToggleButton thu_button;
    private Gtk.ToggleButton fri_button;
    private Gtk.ToggleButton sat_button;
    private Gtk.ToggleButton sun_button;
    
    private Gtk.ToggleButton week_button1;
    private Gtk.ToggleButton week_button2;
    private Gtk.ToggleButton week_button3;
    private Gtk.ToggleButton week_button4;
    private Gtk.ToggleButton week_button5;
    private Gtk.ToggleButton week_button_last;
    
    private Gtk.Switch important_switch;
    private Gtk.Switch lingering_switch;
    
    private Task origtask;
    private Task newtask;
    
    public signal void clicked_apply (Task origtask, Task newtask);
    public signal void clicked_cancel ();
    
    /**
     * Constructor of the TaskDialog class.
     */
    public TaskDialog (Gtk.Window parent, Task? origtask) {
        
        this.set_transient_for (parent);
        
        if (origtask == null)
            this.title = "Add task";
        else
            this.title = "Edit task";
        
        this.origtask = origtask;
        
        setup_widgets ();
    }

    /**
     * Initializes GUI elements and sets their default state.
     */
    private void setup_widgets () {
        
        name_field = new Gtk.Entry ();
        
        name_field.set_placeholder_text ("Task name");
        name_field.hexpand = true;
        
        if (origtask != null) {
            name_field.set_text (origtask.taskname);
        }
        
        important_switch = new Gtk.Switch ();
        important_switch.halign = Gtk.Align.START;
        important_switch.valign = Gtk.Align.CENTER;
        
        lingering_switch = new Gtk.Switch ();
        lingering_switch.halign = Gtk.Align.START;
        lingering_switch.valign = Gtk.Align.CENTER;
        
        setup_days_box ();
        setup_weeks_box ();
        setup_layout ();
        set_button_values ();
        
        this.border_width = 5;
        this.get_content_area ().margin = 10;
        this.get_content_area ().pack_start (layout);
        
        this.button_cancel = add_button ("Cancel", Gtk.ResponseType.CLOSE);
        if (origtask == null)
            this.button_add = add_button ("Add", Gtk.ResponseType.APPLY);
        else
            this.button_add = add_button ("Apply", Gtk.ResponseType.APPLY);
        this.response.connect (on_response);
    }
    
    /**
     * Creating and filling the layout of the content area.
     * Could use some more work.
     */
    private void setup_layout () {
        
        layout = new Gtk.Grid ();
        layout.orientation = Gtk.Orientation.VERTICAL;
        layout.row_spacing = 6;
        layout.column_spacing = 12;
        
        var title_label = make_label ("Title:");
        var days_label = make_label ("Days:");
        var weeks_label = make_label ("Weeks of the month:");
        var options_label = make_label ("Additional options:");
        var important_label = new Gtk.Label ("Important:");
        var lingering_label = new Gtk.Label ("Lingering:");
        
        layout.attach (title_label,         0, 0, 4, 1);
        layout.attach (name_field,          0, 1, 4, 1);
        layout.attach (days_label,          0, 2, 4, 1);
        layout.attach (days_box,            0, 3, 4, 1);
        layout.attach (weeks_label,         0, 4, 4, 1);
        layout.attach (weeks_box,           0, 5, 4, 1);
        layout.attach (options_label,       0, 6, 4, 1);
        layout.attach (important_label,     0, 7, 1, 1);
        layout.attach (important_switch,    1, 7, 1, 1);
        layout.attach (lingering_label,     2, 7, 1, 1);
        layout.attach (lingering_switch,    3, 7, 1, 1);
    }
    
    private void setup_days_box () {
        
        days_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
        days_box.homogeneous = true;
        days_box.get_style_context ().add_class (Gtk.STYLE_CLASS_LINKED);
        days_box.get_style_context ().add_class ("raised");
        
        mon_button = new Gtk.ToggleButton.with_label ("Mon");
        tue_button = new Gtk.ToggleButton.with_label ("Tue");
        wed_button = new Gtk.ToggleButton.with_label ("Wed");
        thu_button = new Gtk.ToggleButton.with_label ("Thu");
        fri_button = new Gtk.ToggleButton.with_label ("Fri");
        sat_button = new Gtk.ToggleButton.with_label ("Sat");
        sun_button = new Gtk.ToggleButton.with_label ("Sun");
        
        days_box.add (mon_button);
        days_box.add (tue_button);
        days_box.add (wed_button);
        days_box.add (thu_button);
        days_box.add (fri_button);
        days_box.add (sat_button);
        days_box.add (sun_button);
    }
    
    private void setup_weeks_box () {
        weeks_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
        weeks_box.homogeneous = true;
        weeks_box.get_style_context ().add_class (Gtk.STYLE_CLASS_LINKED);
        weeks_box.get_style_context ().add_class ("raised");
        
        week_button1 = new Gtk.ToggleButton.with_label ("1");
        week_button2 = new Gtk.ToggleButton.with_label ("2");
        week_button3 = new Gtk.ToggleButton.with_label ("3");
        week_button4 = new Gtk.ToggleButton.with_label ("4");
        week_button5 = new Gtk.ToggleButton.with_label ("5");
        week_button_last = new Gtk.ToggleButton.with_label ("last");
        
        weeks_box.add (week_button1);
        weeks_box.add (week_button2);
        weeks_box.add (week_button3);
        weeks_box.add (week_button4);
        weeks_box.add (week_button5);
        weeks_box.add (week_button_last);
    }
    
    private void set_button_values () {
        if (origtask == null) {
            mon_button.set_active (true);
            tue_button.set_active (true);
            wed_button.set_active (true);
            thu_button.set_active (true);
            fri_button.set_active (true);
            sat_button.set_active (true);
            sun_button.set_active (true);
            
            week_button1.set_active (true);
            week_button2.set_active (true);
            week_button3.set_active (true);
            week_button4.set_active (true);
            week_button5.set_active (true);
            week_button_last.set_active (true);
            
            important_switch.set_active (false);
            lingering_switch.set_active (false);
        }
        else {
            mon_button.set_active (origtask.days.get_char(0) == '1');
            tue_button.set_active (origtask.days.get_char(1) == '1');
            wed_button.set_active (origtask.days.get_char(2) == '1');
            thu_button.set_active (origtask.days.get_char(3) == '1');
            fri_button.set_active (origtask.days.get_char(4) == '1');
            sat_button.set_active (origtask.days.get_char(5) == '1');
            sun_button.set_active (origtask.days.get_char(6) == '1');
            
            week_button1.set_active (origtask.weeks.get_char(0) == '1');
            week_button2.set_active (origtask.weeks.get_char(1) == '1');
            week_button3.set_active (origtask.weeks.get_char(2) == '1');
            week_button4.set_active (origtask.weeks.get_char(3) == '1');
            week_button5.set_active (origtask.weeks.get_char(4) == '1');
            week_button_last.set_active (origtask.weeks.get_char(5) == '1');
            
            important_switch.set_active (origtask.important);
            lingering_switch.set_active (origtask.lingering);
        }
    }
    
    /**
     * Credits go to Maya developpers.
     */
    private static Gtk.Label make_label (string text) {
        var label = new Gtk.Label ("<span weight='bold'>%s</span>".printf (text));
        label.use_markup = true;
        label.halign = Gtk.Align.START;
        label.valign = Gtk.Align.END;
        return label;
    }
    
    private void on_response (Gtk.Dialog source, int response_id) {
        switch (response_id) {
        case Gtk.ResponseType.APPLY:
            if (gen_task ()) {
                if (origtask == null)
                    clicked_apply (new Task(), newtask);
                else
                    clicked_apply (origtask, newtask);
            }
            else {
                Gtk.MessageDialog msg = new Gtk.MessageDialog (this.get_transient_for(), Gtk.DialogFlags.MODAL, 
                    Gtk.MessageType.INFO, Gtk.ButtonsType.OK, 
                    "The title doesn't seem to have any letters, please enter a valid title."
                );
                msg.response.connect ((response_id) => {
			        msg.destroy();
                });
                msg.show ();
            }
            
            break;
        case Gtk.ResponseType.CLOSE:
            destroy ();
            break;
        }
    }
    
    /**
     * Creates a task from user input.
     */
    private bool gen_task () {
        string taskname;
        if (get_name (out taskname)) {
            bool done;
            if (origtask == null) 
                done = false;
            else 
                done = origtask.done;
            
            bool lingering = lingering_switch.get_active ();
            string days = gen_string_days ();
            string weeks = gen_string_weeks ();
            done = ((lingering && !TaskUtils.today (weeks, days, null)) || done);
            
            newtask = new Task.from_data (taskname, weeks, days, important_switch.get_active (), done, lingering);
            return true;
        }
        else {
            return false;
        }
    }
    
    /**
     * Removes whitespace from the title field and checks if the resulting string is a valid title.
     * @return true if the resulting string has letters, false otherwise.
     */
    private bool get_name (out string taskname) {
        taskname = name_field.get_text ().strip ();
        
        return (taskname.length > 0);
    }
    
    /**
     * Creates a string representation of which buttons are pressed.
     */
    private string gen_string_days () {
        string temp = "0000000";
        char* chartemp = (char*) temp; // we know that the characters are one byte long. 
        if (mon_button.get_active())
            chartemp[0] = '1';
        if (tue_button.get_active())
            chartemp[1] = '1';
        if (wed_button.get_active())
            chartemp[2] = '1';
        if (thu_button.get_active())
            chartemp[3] = '1';
        if (fri_button.get_active())
            chartemp[4] = '1';
        if (sat_button.get_active())
            chartemp[5] = '1';
        if (sun_button.get_active())
            chartemp[6] = '1';
        return temp;
    }
    
    /**
     * Creates a string representation of which buttons are pressed.
     */
    private string gen_string_weeks () {
        string temp = "000000";
        char* chartemp = (char*) temp; // we know that the characters are one byte long. 
        if (week_button1.get_active())
            chartemp[0] = '1';
        if (week_button2.get_active())
            chartemp[1] = '1';
        if (week_button3.get_active())
            chartemp[2] = '1';
        if (week_button4.get_active())
            chartemp[3] = '1';
        if (week_button5.get_active())
            chartemp[4] = '1';
        if (week_button_last.get_active())
            chartemp[5] = '1';
        return temp;
    }
}

