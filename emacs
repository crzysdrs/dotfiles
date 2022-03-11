; -*- mode: lisp -*-

(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )

(global-auto-revert-mode t)

(require 'uniquify)
(tool-bar-mode -1)
(menu-bar-mode -1)
(setq delete-key-deletes-forward t)
(put 'erase-buffer 'disabled nil)
(setq tab-width 4)
(setq-default indent-tabs-mode nil)
(global-font-lock-mode t)
(setq inhibit-startup-screen t)

(add-hook 'comint-mode-hook
	  '(lambda ()
	     (define-key comint-mode-map "\M-p" 'comint-previous-matching-input-from-input)
	     ))

(add-to-list 'load-path "~/.emacs.d/el-get/el-get")

(unless (require 'el-get nil 'noerror)
  (with-current-buffer
      (url-retrieve-synchronously
       "https://raw.githubusercontent.com/dimitri/el-get/master/el-get-install.el")
    (goto-char (point-max))
    (eval-print-last-sexp)))

(add-to-list 'el-get-recipe-path "~/.emacs.d/el-get-user/recipes")	      

(unless (file-directory-p el-get-recipe-path-elpa)
  (el-get-elpa-build-local-recipes))

(el-get-bundle rustic
	       (defvar rustic-format-on-save t)
	       (defvar rustic-format-display-method 'ignore)
	       ;;(defvar rustic-lsp-format t)
	       )
(el-get-bundle framemove
	       (global-set-key (kbd "C-c <left>")  'windmove-left)
	       (global-set-key (kbd "C-c <right>") 'windmove-right)
	       (global-set-key (kbd "C-c <up>")    'windmove-up)
	       (global-set-key (kbd "C-c <down>")  'windmove-down)
	       (setq framemove-hook-into-windmove t)
	       )
(el-get-bundle magit
	       :info nil
	       )
(el-get-bundle markdown-mode)
(el-get-bundle dtrt-indent)
(el-get-bundle lsp-mode
	       (defvar lsp-rust-analyzer-cargo-watch-command "clippy")
	       (defvar lsp-eldoc-render-all t)
	       (defvar lsp-idle-delay 0.6)
	       ;; Inlay Hints either do not work or have been disabled in rust analyzer
	       ;;(defvar lsp-rust-analyzer-inlay-hints-mode t)
	       ;;(defvar lsp-rust-analyzer-server-display-inlay-hints t)

	       ;;For debugging
	       (defvar lsp-log-io t)
	       )
(el-get-bundle smex	      
	       (global-set-key (kbd "M-x") 'smex)
	       )
(el-get-bundle flycheck :ensure)
(el-get-bundle doom-themes
	       (load-theme 'doom-vibrant t)
	       )
(el-get-bundle ivy
	       (ivy-mode)
	       )

(el-get-bundle doom-modeline
  (doom-modeline-mode 1)
  )
(el-get 'sync)

(require 'cc-mode)
(define-key ivy-minibuffer-map (kbd "TAB") 'ivy-partial)
(define-key global-map "\C-cg"    'goto-line)
(define-key global-map "\C-r"     'isearch-backward-regexp)
(define-key global-map "\C-s"     'isearch-forward-regexp)
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
	     ))

(setq server-name (concat "emacs-server-" (number-to-string (random))))
(setenv "EDITOR" (concat "emacsclient -s " server-name))
(server-start)

(require 'tramp)
(add-to-list 'tramp-remote-path 'tramp-own-remote-path)
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages '(company project ivy)))
