# git
## distributed versioning

git main features
  - no central source of files
  - everything is everywhere
  - almost all steps are local (but sync)
  - filesystem
  - snapshot based
  - branch/merge model

## Basics, terminology

A "git repository" is set of filesystem snapshots and their earlier states back to the initial state. only files that has been changed since the previous snapshot are stored.

A "working copy" is a local filesystem / folder. Contains a (possibly modified) snapshot from the repository.

git repositories' history is a web of filesystem snapshots, it's a single rooted (root is the initial snapshot, or commit) directed graph where the nodes are the commits/snapshots, and the edges are the "ancestor is" relations. Each commit is identified by a hash.

There is only a single root and every node is connected to its ancestors but the root itself (which has no ancestor).

Branches are parallel ways in the graph. Branches can be named or implicite.

TAGs are simply labels, or names, that can be assigned to commits.

Every branch has a special TAG (HEAD) labelling the latest commit of the branch.

## Working with git

Phases:
  - local operations:
    - local change: by editing the files of the working copy
    - stage: by adding changed files to a temporary inged (called "index", or "staging area")
    - commit: creating a snapshot of the lately staged changes with a comment
  - remote operations:
    - clone: create a local copy from a remote repository usually with working copy
    - push: uploading a local sequence of commits
    - pull: download ("fetch") and apply ("merge") a sequence of commits from a remote repository over the local one

## Install
  - linux
    - yum install git
    - apt install git
  - windows
    - https://git-scm.com/download/win

## Tools
  - windows
    - git-scm provides command line tools different types as embeddable and also as standalone windows app
      - https://git-scm.com/download/win
      - bash
      - cmd
      - sh
  - GUI/IDE
    - builtin: gitk
    - use your beloved IDE, like "code", "atom", pycharm, idea, eclipse, ...
    - https://sourceforge.net/projects/vscode-portable/


### Make global settings
```
git config --global user.name "Heidrich Attila"
git config --global user.mail "attila.heidrich@gmail.com"
git config --global http.proxy "http://10.232.127.19:3128"
```

To remove settings use --unset: 
```
git config --global --unset http.proxy
```
### Git server access / authentication
Git server is kind of a hub for common access, handles users/groups/access rights and additional stuff, like Wiki, tickets, pull requests (see later), UI for many operation steps.
Uses "bare" repository, no working copy (files) just the .git dir with the snapshots and related stuff.

Popular server side web UIs:
  - gogs - free (https://about.gitlab.com/gogs/)
  - gitlab - CE/EE (https://about.gitlab.com/)

Access method  is usually https with user/password and/or ssh with key(s).

Popular open hubs:
  - github.com
  - gitlab.com

For groups/individuals the project master sets the access rigths.

### Create new repo from local dir
For server population, the project with the repository should be created first (usually easy on web UI)

```
mkdir mysource
cd mysource
git init                        # creates a new repository in current dir
touch README.md
git remote add origin https://github.com/heidricha/test.git
git add .                       # stages all files in the current dir recursively
git commit -m "initial commit"  # creates a snapshot from the staged files with the "comment"
git push -u origin master       # publish the commit towards the server
```

### Download existing repo from the upstream repository ("server")
```
mkdir your_master_dir_for_git_resources
cd your_master_dir_for_git_resources
git clone url_for_repository [local dir for repository]
```

### Setup environment

.gitignore file - contains the file name patterns that should not be observed
  - relative to repository root
  - ** means a path of arbitrary length

sample lines
  - *.pyc 
  - /.history/
  - **/.vscode

### Status commands
show current config
```
git config --list
```
show status of local repository after diverting from upstream
```
git status
```
create a complete diff file of the local changes. can be sent by mail, or whatever, like a patch
```
git diff
```
show the log of the current branch
```
git log # --graph
```
show the changes after you divert (these would be pulled)
```
git log --stat ...origin/HEAD
```
display existing branches
```
git branch
```
show origins (upstreams)
```
git remote show
git remote show origin # detailed data form an upstream
```

### Update changed repository
```
git add .
git commit -m "command"
git push
```

### Branches
create local branch, and make use it
```
git checkout -b mynewbranch
```

publish the local branch to upstream "origin"
```
git push -u origin mynewbranch # 
```
remote branch name can be different from local (but not recommended)

### Merging branches
__branching__: fork a new history line from an existing snapshot

__merge__: uniting two branches, known on many names: merge, pull, push, rebase

merges are totally normal, happen very often (most server operations is a merge, since the remote repository and the local repository shall be unified), most of the time (changed files are different, changes in the same file can be performed without affecting each other) it isn't even noticable, done automatically.

merges are usually visible in the history graph as node which has two ancestors.
_fast-forward_ merges has no separate nodes (f.e. when one pulls the upstream changes to keep its own branch up-to-date).

_rebase_ means, that the commits themself will be moved from the merged branch to the target branch. rewrites history, which results a simpler graph (single line history), no merge commit; but loose track of the original branch/merge.

__conflict__: when the same portion of the same file has been modified differently in the two branches to be merged. a __confict__ must be resolved by the developer who initiated the merge. Resolve means, that the resolver must conclude a file status, commit and push it. Always creates a new commit. 

Resolving conflicts often called "merge" as well, which is a pity.

### Repository states

repository state is the sync state between working copy and the local repository (branch)

__clean__: all changes are staged and commited

__unclean__: there are unstaged/uncommited changes

server operations (push, pull, merge) are only possible, if repo state is clean

clean state can be achived by:
  - commit - introducing staged changes to repo
  - stash - postponing local changes for later use
  - reset - drop/revert local changes

### Patching
commits can be viewed as multifile patches that lead from snapshot to the next one. 

display current unstaged local changes. if not empty, repository isn't clean: "git status" will also warn about it.
```
git diff
```

if diff is not empty, there are local changes, lets stage 'em:
```
git add .
```

this command stages all local changes including and below current directory, diff is now empty, state is still unclean, since not all changes has been committed.


commit all changes

  - --amend is optional, appends current operation to the previous one, melts commites into one - use with precaution)
  - -a also adds all changed and deleted files, but not the newly created ones
  - -m "message" adds a commit message. Compulsory, so opens an editor, if omitted

```
git commit --amend -a -m "adds all changed file, and commits with message"
```

repo status is now clean, so no diff between repo and working copy

let's display diff of local and remote repositories - practically a patch which makes current local master from origin/master
```
git diff origin/master master
```

a diff is a unix patch file, can be sent by mail f.e. for others to test local changes without advertising to the server. diffs can be obtained between any two existing commits.

stash:  

```
git stash save "message"
```

saves local changes with the message for later use, cleans repo state.

```
git stash list
```

shows the stash content

```
git stash apply ...
```

```
git stash pop
```

applies the latter stashed patch.

### Revoke local changes

revokes all commits back to commit named HEAD, local changes preserved, repo is unclean again with unstaged changes
```
git reset HEAD
```

revoke all commits back too, but also set back all files as they were in that snapshot
```
git reset --hard HEAD
```

### Workflow samples
developement - dev branch, no others
  - init+add+commit+push / clone
  - repeat:
    - work on working copy
      - edit
      - add
      - commit
    - push (test)

developement - dev branch, others
  - init+add+commit+push / clone
  - repeat:
    - work on working copy
      - edit
      - add
      - commit / stash
      - sync
        - pull
        - push

release (dev branch is tested)
  - checkout development
  - pull dev
  - git tag newversion
  - fingers crossed

bugfix
  - checkout production
  - checkout -b bugfix-20171108
  - push -u origin bugfix-20171108
  - work like developement
  - test again
  - ?changes in upstream?
    - pull production
    - test again
  - checkout production
  - pull bugfix-20171108
  - two fingers crossed

  ## References

  My simplified sketch:
  
    - https://sketchboard.me/pAKlzpcYDVBD#/

  A very good visual representation of git operation, both locally and towards upstreams:
  
    - http://ndpsoftware.com/git-cheatsheet.html

  The most official git documentation:

    - https://git-scm.com/book/en/v2
    - https://git-scm.com/documentation