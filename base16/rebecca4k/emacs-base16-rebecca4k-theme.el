;; base16-rebecca4k-theme.el -- A base16 colorscheme

;;; Commentary:
;; Base16: (https://github.com/chriskempson/base16)

;;; Authors:
;; Scheme: Victor Borja (http://github.com/vic) based on Rebecca Theme (http://github.com/vic/rebecca-theme)
;; Tweaks to scheme: bugdie4k
;; Template: Kaleb Elwert <belak@coded.io>

;;; Code:

(require 'base16-theme)

(defvar base16-rebecca4k-colors
    '(:base00 "#09090E" ;; orig: "#292a44" ;; default background
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

;; Define the theme
(deftheme base16-rebecca4k)

;; Add all the faces to the theme
(base16-theme-define 'base16-rebecca4k base16-rebecca4k-colors)

;; Mark the theme as provided
(provide-theme 'base16-rebecca4k)

(provide 'base16-rebecca4k-theme)

;;; base16-rebecca4k-theme.el ends here
