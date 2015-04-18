# Planner
This application doesn't yet have a name, if you come up with something nice, please let me know!

This is a simple application for managing tasks for each day of the month.

## Why I am writting this application:
For me it has always been hard to concentrate on tasks that aren't as intersting as browsing the web, etc... and most of the time I didn't get to do the things I think were most important on each day.

I tried using todo list applications, but they had little effect on my problems.

The idea of a todo application was good, but I needed something that would reward me for just doing every day tasks, something that allowed me to start with a clean slate every day.

Right now, the only reward I get from completing tasks is a small or empty task list at the end of the day, this already helps, but it will get more rearding when I implement some of the planned features.

## Features:
- Two levels of important: normal and important.
- Two kinds of tasks, one type of task that will only display on the configured days, and one that continues to display if you weren't able to finish it the day before.

A lot of work still needs to be done, as only basic functionality has been implemented.

(The tasks are stored in ~/.todo/daily.xml, you can't change this right now.)

## Planned features:
- Settings
- Option to launch an other application when the last (important) task is finished.
- Statistics: How much you got done for the last week.
- Focus mode: blocking distractive sites untill you're done with your important tasks.
- Borrowing the timer from _Go For It!_ ? (Look [here](https://github.com/mank319/Go-For-It/) for this awesome little application.)
- Synchronisation

## How to build this application:

This application depends on libxml2, valac and Gtk+-3.0 >= 3.12. 

On Ubuntu libxml2-dev is incomplete, so you will have to install libxslt1-dev as well (sudo apt-get install libxml2-dev libxslt1-dev).

    mkdir build
    cd build
    cmake -DCMAKE_INSTALL_PREFIX=/usr ../
    make
    sudo make install (This doesn't have an advantage, as of yet.)
