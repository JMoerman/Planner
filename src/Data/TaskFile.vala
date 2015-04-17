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
 * A class for saving tasks to and loading tasks from a file. 
 */
public class TaskFile : GLib.Object {

    private int day_of_year;
    private string filename;
    private string path;
    private int version; // version of file format
    
    /**
     * Constructor of the TaskFile class.
     * @param path directory where the tasks are stored.
     * @param filename name of the file to store the tasks in or load the tasks from
     * @param day the number of this day in this year.
     */
    public TaskFile (string path, string filename, int day) {
        this.filename = filename;
        this.path = path;
        day_of_year = day;
        version = 1;
    }
    
    /**
     * Sets the current day.
     * @param day the new value for the current day of year.
     */
    public void set_day (int day) {
        day_of_year = day;
    }

    /**
     * Reads all tasks from a xml file and adds them to taskstorage.
     * @param taskstorage ArrayList to add the tasks to.
     * @return true if no errors occured, false otherwise.
     */
    public bool read (Gee.ArrayList<Task> taskstorage) {
        Xml.Doc* doc = Xml.Parser.parse_file (path + filename);
        int day = -1, file_version = -1;
        
        if (doc == null) {
            stdout.printf ("File not found or wrong permissions.\n");
            return false;
        }

        Xml.Node* root = doc->get_root_element ();
        if (root == null) {
            stdout.printf ("Missing root element!\n");
            delete doc;
            return false;
        }

        if (root->name == "tasks") {
            string? day_str = root->get_prop ("day");
            if (day_str != null) {
                day = int.parse (day_str);
            } else {
                stdout.printf ("Expected: <tasks day=...\n");
            }
            string? version_str = root->get_prop ("version");
            if (version_str != null) {
                file_version = int.parse (version_str);
                if (file_version != version) {
                    stdout.printf ("%s: Version doesn't match the expected version for this release!", path + filename);
                }
            } else {
                stdout.printf ("%s: Missing version attribute!\n", path + filename);
            }
            if (!read_tasks (root, taskstorage, day == day_of_year)) {
                delete doc;
                return false;
            }
        } else {
            stdout.printf ("Unexpected element %s\n", root->name);
            delete doc;
            return false;
        }

        delete doc;
        return true;
    }
    
    /**
     * Parses all child nodes of node as tasks and adds them to taskstorage.
     * @param keep wether or not the file is up to date.
     */
    private bool read_tasks (Xml.Node* node, Gee.ArrayList<Task> taskstorage, bool keep) {
        assert (node->name == "tasks");
        
        bool succes = true;
        
        for (Xml.Node* iter = node->children; iter != null; iter = iter->next) {
            if (iter->type == Xml.ElementType.ELEMENT_NODE) {
                if (iter->name == "task") {
                    if (!read_task (iter, taskstorage, keep))
                        succes = false;
                } else {
                    stdout.printf ("Unexpected element %s\n", iter->name);
                    succes = false;
                }
            }
        }
        return succes;
    }
    
    /**
     * Adds a task to taskstorage, if node contains a valid task.
     */
    private bool read_task (Xml.Node* node, Gee.ArrayList<Task> taskstorage, bool keep) {
        
        Task newtask;
        
        assert (node->name == "task");
        
        string taskname = "", weeks = "111111", days = "", important = "", done = "";
        bool bool_important = false, bool_done = false, lingering = false;

        for (Xml.Node* iter = node->children; iter != null; iter = iter->next) {
            if (iter->type == Xml.ElementType.ELEMENT_NODE) {
                switch (iter->name) {
                case "taskname":
                    get_content (iter, "taskname", out taskname);
                    break;
                    
                case "weeks":
                    get_content (iter, "weeks", out weeks);
                    break;
    
                case "days":
                    get_content (iter, "days", out days);
                    break;
                    
                case "important":
                    get_content (iter, "important", out important);
                    break;
                    
                case "done":
                    get_content (iter, "done", out done);
                    break;
                    
                case "lingering":
                    string temp;
                    get_content (iter, "lingering", out temp);
                    lingering = bool.parse (temp);
                    break;

                default:
                    stdout.printf ("Unexpected element %s\n", iter->name); // file generated by newer version?
                    break;
                }
            }
        }
        if ( (taskname == "") || !(days.length == 7) || !(weeks.length == 6) || 
                !(bool.try_parse(important, out bool_important)) || !(bool.try_parse(done, out bool_done)) ) {
            return false;
        } else {
            if (keep || (lingering && !TaskUtils.today (weeks, days, null))) // task data is up to date
                newtask = new Task.from_data (taskname, weeks, days, bool_important, bool_done, lingering);
            else // task data needs to be refreshed
                newtask = new Task.from_data (taskname, weeks, days, bool_important, false, lingering);
            
            taskstorage.add (newtask);
        }
        return true;
    }
    
    /**
     * Getting the value of the first child of node, if possible.
     */
    private static bool get_content (Xml.Node* node, string node_name, out string content) {
        assert (node->name == node_name);
        Xml.Node* iter = node->children;
        if (iter != null) {
            if (iter->type == Xml.ElementType.TEXT_NODE) {
                content = iter->get_content ();
                return true;
            } else {
                stdout.printf ("Unexpected element %s\n", iter->name);
            }
        }
        content = "";
        return false;
    }
    
    private inline void ret_to_ex (int errc) throws FileError {
        if (errc < 0) {
            throw new FileError.FAILED ("Writing failed!");
        }
    }
    
    private void write_task (Xml.TextWriter writer, Task task) throws FileError {
        ret_to_ex (writer.start_element ("task"));
        
        ret_to_ex (writer.write_element ("taskname", task.taskname));
        
        ret_to_ex (writer.write_element ("weeks", task.weeks));
        
        ret_to_ex (writer.write_element ("days", task.days));
        
        ret_to_ex (writer.write_element ("important", task.important.to_string()));
        
        ret_to_ex (writer.write_element ("done", task.done.to_string()));
        
        ret_to_ex (writer.write_element ("lingering", task.lingering.to_string()));

        ret_to_ex (writer.end_element ());
    }
    
    /**
     * Writes all tasks to a xml file.
     */
    public void write (Gee.ArrayList<Task> tasks) {
        create_path ();
        
        Xml.TextWriter writer = new Xml.TextWriter.filename (path + filename, false);
        
        if (writer == null) {
	        stdout.printf ("Error: Xml.TextWriter.filename () == null\n");
	    }
        
        try {
            ret_to_ex (writer.start_document ("1.0", "utf-8"));
            writer.set_indent (true);
            
            ret_to_ex (writer.start_element ("tasks"));
            ret_to_ex (writer.write_attribute ("day", day_of_year.to_string ()));
            ret_to_ex (writer.write_attribute ("version", version.to_string ()));
            
            foreach (Task task in tasks) {
                write_task (writer, task);
            }
            
            ret_to_ex (writer.end_element ());
            
            ret_to_ex (writer.flush ());
        } catch (Error e) {
            stdout.printf ("Error: %s\n", e.message);
        }
    }
    
    /**
     * On one of my systems the TextWriter didn't create a file in an existing directory.
     * This function makes sure that both the file and directory exist.
     */
    private void create_path () {
        var file = File.new_for_path (path + filename);
        var file_path = File.new_for_path (path);
        
        try {
            if (!file_path.query_exists()) {
                stdout.printf ("Directory %s does not exist! Trying to create it!\n", path);
                file_path.make_directory_with_parents ();
            }
            if (!file.query_exists ()) {
                stdout.printf ("The file %s does not exist! Trying to create it!\n", path + filename);
                // creating an empty file. 
                file.create (FileCreateFlags.REPLACE_DESTINATION);
            }
        } catch (Error e) {
            stdout.printf ("Error: %s\n", e.message);
        }
    }
}
