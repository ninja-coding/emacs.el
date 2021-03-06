;; Code borrowed from https://github.com/gabrielelanaro/emacs-for-python/
; "C-c d" -> Duplicate line
; "C-c c" -> Duplicate line and comment the first
; "C-c l" -> Mark a line
; "M-<up>" -> Move line or region up
; "M-<down>" -> Move line or region down
; "C-c -" -> Expand snippet

;; Duplicating lines and commenting them

(defun duplicate-line (&optional commentfirst)
  "comment line at point; if COMMENTFIRST is non-nil, comment the
original" (interactive)
(beginning-of-line)
(push-mark)
(end-of-line)
(let ((str (buffer-substring (region-beginning) (region-end))))
  (when commentfirst
    (comment-region (region-beginning) (region-end)))
  (insert-string
   (concat (if (= 0 (forward-line 1)) "" "\n") str "\n"))
  (forward-line -1)))

;; duplicate a line
(global-set-key (kbd "C-c d") 'duplicate-line)

;; duplicate a line and comment the first
(global-set-key (kbd "C-c c")(lambda()(interactive)(duplicate-line t)))

;; Mark whole line
(defun mark-line (&optional arg)
  "Marks a line"
  (interactive "p")
  (beginning-of-line)
  (push-mark (point) nil t)
  (end-of-line))

(global-set-key (kbd "C-c l") 'mark-line)


; Move line or region up and down
(defun move-text-internal (arg)
  (cond
   ((and mark-active transient-mark-mode)
    (if (> (point) (mark))
        (exchange-point-and-mark))
    (let ((column (current-column))
          (text (delete-and-extract-region (point) (mark))))
      (forward-line arg)
      (move-to-column column t)
      (set-mark (point))
      (insert text)
      (exchange-point-and-mark)
      (setq deactivate-mark nil)))
   (t
    (let ((column (current-column)))
      (beginning-of-line)
      (when (or (> arg 0) (not (bobp)))
        (forward-line)
        (when (or (< arg 0) (not (eobp)))
          (transpose-lines arg))
        (forward-line -1))
      (move-to-column column t)))))

(defun move-text-down (arg)
  "Move region (transient-mark-mode active) or current line
arg lines down."
  (interactive "*p")
  (move-text-internal arg))

(defun move-text-up (arg)
  "Move region (transient-mark-mode active) or current line
arg lines up."
  (interactive "*p")
  (move-text-internal (- arg)))

(defun balle-python-shift-left ()
  (interactive)
  (let (start end bds)
    (if (and transient-mark-mode
             mark-active)
        (setq start (region-beginning) end (region-end))
      (progn
        (setq bds (bounds-of-thing-at-point 'line))
        (setq start (car bds) end (cdr bds))))
    (python-indent-shift-left start end))
  (setq deactivate-mark nil)
  )

(defun balle-python-shift-right ()
  (interactive)
  (let (start end bds)
    (if (and transient-mark-mode
             mark-active)
        (setq start (region-beginning) end (region-end))
      (progn
        (setq bds (bounds-of-thing-at-point 'line))
        (setq start (car bds) end (cdr bds))))
    (python-indent-shift-right start end))
  (setq deactivate-mark nil)
  )

(global-set-key (kbd "M-<up>") 'move-text-up)
(global-set-key (kbd "M-<down>") 'move-text-down)

(add-hook 'python-mode-hook
          (lambda ()
            (define-key python-mode-map (kbd "M-<right>")
              'balle-python-shift-right)
            (define-key python-mode-map (kbd "M-<left>")
              'balle-python-shift-left))
          )

(provide 'python-editing)
;;; python-editing.el ends here
