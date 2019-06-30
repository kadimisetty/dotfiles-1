function fish_prompt
  set -l command_status $status
  set -l question_mark_in_circle '?'\u20dd
  set_color red; echo -n '# '

  # print current location
  if [ "$PWD" = "$HOME" ]
    set_color green; echo -n '~'
  else
    set -l parent_dir (dirname "$PWD")
    set_color blue
    if [ "$parent_dir" = "$HOME" ]
      echo -n '~'
    else
      echo -n (basename "$parent_dir")
    end
    echo -n ' → '
    set_color green; echo -n (basename "$PWD")
  end
  echo -n ' '

  # show some pretty git information if we're in a git repo
  set -l git_branch (git branch 2>/dev/null | sed -n '/\* /s///p')
  if [ -n "$git_branch" ]
    if git rev-parse '@{u}' >/dev/null 2>&1
      # if an upstream is set, check how far ahead/behind the branch is
      set -l git_commits_ahead (git rev-list '@{u}..HEAD' | wc -l | awk \{'print $1'\})
      set -l git_commits_behind (git rev-list 'HEAD..@{u}' | wc -l | awk \{'print $1'\})
      if [ \( "$git_commits_ahead" -eq 0 \) -a \( "$git_commits_behind" -eq 0 \) ]
        set_color blue; echo -n '⦿'
      else
        if [ "$git_commits_behind" -gt 0 ]
          set_color red; echo -n "↓$git_commits_behind"
        end
        if [ "$git_commits_ahead" -gt 0 ]
          set_color brred; echo -n "↑$git_commits_ahead"
        end
      end
    else
      # otherwise, indicate that an upstream is unknown
      set_color brred; echo -n "$question_mark_in_circle"
    end

    set_color blue; echo -n ' ['
    # color the branch name differently if the working tree is dirty
    if [ (count (git status --porcelain)) -gt 0 ]
      set_color brred
    else
      set_color yellow
    end
    echo -n "$git_branch"
    set_color blue; echo -n '] '
  end

  if [ "$command_status" -eq 0 ]
    set_color brcyan; echo -n 'λ: '
  else
    set_color red; echo -n 'λ! '
  end
  set_color normal
end
