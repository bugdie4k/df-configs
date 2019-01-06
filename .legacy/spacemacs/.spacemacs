;; -*- mode: emacs-lisp -*-
;; This file is loaded by Spacemacs at startup.
;; It must be stored in your home directory.

(defun dotspacemacs/layers ()
  "Configuration Layers declaration.
You should not put any user code in this function besides modifying the variable
values."
  (setq-default
   ;; Base distribution to use. This is a layer contained in the directory
   ;; `+distribution'. For now available distributions are `spacemacs-base'
   ;; or `spacemacs'. (default 'spacemacs)
   dotspacemacs-distribution 'spacemacs
   ;; Lazy installation of layers (i.e. layers are installed only when a file
   ;; with a supported type is opened). Possible values are `all', `unused'
   ;; and `nil'. `unused' will lazy install only unused layers (i.e. layers
   ;; not listed in variable `dotspacemacs-configuration-layers'), `all' will
   ;; lazy install any layer that support lazy installation even the layers
   ;; listed in `dotspacemacs-configuration-layers'. `nil' disable the lazy
   ;; installation feature and you have to explicitly list a layer in the
   ;; variable `dotspacemacs-configuration-layers' to install it.
   ;; (default 'unused)
   dotspacemacs-enable-lazy-installation 'unused
   ;; If non-nil then Spacemacs will ask for confirmation before installing
   ;; a layer lazily. (default t)
   dotspacemacs-ask-for-lazy-installation t
   ;; If non-nil layers with lazy install support are lazy installed.
   ;; List of additional paths where to look for configuration layers.
   ;; Paths must have a trailing slash (i.e. `~/.mycontribs/')
   dotspacemacs-configuration-layer-path '()
   ;; List of configuration layers to load.
   dotspacemacs-configuration-layers
   '(
     graphviz
     go
     yaml
     csv
     common-lisp
     python
     java
     c-c++
     gtags
     html
     shell-scripts
     nlinum
     spacemacs-editing
     spacemacs-editing-visual
     ;; themes-megapack

     ;; ----------------------------------------------------------------
     ;; Example of useful layers you may want to use right away.
     ;; Uncomment some layer names and press <SPC f e R> (Vim style) or
     ;; <M-m f e R> (Emacs style) to install them.
     ;; ----------------------------------------------------------------
     helm
     auto-completion
     better-defaults
     emacs-lisp
     git
     markdown
     org
     (shell :variables
            shell-default-height 30
            shell-default-position 'bottom)
     spell-checking
     syntax-checking
     version-control
     )
   ;; List of additional packages that will be installed without being
   ;; wrapped in a layer. If you need some configuration for these
   ;; packages, then consider creating a layer. You can also put the
   ;; configuration in `dotspacemacs/user-config'.
   dotspacemacs-additional-packages '(
                                      cobol-mode
                                      highlight-symbol
                                      tabbar
                                      multiple-cursors
                                      easy-kill
                                      nasm-mode
                                      go-autocomplete
                                      )
   ;; A list of packages that cannot be updated.
   dotspacemacs-frozen-packages '()
   ;; A list of packages that will not be installed and loaded.
   dotspacemacs-excluded-packages '()
   ;; Defines the behaviour of Spacemacs when installing packages.
   ;; Possible values are `used-only', `used-but-keep-unused' and `all'.
   ;; `used-only' installs only explicitly used packages and uninstall any
   ;; unused packages as well as their unused dependencies.
   ;; `used-but-keep-unused' installs only the used packages but won't uninstall
   ;; them if they become unused. `all' installs *all* packages supported by
   ;; Spacemacs and never uninstall them. (default is `used-only')
   dotspacemacs-install-packages 'used-only))

(defun dotspacemacs/init ()
  "Initialization function.
This function is called at the very startup of Spacemacs initialization
before layers configuration.
You should not put any user code in there besides modifying the variable
values."
  ;; This setq-default sexp is an exhaustive list of all the supported
  ;; spacemacs settings.
  (setq-default
   ;; If non nil ELPA repositories are contacted via HTTPS whenever it's
   ;; possible. Set it to nil if you have no way to use HTTPS in your
   ;; environment, otherwise it is strongly recommended to let it set to t.
   ;; This variable has no effect if Emacs is launched with the parameter
   ;; `--insecure' which forces the value of this variable to nil.
   ;; (default t)
   dotspacemacs-elpa-https t
   ;; Maximum allowed time in seconds to contact an ELPA repository.
   dotspacemacs-elpa-timeout 5
   ;; If non nil then spacemacs will check for updates at startup
   ;; when the current branch is not `develop'. Note that checking for
   ;; new versions works via git commands, thus it calls GitHub services
   ;; whenever you start Emacs. (default nil)
   dotspacemacs-check-for-update nil
   ;; If non-nil, a form that evaluates to a package directory. For example, to
   ;; use different package directories for different Emacs versions, set this
   ;; to `emacs-version'.
   dotspacemacs-elpa-subdirectory nil
   ;; One of `vim', `emacs' or `hybrid'.
   ;; `hybrid' is like `vim' except that `insert state' is replaced by the
   ;; `hybrid state' with `emacs' key bindings. The value can also be a list
   ;; with `:variables' keyword (similar to layers). Check the editing styles
   ;; section of the documentation for details on available variables.
   ;; (default 'vim)
   dotspacemacs-editing-style '(hybrid :variables
                                       hybrid-mode-enable-evilified-state t
                                       hybrid-mode-enable-hjkl-bindings t
                                       hybrid-mode-default-state 'normal)

   ;; If non nil output loading progress in `*Messages*' buffer. (default nil)
   dotspacemacs-verbose-loading nil
   ;; Specify the startup banner. Default value is `official', it displays
   ;; the official spacemacs logo. An integer value is the index of text
   ;; banner, `random' chooses a random text banner in `core/banners'
   ;; directory. A string value must be a path to an image format supported
   ;; by your Emacs build.
   ;; If the value is nil then no banner is displayed. (default 'official)
   dotspacemacs-startup-banner 'official
   ;; List of items to show in startup buffer or an association list of
   ;; the form `(list-type . list-size)`. If nil then it is disabled.
   ;; Possible values for list-type are:
   ;; `recents' `bookmarks' `projects' `agenda' `todos'."
   ;; List sizes may be nil, in which case
   ;; `spacemacs-buffer-startup-lists-length' takes effect.
   dotspacemacs-startup-lists '((recents . 20)
                                (bookmarks . 20)
                                (projects . 20))
   ;; True if the home buffer should respond to resize events.
   dotspacemacs-startup-buffer-responsive t
   ;; Default major mode of the scratch buffer (default `text-mode')
   dotspacemacs-scratch-mode 'text-mode
   ;; List of themes, the first of the list is loaded when spacemacs starts.
   ;; Press <SPC> T n to cycle to the next theme in the list (works great
   ;; with 2 themes variants, one dark and one light)
   dotspacemacs-themes '(spacemacs-dark
                         spacemacs-light)
   ;; If non nil the cursor color matches the state color in GUI Emacs.
   dotspacemacs-colorize-cursor-according-to-state t
   ;; Default font, or prioritized list of fonts. `powerline-scale' allows to
   ;; quickly tweak the mode-line size to make separators look not too crappy.
   dotspacemacs-default-font '("DejaVu Sans Mono"
                               :size 13
                               :weight normal
                               :width normal
                               :powerline-scale 1.1)
   ;; The leader key
   dotspacemacs-leader-key "SPC"
   ;; The key used for Emacs commands (M-x) (after pressing on the leader key).
   ;; (default "SPC")
   dotspacemacs-emacs-command-key "SPC"
   ;; The key used for Vim Ex commands (default ":")
   dotspacemacs-ex-command-key ":"
   ;; The leader key accessible in `emacs state' and `insert state'
   ;; (default "M-m")
   dotspacemacs-emacs-leader-key "M-m"
   ;; Major mode leader key is a shortcut key which is the equivalent of
   ;; pressing `<leader> m`. Set it to `nil` to disable it. (default ",")
   dotspacemacs-major-mode-leader-key ","
   ;; Major mode leader key accessible in `emacs state' and `insert state'.
   ;; (default "C-M-m")
   dotspacemacs-major-mode-emacs-leader-key "C-M-m"
   ;; These variables control whether separate commands are bound in the GUI to
   ;; the key pairs C-i, TAB and C-m, RET.
   ;; Setting it to a non-nil value, allows for separate commands under <C-i>
   ;; and TAB or <C-m> and RET.
   ;; In the terminal, these pairs are generally indistinguishable, so this only
   ;; works in the GUI. (default nil)
   dotspacemacs-distinguish-gui-tab nil
   ;; If non nil `Y' is remapped to `y$' in Evil states. (default nil)
   dotspacemacs-remap-Y-to-y$ nil
   ;; If non-nil, the shift mappings `<' and `>' retain visual state if used
   ;; there. (default t)
   dotspacemacs-retain-visual-state-on-shift t
   ;; If non-nil, J and K move lines up and down when in visual mode.
   ;; (default nil)
   dotspacemacs-visual-line-move-text nil
   ;; If non nil, inverse the meaning of `g' in `:substitute' Evil ex-command.
   ;; (default nil)
   dotspacemacs-ex-substitute-global nil
   ;; Name of the default layout (default "Default")
   dotspacemacs-default-layout-name "Default"
   ;; If non nil the default layout name is displayed in the mode-line.
   ;; (default nil)
   dotspacemacs-display-default-layout nil
   ;; If non nil then the last auto saved layouts are resume automatically upon
   ;; start. (default nil)
   dotspacemacs-auto-resume-layouts nil
   ;; Size (in MB) above which spacemacs will prompt to open the large file
   ;; literally to avoid performance issues. Opening a file literally means that
   ;; no major mode or minor modes are active. (default is 1)
   dotspacemacs-large-file-size 1
   ;; Location where to auto-save files. Possible values are `original' to
   ;; auto-save the file in-place, `cache' to auto-save the file to another
   ;; file stored in the cache directory and `nil' to disable auto-saving.
   ;; (default 'cache)
   dotspacemacs-auto-save-file-location 'cache
   ;; Maximum number of rollback slots to keep in the cache. (default 5)
   dotspacemacs-max-rollback-slots 5
   ;; If non nil, `helm' will try to minimize the space it uses. (default nil)
   dotspacemacs-helm-resize nil
   ;; if non nil, the helm header is hidden when there is only one source.
   ;; (default nil)
   dotspacemacs-helm-no-header nil
   ;; define the position to display `helm', options are `bottom', `top',
   ;; `left', or `right'. (default 'bottom)
   dotspacemacs-helm-position 'bottom
   ;; Controls fuzzy matching in helm. If set to `always', force fuzzy matching
   ;; in all non-asynchronous sources. If set to `source', preserve individual
   ;; source settings. Else, disable fuzzy matching in all sources.
   ;; (default 'always)
   dotspacemacs-helm-use-fuzzy 'always
   ;; If non nil the paste micro-state is enabled. When enabled pressing `p`
   ;; several times cycle between the kill ring content. (default nil)
   dotspacemacs-enable-paste-transient-state nil
   ;; Which-key delay in seconds. The which-key buffer is the popup listing
   ;; the commands bound to the current keystroke sequence. (default 0.4)
   dotspacemacs-which-key-delay 0.4
   ;; Which-key frame position. Possible values are `right', `bottom' and
   ;; `right-then-bottom'. right-then-bottom tries to display the frame to the
   ;; right; if there is insufficient space it displays it at the bottom.
   ;; (default 'bottom)
   dotspacemacs-which-key-position 'bottom
   ;; If non nil a progress bar is displayed when spacemacs is loading. This
   ;; may increase the boot time on some systems and emacs builds, set it to
   ;; nil to boost the loading time. (default t)
   dotspacemacs-loading-progress-bar t
   ;; If non nil the frame is fullscreen when Emacs starts up. (default nil)
   ;; (Emacs 24.4+ only)
   dotspacemacs-fullscreen-at-startup t
   ;; If non nil `spacemacs/toggle-fullscreen' will not use native fullscreen.
   ;; Use to disable fullscreen animations in OSX. (default nil)
   dotspacemacs-fullscreen-use-non-native nil
   ;; If non nil the frame is maximized when Emacs starts up.
   ;; Takes effect only if `dotspacemacs-fullscreen-at-startup' is nil.
   ;; (default nil) (Emacs 24.4+ only)
   dotspacemacs-maximized-at-startup t
   ;; A value from the range (0..100), in increasing opacity, which describes
   ;; the transparency level of a frame when it's active or selected.
   ;; Transparency can be toggled through `toggle-transparency'. (default 90)
   dotspacemacs-active-transparency 90
   ;; A value from the range (0..100), in increasing opacity, which describes
   ;; the transparency level of a frame when it's inactive or deselected.
   ;; Transparency can be toggled through `toggle-transparency'. (default 90)
   dotspacemacs-inactive-transparency 90
   ;; If non nil show the titles of transient states. (default t)
   dotspacemacs-show-transient-state-title t
   ;; If non nil show the color guide hint for transient state keys. (default t)
   dotspacemacs-show-transient-state-color-guide t
   ;; If non nil unicode symbols are displayed in the mode line. (default t)
   dotspacemacs-mode-line-unicode-symbols t
   ;; If non nil smooth scrolling (native-scrolling) is enabled. Smooth
   ;; scrolling overrides the default behavior of Emacs which recenters point
   ;; when it reaches the top or bottom of the screen. (default t)
   dotspacemacs-smooth-scrolling t
   ;; Control line numbers activation.
   ;; If set to `t' or `relative' line numbers are turned on in all `prog-mode' and
   ;; `text-mode' derivatives. If set to `relative', line numbers are relative.
   ;; This variable can also be set to a property list for finer control:
   ;; '(:relative nil
   ;;   :disabled-for-modes dired-mode
   ;;                       doc-view-mode
   ;;                       markdown-mode
   ;;                       org-mode
   ;;                       pdf-view-mode
   ;;                       text-mode
   ;;   :size-limit-kb 1000)
   ;; (default nil)
   dotspacemacs-line-numbers nil
   ;; Code folding method. Possible values are `evil' and `origami'.
   ;; (default 'evil)
   dotspacemacs-folding-method 'evil
   ;; If non-nil smartparens-strict-mode will be enabled in programming modes.
   ;; (default nil)
   dotspacemacs-smartparens-strict-mode nil
   ;; If non-nil pressing the closing parenthesis `)' key in insert mode passes
   ;; over any automatically added closing parenthesis, bracket, quote, etc…
   ;; This can be temporary disabled by pressing `C-q' before `)'. (default nil)
   dotspacemacs-smart-closing-parenthesis nil
   ;; Select a scope to highlight delimiters. Possible values are `any',
   ;; `current', `all' or `nil'. Default is `all' (highlight any scope and
   ;; emphasis the current one). (default 'all)
   dotspacemacs-highlight-delimiters 'all
   ;; If non nil, advise quit functions to keep server open when quitting.
   ;; (default nil)
   dotspacemacs-persistent-server nil
   ;; List of search tool executable names. Spacemacs uses the first installed
   ;; tool of the list. Supported tools are `ag', `pt', `ack' and `grep'.
   ;; (default '("ag" "pt" "ack" "grep"))
   dotspacemacs-search-tools '("ag" "pt" "ack" "grep")
   ;; The default package repository used if no explicit repository has been
   ;; specified with an installed package.
   ;; Not used for now. (default nil)
   dotspacemacs-default-package-repository nil
   ;; Delete whitespace while saving buffer. Possible values are `all'
   ;; to aggressively delete empty line and long sequences of whitespace,
   ;; `trailing' to delete only the whitespace at end of lines, `changed' to
   ;; delete only whitespace for changed lines or `nil' to disable cleanup.
   ;; (default nil)
   dotspacemacs-whitespace-cleanup nil
   ))

(defun dotspacemacs/user-init ()
  "Initialization function for user code.
It is called immediately after `dotspacemacs/init', before layer configuration
executes.
 This function is mostly useful for variables that need to be set
before packages are loaded. If you are unsure, you should try in setting them in
`dotspacemacs/user-config' first."
  ;; (defvar slime-repl-enable-smartparens t
  ;;   "If non nil smartparens is enabled on SLIME REPL.")
  (custom-set-variables '(spacemacs-theme-custom-colors
                          '((comment . "#697b8c"))))
  )

(defun dotspacemacs/user-config ()
  "Configuration function for user code.
This function is called at the very end of Spacemacs initialization after
layers configuration.
This is the place where most of your configurations should be done. Unless it is
explicitly specified that a variable should be set before a package is loaded,
you should place your code here."
  ;; ======================================== LISP
  ;; -------------------- PARENTHESES
  ;; * make smartparens use paredit bindings
  (sp-use-paredit-bindings)
  ;; * make smartparens more like paredit for lisp
  (add-hook 'lisp-mode-hook 'smartparens-strict-mode)
  (add-hook 'emacs-lisp-mode-hook 'smartparens-strict-mode)
  ;; * show parentheses with 'parentheses' style
  (setq show-paren-style 'parentheses)
  ;; * wrap with parentheses
  (global-set-key (kbd "M-(") 'lisp-state-wrap)
  ;; -------------------- CLHS
  ;; * directory with CLHS files
  (setq common-lisp-hyperspec-root (expand-file-name "~/.emacs.d/private/CLHS/HyperSpec/"))
  ;; * look up thing in CLHS on F2
  (global-set-key [(f2)] 'slime-hyperspec-lookup)
  ;; -------------------- SLIME
  ;; (add-hook 'slime-repl-mode-hook 'rainbow-delimiters-mode)
  ;; (add-hook 'slime-repl-mode-hook 'highlight-parentheses-mode)
  (add-hook 'slime-repl-mode-hook 'smartparens-strict-mode)
  ;; (add-hook 'slime-repl-mode-hook '(lambda () (show-smartparens-mode -1)))
  ;; * override slime defaults with smartparens functions
  (defun keys-for-slime ()
    ;; - smartparens keys
    (define-key slime-repl-mode-map (kbd "M-r") 'sp-splice-sexp-killing-around)
    (define-key slime-repl-mode-map (kbd "M-s") 'sp-splice-sexp)
    ;; - home/end keys
    (define-key slime-repl-mode-map (kbd "C-e") 'move-end-of-line)
    (define-key slime-repl-mode-map (kbd "C-a") 'move-beginning-of-line))
  (add-hook 'slime-repl-mode-hook 'keys-for-slime)
  ;; * enable LISP syntax highlighting in SLIME REPL. stolen from
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
  (defun slime-repl-font-lock-find-prompt (limit) ;; Rough: (re-search-forward "^\\w*>" limit t)
    (let (beg end)
      (when (setq beg (text-property-any (point) limit 'slime-repl-prompt t))
        (setq end (or (text-property-any beg limit 'slime-repl-prompt nil) limit))
        (goto-char beg)
        (set-match-data (list beg end)) t)))
  (setq slime-repl-font-lock-keywords (cons '(slime-repl-font-lock-find-prompt . 'slime-repl-prompt-face) slime-repl-font-lock-keywords))
  ;; -------------------- MISC
  ;; * replace 'lambda' word with Greek letter
  (add-hook 'prog-mode-hook '(lambda ()
                               (font-lock-add-keywords
                                nil `(("(?\\(lambda\\>\\)"
                                       (0 (progn (compose-region (match-beginning 1) (match-end 1)
                                                                 ,(make-char 'greek-iso8859-7 107))
                                                 nil)))))))
  ;; * set inferior-lisp-program
  (setq inferior-lisp-program (getenv "LISP_INTERPRETER"))
  ;; * highlight-parentheses-mode color
  (setq hl-paren-colors '("yellow"))
  ;; * enable smg-mode
  (load-file (expand-file-name "~/.emacs.d/private/smg-mode.el"))
  ;; * cool debug outputs
  (defun dbp ()
    (interactive)
    (let ((mark (read-string "mark: ")))
      (insert (concat "(df:dbp :p> \"m::" mark "\" :m> )"))
      (backward-char)))
  (defun insert-call (text backward-char?)
    (insert text)
    (when backward-char? (backward-char)))
  (defmacro definserts (&rest defs)
    `(progn
       ,@(mapcar (lambda (def)
                   `(defun ,(car def) '() (interactive) (insert-call ,@(cdr def))))
                 defs)))
  (definserts
     (dbp-reset "(df:dbp-reset-counter)" nil)
     (mkup      "(df:mkup )"             t)
     (fmt       "(df:fmt )"              t)
     (ft        "(df:ft )"               t))
  ;; * i don't like it with lisp
  (add-hook 'lisp-mode-hook '(lambda () (highlight-parentheses-mode -1)))
  (add-hook 'emacs-lisp-mode-hook '(lambda () (highlight-parentheses-mode -1)))
  ;; * sunrise with slime mode in lisp buffers KLUDGE
  (add-hook 'slime-mode-hook '(lambda () (define-key slime-mode-map (kbd "C-c x") 'sunrise)))
  ;; * completion at point
  (global-set-key (kbd "M-/") 'completion-at-point)
  ;; * quit to normal mode (command mode)
  (define-key evil-hybrid-state-map (kbd "M-q") 'evil-normal-state)
  ;; * break insert
  (defun bri ()
    (interactive)
    (let ((mark (read-string "break mark: ")))
      (insert (concat "(break \"[break mark: " mark "]~%~% ~A\" )"))
      (backward-char)))

  ;; ======================================== C/C++
  ;; * nice braces and indentation
  (setq-default
   c-default-style "linux" ;; "bsd"
   c-basic-offset 4)
  ;; * header
  (add-to-list 'auto-mode-alist '("\\.h\\'" . c++-mode))
  ;; * disable std=c++11 warnings
  (add-hook 'c++-mode-hook (lambda () (setq flycheck-gcc-language-standard "c++11")))
  ;; * go to corresponding .cpp or .h file
  (add-hook 'c-mode-common-hook
            (lambda()
              (local-set-key  (kbd "C-c o") 'ff-find-other-file)))
  ;; * better incalss indentation
  (c-set-offset 'inclass 5)
  (c-set-offset 'access-label -1)

  ;; ======================================== GO
  ;; * autocompletion
  (defun auto-complete-for-go ()
    (auto-complete-mode 1))
  (add-hook 'go-mode-hook 'auto-complete-for-go)
  (with-eval-after-load 'go-mode
    (require 'go-autocomplete))
  ;; * godef
  (defun my-go-mode-hook ()
    (define-key evil-normal-state-map (kbd "M-.") nil)
    ;; Call Gofmt before saving
    ;; (add-hook 'before-save-hook 'gofmt-before-save)
    ;; Godef jump key binding
    (define-key 'helm-mode (kbd "M-.") nil)
    (define-key 'helm-mode (kbd "M-,") nil)
    (local-set-key (kbd "M-.") 'godef-jump)
    (local-set-key (kbd "M-,") 'pop-tag-mark)
    (setq go-tab-width 8)
    )
  (add-hook 'go-mode-hook 'my-go-mode-hook)

  ;; ======================================== MISC
  ;; * sunrise commander
  (load-file (expand-file-name "~/.emacs.d/private/sunrise-commander/sunrise-commander.el"))
  (load-file (expand-file-name "~/.emacs.d/private/sunrise-commander/sunrise-x-buttons.el"))
  ;; (load-file (expand-file-name "~/.emacs.d/private/sunrise-commander/sunrise-x-modeline.el"))
  (load-file (expand-file-name "~/.emacs.d/private/sunrise-commander/sunrise-x-popviewer.el"))
  ;; (load-file (expand-file-name "~/.emacs.d/private/sunrise-commander/sunrise-x-tabs.el"))
  (load-file (expand-file-name "~/.emacs.d/private/sunrise-commander/sunrise-x-tree.el"))
  (load-file (expand-file-name "~/.emacs.d/private/sunrise-commander/sunrise-x-checkpoints.el"))
  ;;
  (global-set-key (kbd "C-c x") 'sunrise)
  (global-set-key (kbd "C-c X") 'sunrise-cd)
  ;; usual mc keys
  (define-key sr-mode-map (kbd "b")   'sr-dired-prev-subdir)
  (define-key sr-mode-map (kbd "f") 'sr-advertised-find-file)
  (define-key sr-mode-map (kbd "n") 'dired-next-line)
  (define-key sr-mode-map (kbd "p") 'dired-previous-line)
  (define-key sr-mode-map (kbd "C-w") 'sr-popviewer-mode)
  (define-key sr-mode-map (kbd "C-o") 'sr-term-cd-newterm)
  ;; dired
  (define-key dired-mode-map (kbd "b") 'dired-up-directory)
  ;; * fix for 'Invalid face: linum' when creating new frame with linum enabled or starting as daemon with global linum
  ;; https://github.com/kaushalmodi/.emacs.d/issues/4#issue comment-228526663
  (defun initialize-nlinum (&optional frame)
    (require 'nlinum)
    (add-hook 'prog-mode-hook 'nlinum-mode))
  (when (daemonp)
    (add-hook 'window-setup-hook 'initialize-nlinum)
    (defadvice make-frame (around toggle-nlinum-mode compile activate)
      (nlinum-mode -1) ad-do-it (nlinum-mode 1)))
  ;; * make completion use TAB to select and leave RET and C-f alone
  (setq auto-completion-return-key-behavior nil)
  (setq auto-completion-tab-key-behavior 'complete)
  (with-eval-after-load 'company
    (define-key company-active-map (kbd "C-f") nil))
  ;; * do not turn nlinum on on startup (it causes weird error '*ERROR*: Invalid face: linum'), but turn it on in prog modes
  (add-hook 'prog-mode-hook 'nlinum-mode)
  ;; * maximize frame on its creation
  (add-to-list 'default-frame-alist '(fullscreen . maximized))
  ;; * browser setup
  (setq browse-url-browser-function 'browse-url-generic
        browse-url-generic-program "vivaldi")
  ;; ;; * more convenient window splits
  (global-unset-key (kbd "M-O"))
  (global-set-key (kbd "M-O") 'split-window-below) ; i.e. M-S-o, hOrizontally
  (global-unset-key (kbd "M-E"))
  (global-set-key (kbd "M-E") 'split-window-right) ; i.e. M-S-e, vertically
  ;; * more convenient 'other-window
  (global-set-key (kbd "C-<tab>") 'other-window)
  ;; * insert instead if selected text. allows to delete selections with backspace
  (delete-selection-mode)
  ;; * symbol highlighting with highlight-symbol
  (add-hook 'prog-mode-hook 'highlight-symbol-mode)
  (global-set-key [(control f3)] 'highlight-symbol)
  (global-set-key [f3] 'highlight-symbol-next)
  (global-set-key [(shift f3)] 'highlight-symbol-prev)
  (global-set-key [(meta f3)] 'highlight-symbol-query-replace)
  ;; * disable highlighting of current line
  (global-hl-line-mode -1)
  ;; * moving border
  (load-file (expand-file-name "~/.emacs.d/private/move-border.el")) ; keys are defined inside
  ;; * MULTIPLE CURSORS (they just make me happy, don't know why)
  (global-set-key (kbd "C->") 'mc/mark-next-like-this)
  (global-set-key (kbd "C-<") 'mc/mark-previous-like-this)
  (global-set-key (kbd "C-S-c a") 'mc/mark-all-like-this)
  (global-set-key (kbd "C-S-c l") 'mc/edit-lines)
  ;; * avy (ace-jump improved)
  (global-set-key (kbd "C-'") 'avy-goto-char)
  ;; (global-set-key (kbd "C-:") 'avy-goto-word-1) ;; == C-S-;
  ;; ;; * Change cursor color according to mode (from https://www.emacswiki.org/emacs/ChangingCursorDynamically)
  ;; (defvar hcz-set-cursor-color-color "")
  ;; (defvar hcz-set-cursor-color-buffer "")
  ;; (defun hcz-set-cursor-color-according-to-mode ()
  ;;   "change cursor color according to some minor modes."
  ;;   ;; set-cursor-color is somewhat costly, so we only call it when needed:
  ;;   (let ((color
  ;;          (if buffer-read-only
  ;;              "palegreen1"
  ;;            (if overwrite-mode
  ;;                "red"
  ;;              "skyblue2"))))
  ;;     (unless (and
  ;;              (string= color hcz-set-cursor-color-color)
  ;;              (string= (buffer-name) hcz-set-cursor-color-buffer))
  ;;       (set-cursor-color (setq hcz-set-cursor-color-color color))
  ;;       (setq hcz-set-cursor-color-buffer (buffer-name)))))
  ;; (add-hook 'post-command-hook 'hcz-set-cursor-color-according-to-mode)
  ;; * neotree
  (global-set-key [f8] 'neotree-toggle)
  ;; * jump to current node when neotree is open
  (setq neo-smart-open t)
  ;; * recenter when searching
  (add-hook 'isearch-mode-end-hook 'recenter)
  (defadvice
      isearch-repeat-forward
      (after isearch-repeat-forward-recenter activate)
    (recenter))
  (defadvice
      isearch-repeat-backward
      (after isearch-repeat-backward-recenter activate)
    (recenter))
  (ad-activate 'isearch-repeat-forward)
  (ad-activate 'isearch-repeat-backward)
  ;; * recenter on M-. and M-,
  (defun recenter-advice (&rest args)
    (recenter))
  (advice-add 'slime-edit-definition :after #'recenter-advice)
  (advice-add 'slime-pop-find-definition-stack :after #'recenter-advice)
  (advice-add 'smg-go-to-def :after #'recenter-advice)
  (advice-add 'smg-go-back :after #'recenter-advice)
  ;; * scroll half window
  (defun window-half-height ()
    (max 1 (/ (1- (window-height (selected-window))) 2)))
  (defun scroll-up-half ()
    (interactive)
    (scroll-up (window-half-height)))
  (defun scroll-down-half ()
    (interactive)
    (scroll-down (window-half-height)))
  (global-set-key (kbd "C-v") 'scroll-up-half)   ;; half scrolls up and you scroll down
  (global-set-key (kbd "M-v") 'scroll-down-half) ;; same
  ;; * scroll line
  (global-set-key (kbd "C-<up>") 'scroll-down-line)
  (global-set-key (kbd "C-<down>") 'scroll-up-line)
  ;; * enable easy-kill
  (global-set-key [remap kill-ring-save] 'easy-kill)
  ;; * evil-mode enchancements
  ;; (define-key evil-normal-state-map (kbd "C-e") 'mwim-end-of-line-or-code)
  ;; (define-key evil-normal-state-map (kbd "C-a") 'mwim-beginning-of-code-or-line)
  (define-key evil-normal-state-map (kbd "0") 'mwim-beginning-of-code-or-line)
  (define-key evil-normal-state-map (kbd "^") 'evil-digit-argument-or-evil-beginning-of-line)
  ;;
  (define-key evil-normal-state-map (kbd "M-.") nil)
  ;; * nasm
  (add-to-list 'auto-mode-alist '("\\.\\(asm\\|s\\)$" . nasm-mode))
  ;; * Smart way is to load files in ~/.sbclrc, but it doesn't work for reasons
  (defun slime2 ()
    (interactive)
    (slime)
    (sleep-for 3)
    (slime-load-file "~/work/utils/run.lsp"))
  (defun slime-restart-inferior-lisp2 ()
    (interactive)
    (slime-restart-inferior-lisp)
    (sleep-for 1)
    (slime-load-file "~/work/utils/run.lsp"))
  )

;; do not write anything past this comment. This is where Emacs will
;; auto-generate custom variable definitions.
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-safe-themes
   (quote
    ("bffa9739ce0752a37d9b1eee78fc00ba159748f50dc328af4be661484848e476" default)))
 '(evil-want-Y-yank-to-eol nil)
 '(highlight-symbol-idle-delay 0.3)
 '(nlinum-highlight-current-line t)
 '(package-selected-packages
   (quote
    (bison-mode graphviz-dot-mode company-anaconda anaconda-mode go-autocomplete nasm-mode go-guru go-eldoc company-go go-mode web-beautify livid-mode skewer-mode simple-httpd json-mode json-snatcher json-reformat js2-refactor js2-mode js-doc company-tern dash-functional tern coffee-mode yaml-mode helm-gtags ggtags easy-kill highlight-parentheses multiple-cursors tabbar highlight-symbol cobol-mode live-py-mode less-css-mode insert-shebang hy-mode helm-pydoc helm-css-scss haml-mode fish-mode common-lisp-snippets slime-company slime zonokai-theme zenburn-theme zen-and-art-theme underwater-theme ujelly-theme twilight-theme twilight-bright-theme twilight-anti-bright-theme tronesque-theme toxi-theme tao-theme tangotango-theme tango-plus-theme tango-2-theme sunny-day-theme sublime-themes subatomic256-theme subatomic-theme spacegray-theme soothe-theme solarized-theme soft-stone-theme soft-morning-theme soft-charcoal-theme smyx-theme seti-theme reverse-theme railscasts-theme purple-haze-theme professional-theme planet-theme phoenix-dark-pink-theme phoenix-dark-mono-theme pastels-on-dark-theme organic-green-theme omtose-phellack-theme oldlace-theme occidental-theme obsidian-theme noctilux-theme niflheim-theme naquadah-theme mustang-theme monokai-theme monochrome-theme molokai-theme moe-theme minimal-theme material-theme majapahit-theme madhat2r-theme lush-theme light-soap-theme jbeans-theme jazz-theme ir-black-theme inkpot-theme heroku-theme hemisu-theme hc-zenburn-theme gruvbox-theme gruber-darker-theme grandshell-theme gotham-theme gandalf-theme flatui-theme flatland-theme firebelly-theme farmhouse-theme espresso-theme dracula-theme django-theme darktooth-theme autothemer darkokai-theme darkmine-theme darkburn-theme dakrone-theme cyberpunk-theme color-theme-sanityinc-tomorrow color-theme-sanityinc-solarized clues-theme cherry-blossom-theme busybee-theme bubbleberry-theme birds-of-paradise-plus-theme badwolf-theme aproppospriate-theme anti-zenburn-theme ample-zen-theme ample-theme alect-themes afternoon-theme hlinum yapfify web-mode tagedit slim-mode scss-mode sass-mode pyvenv pytest pyenv-mode py-isort pug-mode pip-requirements nlinum-relative nlinum emmet-mode disaster cython-mode company-web web-completion-data company-shell company-emacs-eclim eclim company-c-headers cmake-mode clang-format pythonic xterm-color unfill smeargle shell-pop orgit org-projectile org-present org-pomodoro alert log4e gntp org-download mwim multi-term mmm-mode markdown-toc markdown-mode magit-gitflow htmlize helm-gitignore helm-company helm-c-yasnippet gnuplot gitignore-mode gitconfig-mode gitattributes-mode git-timemachine git-messenger git-link git-gutter-fringe+ git-gutter-fringe fringe-helper git-gutter+ git-gutter gh-md fuzzy flyspell-correct-helm flyspell-correct flycheck-pos-tip pos-tip flycheck evil-magit magit magit-popup git-commit with-editor eshell-z eshell-prompt-extras esh-help diff-hl company-statistics company auto-yasnippet yasnippet auto-dictionary ac-ispell auto-complete csv-mode spinner adaptive-wrap ws-butler winum which-key volatile-highlights vi-tilde-fringe uuidgen use-package toc-org spaceline powerline restart-emacs request rainbow-delimiters popwin persp-mode pcre2el paradox org-plus-contrib org-bullets open-junk-file neotree move-text macrostep lorem-ipsum linum-relative link-hint info+ indent-guide hydra hungry-delete hl-todo highlight-numbers parent-mode highlight-indentation hide-comnt help-fns+ helm-themes helm-swoop helm-projectile helm-mode-manager helm-make projectile pkg-info epl helm-flx helm-descbinds helm-ag google-translate golden-ratio flx-ido flx fill-column-indicator fancy-battery eyebrowse expand-region exec-path-from-shell evil-visualstar evil-visual-mark-mode evil-unimpaired evil-tutor evil-surround evil-search-highlight-persist evil-numbers evil-nerd-commenter evil-mc evil-matchit evil-lisp-state smartparens evil-indent-plus evil-iedit-state iedit evil-exchange evil-escape evil-ediff evil-args evil-anzu anzu evil goto-chg undo-tree eval-sexp-fu highlight elisp-slime-nav dumb-jump f s diminish define-word column-enforce-mode clean-aindent-mode bind-map bind-key auto-highlight-symbol auto-compile packed dash aggressive-indent ace-window ace-link ace-jump-helm-line helm avy helm-core popup async)))
 '(show-smartparens-global-mode t)
 '(sp-show-pair-delay 0)
 '(sp-show-pair-from-inside nil)
 '(spacemacs-theme-custom-colors (quote ((comment . "#697b8c"))))
 '(sr-modeline-use-utf8-marks t)
 '(sr-terminal-program "eshell")
 '(sr-traditional-other-window t)
 '(sr-windows-default-ratio 75))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(default ((t (:background nil))))
 '(dired-directory ((t (:inherit nil :background "#292b2e" :foreground "#ff5faf"))))
 '(dired-header ((t (:inherit bold :foreground "#5fff87"))))
 '(dired-marked ((t (:inherit bold :foreground "#87ff00"))))
 '(dired-symlink ((t (:inherit nil :background "#292b2e" :foreground "#28def0"))))
 '(highlight-symbol-face ((t (:background "#7520a0"))))
 '(linum ((t (:inherit default :background "#292b2e" :foreground "#44505c"))))
 '(nlinum-current-line ((t (:inherit linum :foreground "#2aa1ae"))))
 '(rainbow-delimiters-depth-1-face ((t (:foreground "#67b11d"))))
 '(rainbow-delimiters-depth-2-face ((t (:foreground "#67b11d"))))
 '(rainbow-delimiters-depth-3-face ((t (:foreground "#67b11d"))))
 '(rainbow-delimiters-depth-4-face ((t (:foreground "#67b11d"))))
 '(rainbow-delimiters-depth-5-face ((t (:foreground "#67b11d"))))
 '(rainbow-delimiters-depth-6-face ((t (:foreground "#67b11d"))))
 '(rainbow-delimiters-depth-7-face ((t (:foreground "#67b11d"))))
 '(rainbow-delimiters-depth-8-face ((t (:foreground "#67b11d"))))
 '(rainbow-delimiters-depth-9-face ((t (:foreground "#67b11d"))))
 '(slime-repl-prompt-face ((t (:foreground "medium spring green"))))
 '(sp-show-pair-match-face ((t (:inherit bold :foreground "magenta" :underline t))))
 '(sp-wrap-overlay-closing-pair ((t (:inherit sp-wrap-overlay-face :foreground "red"))))
 '(sr-active-path-face ((t (:background "#5fff87" :foreground "#080808" :weight bold :height 120))))
 '(sr-alt-marked-dir-face ((t (:foreground "#87ff00" :weight bold))))
 '(sr-directory-face ((t (:inherit dired-directory))))
 '(sr-marked-file-face ((t (:inherit dired-marked :weight light))))
 '(sr-passive-path-face ((t (:foreground "#5fff87" :weight bold :height 120))))
 '(sr-symlink-face ((t (:inherit dired-symlink))))
 '(trailing-whitespace ((t (:background "#4c3d35")))))
