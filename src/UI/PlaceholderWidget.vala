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
 * 
 */
class PlaceholderWidget : Gtk.Grid {
    
    private Gtk.Label header_label;
    private Gtk.Label subtext_label;
    private Gtk.Box text_box;
    
    /**
     * Constructor of the PlaceholderWidget class.
     */
    public PlaceholderWidget (string header, string subtext) {
        text_box = new Gtk.Box(Gtk.Orientation.VERTICAL, 20);
        
        header_label = new Gtk.Label (header);
        header_label.get_style_context().add_class("ph_header");
        subtext_label = new Gtk.Label (subtext);
        subtext_label.get_style_context().add_class("ph_subtext");
        
        text_box.add (header_label);
        text_box.add (subtext_label);
        text_box.valign = Gtk.Align.CENTER;
        text_box.expand = true;
        this.add (text_box);
        this.show_all ();
    }
}
