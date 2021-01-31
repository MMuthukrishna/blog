+++
title = "Simple Monthly Todo List Using Vimwiki"
slug = "simple-cli-monthly-todo-list-using-vimwiki"
author = "M.Muthukrishna"
date = 2021-01-31T08:39:35+05:30
categories = ["cli"]
tags = ["cli", "vimwiki"]
draft = false
+++

## Introduction

I use [Loop Habit Tracker](https://play.google.com/store/apps/details?id=org.isoron.uhabits&hl=en_IN&gl=US) as a reminder for daily to do checklist.

I wanted to implement something similar for tracking monthly todo list. But I was too lazy to implement an android app or fork and modify [Loop Habit Tracker](https://play.google.com/store/apps/details?id=org.isoron.uhabits&hl=en_IN&gl=US).

And running a webserver on a Single Board Computer (Orange Pi 4B) seemed like a bad idea as it constantly hogs resources.

So I decided to write a simple bash script to create a monthly todo checklist.

## Prerequisites

Install [neovim](https://github.com/neovim/neovim), [vimwiki](https://github.com/vimwiki/vimwiki) plugin and [fzf](https://github.com/junegunn/fzf).

## Implementation

1. Create a directory monthly_todo_list 
2. Create a template list.md with the monthly to do list.

![](/image/simple-cli-monthly-todo-list-using-vimwiki/todo_list_img.png)

3. A simple create script to copy the template list.md to {current_year}/{current_month}/list.md. Do this only if the file doesn't exist
```bash
d=`date +%Y/%m`
if [[ ! -f $todo_dir/$d/list.md ]]; then
  mkdir -p $d && cp list.md $d/list.md
fi
```

4. A simple edit script to edit the current month to do list. Since vimwiki is installed, you can use < C-Space > to toggle list item on/off.
```bash
nvim $todo_dir/`date +%Y/%m`/list.md
```

![](/image/simple-cli-monthly-todo-list-using-vimwiki/todo_list_edit.png)

5. To edit previous month todo list
```bash
    find $todo_dir -maxdepth 2 -mindepth 2 -type d -not -path '*/\.git/*' | sed "s|$todo_dir\/||g" | fzf | xargs -I {} nvim $todo_dir/{}/list.md
```

## Script

Combining this in a simple script

```bash
#!/bin/bash
# To get the todo files dir
todo_dir="${0%/*}"

c() {
  d=`date +%Y/%m`
  if [[ ! -f $d/list.md ]]; then
    cp $todo_dir/list.md $todo_dir/$d/list.md
  fi
}

e() {
  nvim $todo_dir/`date +%Y/%m`/list.md
}

f() {
  find $todo_dir -maxdepth 2 -mindepth 2 -type d -not -path '*/\.git/*' | sed "s|$todo_dir\/||g" | fzf | xargs -I {} nvim $todo_dir/{}/list.md
}

while getopts cef flag
do
  case "${flag}" in
    c) c;;
    e) e;;
    f) f;;
  esac
done
```

To edit current month todo list, just run
```bash
./todo -e
```
And can add aliases to create and edit monthly to do list

```bash
alias mte="{path_to_todo_dir}/todo -e"
alias mtc="{path_to_todo_dir}/todo -c"
alias mtf="{path_to_todo_dir}/todo -f"
```

You can add more options, say to sync the todo dir with rsync or to commit and push to a git repo.
Or use [this](https://github.com/MMuthukrishna/monthly-todo-example) example repo to get started.