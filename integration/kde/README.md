rundir KDE integration
======================

This directory contains service menu entries that will add "Run Folder"
and "Run Folder in Konsole" items to context menus in KDE file managers
such as Dolphin and Konqueror.

Installation
------------

1.  Copy `rundir.desktop` and `rundir_konsole.desktop` to
    `~/.local/share/kservices5/ServiceMenus` (for KDE 5) or
    `~/.kde/share/kde4/services/ServiceMenus` (for KDE 4),
    creating that directory if it does not exist.

2.  If necessary, ensure that the menu items are enabled
    in your file manager (in Dolphin and Konqueror, go to
    the Services (or File Management > Services) section in
    Settings > Configure <program>).
