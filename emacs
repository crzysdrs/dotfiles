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
(global-auto-revert-mode t)
(add-hook 'comint-mode-hook
	  '(lambda ()
	     (define-key comint-mode-map "\M-p" 'comint-previous-matching-input-from-input)
	     ))

(defvar bootstrap-version)
(let ((bootstrap-file
       (expand-file-name
        "straight/repos/straight.el/bootstrap.el"
        (or (bound-and-true-p straight-base-dir)
            user-emacs-directory)))
      (bootstrap-version 7))
  (unless (file-exists-p bootstrap-file)
    (with-current-buffer
        (url-retrieve-synchronously
         "https://raw.githubusercontent.com/radian-software/straight.el/develop/install.el"
         'silent 'inhibit-cookies)
      (goto-char (point-max))
      (eval-print-last-sexp)))
  (load bootstrap-file nil 'nomessage))

(setq package-enable-at-startup nil)

;(straight-use-package 'use-package)
(straight-use-package '(rustic
                        :fork "emacs-rustic/rustic"
                        ))
(defvar rustic-format-on-save t)
(straight-use-package 'framemove)
(global-set-key (kbd "C-c <left>")  'windmove-left)
(global-set-key (kbd "C-c <right>") 'windmove-right)
(global-set-key (kbd "C-c <up>")    'windmove-up)
(global-set-key (kbd "C-c <down>")  'windmove-down)
(setq framemove-hook-into-windmove t)
(straight-use-package 'magit)
(straight-use-package 'lsp-mode)
(defvar lsp-eldoc-render-all t)
(defvar lsp-idle-delay 0.6)
(defvar lsp-inlay-hint-enable t)
(defvar lsp-rust-analyzer-server-display-inlay-hints t)
(straight-use-package 'doom-modeline)
(doom-modeline-mode 1)
(straight-use-package 'smex)
(global-set-key (kbd "M-x") 'smex)
(straight-use-package 'ivy)
(ivy-mode)
(define-key ivy-minibuffer-map (kbd "TAB") 'ivy-partial)
(straight-use-package 'docker-tramp)
(straight-use-package 'markdown-mode)
(straight-use-package 'cc-mode)
(straight-use-package 'company)
(straight-use-package 'doom-themes)
(load-theme 'doom-vibrant t)
(straight-use-package 'nerd-icons)
;;(nerd-icons-install-fonts)

(define-key global-map "\C-cg"    'goto-line)
(define-key global-map "\C-r"     'isearch-backward-regexp)
(define-key global-map "\C-s"     'isearch-forward-regexp)
(define-key global-map "\M-g"     'counsel-rg)
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
