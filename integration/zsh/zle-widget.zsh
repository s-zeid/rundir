# vim: set fdm=marker:
# 
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
# https://code.s.zeid.me/rundir
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
  
  if [ -n "$arg0" ] && (__rundir_is_command "$arg0"); then
   if [ -d "$arg0" ] && \
      (printf '%s' "$arg0" | grep -q -e '/') && \
      (__rundir_is_runnable_dir "$arg0"); then
    if (printf "$arg0" | grep -e '^-'); then
     RBUFFER="rundir -- $RBUFFER"
    else
     RBUFFER="rundir $RBUFFER"
    fi
   #elif (rundir -w "$arg0" &>/dev/null); then
   elif (__rundir_resolve_path "$arg0" &>/dev/null) &&
        (__rundir_is_runnable_dir "$(__rundir_resolve_path "$arg0")"); then
    RBUFFER="rundir -p $RBUFFER"
   fi
  fi
 fi
 zle accept-line
}
zle -N rundir_process_line_widget rundir_process_line
bindkey '^J' rundir_process_line_widget
bindkey '^M' rundir_process_line_widget


__rundir_is_command() {
 if [ -z "$1" ]; then
  echo "$0:is_command: first argument must be non-empty" >&2
  return 127
 fi
 
 local arg=$1
 shift
 
 if (type -- "$arg" \
     | grep -q -e 'is an\? \(shell \(builtin\|function\)\|alias\|reserved\)'); then
  return 1
 fi
 
 return 0
}


__rundir_is_runnable() {
 if [ -z "$1" ]; then
  echo "$0:is_runnable: first argument must be the file or directory" >&2
  return 127
 fi
 
 local file=$1
 shift
 
 [ ! -d "$file" ] && [ -x "$file" ] && return 0
 __rundir_is_runnable_dir "$file" || return 1
}


# Runnable directory logic {{{1

__rundir_is_runnable_dir() {
 if [ -z "$1" ]; then
  echo "$0:is_runnable_dir: first argument must be the directory" >&2
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


__rundir_resolve_path() {
 # handle the case where the last path component is empty
 if [ x"$1" = x"" ] || (printf '%s' "$1" | grep -q -e '/$'); then
  return 1
 fi
 
 local dir=$(basename "/$1")
 local all=$2
 if [ x"$all" = x"" ] || [ x"$all" = x"0" ]; then
  all=0
 else
  all=1
 fi
 
 local r=127
 
 #local search=$PATH:
 #while [ -n "$search" ]; do
 # local i=${search%%:*}
 # local search=${search#*:}
 local oldifs=$IFS
 IFS=:
 local i
 for i in ${=PATH}; do
  if __rundir_is_runnable "$i/$dir"; then
   echo "$i/$dir"
   r=0
   if [ $all -eq 0 ]; then
    break
   fi
  fi
 done
 IFS=$oldifs
 if [ $r -eq 127 ]; then
  r=1
 fi
 return $r
}
