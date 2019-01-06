;;; smg-mode.el --- major mode for SMG grammar files

;; Copyright (C) 1999-2015 Free Software Foundation, Inc.
;; Copyright (C) 2017-2017 Yurii Hryhorenko

;; Author: Yurii Hryhorenko
;; Keywords: languages, SMG, code generator
;; Version: 0.1c
;; Based on antlr-mode by Christoph Wedler

;;; Commentary:

;; The Emacs package SMG-Mode provides: syntax highlighting for SMG grammar
;; files, automatic indentation, menus containing rule/token definitions and
;; supported options and various other things.

;; For details,  follow all commands mentioned in the documentation of
;; `smg-mode'.

;; Bug fixes, bug reports, improvements, and suggestions for the newest version
;; are strongly appreciated.

;;; Installation:

;; This file requires Emacs-24 or higher and package cc-mode.

;; If smg-mode is not part of your distribution, put this file into your
;; load-path and the following into your init file:
;;   (autoload 'smg-mode "smg-mode" nil t)
;;   (push '("\\.smg\\'" . smg-mode) auto-mode-alist)

;; To customize, use menu item "Smg" -> "Customize Smg".

;;; Code:

(require 'easymenu)
(require 'cc-mode)
(require 'cl-lib)

(defvar outline-level)
(defvar imenu-use-markers)
(defvar imenu-create-index-function)

;; We cannot use `c-forward-syntactic-ws' directly since it is a macro since
;; cc-mode-5.30 => smg-mode compiled with older cc-mode would fail (macro
;; call) when used with newer cc-mode.  Also, smg-mode compiled with newer
;; cc-mode would fail (undefined `c-forward-sws') when used with older cc-mode.
;; Additional to the `defalias' below, we must set `smg-c-forward-sws' to
;; `c-forward-syntactic-ws' when `c-forward-sws' is not defined after requiring
;; cc-mode.
(defalias 'smg-c-forward-sws 'c-forward-sws)


;;;;##########################################################################
;;;;  Variables
;;;;##########################################################################

(defgroup smg nil
  "Major mode for SMG grammar files."
  :group 'languages
  :link '(emacs-commentary-link "smg-mode.el")
  :prefix "smg-")

(defconst smg-version "0.1c"
  "SMG major mode version number.")


;;;===========================================================================
;;;  Controlling SMG's code generator (language option)
;;;===========================================================================

;; (defvar smg-language nil
;;   "Major mode corresponding to SMG's \"language\" option.
;; Set via `smg-language-alist'.  The only useful place to change this
;; buffer-local variable yourself is in `smg-mode-hook' or in the \"local
;; variable list\" near the end of the file, see
;; `enable-local-variables'.")

;; (defcustom smg-language-alist
;;   '((java-mode "Java" nil "\"Java\"" "Java")
;;     (c++-mode "C++" "\"Cpp\"" "Cpp"))
;;   "List of SMG's supported languages.
;; Each element in this list looks like
;;   \(MAJOR-MODE MODELINE-STRING OPTION-VALUE...)

;; MAJOR-MODE, the major mode of the code in the grammar's actions, is the
;; value of `smg-language' if the first group in the string matched by
;; REGEXP in `smg-language-limit-n-regexp' is one of the OPTION-VALUEs.
;; An OPTION-VALUE of nil denotes the fallback element.  MODELINE-STRING is
;; also displayed in the mode line next to \"Smg\"."
;;   :group 'smg
;;   :type '(repeat (group :value (java-mode "")
;;                         (function :tag "Major mode")
;;                         (string :tag "Mode line string")
;;                         (repeat :tag "SMG language option" :inline t
;;                                 (choice (const :tag "Default" nil)
;;                                         string)))))

;;;===========================================================================
;;;  Hide/Unhide, Indent/Tabs
;;;===========================================================================

(defcustom smg-action-visibility 3
  "Visibility of actions when command `smg-hide-actions' is used.
If nil, the actions with their surrounding braces are hidden.  If a
number, do not hide the braces, only hide the contents if its length is
greater than this number."
  :group 'smg
  :type '(choice (const :tag "Completely hidden" nil)
                 (integer :tag "Hidden if longer than" :value 3)))

(defcustom smg-indent-comment 'tab
  "Non-nil, if the indentation should touch lines in block comments.
If nil, no continuation line of a block comment is changed.  If t, they
are changed according to `c-indentation-line'.  When not nil and not t,
they are only changed by \\[smg-indent-command]."
  :group 'smg
  :type '(radio (const :tag "No" nil)
                (const :tag "Always" t)
                (sexp :tag "With TAB" :format "%t" :value tab)))

(defcustom smg-tab-offset-alist
  '((smg-mode nil 4 nil)
    (java-mode "smg" 4 nil))
  "Alist to determine whether to use SMG's convention for TABs.
Each element looks like \(MAJOR-MODE REGEXP TAB-WIDTH INDENT-TABS-MODE).
The first element whose MAJOR-MODE is nil or equal to `major-mode' and
whose REGEXP is nil or matches variable `buffer-file-name' is used to
set `tab-width' and `indent-tabs-mode'.  This is useful to support both
SMG's and Java's indentation styles.  Used by `smg-set-tabs'."
  :group 'smg
  :type '(repeat (group :value (smg-mode nil 8 nil)
                        (choice (const :tag "All" nil)
                                (function :tag "Major mode"))
                        (choice (const :tag "All" nil) regexp)
                        (integer :tag "Tab width")
                        (boolean :tag "Indent-tabs-mode"))))

(defcustom smg-indent-style "java"
  "If non-nil, cc-mode indentation style used for `smg-mode'.
See `c-set-style' and for details, where the most interesting part in
`c-style-alist' is the value of `c-basic-offset'."
  :group 'smg
  :type '(choice (const nil) regexp))

(defcustom smg-indent-item-regexp
  "[]});|]" ; & is local SMG extension (SGML's and-connector)
  "Regexp matching lines which should be indented by one TAB less.
See `smg-indent-line' and command \\[smg-indent-command]."
  :group 'smg
  :type 'regexp)

;; (defcustom smg-indent-at-bol-alist
;;   '((java-mode . "\\(package\\|import\\)\\>")
;;     (c++-mode . "#\\(assert\\|cpu\\|define\\|endif\\|el\\(if\\|se\\)\\|i\\(dent\\|f\\(def\\|ndef\\)?\\|mport\\|nclude\\(_next\\)?\\)\\|line\\|machine\\|pragma\\|system\\|un\\(assert\\|def\\)\\|warning\\)\\>"))
;;   "Alist of regexps matching lines are indented at column 0.
;; Each element in this list looks like (MODE . REGEXP) where MODE is a
;; function and REGEXP is a regular expression.

;; If `smg-language' equals to a MODE, the line starting at the first
;; non-whitespace is matched by the corresponding REGEXP, and the line is
;; part of a header action, indent the line at column 0 instead according
;; to the normal rules of `smg-indent-line'."
;;   :group 'smg
;;   :type '(repeat (cons (function :tag "Major mode") regexp)))

;; ;; adopt indentation to cc-engine
;; (defvar smg-disabling-cc-syntactic-symbols
;;   '(statement-block-intro
;;     defun-block-intro topmost-intro statement-case-intro member-init-intro
;;     arglist-intro brace-list-intro knr-argdecl-intro inher-intro
;;     objc-method-intro
;;     block-close defun-close class-close brace-list-close arglist-close
;;     inline-close extern-lang-close namespace-close))


;;;===========================================================================
;;;  Options: customization
;;;===========================================================================

(defcustom smg-options-use-submenus t
  "Non-nil, if the major mode menu should include option submenus.
If nil, the menu just includes a command to insert options.  Otherwise,
it includes four submenus to insert file/grammar/rule/subrule options."
  :group 'smg
  :type 'boolean)

;; (defcustom smg-tool-version 20701
;;   "The version number of the Smg tool.
;; The value is an integer of the form XYYZZ which stands for vX.YY.ZZ.
;; This variable is used to warn about non-supported options and to supply
;; version correct option values when using \\[smg-insert-option].

;; Don't use a number smaller than 20600 since the stored history of
;; Smg's options starts with v2.06.00, see `smg-options-alists'.  You
;; can make this variable buffer-local."
;;   :group 'smg
;;   :type 'integer)

(defcustom smg-options-auto-colon t
  "Non-nil, if `:' is inserted with a rule or subrule options section.
A `:' is only inserted if this value is non-nil, if a rule or subrule
option is inserted with \\[smg-insert-option], if there was no rule or
subrule options section before, and if a `:' is not already present
after the section, ignoring whitespace, comments and the init action."
  :group 'smg
  :type 'boolean)

(defcustom smg-options-style nil
  "List of symbols which determine the style of option values.
If a style symbol is present, the corresponding option value is put into
quotes, i.e., represented as a string, otherwise it is represented as an
identifier.

The only style symbol used in the default value of `smg-options-alist'
is `language-as-string'.  See also `smg-read-value'."
  :group 'smg
  :type '(repeat (symbol :tag "Style symbol")))

(defcustom smg-options-push-mark t
  "Non-nil, if inserting an option should set & push mark.
If nil, never set mark when inserting an option with command
\\[smg-insert-option].  If t, always set mark via `push-mark'.  If a
number, only set mark if point was outside the options area before and
the number of lines between point and the insert position is greater
than this value.  Otherwise, only set mark if point was outside the
options area before."
  :group 'smg
  :type '(radio (const :tag "No" nil)
                (const :tag "Always" t)
                (integer :tag "Lines between" :value 10)
                (sexp :tag "If outside options" :format "%t" :value outside)))

(defcustom smg-options-assign-string " = "
  "String containing `=' to use between option name and value.
This string is only used if the option to insert did not exist before
or if there was no `=' after it.  In other words, the spacing around an
existing `=' won't be changed when changing an option value."
  :group 'smg
  :type 'string)


;;;===========================================================================
;;;  Options: definitions
;;;===========================================================================

;; (defvar smg-options-headings '("file" "grammar" "rule" "subrule")
;;   "Headings for the four different option kinds.
;; The standard value is (\"file\" \"grammar\" \"rule\" \"subrule\").  See
;; `smg-options-alists'")

;; (defvar smg-options-alists
;;   '(;; file options ----------------------------------------------------------
;;     (("language" smg-language-option-extra
;;       (20600 smg-read-value
;;              "Generated language: " language-as-string
;;              (("Java") ("Cpp") ("HTML") ("Diagnostic")))
;;       (20700 smg-read-value
;;              "Generated language: " language-as-string
;;              (("Java") ("Cpp") ("HTML") ("Diagnostic") ("Sather"))))
;;      ("mangleLiteralPrefix" nil
;;       (20600 smg-read-value
;;              "Prefix for literals (default LITERAL_): " t))
;;      ("namespace" smg-c++-mode-extra
;;       (20700 smg-read-value
;;              "Wrap generated C++ code in namespace: " t))
;;      ("namespaceStd" smg-c++-mode-extra
;;       (20701 smg-read-value
;;              "Replace SMG_USE_NAMESPACE(std) by: " t))
;;      ("namespaceSmg" smg-c++-mode-extra
;;       (20701 smg-read-value
;;              "Replace SMG_USE_NAMESPACE(smg) by: " t))
;;      ("genHashLines" smg-c++-mode-extra
;;       (20701 smg-read-boolean
;;              "Include #line in generated C++ code? "))
;;      )
;;     ;; grammar options --------------------------------------------------------
;;     (("k" nil
;;       (20600 smg-read-value
;;              "Lookahead depth: "))
;;      ("importVocab" nil
;;       (20600 smg-read-value
;;              "Import vocabulary: "))
;;      ("exportVocab" nil
;;       (20600 smg-read-value
;;              "Export vocabulary: "))
;;      ("testLiterals" nil                ; lexer only
;;       (20600 smg-read-boolean
;;              "Test each token against literals table? "))
;;      ("defaultErrorHandler" nil         ; not for lexer
;;       (20600 smg-read-boolean
;;              "Generate default exception handler for each rule? "))
;;      ("codeGenMakeSwitchThreshold" nil
;;       (20600 smg-read-value
;;              "Min number of alternatives for 'switch': "))
;;      ("codeGenBitsetTestThreshold" nil
;;       (20600 smg-read-value
;;              "Min size of lookahead set for bitset test: "))
;;      ("analyzerDebug" nil
;;       (20600 smg-read-boolean
;;              "Display debugging info during grammar analysis? "))
;;      ("codeGenDebug" nil
;;       (20600 smg-read-boolean
;;              "Display debugging info during code generation? "))
;;      ("buildAST" nil                    ; not for lexer
;;       (20600 smg-read-boolean
;;              "Use automatic AST construction/transformation? "))
;;      ("ASTLabelType" nil                ; not for lexer
;;       (20600 smg-read-value
;;              "Class of user-defined AST node: " t))
;;      ("charVocabulary" nil              ; lexer only
;;       (20600 nil
;;              "Insert character vocabulary"))
;;      ("interactive" nil
;;       (20600 smg-read-boolean
;;              "Generate interactive lexer/parser? "))
;;      ("caseSensitive" nil               ; lexer only
;;       (20600 smg-read-boolean
;;              "Case significant when matching characters? "))
;;      ("caseSensitiveLiterals" nil       ; lexer only
;;       (20600 smg-read-boolean
;;              "Case significant when testing literals table? "))
;;      ("classHeaderSuffix" nil
;;       (20600 nil
;;              "Additional string for grammar class definition"))
;;      ("filter" nil                      ; lexer only
;;       (20600 smg-read-boolean
;;              "Skip rule (the name, true or false): "
;;              smg-grammar-tokens))
;;      ("namespace" smg-c++-mode-extra
;;       (20700 smg-read-value
;;              "Wrap generated C++ code for grammar in namespace: " t))
;;      ("namespaceStd" smg-c++-mode-extra
;;       (20701 smg-read-value
;;              "Replace SMG_USE_NAMESPACE(std) by: " t))
;;      ("namespaceSmg" smg-c++-mode-extra
;;       (20701 smg-read-value
;;              "Replace SMG_USE_NAMESPACE(smg) by: " t))
;;      ("genHashLines" smg-c++-mode-extra
;;       (20701 smg-read-boolean
;;              "Include #line in generated C++ code? "))
;; ;;;     ("autoTokenDef" nil             ; parser only
;; ;;;      (80000 smg-read-boolean                ; default: true
;; ;;;          "Automatically define referenced token? "))
;; ;;;     ("keywordsMeltTo" nil           ; parser only
;; ;;;      (80000 smg-read-value
;; ;;;          "Change non-matching keywords to token type: "))
;;      )
;;     ;; rule options ----------------------------------------------------------
;;     (("testLiterals" nil                ; lexer only
;;       (20600 smg-read-boolean
;;              "Test this token against literals table? "))
;;      ("defaultErrorHandler" nil         ; not for lexer
;;       (20600 smg-read-boolean
;;              "Generate default exception handler for this rule? "))
;;      ("ignore" nil                      ; lexer only
;;       (20600 smg-read-value
;;              "In this rule, ignore tokens of type: " nil
;;              smg-grammar-tokens))
;;      ("paraphrase" nil                  ; lexer only
;;       (20600 smg-read-value
;;              "In messages, replace name of this token by: " t))
;;      )
;;     ;; subrule options -------------------------------------------------------
;;     (("warnWhenFollowAmbig" nil
;;       (20600 smg-read-boolean
;;              "Display warnings for ambiguities with FOLLOW? "))
;;      ("generateAmbigWarnings" nil
;;       (20600 smg-read-boolean
;;              "Display warnings for ambiguities? "))
;;      ("greedy" nil
;;       (20700 smg-read-boolean
;;              "Make this optional/loop subrule greedy? "))
;;      ))
;;   "Definitions for Smg's options of all four different kinds.

;; The value looks like \(FILE GRAMMAR RULE SUBRULE) where each FILE,
;; GRAMMAR, RULE, and SUBRULE is a list of option definitions of the
;; corresponding kind, i.e., looks like \(OPTION-DEF...).

;; Each OPTION-DEF looks like \(OPTION-NAME EXTRA-FN VALUE-SPEC...) which
;; defines a file/grammar/rule/subrule option with name OPTION-NAME.  The
;; OPTION-NAMEs are used for the creation of the \"Insert XXX Option\"
;; submenus, see `smg-options-use-submenus', and to allow to insert the
;; option name with completion when using \\[smg-insert-option].

;; If EXTRA-FN is a function, it is called at different phases of the
;; insertion with arguments \(PHASE OPTION-NAME).  PHASE can have the
;; values `before-input' or `after-insertion', additional phases might be
;; defined in future versions of this mode.  The phase `before-input'
;; occurs before the user is asked to insert a value.  The phase
;; `after-insertion' occurs after the option value has been inserted.
;; EXTRA-FN might be called with additional arguments in future versions of
;; this mode.

;; Each specification VALUE-SPEC looks like \(VERSION READ-FN ARG...).  The
;; last VALUE-SPEC in an OPTION-DEF whose VERSION is smaller or equal to
;; `smg-tool-version' specifies how the user is asked for the value of
;; the option.

;; If READ-FN is nil, the only ARG is a string which is printed at the echo
;; area to guide the user what to insert at point.  Otherwise, READ-FN is
;; called with arguments \(INIT-VALUE ARG...) to get the new value of the
;; option.  INIT-VALUE is the old value of the option or nil.

;; The standard value contains the following functions as READ-FN:
;; `smg-read-value' with ARGs = \(PROMPT AS-STRING TABLE) which reads a
;; general value, or `smg-read-boolean' with ARGs = \(PROMPT TABLE) which
;; reads a boolean value or a member of TABLE.  PROMPT is the prompt when
;; asking for a new value.  If non-nil, TABLE is a table for completion or
;; a function evaluating to such a table.  The return value is quoted if
;; AS-STRING is non-nil and is either t or a symbol which is a member of
;; `smg-options-style'.")


;;;===========================================================================
;;;  Run tool, create Makefile dependencies
;;;===========================================================================

;; (defcustom smg-tool-command "java smg.Tool"
;;   "Command used in \\[smg-run-tool] to run the Smg tool.
;; This variable should include all options passed to Smg except the
;; option \"-glib\" which is automatically suggested if necessary."
;;   :group 'smg
;;   :type 'string)

;; (defcustom smg-ask-about-save t
;;   "If not nil, \\[smg-run-tool] asks which buffers to save.
;; Otherwise, it saves all modified buffers before running without asking."
;;   :group 'smg
;;   :type 'boolean)

;; (defcustom smg-makefile-specification
;;   '("\n" ("GENS" "GENS%d" " \\\n\t") "$(SMG)")
;;   "Variable to specify the appearance of the generated makefile rules.
;; This variable influences the output of \\[smg-show-makefile-rules].
;; It looks like \(RULE-SEP GEN-VAR-SPEC COMMAND).

;; RULE-SEP is the string to separate different makefile rules.  COMMAND is
;; a string with the command which runs the Smg tool, it should include
;; all options except the option \"-glib\" which is automatically added
;; if necessary.

;; If GEN-VAR-SPEC is nil, each target directly consists of a list of
;; files.  If GEN-VAR-SPEC looks like \(GEN-VAR GEN-VAR-FORMAT GEN-SEP), a
;; Makefile variable is created for each rule target.

;; Then, GEN-VAR is a string with the name of the variable which contains
;; the file names of all makefile rules.  GEN-VAR-FORMAT is a format string
;; producing the variable of each target with substitution COUNT/%d where
;; COUNT starts with 1.  GEN-SEP is used to separate long variable values."
;;   :group 'smg
;;   :type '(list (string :tag "Rule separator")
;;                (choice
;;                 (const :tag "Direct targets" nil)
;;                 (list :tag "Variables for targets"
;;                       (string :tag "Variable for all targets")
;;                       (string :tag "Format for each target variable")
;;                       (string :tag "Variable separator")))
;;                (string :tag "SMG command")))

;; (defvar smg-file-formats-alist
;;   '((java-mode ("%sTokenTypes.java") ("%s.java"))
;;     (c++-mode ("%sTokenTypes.hpp") ("%s.cpp" "%s.hpp")))
;;   "Language dependent formats which specify generated files.
;; Each element in this list looks looks like
;;   \(MAJOR-MODE (VOCAB-FILE-FORMAT...) (CLASS-FILE-FORMAT...)).

;; The element whose MAJOR-MODE is equal to `smg-language' is used to
;; specify the generated files which are language dependent.  See variable
;; `smg-special-file-formats' for language independent files.

;; VOCAB-FILE-FORMAT is a format string, it specifies with substitution
;; VOCAB/%s the generated file for each export vocabulary VOCAB.
;; CLASS-FILE-FORMAT is a format string, it specifies with substitution
;; CLASS/%s the generated file for each grammar class CLASS.")

;; (defvar smg-special-file-formats '("%sTokenTypes.txt" "expanded%s.g")
;;   "Language independent formats which specify generated files.
;; The value looks like \(VOCAB-FILE-FORMAT EXPANDED-GRAMMAR-FORMAT).

;; VOCAB-FILE-FORMAT is a format string, it specifies with substitution
;; VOCAB/%s the generated or input file for each export or import
;; vocabulary VOCAB, respectively.  EXPANDED-GRAMMAR-FORMAT is a format
;; string, it specifies with substitution GRAMMAR/%s the constructed
;; grammar file if the file GRAMMAR.g contains a grammar class which
;; extends a class other than \"Lexer\", \"Parser\" or \"TreeParser\".

;; See variable `smg-file-formats-alist' for language dependent
;; formats.")

;; (defvar smg-unknown-file-formats '("?%s?.g" "?%s?")
;;   "Formats which specify the names of unknown files.
;; The value looks like \(SUPER-GRAMMAR-FILE-FORMAT SUPER-EVOCAB-FORMAT).

;; SUPER-GRAMMAR-FORMAT is a format string, it specifies with substitution
;; SUPER/%s the name of a grammar file for Smg's option \"-glib\" if no
;; grammar file in the current directory defines the class SUPER or if it
;; is defined more than once.  SUPER-EVOCAB-FORMAT is a format string, it
;; specifies with substitution SUPER/%s the name for the export vocabulary
;; of above mentioned class SUPER.")

;; (defvar smg-help-unknown-file-text
;;   "## The following rules contain filenames of the form
;; ##  \"?SUPERCLASS?.g\" (and \"?SUPERCLASS?TokenTypes.txt\")
;; ## where SUPERCLASS is not found to be defined in any grammar file of
;; ## the current directory or is defined more than once.  Please replace
;; ## these filenames by the grammar files (and their exportVocab).\n\n"
;;   "String indicating the existence of unknown files in the Makefile.
;; See \\[smg-show-makefile-rules] and `smg-unknown-file-formats'.")

;; (defvar smg-help-rules-intro
;;   "The following Makefile rules define the dependencies for all (non-
;; expanded) grammars in directory \"%s\".\n
;; They are stored in the kill-ring, i.e., you can insert them with C-y
;; into your Makefile.  You can also invoke M-x smg-show-makefile-rules
;; from within a Makefile to insert them directly.\n\n\n"
;;   "Introduction to use with \\[smg-show-makefile-rules].
;; It is a format string and used with substitution DIRECTORY/%s where
;; DIRECTORY is the name of the current directory.")


;;;===========================================================================
;;;  Menu
;;;===========================================================================

(defcustom smg-imenu-name "Tokens"
  "Non-nil, if a \"Index\" menu should be added to the menubar.
If it is a string, it is used instead \"Index\".  Requires package
imenu."
  :group 'smg
  :type '(choice (const :tag "No menu" nil)
                 (const :tag "Index menu" t)
                 (string :tag "Other menu name")))

(defvar smg-mode-map
  (let ((map (make-sparse-keymap)))
    (define-key map "\t" 'smg-indent-command)
    (define-key map "\e\C-a" (lambda () (interactive) (smg-next-rule 1 t)))
    (define-key map "\e\C-e" (lambda () (interactive) (smg-next-rule -2 t)))
    (define-key map "\C-c\C-a" 'smg-beginning-of-body)
    (define-key map "\C-c\C-e" 'smg-end-of-body)
    (define-key map "\C-c\C-f" 'c-forward-into-nomenclature)
    (define-key map "\C-c\C-b" 'c-backward-into-nomenclature)
    (define-key map "\C-c\C-c" 'comment-region)
    (define-key map "\C-c\C-v" 'smg-hide-actions)
    (define-key map "\C-c\C-r" 'smg-run-tool)
    (define-key map "\C-c\C-o" 'smg-insert-option)
    ;; I'm too lazy to define my own:
    (define-key map "\ea" 'c-beginning-of-statement)
    (define-key map "\ee" 'c-end-of-statement)
    ;; electric keys:
    (define-key map ":" 'smg-electric-character)
    (define-key map ";" 'smg-electric-character)
    (define-key map "|" 'smg-electric-character)
    (define-key map "&" 'smg-electric-character)
    (define-key map "(" 'smg-electric-character)
    (define-key map ")" 'smg-electric-character)
    (define-key map "{" 'smg-electric-character)
    (define-key map "}" 'smg-electric-character)
    (define-key map "\M-." 'smg-go-to-def)
    (define-key map "\M-," 'smg-go-back)
    map)
  "Keymap used in `smg-mode' buffers.")

(easy-menu-define smg-mode-menu smg-mode-map
  "Major mode menu."
  `("Smg"
    ,@(if smg-options-use-submenus
          `(("Insert File Option"
             :filter ,(lambda (x) (smg-options-menu-filter 1 x)))
            ("Insert Grammar Option"
             :filter ,(lambda (x) (smg-options-menu-filter 2 x)))
            ("Insert Rule Option"
             :filter ,(lambda (x) (smg-options-menu-filter 3 x)))
            ("Insert Subrule Option"
             :filter ,(lambda (x) (smg-options-menu-filter 4 x)))
            "---")
        '(["Insert Option" smg-insert-option
           :active (not buffer-read-only)]))
    ("Forward/Backward"
     ["Backward Rule" smg-beginning-of-rule t]
     ["Forward Rule" smg-end-of-rule t]
     ["Start of Rule Body" smg-beginning-of-body
      :active (smg-inside-rule-p)]
     ["End of Rule Body" smg-end-of-body
      :active (smg-inside-rule-p)]
     "---"
     ["Backward Statement" c-beginning-of-statement t]
     ["Forward Statement" c-end-of-statement t]
     ["Backward Into Nomencl." c-backward-into-nomenclature t]
     ["Forward Into Nomencl." c-forward-into-nomenclature t])
    ["Indent Region" indent-region
     :active (and (not buffer-read-only) (c-region-is-active-p))]
    ["Comment Out Region" comment-region
     :active (and (not buffer-read-only) (c-region-is-active-p))]
    ["Uncomment Region"
     (comment-region (region-beginning) (region-end) '(4))
     :active (and (not buffer-read-only) (c-region-is-active-p))]
    "---"
    ["Hide Actions (incl. Args)" smg-hide-actions t]
    ["Hide Actions (excl. Args)" (smg-hide-actions 2) t]
    ["Unhide All Actions" (smg-hide-actions 0) t]
    "---"
    ;;["Run Tool on Grammar" smg-run-tool t]
    ["Show Makefile Rules" smg-show-makefile-rules t]
    ;;"---"
    ;;["Customize Smg" (customize-group 'smg) t]
    ))


;;;===========================================================================
;;;  font-lock
;;;===========================================================================

(defcustom smg-font-lock-maximum-decoration 'inherit
  "The maximum decoration level for fontifying actions.
Value `none' means, do not fontify actions, just normal grammar code
according to `smg-font-lock-additional-keywords'.  Value `inherit'
means, use value of `font-lock-maximum-decoration'.  Any other value is
interpreted as in `font-lock-maximum-decoration' with no level-0
fontification, see `smg-font-lock-keywords-alist'.

While calculating the decoration level for actions, `major-mode' is
bound to `smg-language'.  For example, with value
  \((java-mode \. 2) (c++-mode \. 0))
Java actions are fontified with level 2 and C++ actions are not
fontified at all."
  :group 'smg
  :type '(choice (const :tag "None" none)
                 (const :tag "Inherit" inherit)
                 (const :tag "Default" nil)
                 (const :tag "Maximum" t)
                 (integer :tag "Level" 1)
                 (repeat :menu-tag "Mode specific" :tag "Mode specific"
                         :value ((t . t))
                         (cons :tag "Instance"
                               (radio :tag "Mode"
                                      (const :tag "All" t)
                                      (symbol :tag "Name"))
                               (radio :tag "Decoration"
                                      (const :tag "Default" nil)
                                      (const :tag "Maximum" t)
                                      (integer :tag "Level" 1))))))

(defconst smg-no-action-keywords nil
  ;; Using nil directly won't work (would use highest level, see
  ;; `font-lock-choose-keywords'), but a non-symbol, i.e., (list), at `car'
  ;; would break Emacs-21.0:
  "Empty font-lock keywords for actions.
Do not change the value of this constant.")

(defvar smg-font-lock-keywords-alist
  '((java-mode
     smg-no-action-keywords
     ;;java-font-lock-keywords-1 java-font-lock-keywords-2
     ;;java-font-lock-keywords-3
     )
    (c++-mode
     smg-no-action-keywords
     ;;c++-font-lock-keywords-1 c++-font-lock-keywords-2
     ;;c++-font-lock-keywords-3
     ))
  "List of font-lock keywords for actions in the grammar.
Each element in this list looks like
  \(MAJOR-MODE KEYWORD...)

If `smg-language' is equal to MAJOR-MODE, the KEYWORDs are the
font-lock keywords according to `font-lock-defaults' used for the code
in the grammar's actions and semantic predicates, see
`smg-font-lock-maximum-decoration'.")

(require 'rx)
(eval-when-compile
 (require 'rx)
 (make-variable-buffer-local 'rx-constituents)
 (defmacro defre (name re &optional str)
   `(eval-when-compile
      (push (cons ',name  (rx ,re)) rx-constituents)
      (defconst ,(intern (concat "smg--" (symbol-name name) "-re"))
        (rx ,re)))))
(put 'defre 'lisp-indent-function 0)

(defre ident
  (group (: (* ?\#) (or alpha ?\$ ?\- ?\_) (* (or alnum (syntax symbol)))))
  "Regex matching identifiers")

(defre terminal-node-type
  (group (| "symbol" "integer" "real" "character" "charstring")))

(defre func-name
  (group (* (not (syntax whitespace)))))

(defre term-conv-fn?
  (group (? (: (group ":") (* space) func-name))))

(defre pound-string
  (group (: "#" (* (| (not (any ?\#)) "##")) "#")))

(defre filter?
  (? (: (* space )
        (group "::")
        (* space)
        ident)))

(defre rule-start
  (: bol ident (* space) (group (? "-") "->")))

(defvar smg-font-lock-additional-keywords
  `((,(rx (: (group "grammar") (+ space) (regexp "'.*'") (* space) ";"))
     (1 font-lock-function-name-face nil t))
    (,(rx (: "#{" (* space) (group "option") (+ space) ident (+ space) (group (+ (not (syntax whitespace)))) (* space) "}"))
     (1 font-lock-function-name-face nil t)
     (3 font-lock-constant-face nil t))
    (,(rx (: "#{" (* space) (group (| "option" (: (| "lexer" "parser") "::" (| "header" "members"))))))
     (1 font-lock-function-name-face nil t))
    (,(rx rule-start)
     (1 font-lock-function-name-face nil t)
     (2 font-lock-keyword-face nil t))
    (,(rx (: bol (group "terminal") (+ space) ident (* space) (group "::") (* space) terminal-node-type (* space) (group "-->") (* space) ident (* space) term-conv-fn? (* space) term-conv-fn?))
     (1 font-lock-function-name-face nil t)
     (3 font-lock-keyword-face nil t)
     (4 font-lock-type-face nil t)
     (5 font-lock-keyword-face nil t)
     (8 font-lock-keyword-face nil t)
     (9 font-lock-string-face nil t)
     (11 font-lock-keyword-face nil t)
     (12 font-lock-string-face nil t))
    (,(rx (: bol (group "special") (+ space) ident (* space) (group "::") (* space) ident))
     (1 font-lock-function-name-face nil t)
     (3 font-lock-keyword-face nil t)
     (4 font-lock-type-face nil t))
    (,(rx (: bol (group "lexeme") (* space) (regexp "'.*'") (* space) (group "::") (* space) ident))
     (1 font-lock-function-name-face nil t)
     (2 font-lock-keyword-face nil t))
    (,(rx (: bol (group "regexp") (+ space) ident (* space) (group "::") (* space) pound-string filter?))
     (1 font-lock-function-name-face nil t)
     (3 font-lock-keyword-face nil t)
     (6 font-lock-keyword-face nil t))
    (,(rx (: "[" (* space) ident (* space) "]"))
     (0 font-lock-comment-face))
    (,(rx (: "{" (* space) (group "prec") (* space) "}"))
     (1 font-lock-constant-face))
    (,(rx (: "{" (* space) (group "identity") (+ space) ident (* space) "}"))
     (1 font-lock-constant-face))
    (,(rx (:"!" (| ?\: ?\() (* (not (any ?\!))) "!"))
     (0 font-lock-constant-face))
    (,(rx (| "!a" "!b" "!c" "!e" "!f" "!i" "!l" "!m" "!n" "!nnl" "!npp" "!s" "!u"))
     (0 font-lock-comment-face))
    (,(rx ident)
     (0 font-lock-variable-name-face))
    (,(rx (| "|" ";" "*" "+" "*?" "+?" "**" "++" "^"))
     (0 font-lock-keyword-face))
    (,(rx (| "#(" ")" ")=>" "#{" "{" "}" "}?=>" "}?"))
     (0 font-lock-builtin-face)))
  "Font-lock keywords for SMG's normal grammar code.
See `smg-font-lock-keywords-alist' for the keywords of actions.")

(defun smg--syntax-propertize (start end)
  (goto-char start)
  (funcall
   (syntax-propertize-rules
    ((rx (: bol (group "regexp") (+ space) ident (* space) (group "::") (* space) pound-string filter?))
     (4 "\"")))
   start end))

(defvar smg-font-lock-defaults
  '(smg-font-lock-keywords)
  "Font-lock defaults used for SMG syntax highlighting.
The SYNTAX-ALIST element is also used to initialize
`smg-action-syntax-table'.")

;;;===========================================================================
;;;  Internal variables
;;;===========================================================================

(defvar smg-mode-hook nil
  "Hook called by `smg-mode'.")

(defvar smg-mode-syntax-table
  (let ((st (make-syntax-table)))
    (modify-syntax-entry ?\> "." st)
    (modify-syntax-entry ?\n "-" st)
    (modify-syntax-entry ?\% "\"%" st)
    (modify-syntax-entry ?\{ "(}" st)
    (modify-syntax-entry ?\} "){" st)
    (modify-syntax-entry ?\. "_" st)
    (modify-syntax-entry ?\- "_" st)
    (modify-syntax-entry ?\_ "_" st)
    (modify-syntax-entry ?\? "_" st)
    (modify-syntax-entry ?\+ "_" st)
    (modify-syntax-entry ?\$ "_" st)
    (modify-syntax-entry ?\( "()" st)
    (modify-syntax-entry ?\) ")(" st)
    (modify-syntax-entry ?\' "\"'" st)
    (modify-syntax-entry ?\/ "_ 14" st)
    (modify-syntax-entry ?\* "_ 23" st)
    st)
  "Syntax table used in `smg-mode' buffers.")

;; ;; used for "in Java/C++ code" = syntactic-depth>0
;; (defvar smg-action-syntax-table
;;   (let ((st (copy-syntax-table smg-mode-syntax-table))
;;         (slist (nth 3 smg-font-lock-defaults)))
;;     (while slist
;;       (modify-syntax-entry (caar slist) (cdar slist) st)
;;       (setq slist (cdr slist)))
;;     st)
;;   "Syntax table used for SMG action parsing.
;; Initialized by `smg-mode-syntax-table', changed by SYNTAX-ALIST in
;; `smg-font-lock-defaults'.  This table should be selected if you use
;; `buffer-syntactic-context' and `buffer-syntactic-context-depth' in order
;; not to confuse their context_cache.")

(defvar smg-mode-abbrev-table nil
  "Abbreviation table used in `smg-mode' buffers.")
(define-abbrev-table 'smg-mode-abbrev-table ())


;;;;##########################################################################
;;;;  The Code
;;;;##########################################################################

;;;===========================================================================
;;;  Context cache
;;;===========================================================================

(defun smg-syntactic-context (&optional ppss)
  "Return some syntactic context information.
Return `string' if point is within a string, `block-comment' or
`comment' is point is within a comment or the depth within all
parenthesis-syntax delimiters at point otherwise.
WARNING: this may alter `match-data'."
  (unless ppss
    (setq ppss (syntax-ppss)))
  (cond ((nth 3 ppss) :string)
        ((nth 4 ppss) :comment)
        (t (car ppss))))

;;;===========================================================================
;;;  Miscellaneous functions
;;;===========================================================================

;; (defun smg-upcase-p (char)
;;   "Non-nil, if CHAR is an uppercase character (if CHAR was a char)."
;;   ;; in XEmacs, upcase only works for ASCII
;;   (or (and (<= ?A char) (<= char ?Z))
;;       (and (<= ?\300 char) (<= char ?\337)))) ; ?\327 is no letter

(defun smg-re-search-forward (regexp bound)
  "Search forward from point for regular expression REGEXP.
Set point to the end of the occurrence found, and return point.  Return
nil if no occurrence was found.  Do not search within comments, strings
and actions/semantic predicates.  BOUND bounds the search; it is a
buffer position.  See also the functions `match-beginning', `match-end'
and `replace-match'."
  ;; WARNING: Should only be used with `smg-action-syntax-table'!
  (let ((continue t))
    (while (and (re-search-forward regexp bound 'limit)
                (save-match-data
                  (if (eq (smg-syntactic-context) 0)
                      (setq continue nil)
                    t))))
    (if continue nil (point))))

(defun smg-search-forward (string)
  "Search forward from point for STRING.
Set point to the end of the occurrence found, and return point.  Return
nil if no occurrence was found.  Do not search within comments, strings
and actions/semantic predicates."
  ;; WARNING: Should only be used with `smg-action-syntax-table'!
  (let ((continue t))
    (while (and (search-forward string nil 'limit)
                (if (eq (smg-syntactic-context) 0) (setq continue nil) t)))
    (if continue nil (point))))

(defun smg-search-backward (string)
  "Search backward from point for STRING.
Set point to the beginning of the occurrence found, and return point.
Return nil if no occurrence was found.  Do not search within comments,
strings and actions/semantic predicates."
  (let ((continue t))
    (while (and (search-backward string nil 'limit)
                (if (eq (smg-syntactic-context) 0) (setq continue nil) t)))
    (if continue nil (point))))

(defsubst smg-skip-sexps (count)
  "Skip the next COUNT balanced expressions and the comments after it.
Return position before the comments after the last expression."
  (goto-char (or (ignore-errors (scan-sexps (point) count)) (point-max)))
  (prog1 (point)
    (smg-c-forward-sws)))


;;;===========================================================================
;;;  font-lock
;;;===========================================================================

(defun smg-font-lock-keywords ()
  "Return font-lock keywords for current buffer.
See `smg-font-lock-additional-keywords', `smg-language' and
`smg-font-lock-maximum-decoration'."
  smg-font-lock-additional-keywords
  ;; (if (eq smg-font-lock-maximum-decoration 'none)
  ;;     smg-font-lock-additional-keywords
  ;;   (append smg-font-lock-additional-keywords
  ;;           (eval (let ((major-mode smg-language)) ; dynamic
  ;;                    (font-lock-choose-keywords
  ;;                     (cdr (assq smg-language
  ;;                                smg-font-lock-keywords-alist))
  ;;                     (if (eq smg-font-lock-maximum-decoration 'inherit)
  ;;                         font-lock-maximum-decoration
  ;;                       smg-font-lock-maximum-decoration))))))
  )


;;;===========================================================================
;;;  imenu support
;;;===========================================================================

(defun smg-grammar-tokens ()
  "Return alist for tokens defined in current buffer."
  (smg-imenu-create-index-function t))

(defun smg-imenu-create-index-function (&optional tokenrefs-only)
  "Return imenu index-alist for SMG grammar files.
IF TOKENREFS-ONLY is non-nil, just return alist with tokenref names."
  (let ((items (smg--parse-current-buffer)))
    (cond
      (tokenrefs-only
       (mapcar #'car items))
      ((not imenu-use-markers)
       (mapcar (lambda (x)
                 (cons (car x) (marker-position (cdr x))))
               items))
      (t items))))


;;;===========================================================================
;;;  Parse grammar files (internal functions)
;;;===========================================================================

(defun smg-skip-exception-part (skip-comment)
  "Skip exception part of current rule, i.e., everything after `;'.
This also includes the options and tokens part of a grammar class
header.  If SKIP-COMMENT is non-nil, also skip the comment after that
part."
  (let ((pos (point))
        (class nil))
    (smg-c-forward-sws)))

(defun smg-skip-file-prelude (skip-comment)
  "Skip the file prelude: the header and file options.
If SKIP-COMMENT is non-nil, also skip the comment after that part.
Return the start position of the file prelude.

Hack: if SKIP-COMMENT is `header-only' only skip header and return
position before the comment after the header."
  (let* ((pos (point))
         (pos0 pos))
    (smg-c-forward-sws)
    (if skip-comment (setq pos0 (point)))
    (while (looking-at "header\\>[ \t]*\\(\"\\)?")
      (setq pos (smg-skip-sexps (if (match-beginning 1) 3 2))))
    (if (eq skip-comment 'header-only)  ; a hack...
        pos
      (when (looking-at "options\\>")
        (setq pos (smg-skip-sexps 2)))
      (or skip-comment (goto-char pos))
      pos0)))

(defun smg-next-rule (arg skip-comment)
  "Move forward to next end of rule.  Do it ARG many times.
A grammar class header and the file prelude are also considered as a
rule.  Negative argument ARG means move back to ARGth preceding end of
rule.  The behavior is not defined when ARG is zero.  If SKIP-COMMENT
is non-nil, move to beginning of the rule."
  ;; WARNING: Should only be used with `smg-action-syntax-table'!
  ;; PRE: ARG<>0
  (let ((pos (point))
        (beg (point)))
    ;; first look whether point is in exception part
    (if (smg-search-backward ";")
        (progn
          (setq beg (point))
          (forward-char)
          ;;(smg-skip-exception-part skip-comment)
          )
      ;;(smg-skip-file-prelude skip-comment)
        )
    (if (< arg 0)
        (unless (and (< (point) pos) (zerop (incf arg)))
          ;; if we have moved backward, we already moved one defun backward
          (goto-char beg)               ; rewind (to ";" / point)
          (while (and arg (<= (incf arg) 0))
            (if (smg-search-backward ";")
                (setq beg (point))
              (when (>= arg -1)
                ;; try file prelude:
                ;;(setq pos (smg-skip-file-prelude skip-comment))
                (if (zerop arg)
                    (if (>= (point) beg)
                        (goto-char (if (>= pos beg) (point-min) pos)))
                  (goto-char (if (or (>= (point) beg) (= (point) pos))
                                 (point-min) pos))))
              (setq arg nil)))
          (when arg                     ; always found a ";"
            (forward-char)
            (smg-skip-exception-part skip-comment)))
      (if (<= (point) pos)              ; moved backward?
          (goto-char pos)               ; rewind
        (decf arg))                     ; already moved one defun forward
      (unless (zerop arg)
        (while (>= (decf arg) 0)
          (smg-search-forward ";"))
        (smg-skip-exception-part skip-comment)
        ))))

(defun smg-outside-rule-p ()
  "Non-nil if point is outside a grammar rule.
Move to the beginning of the current rule if point is inside a rule."
  ;; WARNING: Should only be used with `smg-action-syntax-table'!
  (let ((pos (point)))
    (smg-next-rule -1 nil)
    (let ((between (or (bobp) (< (point) pos))))
      (smg-c-forward-sws)
      (and between (> (point) pos) (goto-char pos)))))


;;;===========================================================================
;;;  Parse grammar files (commands)
;;;===========================================================================
;; No (interactive "_") in Emacs... use `zmacs-region-stays'.

(defun smg-inside-rule-p ()
  "Non-nil if point is inside a grammar rule.
A grammar class header and the file prelude are also considered as a
rule."
  (save-excursion
    (not (smg-outside-rule-p))))

(defun smg-end-of-rule (&optional arg)
  "Move forward to next end of rule.  Do it ARG [default: 1] many times.
A grammar class header and the file prelude are also considered as a
rule.  Negative argument ARG means move back to ARGth preceding end of
rule.  If ARG is zero, run `smg-end-of-body'."
  (interactive "^p")
  (if (zerop arg)
      (smg-end-of-body)
    (smg-next-rule (1- arg) nil)
    (smg-end-of-body)))

(defun smg-beginning-of-rule (&optional arg)
  "Move backward to preceding beginning of rule.  Do it ARG many times.
A grammar class header and the file prelude are also considered as a
rule.  Negative argument ARG means move forward to ARGth next beginning
of rule.  If ARG is zero, run `smg-beginning-of-body'."
  (interactive "^p")
  (if (zerop arg)
      (smg-beginning-of-body)
    (smg-next-rule (- arg) t)))

(defun smg-end-of-body (&optional msg)
  "Move to position after the `;' of the current rule.
A grammar class header is also considered as a rule.  With optional
prefix arg MSG, move to `:'."
  (interactive "^")
  (let ((orig (point)))
    (if (smg-outside-rule-p)
        (error "Outside an SMG rule"))
    (let ((bor (point)))
      ;; (when (< (smg-skip-file-prelude t) (point))
      ;;   ;; Yes, we are in the file prelude
      ;;   (goto-char orig)
      ;;   (error (or msg "The file prelude is without `;'")))
      (smg-search-forward ";")
      ;; (when msg
      ;;   (when (< (point)
      ;;         (progn (goto-char bor)
      ;;                (or (smg-search-forward ":") (point-max))))
      ;;     (goto-char orig)
      ;;     (error msg))
      ;;   (smg-c-forward-sws))
      )))

(defun smg-beginning-of-body ()
  "Move to the first element after the `:' of the current rule."
  (interactive "^")
  (smg-end-of-body "Grammar and mode definitions are without `:'"))


;;;===========================================================================
;;;  Literal normalization, Hide Actions
;;;===========================================================================

(defun smg-hide-actions (arg &optional silent)
  "Hide or unhide all actions in buffer.
Hide all actions including arguments in brackets if ARG is 1 or if
called interactively without prefix argument.  Hide all actions
excluding arguments in brackets if ARG is 2 or higher.  Unhide all
actions if ARG is 0 or negative.  See `smg-action-visibility'.

Display a message unless optional argument SILENT is non-nil."
  (interactive "p")
  (with-silent-modifications
    (if (> arg 0)
        (let ((regexp (if (= arg 1) "[]}]" "}"))
              (diff (and smg-action-visibility
                         (+ (max smg-action-visibility 0) 2))))
          (smg-hide-actions 0 t)
          (save-excursion
            (goto-char (point-min))
            (while (smg-re-search-forward regexp nil)
              (let ((beg (ignore-errors(scan-sexps (point) -1))))
                (when beg
                  (if diff            ; braces are visible
                      (if (> (point) (+ beg diff))
                          (add-text-properties (1+ beg) (1- (point))
                                               '(invisible t intangible t)))
                      ;; if actions is on line(s) of its own, hide WS
                      (and (looking-at "[ \t]*$")
                           (save-excursion
                            (goto-char beg)
                            (skip-chars-backward " \t")
                            (and (bolp) (setq beg (point))))
                           (beginning-of-line 2)) ; beginning of next line
                      (add-text-properties beg (point)
                                           '(invisible t intangible t)))))))
          (or silent
              (message "Hide all actions (%s arguments)...done"
                       (if (= arg 1) "including" "excluding"))))
      (remove-text-properties (point-min) (point-max)
                              '(invisible nil intangible nil))
      (or silent
          (message "Unhide all actions (including arguments)...done")))))


;; ;;;===========================================================================
;; ;;;  Insert option: command
;; ;;;===========================================================================

;; (defun smg-insert-option (level option &optional location)
;;   "Insert file/grammar/rule/subrule option near point.
;; LEVEL determines option kind to insert: 1=file, 2=grammar, 3=rule,
;; 4=subrule.  OPTION is a string with the name of the option to insert.
;; LOCATION can be specified for not calling `smg-option-kind' twice.

;; Inserting an option with this command works as follows:

;;  1. When called interactively, LEVEL is determined by the prefix
;;     argument or automatically deduced without prefix argument.
;;  2. Signal an error if no option of that level could be inserted, e.g.,
;;     if the buffer is read-only, the option area is outside the visible
;;     part of the buffer or a subrule/rule option should be inserted with
;;     point outside a subrule/rule.
;;  3. When called interactively, OPTION is read from the minibuffer with
;;     completion over the known options of the given LEVEL.
;;  4. Ask user for confirmation if the given OPTION does not seem to be a
;;     valid option to insert into the current file.
;;  5. Find a correct position to insert the option.
;;  6. Depending on the option, insert it the following way \(inserting an
;;     option also means inserting the option section if necessary\):
;;      - Insert the option and let user insert the value at point.
;;      - Read a value (with completion) from the minibuffer, using a
;;        previous value as initial contents, and insert option with value.
;;  7. Final action depending on the option.  For example, set the language
;;     according to a newly inserted language option.

;; The name of all options with a specification for their values are stored
;; in `smg-options-alists'.  The used specification also depends on the
;; value of `smg-tool-version', i.e., step 4 will warn you if you use an
;; option that has been introduced in newer version of SMG, and step 5
;; will offer completion using version-correct values.

;; If the option already exists inside the visible part of the buffer, this
;; command can be used to change the value of that option.  Otherwise, find
;; a correct position where the option can be inserted near point.

;; The search for a correct position is as follows:

;;   * If search is within an area where options can be inserted, use the
;;     position of point.  Inside the options section and if point is in
;;     the middle of a option definition, skip the rest of it.
;;   * If an options section already exists, insert the options at the end.
;;     If only the beginning of the area is visible, insert at the
;;     beginning.
;;   * Otherwise, find the position where an options section can be
;;     inserted and insert a new section before any comments.  If the
;;     position before the comments is not visible, insert the new section
;;     after the comments.

;; This function also inserts \"options {...}\" and the \":\" if necessary,
;; see `smg-options-auto-colon'.  See also `smg-options-assign-string'.

;; This command might also set the mark like \\[set-mark-command] does, see
;; `smg-options-push-mark'."
;;   (interactive (smg-insert-option-interactive current-prefix-arg))
;;   (barf-if-buffer-read-only)
;;   (or location (setq location (cdr (smg-option-kind level))))
;;   (cond ((null level)
;;          (error "Cannot deduce what kind of option to insert"))
;;         ((atom location)
;;          (error "Cannot insert any %s options around here"
;;                 (elt smg-options-headings (1- level)))))
;;   (let ((area (car location))
;;         (place (cdr location)))
;;     (cond ((null place)         ; invisible
;;            (error (if area
;;                       "Invisible %s options, use %s to make them visible"
;;                     "Invisible area for %s options, use %s to make it visible")
;;                   (elt smg-options-headings (1- level))
;;                   (substitute-command-keys "\\[widen]")))
;;           ((null area)                  ; without option part
;;            (smg-insert-option-do level option nil
;;                                    (null (cdr place))
;;                                    (car place)))
;;           ((save-excursion              ; with option part, option visible
;;              (goto-char (max (point-min) (car area)))
;;              (re-search-forward (concat "\\(^\\|;\\)[ \t]*\\(\\<"
;;                                         (regexp-quote option)
;;                                         "\\>\\)[ \t\n]*\\(\\(=[ \t]?\\)[ \t]*\\(\\(\\sw\\|\\s_\\)+\\|\"\\([^\n\"\\]\\|[\\][^\n]\\)*\"\\)?\\)?")
;;                                 ;; 2=name, 3=4+5, 4="=", 5=value
;;                                 (min (point-max) (cdr area))
;;                                 t))
;;            (smg-insert-option-do level option
;;                                    (cons (or (match-beginning 5)
;;                                              (match-beginning 3))
;;                                          (match-end 5))
;;                                    (and (null (cdr place)) area)
;;                                    (or (match-beginning 5)
;;                                        (match-end 4)
;;                                        (match-end 2))))
;;           (t                            ; with option part, option not yet
;;            (smg-insert-option-do level option t
;;                                    (and (null (cdr place)) area)
;;                                    (car place))))))

;; (defun smg-insert-option-interactive (arg)
;;   "Interactive specification for `smg-insert-option'.
;; Return \(LEVEL OPTION LOCATION)."
;;   (barf-if-buffer-read-only)
;;   (if arg (setq arg (prefix-numeric-value arg)))
;;   (unless (memq arg '(nil 1 2 3 4))
;;     (error "Valid prefix args: no=auto, 1=file, 2=grammar, 3=rule, 4=subrule"))
;;   (let* ((kind (smg-option-kind arg))
;;          (level (car kind)))
;;     (if (atom (cdr kind))
;;         (list level nil (cdr kind))
;;       (let* ((table (elt smg-options-alists (1- level)))
;;              (completion-ignore-case t) ;dynamic
;;              (input (completing-read (format "Insert %s option: "
;;                                              (elt smg-options-headings
;;                                                   (1- level)))
;;                                      table)))
;;         (list level input (cdr kind))))))

;; (defun smg-options-menu-filter (level _menu-items)
;;   "Return items for options submenu of level LEVEL."
;;   ;; checkdoc-params: (menu-items)
;;   (let ((active (if buffer-read-only
;;                     nil
;;                   (consp (cdr-safe (cdr (smg-option-kind level)))))))
;;     (mapcar (lambda (option)
;;               (vector option
;;                       (list 'smg-insert-option level option)
;;                       :active active))
;;             (sort (mapcar 'car (elt smg-options-alists (1- level)))
;;                   'string-lessp))))


;; ;;;===========================================================================
;; ;;;  Insert option: determine section-kind
;; ;;;===========================================================================

;; (defun smg-option-kind (requested)
;;   "Return level and location for option to insert near point.
;; Call function `smg-option-level' with argument REQUESTED.  If the
;; result is nil, return \(REQUESTED \. error).  If the result has the
;; non-nil value LEVEL, return \(LEVEL \. LOCATION) where LOCATION looks
;; like \(AREA \. PLACE), see `smg-option-location'."
;;   (save-excursion
;;     (save-restriction
;;       (let ((min0 (point-min))          ; before `widen'!
;;             (max0 (point-max))
;;             (orig (point))
;;             (level (smg-option-level requested)) ; calls `widen'!
;;             pos)
;;         (cond ((null level)
;;                (setq level requested))
;;               ((eq level 1)             ; file options
;;                (goto-char (point-min))
;;                (setq pos (smg-skip-file-prelude 'header-only)))
;;               ((not (eq level 3))       ; grammar or subrule options
;;                (setq pos (point))
;;                (smg-c-forward-sws))
;;               ((looking-at "^\\(private[ \t\n]\\|public[ \t\n]\\|protected[ \t\n]\\)?[ \t\n]*\\(\\(\\sw\\|\\s_\\)+\\)[ \t\n]*\\(!\\)?[ \t\n]*\\(\\[\\)?")
;;                ;; rule options, with complete rule header
;;                (goto-char (or (match-end 4) (match-end 3)))
;;                (setq pos (smg-skip-sexps (if (match-end 5) 1 0)))
;;                (when (looking-at "returns[ \t\n]*\\[")
;;                  (goto-char (1- (match-end 0)))
;;                  (setq pos (smg-skip-sexps 1)))))
;;         (cons level
;;               (cond ((null pos) 'error)
;;                     ((looking-at "options[ \t\n]*{")
;;                      (goto-char (match-end 0))
;;                      (setq pos (ignore-errors (scan-lists (point) 1 1)))
;;                      (smg-option-location orig min0 max0
;;                                             (point)
;;                                             (if pos (1- pos) (point-max))
;;                                             t))
;;                     (t
;;                      (smg-option-location orig min0 max0
;;                                             pos (point)
;;                                             nil))))))))

;; (defun smg-option-level (requested)
;;   "Return level for option to insert near point.
;; Remove any restrictions from current buffer and return level for the
;; option to insert near point, i.e., 1, 2, 3, 4, or nil if no such option
;; can be inserted.  If REQUESTED is non-nil, it is the only possible value
;; to return except nil.  If REQUESTED is nil, return level for the nearest
;; option kind, i.e., the highest number possible.

;; If the result is 2, point is at the beginning of the class after the
;; class definition.  If the result is 3 or 4, point is at the beginning of
;; the rule/subrule after the init action.  Otherwise, the point position
;; is undefined."
;;   (widen)
;;   (if (eq requested 1)
;;       1
;;     (let* ((orig (point))
;;            (outsidep (smg-outside-rule-p))
;;            bor depth)
;;       (if (eq (char-after) ?\{) (smg-skip-sexps 1))
;;       (setq bor (point))              ; beginning of rule (after init action)
;;       (cond ((eq requested 2)         ; grammar options required?
;;              (let (boc)               ; beginning of class
;;                (goto-char (point-min))
;;                (while (and (<= (point) bor)
;;                            (smg-re-search-forward smg-class-header-regexp
;;                                                   nil))
;;                  (if (<= (match-beginning 0) bor)
;;                      (setq boc (match-end 0))))
;;                (when boc
;;                  (goto-char boc)
;;                  2)))
;;             ((save-excursion          ; in region of file options?
;;               (goto-char (point-min))
;;               (smg-skip-file-prelude t) ; ws/comment after: OK
;;               (< orig (point)))
;;              (and (null requested) 1))
;;             (outsidep                 ; outside rule not OK
;;              nil)
;;             ((looking-at smg-class-header-regexp) ; rule = class def?
;;              (goto-char (match-end 0))
;;              (and (null requested) 2))
;;             ((eq requested 3)         ; rule options required?
;;              (goto-char bor)
;;              3)
;;             ((setq depth (smg-syntactic-grammar-depth orig bor))
;;              (if (> depth 0)          ; move out of actions
;;                  (goto-char (scan-lists (point) -1 depth)))
;;              (set-syntax-table smg-mode-syntax-table)
;;              (if (eq (smg-syntactic-context) 0) ; not in subrule?
;;                  (unless (eq requested 4)
;;                    (goto-char bor)
;;                    3)
;;                  (goto-char (1+ (scan-lists (point) -1 1)))
;;                  4))))))

;; (defun smg-option-location (orig min-vis max-vis min-area max-area withp)
;;   "Return location for the options area.
;; ORIG is the original position of `point', MIN-VIS is `point-min' and
;; MAX-VIS is `point-max'.  If WITHP is non-nil, there exists an option
;; specification and it starts after the brace at MIN-AREA and stops at
;; MAX-AREA.  If WITHP is nil, there is no area and the region where it
;; could be inserted starts at MIN-AREA and stops at MAX-AREA.

;; The result has the form (AREA . PLACE).  AREA is (MIN-AREA . MAX-AREA)
;; if WITHP is non-nil, and nil otherwise.  PLACE is nil if the area is
;; invisible, (ORIG) if ORIG is inside the area, (MIN-AREA . beginning) for
;; a visible start position and (MAX-AREA . end) for a visible end position
;; where the beginning is preferred if WITHP is nil and the end if WITHP is
;; non-nil."
;;   (cons (and withp (cons min-area max-area))
;;         (cond ((and (<= min-area orig) (<= orig max-area)
;;                     (save-excursion
;;                       (goto-char orig)
;;                       (not (memq (smg-syntactic-context)
;;                                  '(comment block-comment)))))
;;                ;; point in options area and not in comment
;;                (list orig))
;;               ((and (null withp) (<= min-vis min-area) (<= min-area max-vis))
;;                ;; use start of options area (only if not `withp')
;;                (cons min-area 'beginning))
;;               ((and (<= min-vis max-area) (<= max-area max-vis))
;;                ;; use end of options area
;;                (cons max-area 'end))
;;               ((and withp (<= min-vis min-area) (<= min-area max-vis))
;;                ;; use start of options area (only if `withp')
;;                (cons min-area 'beginning)))))

;; (defun smg-syntactic-grammar-depth (pos beg)
;;   "Return syntactic context depth at POS.
;; Move to POS and from there on to the beginning of the string or comment
;; if POS is inside such a construct.  Then, return the syntactic context
;; depth at point if the point position is smaller than BEG.
;; WARNING: this may alter `match-data'."
;;   (goto-char pos)
;;   (let ((context (or (smg-syntactic-context) 0)))
;;     (while (and context (not (integerp context)))
;;       (cond ((eq context :string)
;;              (setq context
;;                    (and (search-backward "\"" nil t)
;;                         (>= (point) beg)
;;                         (or (smg-syntactic-context) 0))))
;;             ((memq context '(comment block-comment))
;;              (setq context
;;                    (and (re-search-backward "/[/*]" nil t)
;;                         (>= (point) beg)
;;                         (or (smg-syntactic-context) 0))))))
;;     context))


;; ;;;===========================================================================
;; ;;;  Insert options: do the insertion
;; ;;;===========================================================================

;; (defun smg-insert-option-do (level option old area pos)
;;   "Insert option into buffer at position POS.
;; Insert option of level LEVEL and name OPTION.  If OLD is non-nil, an
;; options area is already exists.  If OLD looks like \(BEG \. END), the
;; option already exists.  Then, BEG is the start position of the option
;; value, the position of the `=' or nil, and END is the end position of
;; the option value or nil.

;; If the original point position was outside an options area, AREA is nil.
;; Otherwise, and if an option specification already exists, AREA is a cons
;; cell where the two values determine the area inside the braces."
;;   (let* ((spec (cdr (assoc option (elt smg-options-alists (1- level)))))
;;          (value (smg-option-spec level option (cdr spec) (consp old))))
;;     (if (fboundp (car spec)) (funcall (car spec) 'before-input option))
;;     ;; set mark (unless point was inside options area before)
;;     (if (cond (area (eq smg-options-push-mark t))
;;               ((numberp smg-options-push-mark)
;;                (> (count-lines (min (point) pos) (max (point) pos))
;;                   smg-options-push-mark))
;;               (smg-options-push-mark))
;;         (push-mark))
;;     ;; read option value -----------------------------------------------------
;;     (goto-char pos)
;;     (if (null value)
;;         ;; no option specification found
;;         (if (y-or-n-p (format "Insert unknown %s option %s? "
;;                               (elt smg-options-headings (1- level))
;;                               option))
;;             (message "Insert value for %s option %s"
;;                      (elt smg-options-headings (1- level))
;;                      option)
;;           (error "Didn't insert unknown %s option %s"
;;                  (elt smg-options-headings (1- level))
;;                  option))
;;       ;; option specification found
;;       (setq value (cdr value))
;;       (if (car value)
;;           (let ((initial (and (consp old) (cdr old)
;;                               (buffer-substring (car old) (cdr old)))))
;;             (setq value (apply (car value)
;;                                (and initial
;;                                     (if (eq (aref initial 0) ?\")
;;                                         (read initial)
;;                                       initial))
;;                                (cdr value))))
;;         (message "%s" (or (cadr value) ""))
;;         (setq value nil)))
;;     ;; insert value ----------------------------------------------------------
;;     (if (consp old)
;;         (smg-insert-option-existing old value)
;;       (if (consp area)
;;           ;; Move outside string/comment if point is inside option spec
;;           (smg-syntactic-grammar-depth (point) (car area)))
;;       (smg-insert-option-space area old)
;;       (or old (smg-insert-option-area level))
;;       (insert option " = ;")
;;       (backward-char)
;;       (if value (insert value)))
;;     ;; final -----------------------------------------------------------------
;;     (if (fboundp (car spec)) (funcall (car spec) 'after-insertion option))))

;; (defun smg-option-spec (level option specs existsp)
;;   "Return version correct option value specification.
;; Return specification for option OPTION of kind level LEVEL.  SPECS
;; should correspond to the VALUE-SPEC... in `smg-option-alists'.
;; EXISTSP determines whether the option already exists."
;;   (let (value)
;;     (while (and specs (>= smg-tool-version (caar specs)))
;;       (setq value (pop specs)))
;;     (cond (value)                       ; found correct spec
;;           ((null specs) nil)            ; didn't find any specs
;;           (existsp (car specs)) ; wrong version, but already present
;;           ((y-or-n-p (format "Insert v%s %s option %s in v%s? "
;;                              (smg-version-string (caar specs))
;;                              (elt smg-options-headings (1- level))
;;                              option
;;                              (smg-version-string smg-tool-version)))
;;            (car specs))
;;           (t
;;            (error "Didn't insert v%s %s option %s in v%s"
;;                   (smg-version-string (caar specs))
;;                   (elt smg-options-headings (1- level))
;;                   option
;;                   (smg-version-string smg-tool-version))))))

;; (defun smg-version-string (version)
;;   "Format the Smg version number VERSION, see `smg-tool-version'."
;;   (let ((version100 (/ version 100)))
;;     (format "%d.%d.%d"
;;             (/ version100 100) (mod version100 100) (mod version 100))))


;; ;;;===========================================================================
;; ;;;  Insert options: the details (used by `smg-insert-option-do')
;; ;;;===========================================================================

;; (defun smg-insert-option-existing (old value)
;;   "Insert option value VALUE at point for existing option.
;; For OLD, see `smg-insert-option-do'."
;;   ;; no = => insert =
;;   (unless (car old) (insert smg-options-assign-string))
;;   ;; with user input => insert if necessary
;;   (when value
;;     (if (cdr old)               ; with value
;;         (if (string-equal value (buffer-substring (car old) (cdr old)))
;;             (goto-char (cdr old))
;;           (delete-region (car old) (cdr old))
;;           (insert value))
;;       (insert value)))
;;   (unless (looking-at "\\([^\n=;{}/'\"]\\|'\\([^\n'\\]\\|\\\\.\\)*'\\|\"\\([^\n\"\\]\\|\\\\.\\)*\"\\)*;")
;;     ;; stuff (no =, {, } or /) at point is not followed by ";"
;;     (insert ";")
;;     (backward-char)))

;; (defun smg-insert-option-space (area old)
;;   "Find appropriate place to insert option, insert newlines/spaces.
;; For AREA and OLD, see `smg-insert-option-do'."
;;   (let ((orig (point))
;;         (open t))
;;     (skip-chars-backward " \t")
;;     (unless (bolp)
;;       (let ((before (char-after (1- (point)))))
;;         (goto-char orig)
;;         (and old                        ; with existing options area
;;              (consp area)               ; if point inside existing area
;;              (not (eq before ?\;))      ; if not at beginning of option
;;                                         ; => skip to end of option
;;              (if (and (search-forward ";" (cdr area) t)
;;                       (let ((context (smg-syntactic-context)))
;;                         (or (null context) (numberp context))))
;;                  (setq orig (point))
;;                (goto-char orig)))
;;         (skip-chars-forward " \t")

;;         (if (looking-at "$\\|//")
;;             ;; just comment after point => skip (+ lines w/ same col comment)
;;             (let ((same (if (> (match-end 0) (match-beginning 0))
;;                             (current-column))))
;;               (beginning-of-line 2)
;;               (or (bolp) (insert "\n"))
;;               (when (and same (null area)) ; or (consp area)?
;;                 (while (and (looking-at "[ \t]*\\(//\\)")
;;                             (goto-char (match-beginning 1))
;;                             (= (current-column) same))
;;                   (beginning-of-line 2)
;;                   (or (bolp) (insert "\n")))))
;;           (goto-char orig)
;;           (if (null old)
;;               (progn (insert "\n") (smg-indent-line))
;;             (unless (eq (char-after (1- (point))) ?\ )
;;               (insert " "))
;;             (unless (eq (char-after (point)) ?\ )
;;               (insert " ")
;;               (backward-char))
;;             (setq open nil)))))
;;     (when open
;;       (beginning-of-line 1)
;;       (insert "\n")
;;       (backward-char)
;;       (smg-indent-line))))

;; (defun smg-insert-option-area (level)
;;   "Insert new options area for options of level LEVEL.
;; Used by `smg-insert-option-do'."
;;   (insert "options {\n\n}")
;;   (when (and smg-options-auto-colon
;;              (memq level '(3 4))
;;              (save-excursion
;;                (smg-c-forward-sws)
;;                (if (eq (char-after (point)) ?\{) (smg-skip-sexps 1))
;;                (not (eq (char-after (point)) ?\:))))
;;     (insert "\n:")
;;     (smg-indent-line)
;;     (end-of-line 0))
;;   (backward-char 1)
;;   (smg-indent-line)
;;   (beginning-of-line 0)
;;   (smg-indent-line))


;; ;;;===========================================================================
;; ;;;  Insert options: in `smg-options-alists'
;; ;;;===========================================================================

;; (defun smg-read-value (initial-contents prompt
;;                                           &optional as-string table table-x)
;;   "Read a string from the minibuffer, possibly with completion.
;; If INITIAL-CONTENTS is non-nil, insert it in the minibuffer initially.
;; PROMPT is a string to prompt with, normally it ends in a colon and a
;; space.  If AS-STRING is t or is a member \(comparison done with `eq') of
;; `smg-options-style', return printed representation of the user input,
;; otherwise return the user input directly.

;; If TABLE or TABLE-X is non-nil, read with completion.  The completion
;; table is the resulting alist of TABLE-X concatenated with TABLE where
;; TABLE can also be a function evaluation to an alist.

;; Used inside `smg-options-alists'."
;;   (let* ((completion-ignore-case t)     ; dynamic
;;          (table0 (and (or table table-x)
;;                       (append table-x
;;                               (if (functionp table) (funcall table) table))))
;;          (input (if table0
;;                     (completing-read prompt table0 nil nil initial-contents)
;;                   (read-from-minibuffer prompt initial-contents))))
;;     (if (and as-string
;;              (or (eq as-string t)
;;                  (cdr (assq as-string smg-options-style))))
;;         (format "%S" input)
;;       input)))

;; (defun smg-read-boolean (initial-contents prompt &optional table)
;;   "Read a boolean value from the minibuffer, with completion.
;; If INITIAL-CONTENTS is non-nil, insert it in the minibuffer initially.
;; PROMPT is a string to prompt with, normally it ends in a question mark
;; and a space.  \"(true or false) \" is appended if TABLE is nil.

;; Read with completion over \"true\", \"false\" and the keys in TABLE, see
;; also `smg-read-value'.

;; Used inside `smg-options-alists'."
;;   (smg-read-value initial-contents
;;                     (if table prompt (concat prompt "(true or false) "))
;;                     nil
;;                     table '(("false") ("true"))))

;; ;; (defun smg-language-option-extra (phase &rest _dummies)
;; ;; ;; checkdoc-params: (dummies)
;; ;;   "Change language according to the new value of the \"language\" option.
;; ;; Call `smg-mode' if the new language would be different from the value
;; ;; of `smg-language', keeping the value of variable `font-lock-mode'.

;; ;; Called in PHASE `after-insertion', see `smg-options-alists'."
;; ;;   (when (eq phase 'after-insertion)
;; ;;     (let ((new-language (smg-language-option t)))
;; ;;       (or (null new-language)
;; ;;           (eq new-language smg-language)
;; ;;           (let ((font-lock (and (boundp 'font-lock-mode) font-lock-mode)))
;; ;;             (if font-lock (font-lock-mode 0))
;; ;;             (smg-mode)
;; ;;             (and font-lock (null font-lock-mode) (font-lock-mode 1)))))))

;; (defun smg-c++-mode-extra (phase option &rest _dummies)
;; ;; checkdoc-params: (option dummies)
;;   "Warn if C++ option is used with the wrong language.
;; Ask user \(\"y or n\"), if a C++ only option is going to be inserted but
;; `smg-language' has not the value `c++-mode'.

;; Called in PHASE `before-input', see `smg-options-alists'."
;;   (and (eq phase 'before-input)
;;        (not (eq smg-language 'c++-mode))
;;        (not (y-or-n-p (format "Insert C++ %s option? " option)))
;;        (error "Didn't insert C++ %s option with language %s"
;;               option (cadr (assq smg-language smg-language-alist)))))


;;;===========================================================================
;;;  Indentation
;;;===========================================================================

(defun smg-indent-line ()
  "Indent the current line as SMG grammar code.
The indentation of grammar lines are calculated by `c-basic-offset',
multiplied by:
 - the level of the paren/brace/bracket depth,
 - plus 0/2/1, depending on the position inside the rule: header, body,
   exception part,
 - minus 1 if `smg-indent-item-regexp' matches the beginning of the
   line starting from the first non-whitespace.

Lines inside block comments are indented by `c-indent-line' according to
`smg-indent-comment'.

Lines in actions except top-level actions in a header part or an option
area are indented by `c-indent-line'.

Lines in header actions are indented at column 0 if `smg-language'
equals to a key in `smg-indent-at-bol-alist' and the line starting at
the first non-whitespace is matched by the corresponding value.

For the initialization of `c-basic-offset', see `smg-indent-style' and,
to a lesser extent, `smg-tab-offset-alist'."
  (save-restriction
    (let ((orig (point))
          (min0 (point-min))
          bol boi indent syntax)
      (cl-labels ((indent-for-syntax (syntax)
                    (cond
                      ((symbolp syntax)
                       nil)     ; block-comments, strings, (comments)
                      ((progn
                         (smg-next-rule -1 t)
                         (if (smg-re-search-forward "-?->" nil) (< boi (1- (point))) t))
                       0)              ; in rule header
                      ((smg-inside-rule-p)
                       2) ; in rule body
                      (t
                       (forward-char)
                       (smg-skip-exception-part nil)
                       (if (> (point) boi) 1 0))))) ; in exception part?
       (widen)
       (beginning-of-line)
       (setq bol (point))
       (if (< bol min0)
           (error "Beginning of current line not visible"))
       (skip-chars-forward " \t")
       (setq boi (point))
       ;; check syntax at beginning of indentation ----------------------------
       (setq syntax (smg-syntactic-context))
       (setq indent (indent-for-syntax syntax))
       ;; compute the corresponding indentation and indent --------------------
       (when indent
         (goto-char boi)
         (unless (symbolp syntax)                ; direct indentation
           (and (> indent 0) (looking-at smg-indent-item-regexp) (decf indent))
           (setq indent (* indent 2)))
         ;; the usual major-mode indent stuff ---------------------------------
         (setq orig (- (point-max) orig))
         (unless (= (current-column) indent)
           (delete-region bol boi)
           (beginning-of-line)
           (indent-to indent))
         ;; If initial point was within line's indentation,
         ;; position after the indentation.  Else stay at same point in text.
         (if (> (- (point-max) orig) (point))
             (goto-char (- (point-max) orig))))))))

(defun smg-indent-command (&optional arg)
  "Indent the current line or insert tabs/spaces.
With optional prefix argument ARG or if the previous command was this
command, insert ARG tabs or spaces according to `indent-tabs-mode'.
Otherwise, indent the current line with `smg-indent-line'."
  (interactive "*P")
  (let ((smg-indent-comment (and smg-indent-comment t))) ; dynamic
    (smg-indent-line)))

(defun smg-electric-character (&optional arg)
  "Insert the character you type and indent the current line.
Insert the character like `self-insert-command' and indent the current
line as `smg-indent-command' does.  Do not indent the line if

 * this command is called with a prefix argument ARG,
 * there are characters except whitespaces between point and the
   beginning of the line, or
 * point is not inside a normal grammar code, { and } are also OK in
   actions.

This command is useful for a character which has some special meaning in
SMG's syntax and influences the auto indentation, see
`smg-indent-item-regexp'."
  (interactive "*P")
  (if (or arg
          (save-excursion (skip-chars-backward " \t") (not (bolp)))
          (let ((context (smg-syntactic-context)))
            (not (and (numberp context)
                      (or (zerop context)
                          (memq last-command-event '(?\{ ?\})))))))
      (self-insert-command (prefix-numeric-value arg))
    (self-insert-command (prefix-numeric-value arg))
    (smg-indent-line)))


;;;===========================================================================
;;;  Go to rule
;;;===========================================================================

(defvar-local smg-defn-stack nil)
(defvar-local smg-def-data nil)

(defun smg--strip-text-properties (str)
  (set-text-properties 0 (length str) nil str)
  str)

(defun smg--parse-grammar ()
  (let ((items nil)
        (continue t))
    (goto-char (point-min))
    (while continue
      (when (smg-re-search-forward smg--rule-start-re nil)
        (push (cons (smg--strip-text-properties (match-string 1))
                    (copy-marker (match-beginning 1)))
              items))
      (setq continue (smg-search-forward ";")))
    (setq smg-def-data (nreverse items))))

(defun smg--parse-current-buffer ()
  (unless smg-def-data
    (save-excursion (smg--parse-grammar)))
  smg-def-data)

(defun smg--find-def (ident)
  (assoc ident smg-def-data))
 
(defun smg-go-to-def ()
  (interactive)
  (smg--parse-current-buffer)
  (let* ((def (smg--find-def (thing-at-point 'symbol))))
    (if (not def)
        (message "Entity not found.")
      (push (point) smg-defn-stack)
      (goto-char (marker-position (cdr def)))
      (message "Jumped to \"%s\"." (car def)))))

(defun smg-go-back ()
  (interactive)
  (if smg-defn-stack
      (goto-char (pop smg-defn-stack))
      (message "Defn stack is empty.")))

;; ;; dump tree

;; (defun smg--make-new-buffer-name (name)
;;   (let ((n 0)
;;         (namelen (length name)))
;;     (dolist (buf (buffer-list))
;;       (let* ((bname (buffer-name buf))
;;              (bnamelen (length bname)))
;;         (when (and (> bnamelen namelen)
;;                    (string= (substring bname 0 namelen) name))
;;           (setq n (max n (string-to-number (substring bname namelen (1+ namelen))))))))
;;     (concat name (number-to-string (1+ n)))))

;; (defun smg--dump-from-kind (kind)
;;   (let ((def (smg--find-def kind)))
;;     (format "%s" def)))

;; (defun smg-dump-tree ()
;;   (interactive)
;;   (smg--parse-current-buffer)
;;   (let* ((start-kind (thing-at-point 'symbol))
;;          (buffer-name (smg--make-new-buffer-name start-kind))
;;          (newb (get-buffer-create buffer-name))
;;          (current-buffer (current-buffer)))
;;     (switch-to-buffer newb)
;;     (erase-buffer)
;;     (insert "sup")
;;     (insert
;;      (with-current-buffer current-buffer
;;        (smg--dump-from-kind start-kind)))))


;;;===========================================================================
;;;  Mode entry
;;;===========================================================================

;;;###autoload
(define-derived-mode smg-mode prog-mode
  "SMG"
  "Major mode for editing SMG grammar files."
  :group 'smg
  :abbrev-table smg-mode-abbrev-table
  :syntax-table smg-mode-syntax-table
  (c-initialize-cc-mode)                ; cc-mode is required
  (setq-local indent-line-function 'smg-indent-line)
  (setq-local indent-region-function nil)
  ;; various -----------------------------------------------------------------
  (setq-local font-lock-defaults smg-font-lock-defaults)
  (setq-local syntax-propertize-function #'smg--syntax-propertize)
  (easy-menu-add smg-mode-menu)
  (setq-local imenu-create-index-function 'smg-imenu-create-index-function)
  (setq-local imenu-generic-expression t) ; fool stupid test
  (run-mode-hooks 'antlr-after-body-hook))

;;;###autoload
(defun smg-set-tabs ()
  "Use SMG's convention for TABs according to `smg-tab-offset-alist'.
Used in `smg-mode'.  Also a useful function in `java-mode-hook'."
  (when buffer-file-name
    (cl-loop for elem in smg-tab-offset-alist do
       (and (or (null (car elem)) (eq (car elem) major-mode))
            (or (null (cadr elem))
                (string-match (cadr elem) buffer-file-name))
            (setq tab-width (caddr elem)
                  indent-tabs-mode (cadddr elem)
                  alist nil)))))

(provide 'smg-mode)

;;; Local IspellPersDict: .ispell_smg

;;; smg-mode.el ends here
