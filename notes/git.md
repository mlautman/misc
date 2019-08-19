# Git Cheat Sheet

## Setup

    git config status.showuntrackedfiles no

## Cleanly merge two branches

Avoids having a merge commit:

    git co FEATURE_BRANCH
    git rebase master

## Delete/Remove Commit

Remove Last Commit (unpushed) but leave the changed code there as "Changes to be committed"
    git reset --soft HEAD~1    # increase 1 to any number to delete more commits

Reflect the reset (deleted commmits) on the remote
    git push origin +HEAD  # force-push the new HEAD commit

Remove Last Commit that has been pushed. This creates a new commit that reverses everything from accidental commit
    git revert HEAD

Removes staged and working directory changes.
    git reset --hard  HEAD

Removes the last commit
    git reset --hard  HEAD~1

Delete all untracked files in a Git repo (careful!) including directories
    git clean -f -d

Removes a commit from remote
    git push upstream +dd61ab32^:master
    upstream - remote name
    dd61ab32 - commit id
    master - remote branch

Remove a specific past commit
    git revert COMMIT_NUM
    ... # fix merge issues
    git revert --continue

When there is a merge conflict in a file, just keep mine or theirs:
    git checkout --ours src/file.cpp
    git checkout --theirs src/file.cpp

Copy a version of a single file from one git branch to another
    git checkout otherbranch myfile.txt

View the difference in commits between two branches
    git log A..B

## Branch Stuff

Replace master branch entirely with another branch
    git checkout seotweaks
    git merge -s ours master
    git checkout master
    git merge seotweaks

Graphical editor
    gitk

Create new branch and push to Github
    git branch NEWBRANCH
    git push -u origin NEWBRANCH

Delete a remote (Github) branch:
    git push origin --delete <branchName>
    OR
    git push origin :BRANCH_NAME

Delete a local branch:
    git branch -D <branchName>

Sync a github fork with its parent repo
    #ONE TIME
    git remote add upstream ...
    #EVERY TIME
    git fetch upstream
    git merge upstream/master
    git push origin master

Git GUI
    gitg
	gitk

Move a commit to another branch
    git co BRANCH_WITH_COMMIT
    git log -1                     // get COMMIT_ID to move
    git co BRANCH_TO_MOVE_COMMIT
    git cherry-pick COMMIT_ID

    // Delete prev commit location

Delete A Remote Tag
    git tag -d 12345
    git push origin :refs/tags/12345

Track Remote Branch Locally
    git co -b [branch] [remotename]/[branch]

Clear out tracked branches that no longer exist on remotes
    git branch prune origin --dry-run

Pushing to a Remote Branch with a Different Name

    git push origin local-name:remote-name

## Stash

Stash current changes
    git stash
    or
    git stash save

Recall stash
    git stash pop

See all stashes
    git stash list

Remove all old staets
    git stash clear

Working with Documents / Latex =

Make Diff word wrap for the whole repo:
    git config core.pager 'less -r'

See word-by-word highlights
    git diff --word-diff A B

## Other Stuff

Delete all untracked files
    git clean -f

View the log with file modification info
    git log --stat

Combine commits from one branch and merge into current branch
    git merge squash --feature

Commit part of a file / partial file
    git add -p filename

    y to stage that hunk, or
    n to not stage that hunk, or
    e to manually edit the hunk (useful when git can't split it automatically)
    d to exit or go to the next file.
    ? to get the whole list of available options.

Create new branch and check it out
    git checkout -b feature

See what git did under the hood
    git reflog

See what I'm about to push to a remote repo:
    git diff --stat origin/master

## Rebasing

Combine commits into one
    git rebase -i BASE_COMMIT
    for every commit, change 'pick' to 's' and the first line to 'r' (reword)

Commit changes to a previous commit (not that last one though)

    git stash # if you've already made the changes
    git rebase -i THE_COMMIT_BEFORE_WHAT_YOU_WANT_TO_EDIT  e.g. HEAD^^
	# mark the commits you want to amend with 'edit'. save and exit
	# apply changes, e.g. 'git stash pop'
	git add -A
    git rebase --continue # adds to edited commit

Git tools =

Graphical Interface
    gitk

## Hub

Hub
    https://github.com/github/hub

Pull request

    git push origin FEATURE_BRANCH     e.g. kinetic-feature
    git pull-request -b PARENT_BRANCH  e.g. kinetic-devel

## Submodules

Restore a submodule to the master parent git version

    git co COMMIT_ID_HASH
or
    git pull --rebase origin master

not sure which

## Ignore changes to tracked file

For a more detailed explaination of each [this post](https://stackoverflow.com/questions/936249/how-to-stop-tracking-and-ignore-changes-to-a-file-in-git)

Ignore

    git update-index --assume-unchanged file

To start tracking again

    git update-index --no-assume-unchanged file

To keep your own local version

    git update-index --skip-worktree <path-name>

*NOTE:* `git update-index` does not propagate. Each user must run this themselves.

## List all commits that are part of indigo-devel, but not present in jade-devel

    git cherry -v jade-devel indigo-devel | grep '^+'

## Install the Latest Version of Git

    sudo apt-get install software-properties-common
    sudo add-apt-repository ppa:git-core/ppa
    sudo apt-get update
    sudo apt-get install git

## Amend to a previous commit that was not the last one

You can use git rebase, for example, if you want to modify back to commit bbc643cd, run

    git rebase --interactive 'bbc643cd^'

In the default editor, modify pick to edit in the line whose commit you want to modify. Make your changes and then commit them with the same message you had before:

    git commit --all --amend --no-edit

to modify the commit, and after that

    git rebase --continue

to return back to the previous head commit.

## Create PR on Github
http://astrofrog.github.io/blog/2013/04/10/how-to-conduct-a-full-code-review-on-github/

git checkout --orphan review
git rm -r --cached *
git clean -fxd
git commit --allow-empty -m "Start of the review"
git branch empty
git merge master
git push origin review
git push origin empty

## Gerrit

Setup A repo: be sure to add the hooks, found on the website

Committing:

    git push origin HEAD:refs/for/master
    #or my shortcut: ``gerrit_push``

## Autosquash

Commit changes to an older commit in the log: https://stackoverflow.com/a/32850786/258097

    git commit -a --fixup=OLDER_COMMIT_HASH
    git rebase -i OLDER_COMMIT_HASH^ --autosquash         ...or for up to 20 prev commits: gitautosquash

## Commit part of a file

    git add --patch <filename> (or -p for short)

git will begin to break down your file into what it thinks are sensible "hunks" (portions of the file).
More info: https://stackoverflow.com/questions/1085162/commit-only-part-of-a-file-in-git

## Change author of a commit

    git commit --amend --author="Author Name <email@address.com>"
    git commit --amend --author="Dave Coleman <dave@picknik.ai>"

## See most common contributors to repo or file:

    git shortlog -s -n FILE
