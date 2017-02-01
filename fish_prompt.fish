# Colours
set __seer_trivial_color        (set_color brgrey)
set __seer_normal_color         (set_color normal)
set __seer_success_color        (set_color cyan)
set __seer_error_color          (set_color red)
set __seer_directory_color      (set_color white)
set __seer_bold_directory_color (set_color white --bold)
set __seer_pristine_repo_color  (set_color green)
set __seer_touched_repo_color   (set_color yellow)
set __seer_git_directory_color  (set_color magenta)

# Symbols
set __seer_alive_whale ". ><((.___)"
set __seer_dead_whale  ". ><((x___)"
set __seer_ahead       " ↑"
set __seer_behind      " ↓"
set __seer_diverged    " ⇄"
set __seer_dirty       " x"
set __seer_none        " ⇥"

# Helpers
function seer_prompt_status -d "Display the whale, showing last command status"
  if test $argv[1] -eq 0
    echo -n -s $__seer_trivial_color $__seer_alive_whale $__seer_normal_color
  else
    echo -n -s $__seer_error_color $__seer_dead_whale $__seer_normal_color
  end
end

function seer_path_parent -d "Display a parent directory, shortened to fit the prompt"
  echo -n (dirname $argv[1]) | sed -e "s#^$HOME#~#" -e 's#/\(\.\{0,1\}[^/]\)\([^/]*\)#/\1#g' -e 's#/$##'
end

function seer_path_segment -d "Display a shortened form of a directory"
  set -l directory
  set -l parent

  switch "$argv[1]"
    case /
      set directory "/"
    case "$HOME"
      set directory "~"
    case "*"
      set parent (seer_path_parent "$argv[1]")
      set parent "$parent/"
      set directory (basename "$argv[1]")
  end

  echo -n -s " " $__seer_directory_color $parent $__seer_normal_color
  echo -n -s $__seer_bold_directory_color $directory $__seer_normal_color
end

function seer_prompt_git -d "Display the git root, git branch, and then path in the repo"
  set -l repo_root (command git rev-parse --show-toplevel ^/dev/null)

  seer_path_segment $repo_root

  if git_is_touched
    echo -n -s " on " $__seer_touched_repo_color (git_branch_name) $__seer_normal_color
  else
    echo -n -s " on " $__seer_pristine_repo_color (git_branch_name) $__seer_normal_color
  end

  if git_is_touched
    echo -n -s $__seer_dirty
  else
    echo -n -s (git_ahead $__seer_ahead $__seer_behind $__seer_diverged $__seer_none)
  end

  set -l repo_path (pwd | sed -e "s#^$repo_root##" | sed -e "s#^/##")

  if [ $repo_path != "" ]
    echo -n -s " " $__seer_git_directory_color $repo_path $__seer_normal_color
  end
end

function seer_prompt_dir -d "Display the entire path (but shortened)"
  seer_path_segment (pwd)
end

function seer_prompt_terminator -d "Shows the end of the prompt, before text, indicating root"
  if [ (whoami) = "root" ]
    echo -n -s $__seer_trivial_color " # " $__seer_normal_color
  else
    echo -n -s $__seer_trivial_color " \$ " $__seer_normal_color
  end
end

# Prompt
function fish_prompt
  set last_command_status $status
  set -l cwd (prompt_pwd)

  seer_prompt_status $last_command_status

  if git_is_repo
    seer_prompt_git
  else
    seer_prompt_dir
  end

  seer_prompt_terminator
end
