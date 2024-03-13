# Colours
set -gu __seer_trivial_color        (set_color brgrey)
set -gu __seer_normal_color         (set_color normal)
set -gu __seer_success_color        (set_color cyan)
set -gu __seer_error_color          (set_color red)
set -gu __seer_directory_color      (set_color blue)
set -gu __seer_bold_directory_color (set_color blue)
set -gu __seer_pristine_repo_color  (set_color green)
set -gu __seer_touched_repo_color   (set_color yellow)
set -gu __seer_git_directory_color  (set_color purple)

# Symbols
set -gu __seer_alive_whale ". ><((.___)"
set -gu __seer_dead_whale  ". ><((x___)"
set -gu __seer_ahead       " ↑"
set -gu __seer_behind      " ↓"
set -gu __seer_diverged    " ↕"
set -gu __seer_dirty       " ✘"
set -gu __seer_none        " ≈"

# Helpers
function __seer_prompt_status -d "Display the whale, showing last command status"
  if test $argv[1] -eq 0
    echo -n -s $__seer_trivial_color $__seer_alive_whale $__seer_normal_color
  else
    echo -n -s $__seer_error_color $__seer_dead_whale $__seer_normal_color
  end
end

function __seer_path_parent -d "Display a parent directory, shortened to fit the prompt"
  echo -n (dirname $argv[1]) | sed -e "s#^$HOME#~#" -e 's#/\(\.\{0,1\}[^/]\)\([^/]*\)#/\1#g' -e 's#/$##'
end

function __seer_path_segment -d "Display a shortened form of a directory"
  set -l directory
  set -l parent

  switch "$argv[1]"
    case /
      set directory "/"
    case "$HOME"
      set directory "~"
    case "*"
      set parent (__seer_path_parent "$argv[1]")
      set parent "$parent/"
      set directory (basename "$argv[1]")
  end

  echo -n -s " " $__seer_directory_color $parent $__seer_normal_color
  echo -n -s $__seer_bold_directory_color $directory $__seer_normal_color
end

function __seer_prompt_git -d "Display the git root, git branch, and then path in the repo"
  set -l git_in_git_dir (command git rev-parse --is-inside-git-dir)
  set -l repo_root (command git rev-parse --show-toplevel 2> /dev/null)

  if [ $git_in_git_dir = "true" ]
    set repo_root (command realpath (git rev-parse --git-dir)'/..')
  end

  set -l repo_path (pwd | sed -e "s#^$repo_root##" | sed -e "s#^/##")

  __seer_path_segment $repo_root

  if git_is_touched
    echo -n -s $__seer_trivial_color " on " $__seer_touched_repo_color (git_branch_name) $__seer_normal_color
  else
    echo -n -s $__seer_trivial_color " on " $__seer_pristine_repo_color (git_branch_name) $__seer_normal_color
  end

  if git_is_touched
    echo -n -s $__seer_touched_repo_color $__seer_dirty $__seer_normal_color
  else
    echo -n -s $__seer_pristine_repo_color (git_ahead $__seer_ahead $__seer_behind $__seer_diverged $__seer_none) $__seer_normal_color
  end

  if [ $repo_path != "" ]
    echo -n -s $__seer_trivial_color " in " $__seer_git_directory_color $repo_path $__seer_normal_color
  end
end

function __seer_prompt_dir -d "Display the entire path (but shortened)"
  __seer_path_segment (pwd)
end

# Consider working on this...
# function __seer_prompt_tid -d "Display timesheet short information via tid"
#   command --search tid > /dev/null; and begin
#     set -l tid_duration (tid status --format="{{.Entry.Duration}}")
#     set -l tid_hash (tid status --format="{{.Entry.ShortHash}}")
#
#     echo -n -s $__seer_trivial_color " with " $__seer_success_color $tid_duration $__seer_trivial_color " on " $__seer_success_color $tid_hash $__seer_normal_color
#   end
# end

function __seer_prompt_terminator -d "Shows the end of the prompt, before text, indicating root"
  echo ""

  if [ (whoami) = "root" ]
    echo -n -s $__seer_trivial_color "➔ # " $__seer_normal_color
  else
    echo -n -s $__seer_trivial_color "➔ \$ " $__seer_normal_color
  end
end

# Prompt
function fish_prompt
  set last_command_status $status
  set -l cwd (prompt_pwd)

  __seer_prompt_status $last_command_status

  if git_is_repo
    __seer_prompt_git
  else
    __seer_prompt_dir
  end

  # __seer_prompt_tid

  __seer_prompt_terminator
end
