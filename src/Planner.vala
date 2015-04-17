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
 * Main class, this class currently doesn't do much.
 * The name of this class will change as soon as I know of a good name for this application.
 */
public class Planner : Gtk.Application {
    
    public Planner () {
        Object(application_id: "testing.my.application",
                flags: ApplicationFlags.FLAGS_NONE);
    }
    
    protected override void activate () {
        var window = new MainWindow(this);
        window.show_all ();
    }
    
    public static int main (string[] args) {
        Planner planner = new Planner ();
        
        return planner.run(args);
    }
}
