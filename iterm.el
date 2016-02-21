;; iterm.el --- Handle iterm extensions in shell mode.  -*- indent-tabs-mode: t; tab-width: 8 -*-

;; Copyright (C) 2016 Andrew Taylor

;; Author: Andrew Taylor <ataylor@redtoad.ca>
;; URL: https://github.com/ataylor284/emacs-shell-mode-iterm-extensions
;; Version: 1.0

;; This file is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 2, or (at your option)
;; any later version.

;; This file is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs; see the file COPYING.  If not, write to
;; the Free Software Foundation, Inc., 59 Temple Place - Suite 330,
;; Boston, MA 02111-1307, USA.

;;; Commentary:
;; Allows emacs to interpretes some special escape codes (originally
;; from ITerm 2) that allow terminal programs to interact with the
;; terminal in interesting ways.

;;; Code:

(defconst iterm-escape-regexp "\033\\]\\([0-9]+;[A-Za-z]+\\)=?\\(.*\\)\007")

(defconst iterm-escape-function-map '(("50;CursorShape" . iterm-cursor-shape)
				    ("50;SetMark" . iterm-set-mark)
				    ("50;StealFocus" . iterm-steal-focus)
				    ("50;ClearScrollback" . iterm-clear-scrollback)
				    ("50;CurrentDir" . iterm-current-dir)
;;				    ("50;SetProfile" . iterm-set-profile)
;;				    ("50;CopyToClipboard" . iterm-copy-to-clipboard)
;;				    ("9;" . iterm-growl)
				  ("1337;File" . iterm-image)))

(defconst iterm-cursor-type-map '(("0" . box)
				  ("1" . bar)
				  ("2" . hbar)))

(defun iterm-codes-apply-on-region (begin end)
  "Interprets ITerm 2 extension control sequences.  The BEGIN
parameter is fudged a bit to handle the common case where an
image control sequence spans more than one call."
  (let ((start-marker (copy-marker (max (- begin 8192) (point-min))))
	(end-marker (copy-marker end))
	escape-sequence)
    (save-excursion
      (goto-char start-marker)
      (while (re-search-forward iterm-escape-regexp end-marker t)
	(let* ((name (match-string 1))
	       (args (match-string 2))
	       (fn (assoc-default name iterm-escape-function-map)))
	  (replace-match "")
	  (when fn
	    (funcall fn args)))))))

(defun iterm-cursor-shape (args)
  "Change the cursor shape in reponse to a control sequence."
  (setq cursor-type
	(assoc-default args iterm-cursor-type-map)))

(defun iterm-set-mark (args)
  "Set the mark in reponse to a control sequence."
  (set-mark-command nil))

(defun iterm-steal-focus (args)
  "Steal focus in reponse to a control sequence."
  (select-frame-set-input-focus (nth 0 (frame-list))))

(defun iterm-clear-scrollback (args)
  "Clears the scrollback buffer in reponse to a control sequence."
  (let ((comint-buffer-maximum-size 0))
    (comint-truncate-buffer)))

(defun iterm-current-dir (args)
  "Informs shell-mode of the current directory in reponse to a control sequence."
  (shell-process-cd args))

(defun iterm-image (args)
  "Display an image inline in reponse to a control sequence."
  (when (string-match "\\([^:]+\\):\\(.*\\)" args)
    (let ((props (match-string 1 args))
	  (data (match-string 2 args)))
      (insert-image (create-image (base64-decode-string data) nil t)))))

;; hook iterm control sequence processing onto ansi color processing
(advice-add 'ansi-color-apply-on-region :after #'iterm-codes-apply-on-region)
