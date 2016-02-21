emacs-shell-mode-iterm-extensions
=================================

This extension to shell mode allows emacs to interpretes some special
escape codes (originally from ITerm 2) that allow terminal programs to
interact with the terminal in interesting ways.

# Installing

In your .emacs or .emacs.d/init.el

  ```(load "iterm.el")```

# Examples

 * cat a file from a shell prompt

   ```$ imgcat someimg.jpg```

 * bring emacs to the foreground

   ```$ ./some_time_consuming_script.sh; cat steal_focus.txt```

 * change the cursor shape

   ```$ cat cursor-bar.txt```

 * clear the scrollback buffer (i.e. truncate the shell buffer)

   ```$ cat giant.log```
   ```$ cat clear-scrollback.txt```

 * tell shell-mode what the current directory is

   ```export PROMPT_COMMAND="echo -ne '\033]50;CurrentDir='; pwd | tr -d '\n'; echo -ne '\007'"```

 * set the mark

  ```cat set-mark.txt```


# See Also

http://iterm2.com/documentation-escape-codes.html
