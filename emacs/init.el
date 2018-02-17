;; -*- mode: emacs-lisp -*-

;;; Commentary:

;;; Code:

(eval-when-compile
  (require 'cl))

(defun melpa-ini ()
  "Initialize melpa and elpa repositories."
  (let* ((no-ssl (and (memq system-type '(windows-nt ms-dos))
                      (not (gnutls-available-p))))
     (url (concat (if no-ssl "http" "https") "://melpa.org/packages/")))
    (add-to-list 'package-archives (cons "melpa" url) t))
  (when (< emacs-major-version 24)
    ;; For important compatibility libraries like cl-lib
    (add-to-list 'package-archives '("gnu" . "http://elpa.gnu.org/packages/")))
  (add-to-list 'package-archives '("org" . "http://orgmode.org/elpa/"))
  (add-to-list 'package-archives
               '("marmalade" . "http://marmalade-repo.org/packages/")))

(require 'package)
(melpa-ini)
(package-initialize)

;; https://github.com/jwiegley/use-package/issues/256#issuecomment-263313693
(defun my-package-install-refresh-contents (&rest args)
  (package-refresh-contents)
  (advice-remove 'package-install 'my-package-install-refresh-contents))
(advice-add 'package-install :before 'my-package-install-refresh-contents)

;; configure `use-package'
(unless (or (package-installed-p 'use-pacakge)
            (package-installed-p 'diminish))
  (package-refresh-contents)
  (package-install 'diminish)
  (package-install 'use-package))
(eval-when-compile
  (require 'use-package))
(require 'diminish)
(setq use-package-always-ensure t)
(setq use-package-always-demand t)

;;
(add-to-list 'load-path "~/.emacs.d/downloaded")

;; local
(when (string= (getenv "MACHINE") "work")
  (use-package minor-mode-hack)
  (require 'auto-par-mode)
  (load (concat (getenv "LOCAL_CONFIGS") "/sensitive.el")))

(setq-default show-trailing-whitespace nil)
;; (defun toggle-trailing-whitespace ()
;;   (interactive)
;;   (setq show-trailing-whitespace (not show-trailing-whitespace)))
(set-face-attribute 'trailing-whitespace nil
                    :background "grey15")
(add-hook 'prog-mode-hook 'hs-minor-mode)
(diminish 'hs-minor-mode)

(use-package exec-path-from-shell
  :config
  (when (memq window-system '(mac ns x))
    (exec-path-from-shell-initialize)))

;; (use-package el-patch)

(use-package rtags
  :config
  (setq rtags-completions-enabled t)
  (setq rtags-autostart-diagnostics t)
  (rtags-enable-standard-keybindings))

(use-package helm-rtags
  :config
  (setq rtags-use-helm t))

(use-package company-rtags
  :config
  (eval-after-load 'company
    '(add-to-list
      'company-backends 'company-rtags)))

(use-package irony
  :config
  (add-hook 'c++-mode-hook 'irony-mode)
  (add-hook 'c-mode-hook 'irony-mode)
  (add-hook 'objc-mode-hook 'irony-mode))

(use-package flycheck-irony)

(use-package company-irony
  :config
  (add-hook 'irony-mode-hook 'company-irony-setup-begin-commands)
  (eval-after-load 'company
  '(add-to-list
    'company-backends 'company-irony)))

(use-package company-irony-c-headers)

(use-package company-cmake)

(use-package cmake-ide
  :config
  (cmake-ide-setup))

(use-package workgroups
  :diminish workgroups-mode
  :config
  (setq wg-prefix-key (kbd "C-c w"))
  (setq wg-mode-line-on nil)
  (setq wg-morph-on nil)
  (workgroups-mode 1))

(use-package undo-tree
  :diminish undo-tree-mode
  :config
  (global-undo-tree-mode))

(use-package smart-comment
  :bind ("M-;" . smart-comment))

(use-package smartparens
  :demand
  :config
  (require 'smartparens-config)
  ;; (require 'smartparens-html)
  (diminish 'smartparens-mode nil)
  (sp-use-paredit-bindings)
  (add-hook 'clojure-mode-hook 'smartparens-strict-mode)
  (add-hook 'cider-repl-mode-hook 'smartparens-strict-mode)
  (add-hook 'lisp-mode-hook 'smartparens-strict-mode)
  (add-hook 'emacs-lisp-mode-hook 'smartparens-strict-mode)
  (add-hook 'clojure-mode-hook 'smartparens-strict-mode)
  ;;
  ;; (add-hook 'prog-mode-hook 'smartparens-mode)
  ;; https://github.com/Fuco1/smartparens/issues/286#issuecomment-32324743
  ;; (add-to-list 'sp--lisp-modes 'sly-mrepl-mode)
  (sp-with-modes sp--lisp-modes
    ;; disable ', it's the quote character!
    (sp-local-pair "'" nil :actions nil)
    ;; also only use the pseudo-quote inside strings where it serve as
    ;; hyperlink.
    (sp-local-pair "`" "'" :when '(sp-in-string-p sp-in-comment-p))
    (sp-local-pair "`" nil
                   :skip-match (lambda (ms mb me)
                                 (cond
                                  ((equal ms "'")
                                   (or (sp--org-skip-markup ms mb me)
                                       (not (sp-point-in-string-or-comment))))
                                  (t (not (sp-point-in-string-or-comment)))))))
  ;; (sp-local-pair 'emacs-lisp-mode "'" nil :actions :rem)
  ;; (sp-local-pair 'lisp-mode "'" nil :actions :rem)
  :bind
  ;; TODO try more
  (:map smartparens-mode-map
   ("C-k" . sp-kill-whole-line)
   ("<backspace>" . nil)
   :map smartparens-strict-mode-map
   ("<backspace>" . nil)
   :map lisp-mode-map
   ("<backspace>" . backward-delete-char)))

(use-package slime-company
  :config
  (eval-after-load "company"
    '(add-to-list 'company-backends 'company-slime)))

(use-package slime
  :config
  (add-to-list 'load-path "~/.emacs.d/downloaded/slime-repl-ansi-color")
  (require 'slime-repl-ansi-color)
  (slime-setup '(slime-fancy slime-company slime-repl-ansi-color))
  (setq inferior-lisp-program (getenv "LISP_INTERPRETER"))
  ;;
  ;; smartparens
  (add-hook 'slime-repl-mode-hook 'smartparens-strict-mode)
  (define-key slime-repl-mode-map (kbd "M-r") 'sp-splice-sexp-killing-around)
  (define-key slime-repl-mode-map (kbd "M-s") 'sp-splice-sexp)
  (define-key slime-repl-mode-map (kbd "C-e") 'move-end-of-line)
  (define-key slime-repl-mode-map (kbd "C-a") 'move-beginning-of-line)
  ;; pretty
  (add-hook 'slime-repl-mode-hook 'rainbow-delimiters-mode)
  ;; http://compgroups.net/comp.emacs/tweaking-slime/95455
  (defvar slime-repl-font-lock-keywords lisp-font-lock-keywords-2)
  (defun slime-repl-font-lock-setup ()
    (setq font-lock-defaults
          '(slime-repl-font-lock-keywords
            ;; - From lisp-mode.el
            nil nil (("+-*/.<>=!?$%_&~^:@" . "w")) nil
            (font-lock-syntactic-face-function
             . lisp-font-lock-syntactic-face-function))))
  (add-hook 'slime-repl-mode-hook 'slime-repl-font-lock-setup)
  (defun slime-repl-font-lock-find-prompt (limit)
    ;; Rough: (re-search-forward "^\\w*>" limit t)
    (let (beg end)
      (when (setq beg (text-property-any
                       (point) limit 'slime-repl-prompt t))
        (setq end (or (text-property-any beg limit 'slime-repl-prompt nil)
                      limit))
        (goto-char beg)
        (set-match-data (list beg end)) t)))
  (setq slime-repl-font-lock-keywords
        (cons '(slime-repl-font-lock-find-prompt . 'slime-repl-prompt-face)
              slime-repl-font-lock-keywords)))

(use-package helm-ag)

(use-package helm-flymake)

(use-package flyspell
  ;; :diminish flyspell-mode
  :config
  (add-hook 'prog-mode-hook 'flyspell-prog-mode))

(use-package flyspell-correct)

(use-package helm-flyspell
  :bind
  (:map flyspell-mode-map
   ("C-;" . helm-flyspell-correct)))

(use-package helm
  :diminish helm-mode
  :config
  (require 'helm-config)
  (with-eval-after-load 'helm-files
    (dolist (keymap (list helm-find-files-map helm-read-file-map))
      (define-key keymap (kbd "C-l") 'helm-execute-persistent-action)
      (define-key keymap (kbd "C-h") 'helm-find-files-up-one-level)))
  (setq helm-split-window-default-side 'below)
  (setq helm-split-window-inside-p t)
  (helm-mode 1)
  :bind
  (("M-x" . helm-M-x)
   ("C-x b" . helm-mini)
   ("C-x r b" . helm-filtered-bookmarks)
   ("C-x C-f" . helm-find-files)
   ("C-x g" . helm-do-ag)
   :map helm-map
   ;; evil hjkl keys to helm
   ("C-j" . helm-next-line)
   ("C-k" . helm-previous-line)
   ("C-h" . helm-next-source)
   ("C-l" . helm-prev-source)))

(use-package helm-fuzzier
  :config
  (helm-fuzzier-mode 1))

(use-package projectile)

(use-package helm-projectile)

;; * themes i like:
;; cyberpunk (covers a lot of stuff)
;; rebecca (nice colors, cannot load it correctly, meant for spacemacs)
;; exotica (nice colors, covers helm)
;; cherry-blossom (nice colors)
;; purple-haze (nice colors)
;; ample (nice colors, covers helm)
;; gruvbox (orangy)
;; tao-yin (black and white)
;; molokai (comments are to dark, otherwise nice)
;; grandshell (two dark default text)
;; phoenix-dark-pink
;; leuven (LIGHT but nice)
;; espreso (LIGHT but nice)
;; bubbleberry
;; django (greenish)
;; underwater (blueish)
;; * themes that cause troubles: sublime-themes, moe-theme

;; (use-package exotica-theme
;;   :config
;;   (load-theme 'exotica t))

(use-package rainbow-mode
  :config
  (add-hook 'emacs-lisp-mode-hook 'rainbow-mode)
  (add-hook 'sh-mode-hook 'rainbow-mode))

(use-package base16-theme
  :ensure t
  :config
  (defvar base16-rebecca4k-colors
    '(:base00 "#050507" ;; orig: "#292a44" ;; default background
      :base01 "#663399" ;; lighter background (status bar)
      :base02 "#383a62" ;; selection background
      :base03 "#666699" ;; comments, invisibles
      :base04 "#a0a0c5" ;; dark foreground (status bar)
      :base05 "#f1eff8" ;; default foreground
      :base06 "#ccccff" ;; light foreground
      :base07 "#53495d" ;; light background
      :base08 "#a0a0c5" ;; variables
      :base09 "#efe4a1" ;; constants
      :base0A "#ae81ff" ;; search text background
      :base0B "#6dfedf" ;; strings
      :base0C "#8eaee0" ;; regex, escaped chars
      :base0D "#2de0a7" ;; functions
      :base0E "#7aa5ff" ;; keywords
      :base0F "#ff79c6" ;; deprecations
      )
    "All colors for Base16 Rebecca4k (bugdie4k's spin on Base16 Rebecca) are defined here.")
  (deftheme base16-rebecca4k)
  (base16-theme-define 'base16-rebecca4k base16-rebecca4k-colors)
  (provide-theme 'base16-rebecca4k)
  (load-theme 'base16-rebecca4k t))

(use-package helm-themes)

(use-package mode-line-bell
  :config
  (mode-line-bell-mode))

(use-package company
  :diminish company-mode
  :config
  (add-hook 'after-init-hook 'global-company-mode)
  (setq company-idle-delay 0)
  ;; TODO: use base16 colors
  (set-face-attribute 'company-tooltip nil
                      :background "Grey5"
                      :foreground "Grey80")
  (set-face-attribute 'company-tooltip-selection nil
                      :foreground "White"
                      :background "SlateBlue4")
  (set-face-attribute 'company-tooltip-common nil
                      :foreground "Orchid1")
  (set-face-attribute 'company-tooltip-common-selection nil
                      :foreground "Orchid1")
  (set-face-attribute 'company-preview-common nil
                      :background "DeepPink4")
  :bind
  (:map company-active-map
   ("C-j" . company-select-next)
   ("C-k" . company-select-previous)
   ("<return>" . nil) ;; wut
   ("RET" . nil)      ;; ---
   ("<tab>" . company-complete-selection)
   ("\C-d" . company-show-doc-buffer)
   ("M-." . company-show-location)))

(use-package evil
  :demand
  :bind
  (:map evil-normal-state-map
   ("M-." . nil)
   ("M-," . nil)
   ("C-r" . isearch-backward)
   ("U" . undo-tree-redo)
   ("M-." . nil)
   ;; instead of evil-delete-char, which saves deleted chars to kill-ring
   ("x" . delete-char)
   ;; instead of evil-jump-forward
   ("<tab>" . indent-for-tab-command)
   :map evil-emacs-state-map
   ("M-q" . evil-normal-state)
   ([escape] . evil-normal-state)
   :map evil-motion-state-map
   ("RET" . nil) ; to let RET be slime-xref-goto in slime-xref-mode
   )
  :config
  (evil-define-key 'normal prog-mode-map (kbd "1") 'evilmi-jump-items)
  (evil-define-key 'visual prog-mode-map (kbd "1") 'evilmi-jump-items)
  (add-hook 'evil-insert-state-entry-hook 'evil-emacs-state) ; insert state -> emacs state
  (evil-define-key 'motion slime-inspector-mode-map (kbd "l") 'slime-inspector-pop)
  (setq evil-motion-state-modes '(slime-xref-mode
                                  sldb-mode
                                  undo-tree-visualizer-mode
                                  slime-inspector-mode
                                  help-mode
                                  slime-macroexpansion-minor-mode
                                  messages-buffer-mode
                                  cider-stacktrace-mode))
  (evil-define-key 'motion sldb-mode-map (kbd "v") 'sldb-show-source)
  (evil-define-key 'motion sldb-mode-map (kbd "e") 'sldb-eval-in-frame)
  (evil-define-key 'motion sldb-mode-map (kbd "0") 'sldb-invoke-restart-0)
  (evil-define-key 'motion sldb-mode-map (kbd "1") 'sldb-invoke-restart-1)
  (evil-define-key 'motion sldb-mode-map (kbd "2") 'sldb-invoke-restart-2)
  (evil-define-key 'motion sldb-mode-map (kbd "3") 'sldb-invoke-restart-3)
  (evil-define-key 'motion sldb-mode-map (kbd "4") 'sldb-invoke-restart-4)
  (evil-define-key 'motion sldb-mode-map (kbd "5") 'sldb-invoke-restart-5)
  (setq evil-emacs-state-cursor 'bar)
  (evil-mode 1))

(use-package powerline
  :config
  ;; TODO: figure out what it does
  ;; (set-face-attribute 'powerline-active0 nil
  ;;                     :box nil
  ;;                     :foreground (cl-getf base16-rebecca4k-colors :base0D)
  ;;                     :background (cl-getf base16-rebecca4k-colors :base01))
  (set-face-attribute 'powerline-active1 nil
                      :box nil
                      :foreground (cl-getf base16-rebecca4k-colors :base05)
                      :background (cl-getf base16-rebecca4k-colors :base00))
  (set-face-attribute 'powerline-active2 nil
                      :box nil
                      :foreground (cl-getf base16-rebecca4k-colors :base05)
                      :background (cl-getf base16-rebecca4k-colors :base01))
  ;; TODO: figure out what it does
  ;; (set-face-attribute 'powerline-inactive0 nil
  ;;                     :box nil
  ;;                     :foreground (cl-getf base16-rebecca4k-colors :base0D)
  ;;                     :background (cl-getf base16-rebecca4k-colors :base01))
  (set-face-attribute 'powerline-inactive1 nil
                      :box nil
                      :foreground (cl-getf base16-rebecca4k-colors :base07)
                      :background (cl-getf base16-rebecca4k-colors :base00))
  (set-face-attribute 'powerline-inactive2 nil
                      :box nil
                      :foreground (cl-getf base16-rebecca4k-colors :base07)
                      :background (cl-getf base16-rebecca4k-colors :base00))
  
  (set-face-attribute 'mode-line-buffer-id nil
                      :foreground (cl-getf base16-rebecca4k-colors :base0B))
  (set-face-attribute 'mode-line nil
                      :box nil
                      :foreground (cl-getf base16-rebecca4k-colors :base05)
                      :background (cl-getf base16-rebecca4k-colors :base02))
  
  (set-face-attribute 'mode-line-inactive nil
                      :box nil
                      :foreground (cl-getf base16-rebecca4k-colors :base07)
                      :background (cl-getf base16-rebecca4k-colors :base00))
  (setq powerline-default-separator nil) ;; 'arrow
  (powerline-center-evil-theme))

(use-package hlinum
  :config
  (hlinum-activate)
  (set-face-attribute 'fringe nil
                      :foreground (cl-getf base16-rebecca4k-colors :base05) ;; (face-foreground 'default)
                      :background (cl-getf base16-rebecca4k-colors :base00) ;; (face-background 'default)
                      )
  (set-face-attribute 'linum-highlight-face nil
                      :foreground (cl-getf base16-rebecca4k-colors :base05) ;; "grey80"
                      :background (cl-getf base16-rebecca4k-colors :base00) ;; (face-background 'default)
                      )
  (set-face-attribute 'linum nil
                      :foreground (cl-getf base16-rebecca4k-colors :base07)
                      :background (cl-getf base16-rebecca4k-colors :base00) ;; (face-background 'default)
                      ))

(use-package pos-tip)

(use-package company-quickhelp
  :config
  (company-quickhelp-mode 1)
  (setq company-quickhelp-color-background "grey10")
  (setq company-quickhelp-color-foreground "grey70"))

(use-package company-statistics
  :config
  (add-hook 'after-init-hook 'company-statistics-mode))

(use-package helm-company
  :config
  (autoload 'helm-company "helm-company") ;; Not necessary if using ELPA package
  (eval-after-load 'company
    '(progn
       (define-key company-mode-map (kbd "C-:") 'helm-company)
       (define-key company-active-map (kbd "C-:") 'helm-company))))

(use-package swiper-helm
  :bind
  (("C-s" . swiper-helm)))

(use-package linum
  :config
  (line-number-mode   t)
  (global-linum-mode  t)
  (column-number-mode t)
  (set-face-foreground 'linum "grey26")
  (setq linum-format "%3d"))

(use-package multiple-cursors
  :bind
  (("C->" . mc/mark-next-like-this)
   ("C-<" . mc/mark-previous-like-this)
   ("C-c C-<" . mc/mark-all-like-this)
   ("C-S-c C-S-c" . mc/edit-lines)))

(use-package highlight-symbol
  :demand
  :diminish highlight-symbol-mode
  :config
  (highlight-symbol-set 'highlight-symbol-idle-delay 0.1) ; in seconds
  (add-hook 'prog-mode-hook 'highlight-symbol-mode)
  (add-hook 'emacs-lisp-mode'highlight-symbol-mode) ; ?
  (set-face-background 'highlight-symbol-face "grey20")
  :bind
  (("<f3>" . highlight-symbol-next)
   ("S-<f3>" . highlight-symbol-prev)
   ("C-<f3>" . highlight-symbol)
   ("M-<f3>" . highlight-symbol-query-replace)))

(use-package saveplace
  :config
  (setq-default save-place t))

(use-package hydra
  :config
  (defhydra hydra-zoom (global-map "<f5>")
    "zoom"
    ("g" text-scale-increase "in")
    ("l" text-scale-decrease "out")))

(use-package evil-matchit
  :demand
  :config
  (global-evil-matchit-mode 1)
  (setq evilmi-quote-chars (string-to-list "'\"")))

(use-package window-numbering
  :config
  (window-numbering-mode 1))

(use-package expand-region
  :bind
  ("C-=" . er/expand-region))

(use-package easy-kill
  :bind
  ("M-w" . easy-kill))

(use-package flycheck
  ;; :diminish flycheck-mode
  :init (global-flycheck-mode))

(use-package magit)

(use-package git-gutter-fringe
  :diminish git-gutter-mode
  :config
  (setq git-gutter-fr:side 'right-fringe)
  (global-git-gutter-mode 1))

(use-package ediff
  :config
  (setq-default ediff-forward-word-function 'forward-char))

(use-package hl-todo
  :config
  (global-hl-todo-mode))

(use-package cobol-mode
  :config
  (add-to-list 'auto-mode-alist '("\\.cob\\'" . cobol-mode)))

;; TODO: override `calendar-holidays' with Ukrainian holidays
(use-package calfw)

(use-package calfw-cal)

;; (use-package abbrev-mode
;;   :config
;;   (setq-default abbrev-mode t)
;;   (setq abbrev-file-name "~/.emacs.d/abbrev_defs")
;;   (define-abbrev-table 'global-abbrev-table
;;     '("foramt" "format")))

(use-package ggtags
  :config
  (add-hook 'c-mode-common-hook
          (lambda ()
            (when (derived-mode-p 'c-mode 'java-mode)
              (ggtags-mode 1))))
  (setq-local imenu-create-index-function #'ggtags-build-imenu-index))

(use-package yasnippet
  :diminish yas-minor-mode
  :config
  (yas-reload-all)
  (add-hook 'prog-mode-hook #'yas-minor-mode)
  (add-hook 'slime-repl-mode-hook #'yas-minor-mode)
  ;; (yas-global-mode 1)
  :bind
  ("C-c i" . yas-insert-snippet)
  ("M-/" . yas-expand))

;; (use-package yasnippet-snippets)

(use-package auto-yasnippet)

(use-package volatile-highlights
  :diminish volatile-highlights-mode
  :config
  (volatile-highlights-mode 1)

  (vhl/define-extension 'evil 'evil-paste-after 'evil-paste-before
                      'evil-paste-pop 'evil-move)
  (vhl/install-extension 'evil)

  (vhl/define-extension 'undo-tree 'undo-tree-yank 'undo-tree-move)
  (vhl/install-extension 'undo-tree)

  (vhl/define-extension 'smartparens 'sp-kill-hybrid-sexp
                        'sp-kill-region 'sp-backward-delete-char
                        'sp-delete-char)
  (vhl/install-extension 'smartparens))

(use-package go-mode
  :bind
  (:map go-mode-map
   ("M-." . godef-jump)
   ("M-," . pop-tag-mark)))

(use-package company-go)

(defmacro colorize-parentheses-with (par-color unmatched-par-color)
  `(progn
     ,@(mapcar (lambda (i)
                 `(set-face-attribute
                   ',(intern (concat "rainbow-delimiters-depth-"
                                          (int-to-string i)
                                          "-face"))
                   nil
                   :foreground ,par-color))
               '(1 2 3 4 5 6 7 8 9))
     (set-face-attribute 'rainbow-delimiters-unmatched-face nil
                         :foreground ,unmatched-par-color)))

(use-package rainbow-delimiters
  :config
  (add-hook 'clojure-mode-hook 'rainbow-delimiters-mode)
  (add-hook 'lisp-mode-hook 'rainbow-delimiters-mode)
  (add-hook 'emacs-lisp-mode-hook 'rainbow-delimiters-mode)
  (colorize-parentheses-with (cl-getf base16-rebecca4k-colors :base0D)
                             (cl-getf base16-rebecca4k-colors :base0F)))

(use-package yaml-mode)
(use-package json-mode)
(use-package toml-mode)

(use-package fasd
  :config
  (global-fasd-mode 1)
  ;; (advice-add 'set-buffer :after 'fasd-add-file-to-db) ;; ??? <- is bad
  )

;; ??? v- is good -v
(defadvice set-buffer (after set-buffer-fasd-after activate)
  (fasd-add-file-to-db))

(use-package discover-my-major)

(use-package anaconda-mode
  :config
  (add-hook 'python-mode-hook 'anaconda-mode)
  (add-hook 'python-mode-hook 'anaconda-eldoc-mode)
  :bind
  (:map anaconda-mode-map
   ("M-." . anaconda-mode-find-definitions)
   ("M-," . anaconda-mode-go-back)))

(use-package company-anaconda
  :config
  (eval-after-load "company"
    '(add-to-list 'company-backends 'company-anaconda)))

;; (use-package company-jedi
;;   :config
;;   (add-hook 'python-mode-hook
;;             (lambda () (add-to-list 'company-backends 'company-jedi))))

(use-package flycheck-pyflakes)

(use-package lua-mode
  :config
  (add-to-list 'auto-mode-alist '("\\.lua$" . lua-mode))
  (add-to-list 'interpreter-mode-alist '("lua" . lua-mode)))

(use-package clojure-mode)

(use-package cider
  :config
  (add-hook 'cider-repl-mode-hook 'rainbow-delimiters-mode))

(use-package beacon
  :config
  (setf beacon-color (cl-getf base16-rebecca4k-colors :base01))
  (add-to-list 'beacon-dont-blink-major-modes 'cider-repl-mode)
  (add-to-list 'beacon-dont-blink-major-modes 'slime-repl-mode)
  (beacon-mode 1))

;; https://github.com/millejoh/emacs-ipython-notebook
;; (use-package ein)

(use-package markdown-mode+
  :config
  (add-to-list 'auto-mode-alist '("README\\.md\\'" . gfm-mode))
  (add-to-list 'auto-mode-alist '("\\.md\\'" . markdown-mode))
  (add-to-list 'auto-mode-alist '("\\.markdown\\'" . markdown-mode)))

(use-package minimap
  :bind
  (("<f12>" . minimap-mode)))

(use-package company-web
  :config
  (add-to-list 'company-backends 'company-web-html))

(use-package lorem-ipsum)

(use-package web-mode
  :config
  (add-to-list 'auto-mode-alist '("\\.html\\'" . web-mode))
  (setq web-mode-enable-auto-pairing t)
  (setq web-mode-enable-auto-closing t)
  (setq web-mode-enable-auto-expanding t)
  (setq web-mode-enable-auto-opening t)
  (setq web-mode-enable-css-colorization t)
  (setq web-mode-enable-current-element-highlight t)
  (setq web-mode-enable-current-column-highlight t)  )

(use-package emmet-mode
  :config
  (add-hook 'sgml-mode-hook 'emmet-mode)
  (add-hook 'web-mode-hook 'emmet-mode)
  (add-hook 'css-mode-hook  'emmet-mode))

(use-package helm-emmet)

;; (setq electric-layout-rules '((?\{ . around) (?\} . around)))
(add-hook 'c-mode-hook 'electric-pair-mode)
(add-hook 'c++-mode-hook 'electric-pair-mode)
(add-hook 'java-mode-hook 'electric-pair-mode)
(add-hook 'js-mode-hook 'electric-pair-mode)
(add-hook 'js2-mode-hook 'electric-pair-mode)
(add-hook 'sh-mode-hook 'electric-pair-mode)
(add-hook 'web-mode-hook 'electric-pair-mode)
(add-hook 'css-mode-hook 'electric-pair-mode)


(use-package js2-mode
  :config
  (add-to-list 'auto-mode-alist '("\\.js\\'" . js2-mode)))

(use-package js2-refactor)

(use-package skewer-mode)

(use-package tern
  :config
  (setq tern-command (append tern-command '("--no-port-file"))))

(use-package company-tern
  :config (add-to-list 'company-backend 'company-tern))

;; (use-package ac-js2
;;   :config
;;   (setq ac-js2-evaluate-calls t)
;;   ;;(setq ac-js2-external-libraries '("full/path/to/a-library.js"))
;;   )

(use-package tern
  :config
  (add-hook 'js2-mode-hook 'tern-mode))

(use-package company-tern
  :config
  (add-to-list 'company-backends 'company-tern))

;; (use-package jdee)

;; others ------------------------------------------------------------

;; same as in for cl in lisp-mode with SLIME
(define-key emacs-lisp-mode-map (kbd "C-c C-c") 'eval-defun)
(define-key emacs-lisp-mode-map (kbd "C-c C-k") 'eval-buffer)

;; pretty lambda

(defun esk-pretty-lambdas ()
  (font-lock-add-keywords
   nil
   `(("(?\\(lambda\\>\\)"
      (0 (progn (compose-region (match-beginning 1) (match-end 1)
                                ,(make-char 'greek-iso8859-7 107))
                nil))))))
(add-hook 'prog-mode-hook 'esk-pretty-lambdas)

;; slime with run.lsp
(defun slime-load-run-dot-lsp (&rest args)
  (when (string= (getenv "MACHINE") "work")
    (sleep-for 1)
    (slime-load-file "~/work/utils/run.lsp")))

(advice-add 'slime :after 'slime-load-run-dot-lsp)
(advice-add 'slime-restart-inferior-lisp :after 'slime-load-run-dot-lsp)

;; font
(add-to-list 'default-frame-alist '(font . "DejaVu Sans Mono 10"))

;; https://stackoverflow.com/questions/1242352/get-font-face-under-cursor-in-emacs
(defun what-face (pos)
  "Describe face at point."
    (interactive "d")
        (let ((face (or (get-char-property (point) 'read-face-name)
            (get-char-property (point) 'face))))
    (if face (message "Face: %s" face) (message "No face at %d" pos))))

;; DF: From https://github.com/purcell/emacs.d/blob/master/lisp/init-common-lisp.el
;; From http://bc.tech.coop/blog/070515.html
(defun lispdoc ()
  "Search lispdoc.com for SYMBOL, which is by default the symbol currently under the cursor."
  (interactive)
  (let* ((word-at-point (word-at-point))
         (symbol-at-point (symbol-at-point))
         (default (symbol-name symbol-at-point))
         (inp (read-from-minibuffer
               (if (or word-at-point symbol-at-point)
                   (concat "Symbol (default " default "): ")
                 "Symbol (no default): "))))
    (if (and (string= inp "") (not word-at-point) (not
                                                   symbol-at-point))
        (message "you didn't enter a symbol!")
      (let ((search-type (read-from-minibuffer
                          "full-text (f) or basic (b) search (default b)? ")))
        (browse-url (concat "http://lispdoc.com?q="
                            (if (string= inp "")
                                default
                              inp)
                            "&search="
                            (if (string-equal search-type "f")
                                "full+text+search"
                              "basic+search")))))))
(define-key lisp-mode-map (kbd "<f2>") 'lispdoc)

;; disable startup screen
(setq inhibit-splash-screen t)

;; parentheses things
(show-paren-mode t)
(setq show-paren-style 'parentheses)
(global-set-key (kbd "M-(") '(lambda () (interactive) (sp-wrap-with-pair "(")))
;; (global-set-key (kbd "M-r") 'sp-raise-sexp)
;; (global-set-key (kbd "M-s") 'sp-unwrap-sexp)

;; zap-up-to-char instead of zap-to-char
(autoload 'zap-up-to-char "misc"
   "Kill up to, but not including ARGth occurrence of CHAR." t)
(global-set-key (kbd "M-z") 'zap-up-to-char)

;; ibuffer is better then list-buffers
(global-set-key (kbd "C-x C-b") 'ibuffer)

;; https://github.com/bugdie4k/emacs-smart-home-end
(add-to-list 'load-path "~/.emacs.d/downloaded/emacs-smart-home-end")
(require 'emacs-smart-home-end)

;; https://github.com/bugdie4k/smart-backspace
(add-to-list 'load-path "~/.emacs.d/downloaded/smart-backspace")
(require 'smart-backspace)
(global-set-key (kbd "<backspace>") 'smart-backspace)

(global-set-key [home] 'emacs-smart-home)
(global-set-key (kbd "C-a") 'emacs-smart-home)
(eval-after-load 'evil
  (define-key evil-normal-state-map (kbd "0") 'emacs-smart-home))
(global-set-key (kbd "C-e") 'emacs-smart-end)
(global-set-key [end] 'emacs-smart-end)
(eval-after-load 'evil
  (define-key evil-normal-state-map (kbd "$") 'emacs-smart-end))

;; allows to yank text instead of selected text
;; and use backspace on selected text
(delete-selection-mode 1)

;; disable
(menu-bar-mode -1)
(tool-bar-mode -1)
(when (fboundp 'horizontal-scroll-bar-mode)
  (horizontal-scroll-bar-mode -1))
(scroll-bar-mode -1)

;; tab settings
(setq-default indent-tabs-mode nil)
(setq tab-width 4)

;; switch windows
(global-set-key (kbd "C-<tab>") 'other-window)

;; better defaults stuff
(setq save-interprogram-paste-before-kill t
      apropos-do-all t
      mouse-yank-at-point t
      require-final-newline t
      visible-bell t
      load-prefer-newer t
      ediff-window-setup-function 'ediff-setup-windows-plain
      save-place-file (concat user-emacs-directory "places")
      backup-directory-alist `(("." . ,(concat user-emacs-directory
                                               "backups"))))

;; some editing stuff
(setq kill-whole-line t
      kill-ring-max 5000
      mark-ring-max 5000
      find-lobal-mark-ring-max 5000)
;; (global-set-key "C-k" 'kill-whole-line)

;;
(add-hook 'emacs-lisp-mode-hook 'eldoc-mode)
(diminish 'eldoc-mode nil)
(define-key emacs-lisp-mode-map (kbd "M-.") 'xref-find-definitions)
(define-key emacs-lisp-mode-map (kbd "M-,") 'xref-pop-marker-stack)
;;
(global-auto-revert-mode -1)
(diminish 'auto-revert-mode nil)

;; c/c++
(setq-default
 c-default-style "linux" ;; "bsd"
 c-basic-offset 4)
;; - header
(add-to-list 'auto-mode-alist '("\\.h\\'" . c++-mode))
;; - disable std=c++11 warnings
(add-hook 'c++-mode-hook (lambda () (setq flycheck-gcc-language-standard "c++11")))
;; - go to corresponding .cpp or .h file
(add-hook 'c-mode-common-hook
          (lambda()
            (local-set-key  (kbd "C-c o") 'ff-find-other-file)))
;; - better incalss indentation
(c-set-offset 'inclass 5)
(c-set-offset 'access-label -1)

;; highlight labels/flet/macrolet in lisp
;; https://lists.gnu.org/archive/html/emacs-devel/2012-03/msg00322.html
;; and then
;; https://emacs.stackexchange.com/questions/37220/highlight-labels-flet-macrolet-definitions-in-lisp-mode
(defun mm/match-labels (bound)
  (when (re-search-forward "(\\<\\(labels\\|flet\\|macrolet\\)\\>" bound t)
    (let ((local-functions '())
          (all-start (match-beginning 0))
          (all-end (match-end 0))
          (kw-start (match-beginning 1))
          (kw-end (match-end 1))
          (parse-sexp-ignore-comments t))
      (catch 'done
        (condition-case e
            (progn
              ;; go inside the local functions list
              (goto-char (scan-lists all-end 1 -1))
              (while t
                (save-excursion
                  ;; down into local function definition
                  (goto-char (scan-lists (point) 1 -1))
                  (let* ((name-end (scan-sexps (point) 1))
                         (name-start (scan-sexps name-end -1)))
                    (push name-start local-functions)
                    (push name-end local-functions)))
                ;; advance to the next local function
                (goto-char (scan-sexps (point) 1))))
          (error
           ;; (message "got error %s" e)
           (throw 'done nil))))
      (set-match-data (append
                       (list all-start all-end
                             kw-start kw-end)
                       (nreverse local-functions)
                       (list (current-buffer))))
      (goto-char all-end)
      t)))

(defmacro font-lock-number-of-labels (num)
  `(font-lock-add-keywords
    'lisp-mode
    '(,(append (list 'mm/match-labels
                     '(1 font-lock-keyword-face nil))
               (loop for i from 2 to (1+ num) collect
                     `(,i font-lock-function-name-face nil t))))))

;; try pp-macroexpand-last-sexp on it
(font-lock-number-of-labels 10)

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(browse-url-browser-function (quote browse-url-generic))
 '(browse-url-generic-program "vivaldi")
 '(custom-safe-themes
   (quote
    ("d145690625dc0b4f86fbdd8651fbbb861572c57505edf4fd91be5fead58d692d" "a8cfae7d6dbc794c1d9151aa646166c87e04a484c3143c31c35a4df7c88f6976" "d9edc29a9b27d7098646c3315c5ab8fdf07638b1ab4f80360a521f845a3c5fb0" "45d6370916e70bef5b2a4a93ec7fbaf4e661401d420d9c19d5c3c3397472cb5b" "87d34869134b5497549a25dff75367d68aed7a8e3da598c9fa4e060a4e1f948e" "b04153b12fbb67935f6898f38eb985ec62511fd1df6e2262069efa8565874195" "d6922c974e8a78378eacb01414183ce32bc8dbf2de78aabcc6ad8172547cb074" "2a739405edf418b8581dcd176aaf695d319f99e3488224a3c495cb0f9fd814e3" "8ed752276957903a270c797c4ab52931199806ccd9f0c3bb77f6f4b9e71b9272" "b9a06c75084a7744b8a38cb48bc987de10d68f0317697ccbd894b2d0aca06d2b" "ca1a31c7acdbfe0afc200fe87dc309fed501c4f3c03ed7dfdad67766b7013ceb" "e1b0b148e7bbd941b121dda593e03c1243e0de82118f342bb93165502e5c38ed" "2241178acaad843567b3fd74aca7d454031b29ba4cccfd0cb6fa74db17f36950")))
 '(mode-line-bell-mode t)
 '(package-selected-packages
   (quote
    (rainbow-mode smart-comment mode-line-bell helm-emmet beacon helm-cider cider jdee company-tern tern clojure-mode markdown-mode+ company-tern tern ac-js2 autopair emacs-smart-home-end yasnippet-bundle emmet-mode helm-fuzzier js2-refactor company-web exec-path-from-shell lorem-ipsum minimap indium company-web-html web-mode slime-company ein lua-mode company-anaconda anaconda-mode el-patch flycheck-pyflakes company-jedi jedi json-mode yaml-mode discover-my-major fasd rainbow-delimiters company-go yasnippet volatile-highlights company-cmake ggtags flycheck-irony company-irony company-irony-c-headers irony cmake-ide helm-rtags company-rtags rtags workgroups cfw-ical calfw-cal calfw helm-projectile helm-flyspell flyspell-helm helm-flymake cyberpunk-theme easy-kill git-gutter-fringe flycheck expand-region magit window-numbering evil-matchit powerline company-statistics company-quickhelp helm-company company multiple-cursors highlight-symbol uniquify use-package smartparens helm-ag helm))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(mc/cursor-face ((t (:inherit cursor :inverse-video nil))))
 '(slime-repl-prompt-face ((t (:foreground "medium orchid")))))
(put 'upcase-region 'disabled nil)
(put 'downcase-region 'disabled nil)
