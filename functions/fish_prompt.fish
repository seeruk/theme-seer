# Colours
set -gu __seer_trivial_color        (set_color brgrey)
set -gu __seer_normal_color         (set_color normal)
set -gu __seer_error_color          (set_color red)
set -gu __seer_directory_color      (set_color blue)
set -gu __seer_bold_directory_color (set_color blue)

# Symbols
set -gu __seer_alive_gopher "ʕ◕⩊◕ʔ"
set -gu __seer_dead_gopher "ʕ⤫﹏⤫ʔ"

# Git prompt
set -g __fish_git_prompt_showdirtystate 1
set -g __fish_git_prompt_showuntrackedfiles 0
set -g __fish_git_prompt_showupstream auto
set -g __fish_git_prompt_show_informative_status 0
set -g __fish_git_prompt_showcolorhints 1
set -g __fish_git_prompt_char_stateseparator ""
set -g __fish_git_prompt_char_dirtystate " ✘"
set -g __fish_git_prompt_char_stagedstate " +"
set -g __fish_git_prompt_char_invalidstate " ✖"
set -g __fish_git_prompt_char_upstream_ahead " ↑"
set -g __fish_git_prompt_char_upstream_behind " ↓"
set -g __fish_git_prompt_char_upstream_diverged " ↕"
set -g __fish_git_prompt_char_upstream_equal " ≈"
set -g __fish_git_prompt_color_branch green
set -g __fish_git_prompt_color_branch_dirty yellow
set -g __fish_git_prompt_color_branch_staged yellow
set -g __fish_git_prompt_color_branch_detached red
set -g __fish_git_prompt_color_dirtystate yellow
set -g __fish_git_prompt_color_stagedstate yellow
set -g __fish_git_prompt_color_invalidstate red
set -g __fish_git_prompt_color_upstream green

# Helpers
function __seer_prompt_status -d "Display the Gopher, showing last command status"
  if test $argv[1] -eq 0
    echo -n -s $__seer_trivial_color $__seer_alive_gopher $__seer_normal_color
  else
    echo -n -s $__seer_error_color $__seer_dead_gopher $__seer_normal_color
  end
end

function __seer_path_parent -d "Display a parent directory, shortened to fit the prompt"
  set -l parent (string replace -r '/[^/]*$' '' -- $argv[1])

  if test "$parent" = "$HOME"
    set parent "~"
  else if string match -q "$HOME/*" -- $parent
    set parent (string replace -- $HOME "~" $parent)
  end

  string replace -ar '/(\.?[^/])[^/]*' '/$1' -- $parent \
    | string replace -r '/$' ''
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
      set directory (string replace -r '^.*/' '' -- $argv[1])
  end

  echo -n -s " " $__seer_directory_color $parent $__seer_normal_color
  echo -n -s $__seer_bold_directory_color $directory $__seer_normal_color
end

function __seer_prompt_dir -d "Display the entire path (but shortened)"
  __seer_path_segment (pwd)
end

function __seer_prompt_git -d "Display Git status via Fish's built-in git prompt"
  set -l git_prompt (fish_git_prompt " on %s")

  if test -n "$git_prompt"
    string match -q "* ✘*" -- $git_prompt; or string match -q "* +*" -- $git_prompt; or string match -q "* ✖*" -- $git_prompt
    and set git_prompt (string replace " ≈" "" -- $git_prompt)

    echo -n -s $__seer_trivial_color $git_prompt $__seer_normal_color
  end
end

function __seer_prompt_terminator -d "Shows the end of the prompt, before text, indicating root"
  echo ""

  if [ "$USER" = "root" ]
    echo -n -s $__seer_trivial_color "➔ # " $__seer_normal_color
  else
    echo -n -s $__seer_trivial_color "➔ \$ " $__seer_normal_color
  end
end

# Prompt
function fish_prompt
  set last_command_status $status

  __seer_prompt_status $last_command_status
  __seer_prompt_dir
  __seer_prompt_git

  __seer_prompt_terminator
end
