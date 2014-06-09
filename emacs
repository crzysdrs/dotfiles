; -*- mode: lisp -*-
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(inhibit-startup-screen t)
 '(load-home-init-file t t)
 '(scheme-program-name "guile"))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(default ((t (:family "DejaVu Sans Mono" :foundry "unknown" :slant normal :weight normal :height 90 :width normal)))))

(put 'erase-buffer 'disabled nil)
(setq tab-width 4)
(setq-default indent-tabs-mode nil)

;; For some reason grep doesn't like fontify buffer, force it
(add-hook 'grep-mode-hook
	  '(lambda () (font-lock-mode 1)))


(setq auto-mode-alist 
      (append 
       '(
         ("\\.el\\'"   . emacs-lisp-mode)
         ("\\.cc\\'"   . c++-mode)
         ("\\.idl\\'"  . indented-text-mode)
         ("\\.v\\'"    . verilog-mode)
         ("\\.sv\\'"   . verilog-mode)
         ("\\.svh\\'"  . verilog-mode)
         ("\\.y\\'"    . indented-text-mode)
         ("\\.l\\'"    . indented-text-mode)
         ("\\.idl\\'"  . indented-text-mode)
         ("\\.tex\\'"  . TeX-mode)
         ("\\.diff\\'" . diff-mode) 
         ("\\.j\\'" . java-mode) 
         )
       auto-mode-alist
       )
      )

(require 'cc-mode)
(require 'cl)

(auto-compression-mode t)
(pending-delete-mode t)

(define-key global-map "\C-cg"    'goto-line)
(define-key global-map "\C-hu"    'manual-entry)
(define-key global-map "\C-r"     'isearch-backward-regexp)
(define-key global-map "\C-s"     'isearch-forward-regexp)
(define-key global-map "\C-x\C-y" 'mark-defun)
(define-key global-map "\M-%"     'query-replace-regexp)
(define-key global-map "\M-g"     'grep)
(define-key global-map "\C-cm"    'compile)
(define-key global-map "\C-xr"    'rename-buffer)
(define-key global-map "\C-x/"    'point-to-register)
(define-key global-map "\C-xj"    'jumo-to-register)
(define-key global-map [f11]       'call-last-kbd-macro)
(define-key global-map [f4]       'ispell-word)
(define-key global-map [f5]       'previous-error)
(define-key global-map [f6]       'next-error)
(define-key global-map [f7]       'compile)
(define-key global-map [f8]       'sort-lines)

(if (not (boundp 'ctl-z-map)) (setq ctl-z-map (make-keymap)))
(define-key global-map [(control z)]   ctl-z-map)
(define-key ctl-z-map "\C-f" 'find-file-other-frame)
(define-key ctl-z-map "b" 'switch-to-buffer-other-frame)
(define-key ctl-z-map "2" 'new-frame)
(define-key ctl-z-map "o" 'other-frame)

;;(defvar clipboard-cut-limit 1024 "Maximun number of characters to copy from kill-region into the clipboard")


;;(defun my-own-clipboard (string &optional push)
;;  "Paste the given string to the window system Clipboard.
;;See `interprogram-cut-function' for more information."
;;  (if (< (length string) clipboard-cut-limit)
;;      (x-set-selection 'PRIMARY string)
;;    (message "[String not placed into clipboard]")))

;;(setq interprogram-cut-function 'my-own-clipboard)

(defun tweak-tab-width (width) (interactive "NTab width: ")
  (message (format "Width=%d" width))
  (cond ((eq width 1) 
	 (setq tab-width 8)
	 (setq c-basic-offset 8)
	 (message "Reset tab width to 8"))
	((or (eq width 2) (eq width 4) (eq width 8) (eq width 12))
	 (setq tab-width width)
	 (setq c-basic-offset width)
	 (message (format "Set tab width to %d" width)))
	(t (message (format "Bogus width %d" width)) (ding)))
)

(define-key ctl-z-map [tab] 'tweak-tab-width)

;; GDB-mode
;; ********

(require 'gud)
(defun gdb (command-line)
  (interactive (list (gud-query-cmdline 'gud-gdb)))
  (gud-gdb command-line))

(setq gdb-command-name "gdb")

(add-hook 'gud-mode-hook
	  '(lambda ()
	     (define-key gud-mode-map [up] 'gud-up)
	     (define-key gud-mode-map [down] 'gud-down)
	     (define-key gud-mode-map [left] 'gud-finish)
	     (define-key gud-mode-map [M-right] 'gud-next)
	     (define-key gud-mode-map [right] 'gud-step)
	     (define-key gud-mode-map [f4] 'gud-cd)
	     (require 'cc-mode)
	     ))

(defun find-buffer-by-mode (buffers mode n)
  (cond 
   ((not buffers) nil)
   ((eq (with-current-buffer (car buffers) major-mode) mode)
    (car buffers))
   (t (find-buffer-by-mode (cdr buffers) mode n))))

(defun switch-to-gud (n) (interactive "p")
  (let* ((gud-buffer (find-buffer-by-mode (buffer-list) 'gud-mode (/ n 4)))
	 (gud-window (if gud-buffer (get-buffer-window gud-buffer 'visible) nil))
	 (compilation-buffer (find-buffer-by-mode (buffer-list) 'compilation-mode 0))
	 (compilation-window (if compilation-buffer (get-buffer-window compilation-buffer 'visible) nil)))
    (cond 
     (gud-window 
      (progn
	(select-frame-set-input-focus (window-frame gud-window))
	(select-window gud-window)
	(end-of-buffer)))
     ((and gud-buffer compilation-window)
      (progn
	(select-frame-set-input-focus (window-frame compilation-window))
	(select-window compilation-window)
	(switch-to-buffer gud-buffer)
	(end-of-buffer)))
     (gud-buffer
      (progn 
	(switch-to-buffer gud-buffer)
	(end-of-buffer)))
     (t
      (gud-gdb (gud-query-cmdline 'gud-gdb "/s/case/mmccarth/"))))))

(define-key global-map [f3] 'switch-to-gud)

(defun gud-cd (dir) (interactive "DDirectory: ")
  (progn
    (gud-call (concat "cd " dir))
    (let ((rcfile (concat dir "/init.gdb")))
      (cond  ((file-exists-p (concat dir "/init.gdb"))
	      (progn
		(gud-call "echo Loading init.gdb\n")
		(gud-call "source init.gdb")))
	     (t (message (concat "No init.gdb in " dir)))))))

;; CC-mode
;; *******

(add-hook 'compilation-mode-hook
	  '(lambda () (font-lock-mode 1)))

(setq c-mode-common-hook
      '(lambda ()
	 (auto-fill-mode -1)
	 ;; (setenv "LC_ALL" "en_US")
	 (require 'gud)
	 ;; (c-set-offset 'arglist-cont-nonempty 'c-lineup-arglist-intro-after-paren)
	 (c-set-offset 'arglist-cont-nonempty '+)
	 (c-set-offset 'arglist-intro '+)
	 (c-set-offset 'arglist-cont 0)
	 (c-set-offset 'stream-op 'c-lineup-streamop)
	 (c-set-offset 'inline-open 0)
	 (auto-fill-mode 1)
	 (setq c-echo-syntactic-information-p t)
	 (setq fill-column 120)
	 (setq indent-tabs-mode nil)
	 (setq tab-width 4)
	 (setq c-basic-offset 4)
	 (setq comment-column 40)
	 (setq c-auto-align-backslashes nil)
	 (require 'compile)
	 )
      )

(defadvice compile (after put-point-at-end activate)
  "Puts the point at the end of the compilation buffer."
  (let ((win (get-buffer-window "*compilation*"))
	(curwindow (selected-window)))
    (if win
	(progn
	  (select-window win)
	  (goto-char (point-max))
	  (select-window curwindow)))))

;; Verilog mode
;; ************

(setq delete-key-deletes-forward t)
(add-hook 'verilog-mode-hook
	  '(lambda ()
	     (setq tab-width 4)
	     (setq verilog-auto-lineup t)
	     (setq verilog-auto-newline ())
	     (setq verilog-cexp-indent 2)
	     (setq verilog-indent-level 2)
	     (setq verilog-indent-level-behavioral 2)
	     (setq verilog-indent-level-declaration 2)
	     (setq verilog-indent-level-module 2)
	     (modify-syntax-entry ?_ "." verilog-mode-syntax-table)
	     ;;(font-lock-mode -1)
	     ;;(pushnew 
	     ;; '(gnu ("^\*\* *Error: *\\([^(]+\\)(\\([0-9]+\\)).*$" 1 2))
	     ;; compilation-error-regexp-alist-alist)
	     ;;(compilation-build-compilation-error-regexp-alist)
	     ))

;; Comint mode
;; ***********

;; Base of shell mode and gud mode and probably other modes too

(cond
 ((file-accessible-directory-p "/proc")
  (add-hook 'comint-preoutput-filter-functions
	  (lambda (str)
	    (prog1 str
	      (when (string-match comint-prompt-regexp str)
		(cd (file-symlink-p (format "/proc/%s/cwd" (process-id (get-buffer-process (current-buffer)))))))))))
)

(add-hook 'comint-mode-hook
	  '(lambda ()
	     (font-lock-mode 0)
	     (define-key comint-mode-map "\M-p" 'comint-previous-matching-input-from-input)
	     ))

(setq compilation-buffer-name-function 
      (lambda (mode-name)
	(cond ((equal mode-name "grep")	       
	       (concat "#" (downcase mode-name) "#"))
	      (t (concat "*" (downcase mode-name) "*")))))

(autoload 'ansi-color-for-comint-mode-on "ansi-color" nil t)
(add-hook 'shell-mode-hook 'ansi-color-for-comint-mode-on)
