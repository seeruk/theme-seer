# You can override some default options with config.fish:
#
#  set -g theme_short_path yes

function fish_prompt
  set -l last_command_status $status
  set -l cwd

  if test "$theme_short_path" = 'yes'
    set cwd (basename (prompt_pwd))
  else
    set cwd (prompt_pwd)
  end

  set -l alive_whale ". ><((.___)"
  set -l dead_whale  ". ><((x___)"
  set -l ahead       "↑"
  set -l behind      "↓"
  set -l diverged    "⇄"
  set -l dirty       "x"
  set -l none        "⇥"

  set -l trivial_color        (set_color brgrey)
  set -l normal_color         (set_color normal)
  set -l success_color        (set_color cyan)
  set -l error_color          (set_color red)
  set -l directory_color      (set_color white)
  set -l bold_directory_color (set_color white --bold)
  set -l pristine_repo_color  (set_color green)
  set -l touched_repo_color   (set_color yellow)

  if test $last_command_status -eq 0
    echo -n -s $trivial_color $alive_whale $normal_color
  else
    echo -n -s $error_color $dead_whale $normal_color
  end

  if git_is_repo
    if test "$theme_short_path" = 'yes'
      set root_folder (command git rev-parse --show-toplevel ^/dev/null)
      set parent_root_folder (dirname $root_folder)
      set cwd (echo $PWD | sed -e "s|$parent_root_folder/||")

      echo -n -s " " $directory_color $cwd $normal_color
    else
      set base (basename (prompt_pwd))
      set cwd (echo $cwd | sed 's/'$base'$//')

      echo -n -s " " $directory_color $cwd $normal_color
      echo -n -s $bold_directory_color $base $normal_color
    end

    if git_is_touched
      echo -n -s " on " $touched_repo_color (git_branch_name) $normal_color " "
    else
      echo -n -s " on " $pristine_repo_color (git_branch_name) $normal_color " "
    end

    if git_is_touched
      echo -n -s $dirty
    else
      echo -n -s (git_ahead $ahead $behind $diverged $none)
    end
  else
    set base (basename (prompt_pwd))
    set cwd (echo $cwd | sed 's/'$base'$//')

    echo -n -s " " $directory_color $cwd $normal_color
    echo -n -s $bold_directory_color $base $normal_color
  end

  if [ (whoami) = "root" ]
    echo -n -s " # "
  else
    echo -n -s " \$ "
  end
end
