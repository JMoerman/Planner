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
 * This class manages all tasks and saves/loads them from a file.
 */
class TaskController : GLib.Object {
    private GLib.DateTime date;
    private Gee.ArrayList<Task> tasks;
    private TaskFile taskfile;
    
    /**
     * Constuctor of the TaskController class.
     */
    public TaskController () {
        date = new GLib.DateTime.now_local ();
        tasks = new Gee.ArrayList<Task> ();
        taskfile = new TaskFile (GLib.Environment.get_home_dir () + "/.todo", "/daily.xml", date.get_day_of_year ());
        taskfile.read (tasks);
    }
    
    /**
     * Clears the internal ArrayList of tasks and loads all tasks from a file.
     */
    public void reset () {
        date = new GLib.DateTime.now_local ();
        
        tasks.clear ();
        taskfile.set_day (date.get_day_of_year ());
        taskfile.read (tasks);
    }
    
    /**
     * Writes all tasks to a file.
     */
    public void write () {
        taskfile.write (tasks);
    }
    
    /**
     * Replaces a task and writes the changes to a file.
     */
    public void edit_task (Task origtask, Task newtask) {
        origtask.replace (newtask);
        write ();
    }
    
    /**
     * Removes a task.
     */
    public void delete_task (Task task) {
        if (tasks.remove (task)) {
            write ();
        }
        else {
            warning ("Couldn't find task!");
        }
    }
    
    /**
     * Adds a task.
     */
    public bool add_task (Task newtask) {
        bool succes = tasks.add (newtask);
        write ();
        return succes;
    }
    
    /**
     * Gets the task stored at an index and increases index with one.
     * @param pos index to get task from.
     * @param task the location to store the Task.
     * @return true if index was valid, false otherwise. 
     */
    public bool get_task (ref int pos, out Task task) {
        if (pos < tasks.size) {
            task = tasks.get (pos);
            pos++;
            return true;
        }
        task = null;
        return false;
    }
}
