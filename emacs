; -*- mode: lisp -*-

(require 'package)
(add-to-list
  'package-archives
  '("melpa" . "http://melpa.org/packages/") t)
(package-initialize)
(package-refresh-contents)

;; Install Intero
(package-install 'intero)
(add-hook 'haskell-mode-hook 'intero-mode)

(add-to-list 'load-path "~/.emacs.d/el-get/el-get")

(unless (require 'el-get nil 'noerror)
  (with-current-buffer
      (url-retrieve-synchronously
       "https://raw.githubusercontent.com/dimitri/el-get/master/el-get-install.el")
    (goto-char (point-max))
    (eval-print-last-sexp)))

(add-to-list 'el-get-recipe-path "~/.emacs.d/el-get-user/recipes")
(el-get 'sync)
(el-get-bundle verilog-mode)
(el-get-bundle framemove)
(el-get-bundle magit)
(el-get-bundle markdown-mode)
(el-get-bundle latex-preview-pane)
(el-get-bundle dtrt-indent)
(el-get-bundle smex)
(global-set-key (kbd "M-x") 'smex)

(require 'uniquify)
(tool-bar-mode -1)
(menu-bar-mode -1)
(add-hook 'before-save-hook
          '(lambda ()
             (when (not (derived-mode-p 'markdown-mode))
               (delete-trailing-whitespace)))
          )

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

(setq delete-key-deletes-forward t)
(put 'erase-buffer 'disabled nil)
(setq tab-width 4)
(setq-default indent-tabs-mode nil)
(global-font-lock-mode t)

(add-hook 'comint-mode-hook
	  '(lambda ()
	     (define-key comint-mode-map "\M-p" 'comint-previous-matching-input-from-input)
	     ))

(setq auto-mode-alist
      (append
       '(
         ("\\.el\\'"   . emacs-lisp-mode)
         ("\\.cc\\'"   . c++-mode)
         ("\\.cu\\'"   . c++-mode)
         ("\\.idl\\'"  . indented-text-mode)
         ("\\.v\\'"    . verilog-mode)
         ("\\.sv\\'"   . verilog-mode)
         ("\\.svh\\'"  . verilog-mode)
         ("\\.md\\'"   . markdown-mode)
         ("\\.mkd\\'"   . markdown-mode)
         ("\\.y\\'"    . indented-text-mode)
         ("\\.l\\'"    . indented-text-mode)
         ("\\.idl\\'"  . indented-text-mode)
         ("\\.tex\\'"  . TeX-mode)
         ("\\.diff\\'" . diff-mode)
         ("\\.j\\'"    . java-mode)
         ("\\.hs\\'"   . haskell-mode)
         )
       auto-mode-alist
       )
      )

(setq browse-url-generic-program
      (substring (shell-command-to-string "gconftool-2 -g /desktop/gnome/applications/browser/exec") 0 -1)
      browse-url-browser-function 'browse-url-generic)

(require 'cc-mode)
(require 'cl)

(auto-compression-mode t)

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
(define-key global-map [f11]      'call-last-kbd-macro)
(define-key global-map [f4]       'ispell-word)
(define-key global-map [f5]       'previous-error)
(define-key global-map [f6]       'next-error)
(define-key global-map [f7]       'compile)
(define-key global-map [f8]       'sort-lines)
(global-set-key (kbd "C-x SPC")   'gud-break)


;; GDB-mode
;; ********

(require 'gud)
(defun gdb (command-line)
  (interactive (list (gud-query-cmdline 'gud-gdb)))
  (gud-gdb command-line))

(setq gdb-command-name "gdb")

(add-hook 'gud-mode-hook
	  '(lambda ()
	     (define-key gud-mode-map [up]      'gud-up)
	     (define-key gud-mode-map [down]    'gud-down)
	     (define-key gud-mode-map [left]    'gud-finish)
	     (define-key gud-mode-map [M-right] 'gud-next)
	     (define-key gud-mode-map [right]   'gud-step)
	     (require 'cc-mode)
	     ))

;; CC-mode
;; *******

(add-hook 'compilation-mode-hook
	  '(lambda () (font-lock-mode 1)))

(setq c-mode-common-hook
      '(lambda ()
	 (auto-fill-mode -1)
	 (require 'gud)
	 (c-set-offset 'arglist-cont-nonempty '+)
	 (c-set-offset 'arglist-intro '+)
	 (c-set-offset 'arglist-cont 0)
	 (c-set-offset 'stream-op 'c-lineup-streamop)
	 (c-set-offset 'inline-open 0)
	 (setq tab-width 4)
	 (setq c-basic-offset 4)
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
(setq compilation-buffer-name-function
      (lambda (mode-name)
	(cond ((equal mode-name "grep")
	       (concat "#" (downcase mode-name) "#"))
	      (t (concat "*" (downcase mode-name) "*")))))

(setq server-name (concat "emacs-server-" (number-to-string (random))))
(setenv "EDITOR" (concat "emacsclient -s " server-name))
(server-start)

(require 'tramp)
(add-to-list 'tramp-remote-path 'tramp-own-remote-path)

(require 'framemove)
(global-set-key (kbd "C-c <left>")  'windmove-left)
(global-set-key (kbd "C-c <right>") 'windmove-right)
(global-set-key (kbd "C-c <up>")    'windmove-up)
(global-set-key (kbd "C-c <down>")  'windmove-down)
(setq framemove-hook-into-windmove t)
