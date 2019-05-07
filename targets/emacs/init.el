;; -*- mode: emacs-lisp -*-

(require 'package)

;; Add MELPA as a pacakges source
(add-to-list 'package-archives (cons "melpa" "https://melpa.org/packages/") t)
;; Load installed packages
(package-initialize)

;; Disable startup screen
(setq inhibit-splash-screen t)
;; Disable menu bar
(menu-bar-mode -1)
;; Disable scroll bar
(when (fboundp 'horizontal-scroll-bar-mode)
  (horizontal-scroll-bar-mode -1))
(scroll-bar-mode -1)
;; Disable tool bar
(tool-bar-mode -1)
;; Allow to yank text instead of selected text
(delete-selection-mode 1)
;; Show trailing spaces
(setq-default show-trailing-whitespace t)
(set-face-attribute 'trailing-whitespace nil :background "red")
;; Do not indent with tabs settings
(setq-default indent-tabs-mode nil)
;; Set tab char to show up as 4 chars
(setq tab-width 4)
;; Highlihg matching paren
(show-paren-mode 1)
;; Remove the delay when highlighting matching paren
(setq show-paren-delay 0)
;; Set font
(set-default-font "DejaVu Sans Mono 10")
;; Show line numbers
; (global-display-line-numbers-mode)

;; An Emacs port of the Atom One Dark theme from Atom.io.
(package-install 'atom-one-dark-theme)
(defvar atom-one-dark-colors-alist
  (let* ((256color  (eq (display-color-cells (selected-frame)) 256))
         (colors `(("atom-one-dark-accent"   . "#528BFF")
                   ("atom-one-dark-fg"       . (if ,256color "color-248" "#ABB2BF"))
                   ;; ("atom-one-dark-bg"       . (if ,256color "color-235" "#282C34"))
                   ("atom-one-dark-bg"       . (if ,256color "color-232" "#090a0c"))
                   ;; ("atom-one-dark-bg-1"     . (if ,256color "color-234" "#121417"))
                   ("atom-one-dark-bg-1"     . (if ,256color "color-232" "#010101"))
                   ;; ("atom-one-dark-bg-hl"    . (if ,256color "color-236" "#2C323C"))
                   ("atom-one-dark-bg-hl"    . (if ,256color "color-234" "#111317"))
                   ("atom-one-dark-gutter"   . (if ,256color "color-239" "#4B5363"))
                   ("atom-one-dark-mono-1"   . (if ,256color "color-248" "#ABB2BF"))
                   ("atom-one-dark-mono-2"   . (if ,256color "color-244" "#828997"))
                   ("atom-one-dark-mono-3"   . (if ,256color "color-240" "#5C6370"))
                   ("atom-one-dark-cyan"     . "#56B6C2")
                   ("atom-one-dark-blue"     . "#61AFEF")
                   ("atom-one-dark-purple"   . "#C678DD")
                   ("atom-one-dark-green"    . "#98C379")
                   ("atom-one-dark-red-1"    . "#E06C75")
                   ("atom-one-dark-red-2"    . "#BE5046")
                   ("atom-one-dark-orange-1" . "#D19A66")
                   ("atom-one-dark-orange-2" . "#E5C07B")
                   ("atom-one-dark-gray"     . (if ,256color "color-237" "#3E4451"))
                   ("atom-one-dark-silver"   . (if ,256color "color-247" "#9DA5B4"))
                   ("atom-one-dark-black"    . (if ,256color "color-233" "#21252B"))
                   ("atom-one-dark-border"   . (if ,256color "color-232" "#181A1F")))))
    colors))
(load-theme 'atom-one-dark t)

;; Evil is an extensible vi layer for Emacs.
(package-install 'evil)
(require 'evil)
(evil-mode 1)

;; A port of vim's easymotion to emacs
(package-install 'evil-easymotion)
(evilem-default-keybindings "SPC")
;; For some reason author desided to scope these motions to a line:
;; https://github.com/PythonNut/evil-easymotion/issues/50#issue-305019561
;; I don't know other way to fix it other than to redefine motions like this.
(evilem-make-motion evilem-motion-forward-word-begin #'evil-forward-word-begin)
(evilem-make-motion evilem-motion-forward-WORD-begin #'evil-forward-WORD-begin)
(evilem-make-motion evilem-motion-forward-word-end #'evil-forward-word-end)
(evilem-make-motion evilem-motion-forward-WORD-end #'evil-forward-WORD-end)
(evilem-make-motion evilem-motion-backward-word-begin #'evil-backward-word-begin)
(evilem-make-motion evilem-motion-backward-WORD-begin #'evil-backward-WORD-begin)

;; Emulate surround.vim from Vim
(package-install 'evil-surround)
(global-evil-surround-mode 1)

;; Comment stuff out. A port of vim-commentary.
(package-install 'evil-commentary)
(require 'evil-commentary)
(evil-commentary-mode)

;; Precision Lisp editing with Evil and Lispy
(package-install 'evil-lispy)
(require 'evil-lispy)
(add-hook 'emacs-lisp-mode-hook #'evil-lispy-mode)
(add-hook 'clojure-mode-hook #'evil-lispy-mode)
(add-hook 'lisp-mode-hook #'evil-lispy-mode)

;; Rewrite of Powerline
(require 'powerline)
(powerline-center-evil-theme)

;; Superior Lisp Interaction Mode for Emacs
(package-install 'slime)
(setq inferior-lisp-program "ros run")
(setq slime-contribs '(slime-fancy))

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-safe-themes
   (quote
    ("01e067188b0b53325fc0a1c6e06643d7e52bc16b6653de2926a480861ad5aa78" "b563a87aa29096e0b2e38889f7a5e3babde9982262181b65de9ce8b78e9324d5" "003a9aa9e4acb50001a006cfde61a6c3012d373c4763b48ceb9d523ceba66829" "3eb93cd9a0da0f3e86b5d932ac0e3b5f0f50de7a0b805d4eb1f67782e9eb67a4" "b59d7adea7873d58160d368d42828e7ac670340f11f36f67fa8071dbf957236a" default)))
 '(package-selected-packages
   (quote
    (evil-easymotion evil-lispy powerline evil atom-one-dark-theme))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
