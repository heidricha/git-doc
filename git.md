# git
## distributed versioning

git main features
  - no central source of files
  - everything is everywhere
  - almost all steps are local (but sync)
  - filesystem
  - snapshot based
  - branch/merge model

git repositorys history is a web of filesystem snapshots, or a single rooted directed graph where the nodes are the commits/snapshots, there is only a single root and every node is connected to its ancestors (maybe more) but the root itself (which has no ancestor)

each commit is identified by a hash

labels can be assigned to commits, called TAGs

there is at least one "end" node at the end of all distinct pathes - called branch. Every branch is identified a special TAG (HEAD) labelling the lead commit of the branch.

## install
  - linux
    - yum install git
    - apt install git
  - windows
    - https://git-scm.com/download/win

## usage
  - windows
    - git-scm provides command line tools different types as embeddable and also as standalone windows app
      - https://git-scm.com/download/win
      - bash
      - cmd
      - sh
  - GUI/IDE
    - builtin log browser: gitk
    - use your beloved IDE, like "code", "atom", ...
    - https://sourceforge.net/projects/vscode-portable/


### make global settings
```
git config --global user.name "Heidrich Attila"
git config --global user.mail "attila.heidrich@gmail.com"
git config --global http.proxy "http://10.232.127.19:3128"
```

### git server access / authentication
Git server is a hub for the developers as spokes, handles users/groups/access rights and additional stuff, like Wiki, tickets, pull requests (see later), UI for many operation steps.
Uses "bare" repository, no working copy (files) just the .git dir with the snapshots and related stuff.

Popular server side web UIs:
  - gogs - free (https://about.gitlab.com/gogs/)
  - gitlab - CE/EE (https://about.gitlab.com/)

Access method  is usually https with user/password and/or ssh with key(s).

Popular open hubs:
  - github.com
  - gitlab.com

For groups/individuals the project master sets the access rigths

For deployments, the ssh way is the only option, _deployment keys_ are handled separately, always readonly access, no accidental pushes etc.

### create new repo from local dir
For server population, the project with the repository should be created first (usually easy on web UI)

```
mkdir mysource
cd mysource
git init # creates a new repository in current dir
touch README.md
git remote add origin https://github.com/heidricha/test.git
git add .
git commit -m "initial commit"
git push -u origin master
```

### get an existing repo from the upstream repository ("server")
```
mkdir your_master_dir_for_git_resources
cd your_master_dir_for_git_resources
git clone url_for_repository [local dir for repository]
```

### setup environment

.gitignore file - contains the file name patterns that should not be observed
  - relative to repository root
  - ** means a path of arbitrary length

samples
  - *.pyc
  - /.history/

### status commands
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

### update changed repository
```
git add . # or list files instead of the ".", file specification can be omitted if need to add all files (see next command)
git commit -m "command" # also add "-a" if want to add all modified files
git push # name the upstream if not sure
```

### branches
create local branch, and make use it
```
git checkout -b mynewbranch
```
publish the local branch to upstream "origin"
```
git push -u origin mynewbranch # remote branch name can be different from local (but not recommended)
```

### repository states

repository state is the sync state between working copy and the local repository (branch)

clean: all changes are staged and commited

unclean: there are unstaged/uncommited changes

server operations (push, pull, merge) are only possible, if repo state is clean

clean state can be achived by:
  - commit - introducing staged changes to repo
  - stash - postponing local changes for later use
  - revert - drop local changes

### patching
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
git stash create message
```

saves local diff with the message for later use, cleans repo state.

```
git stash pop
```

applies the latter stashed patch.

### workflow samples
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
  - fingers crossed