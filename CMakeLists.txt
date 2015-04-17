# project name
project (Planner)
# the oldest stable cmake version we support
cmake_minimum_required (VERSION 2.6)
# tell cmake where its modules can be found in our project directory
list (APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake)
# where we install data directory (if we have any)
set (DATADIR "${CMAKE_INSTALL_PREFIX}/share")
# what to call that directory where we install data too
set (PKGDATADIR "${DATADIR}/Planner")
set (EXEC_NAME "Planner")
set (RELEASE_NAME "A recurring tasks application.")
set (VERSION "0.1")
set (VERSION_INFO "The version with only the basics implemented.")
#set (CMAKE_C_FLAGS "-ggdb")
# disabling those anoying incompatible pointer warnings:
set (CMAKE_C_FLAGS "-w")

set (CORE_DEPS "gobject-2.0;glib-2.0;gio-2.0;gee-0.8;libxml-2.0;")
set (UI_DEPS "gtk+-3.0>=3.12.0;")

find_package(PkgConfig)
pkg_check_modules (DEPS REQUIRED "${CORE_DEPS}${UI_DEPS}")
add_definitions(${DEPS_CFLAGS})
link_libraries(${DEPS_LIBRARIES})
link_directories(${DEPS_LIBRARY_DIRS})

find_package(Vala REQUIRED)
include(ValaVersion)

# I guess 0.20 will also work, using 0.28 here
ensure_vala_version("0.20" MINIMUM)

include(ValaPrecompile)
vala_precompile(VALA_C ${EXEC_NAME}
    src/Data/Task.vala
    src/Data/TaskUtils.vala
    src/Data/TaskFile.vala
    src/Data/TaskController.vala
    src/UI/OverviewTask.vala
    src/UI/TaskDialog.vala
    src/UI/OverviewView.vala
    src/UI/DailyTask.vala
    src/UI/DailyView.vala
    src/UI/MainWindow.vala
    src/Planner.vala
    
# tell what libraries to use when compiling
PACKAGES
    gtk+-3.0
    gee-0.8
    gio-2.0
    libxml-2.0
)
# tell cmake what to call the executable we just made
add_executable(${EXEC_NAME} ${VALA_C})
# install the binaries we just made
install (TARGETS ${EXEC_NAME} RUNTIME DESTINATION bin)
# install our .desktop file so the Applications menu will see it
#install (FILES ${CMAKE_CURRENT_SOURCE_DIR}/data/Planner.desktop DESTINATION ${DATADIR}/applications/)
