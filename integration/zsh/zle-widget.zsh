# rundir ZSH integration
# 
# This ZLE widget makes it possible to invoke runnable directories from an
# interactive ZSH shell, provided that the name of the runnable directory is
# the first argument on the line entered.  The directory may be an actual path
# to a directory or the name of a runnable subdirectory of any directory on
# $PATH.  To invoke a directory in the current working directory, `./` (or
# something equivalent, like the absolute path) must be prepended to its name,
# just like when executing a regular file in the current directory.  If the
# first argument does not meet these criteria, then this widget will let ZSH
# handle it normally.
# 
# Parameter and arithmetic expansion, but not command substitution,
# will be performed on the directory's name.  The history entry for the line
# will show the actual rundir command used to run the directory.
# 
# Copyright (c) 2015 Scott Zeid.
# http://code.s.zeid.me/rundir
# 
# Released under the X11 License:  <https://tldrlegal.com/license/x11-license>


function rundir_process_line() {
 if (which rundir &>/dev/null); then
  zle vi-beginning-of-line
  zle vi-first-non-blank
  # get first argument from buffer in a (hopefully) safe manner
  # parameter and arithmetic expansion are done but not command substitution
  local line="${(q)RBUFFER}"
: 'quotes';                line=${line//\\\"/\"}; line=${line//\\\'/\'}
: 'whitespace';            line=${line//\\ / }; line=${line//\\	/	}
: 'variables';             line=${line//\\\$/\$}
: 'parameter expansion';   line=${line//\$\\\{/\$\{}; line=${line//\\\}/\}}
: 'arithmetic expansion';  line=${line//\$\\\(\\\(/\$\(\(}; line=${line//\\\)\\\)/\)\)}
: 'escape $() expansions'; line=${line//\$\\\(/\\\$\\\(}
  local arg0=
  eval "function() { arg0=\$1; } $line" #${${(z)line}[1]}"
  
  if [ -d "$arg0" ] && (printf '%s' "$arg0" | grep -q -e '/') && \
     (__rundir_is_runnable_dir "$arg0"); then
   if (printf "$arg0" | grep -e '^-'); then
    RBUFFER="rundir -- $RBUFFER"
   else
    RBUFFER="rundir $RBUFFER"
   fi
  elif (rundir -w "$arg0" &>/dev/null); then
   RBUFFER="rundir -p $RBUFFER"
  fi
 fi
 zle accept-line
}
zle -N rundir_process_line_widget rundir_process_line
bindkey '^J' rundir_process_line_widget
bindkey '^M' rundir_process_line_widget

__rundir_is_runnable_dir() {
 if [ -z "$1" ]; then
  echo "$SCRIPT:is_runnable_dir: first argument must be the directory" >&2
  return 127
 fi
 
 local dir=$1
 shift
 
 [ ! -d "$dir" ] && return 1
 [ -x "$dir/run" ] && return 0
 [ -f "$dir/run.mk" ] && return 0
 [ -x "$dir/AppRun" ] && return 0
 return 1
}
