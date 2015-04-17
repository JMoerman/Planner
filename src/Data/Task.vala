/**
 * This class is used to store and access all information of a task.
 */
public class Task : GLib.Object {
    private string _weeks;
    private string _days;
    private string _taskname;
    private bool _important;
    private bool _done;
    private bool _show;
    private bool _lingering;
    
    /**
     * This string is used to store the information about the weeks in which this task needs to be shown. 
     * This consisting of 6 chars, 5 chars for 5 weeks and a final char to represent the last 7 days of the month.
     * Each char represents a boolean value, '1' is interpreted as true, everything else as false.
     */
    public string weeks {
        get { return _weeks; }
        set { 
            if (value.length == 6) {
                _weeks = value;
                check_relevant ();
                changed ();
            }
        }
    }
    
    /**
     * This string is used to store the information about the days at which this task needs to be shown. 
     * This consisting of 7 chars, for each day one char, starting with monday.
     * Each char represents a boolean value, '1' is interpreted as true, everything else as false.
     */
    public string days {
        get { return _days; }
        set { 
            if (value.length == 7) {
                _days = value;
                check_relevant ();
                changed ();
            }
        }
    }
    
    /**
     * The title of this task.
     */
    public string taskname {
        get { return _taskname; }
        set { 
            string stripped_value = value.strip ();
            if (stripped_value.length != 0) {
                _taskname = stripped_value;
                changed ();
            }
        }
    }
    
    /**
     * Whether or not this task is important.
     */
    public bool important {
        get { return _important; }
        set { _important = value; changed ();}
    }
    
    /**
     * Whether or not to show this task today.
     */
    public bool show {
        get { return _show; }
        set { _show = value; changed ();}
    }
    
    /**
     * Whether or not this task is done.
     */
    public bool done {
        get { return _done; }
        set { _done = value; changed ();}
    }
    
    /**
     * If true, the task must be shown until it is finished. 
     */
    public bool lingering {
        get { return _lingering; }
        set { _lingering = value; check_relevant (); changed (); }
    }
    
    public signal void changed ();

    /**
     * Creates an empty task, not for direct use.
     */
    public Task () {
        _days = "0000000";
        _weeks = "111111";
        _taskname = "NULL";
        _important = false;
        _done = false;
        _lingering = false;
        check_relevant ();
    }
    
    /**
     * Constuctor of the Task class.
     * Creates a task from parameters.
     */
    public Task.from_data (string taskname, string weeks, string days, bool important, bool done, bool lingering) {
        _weeks = weeks;
        _days = days;
        _taskname = taskname.strip ();
        _important = important;
        _done = done;
        _lingering = lingering;
        check_relevant ();
    }
    
    /**
     * Constuctor of the Task class.
     * Creates a task as a copy from an other task.
     */
    public Task.from_task (Task task) {
        set_task (task);
    }
    
    /**
     * Returns a copy of this task.
     */
    public Task copy () {
        return new Task.from_task (this);
    }
    
    /**
     * Replaces the contents of this task with the contents of another task.
     */
    public void replace (Task task) {
        set_task (task);
        changed ();
    }
    
    private void set_task (Task task) {
        _weeks = task.weeks;
        _days = task.days;
        _taskname = task.taskname;
        _important = task.important;
        _done = task.done;
        _show = task.show;
        _lingering = task.lingering;
    }
    
    /**
     * Compares the importance and name of this task and an other task.
     */
    public int compare (Task othertask) {
        if ( this.important && !othertask.important )
            return 1;
        if ( !this.important && othertask.important )
            return -1;
        if ( this.taskname > othertask.taskname )
            return -1;
        if ( this.taskname < othertask.taskname )
            return 1;
        return 0;
    }
    
    /**
     * Checks whether or not this tasks needs to be shown today.
     */
    private void check_relevant () {
        if ( _lingering && !_done) {
            _show = true;
        }
        else {
            _show = TaskUtils.today(_weeks,_days,null);
        }
    }
}


