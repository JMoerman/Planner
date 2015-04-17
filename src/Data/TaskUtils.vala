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
 * A class providing methods for calculating whether or not a task needs to be shown this day.
 */
public class TaskUtils : GLib.Object {
    public static bool today ( string weeks, string days, out bool this_week) {
        bool this_weekday;
        var date = new GLib.DateTime.now_local ();
        
        int day, month, year;
        date.get_ymd (out year, out month, out day);
        
        int week = (date.get_day_of_month () / 7);
        
        this_weekday = (days.get_char (date.get_day_of_week () - 1) == '1');
            
        this_week = (weeks.get_char (week) == '1');
        if (last_week (year, month, day) && weeks.get_char (6) == '1')
            this_week = true;
            
        return this_weekday && this_week;
    }
    
    public static bool last_week (int year, int month, int day) {
        return ((GLib.Date.get_days_in_month ((DateMonth) month, (DateYear) year) - day) < 7);
    }
    
}
