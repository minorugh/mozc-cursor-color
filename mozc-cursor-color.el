;;; mozc-cursor-color.el --- Set cursor color for mozc.
;;; Commentary:
;;
;; Copyright (C) 2013 S. Irie from iTi-E/mozc-el-extensions
;; 2021.9.14 Modify by Minoru Yamada.
;;
;;; Code:
;;  (setq debug-on-error t)

(defvar mozc-cursor-color-conflicts-list
  '(ac-completing))

;; Like doom-dracura-theme color
(defvar mozc-cursor-color-alist
  '((direct . "#50fa7b")
    (read-only . "#f8f8f2")
	(hiragana . "#ff5555")
    (full-katakana . "goldenrod")
    (half-ascii . "dark orchid")
    (full-ascii . "orchid")
    (half-katakana . "dark goldenrod")))

(defvar mozc-cursor-color-timer-delay 0.1)

(defvar mozc-current-input-mode 'hiragana)
(make-variable-buffer-local 'mozc-current-input-mode)

(defadvice mozc-session-execute-command (after mozc-current-input-mode () activate)
  "After current input."
  (if ad-return-value
      (let ((mode (mozc-protobuf-get ad-return-value 'mode)))
		(if mode
			(setq mozc-current-input-mode mode)))))

(defvar mozc-cursor-color-timer nil)

(defun mozc-cursor-color-setup-timer (&optional cancel)
  "Setup timer CANCEL optional."
  (if (timerp mozc-cursor-color-timer)
	  (cancel-timer mozc-cursor-color-timer))
  (setq mozc-cursor-color-timer
		(and (not cancel)
			 (run-with-idle-timer mozc-cursor-color-timer-delay t
								  'mozc-cursor-color-update))))

(defun mozc-cursor-color-update ()
  "Color update."
  (condition-case err
      (catch 'exit
		(mapc (lambda (symbol)
				(if (and (boundp symbol)
						 (symbol-value symbol))
					(throw 'exit nil)))
			  mozc-cursor-color-conflicts-list)
		(set-cursor-color
		 (or (cdr (assq (cond
						 ((and buffer-read-only
							   (not inhibit-read-only))
						  'read-only)
						 ((not mozc-mode)
						  'direct)
						 (t
						  mozc-current-input-mode))
						mozc-cursor-color-alist))
			 (frame-parameter nil 'foreground-color))))
    (error
     (message "error in mozc-cursor-color-update(): %S" err)
     (set-cursor-color (frame-parameter nil 'foreground-color))
     (mozc-cursor-color-setup-timer t)
     (remove-hook 'post-command-hook 'mozc-cursor-color-update)
     (message "mozc-cursor-color was disabled due to the error.  See \"*Messages*\" buffer."))))

;;;###autoload
(defun mozc-cursor-color-setup ()
  "Color setup."
  (interactive)
  (mozc-cursor-color-setup-timer)
  (remove-hook 'post-command-hook 'mozc-cursor-color-update)
  (add-hook 'post-command-hook 'mozc-cursor-color-update t))

(mozc-cursor-color-setup)


(provide 'mozc-cursor-color)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; mozc-cursor-color.el ends here
