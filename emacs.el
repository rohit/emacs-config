;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Emacs config of Rohit Arondekar. Under heave adaptation ;;
;; and change. Don't look!                                 ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; SETUP PACKAGES AND REQUIRED PACKAGE AUTO INSTALL ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Initialize emacs package system and set melpa archive
(require 'package)
(add-to-list 'package-archives
             '("melpa" . "http://melpa.org/packages/") t)
(package-initialize)

;; Auto install packages that we want if they are not already
;; installed at startup. So we have a familiar Emacs on startup
;; anywhere!

;; List of required packages
(defvar required-packages
  '(auto-complete
    projectile
    robe
    rspec-mode
    yasnippet
    flx-ido
    clojure-mode
    coffee-mode
    haml-mode
    sass-mode
    handlebars-mode
    markdown-mode
    nodejs-repl
    feature-mode
    ledger-mode
    flycheck
    web-mode
    ace-jump-mode
    expand-region
    zenburn-theme
    rvm
    ansi-color
    smooth-scrolling
    smartparens
    rainbow-mode) "a list of required packages at launch")

(require 'cl)

; method to check if all packages are installed
(defun packages-installed-p ()
  (loop for p in required-packages
        when (not (package-installed-p p)) do (return nil)
        finally (return t)))

; if not all packages are installed, check one by one and install the missing ones.
(unless (packages-installed-p)
  ; check for new packages (package versions)
  (message "%s" "Emacs is now refreshing its package database...")
  (package-refresh-contents)
  (message "%s" " done.")
  ; install the missing packages
  (dolist (p required-packages)
    (when (not (package-installed-p p))
      (package-install p))))



;######################
;# CORE EMACS CONFIG ##
;######################

;; Add ~/.emacs.d to load-path
(add-to-list 'load-path "~/.emacs.d")

;; Sets the default font to Inconsolata
(set-default-font "-unknown-Inconsolata-normal-normal-normal-*-20-*-*-*-m-0-iso10646-1")

;; Highlight current line
(global-hl-line-mode 1)
(set-face-background 'hl-line "#444")
(set-face-underline 'hl-line nil)

;; Use zenburn theme
(load-theme 'zenburn t)
(set-face-attribute 'region nil :background "#1a4244")

;; Switch off menubar, scrollbar and toolbar and the startup message
(scroll-bar-mode -1)
(menu-bar-mode -1)
(tool-bar-mode -1)
(setq inhibit-startup-message 0)

;; Use column-number-mode
(setq column-number-mode t)

;; Stop making backup files and save files
(setq make-backup-files         nil)
(setq auto-save-list-file-name  nil)
(setq auto-save-default nil)
(setq backup-inhibited t)

;; Use spaces for indent
(setq-default indent-tabs-mode nil)
(setq-default tab-width 2)
(setq tab-width 2)

;; Prefer utf-8 encoding
(prefer-coding-system 'utf-8)

;; show annoying trailing whitespace
(setq show-trailing-whitespace t)

;; Scroll with output of rake test etc
(setq compilation-scroll-output t)

;; Shortcut to align = vertically
(fset 'align-equals "\C-[xalign-regex\C-m=\C-m")
(global-set-key "\M-=" 'align-equals)

;; Use windmove bindings
;; Navigate between windows using Alt-1, Alt-2, Shift-left, shift-up, shift-right
(windmove-default-keybindings)

;; show key chords quickly
(setq echo-keystroke 0.1)


(defun smarter-move-beginning-of-line (arg)
  "Move point back to indentation of beginning of line.

Move point to the first non-whitespace character on this line.
If point is already there, move to the beginning of the line.
Effectively toggle between the first non-whitespace character and
the beginning of the line.

If ARG is not nil or 1, move forward ARG - 1 lines first.  If
point reaches the beginning or end of the buffer, stop there."
  (interactive "^p")
  (setq arg (or arg 1))

  ;; Move lines first
  (when (/= arg 1)
    (let ((line-move-visual nil))
      (forward-line (1- arg))))

  (let ((orig-point (point)))
    (back-to-indentation)
    (when (= orig-point (point))
      (move-beginning-of-line 1))))

;; remap C-a to `smarter-move-beginning-of-line'
(global-set-key [remap move-beginning-of-line]
                'smarter-move-beginning-of-line)



;###############################
;# CONFIGURE VARIOUS PACKAGES ##
;###############################

;; Auto Complete
(require 'auto-complete-config)
(add-to-list 'ac-dictionary-directories "~/.emacs.d/elpa/auto-complete-20141228.633/dict/")
(ac-config-default)

;; Cucumber mode
(require 'feature-mode)
(add-to-list 'auto-mode-alist '("\.feature$" . feature-mode))

;; HAML & SASS mode
(require 'haml-mode)
(add-to-list 'auto-mode-alist '("\.haml$" . haml-mode))
(require 'sass-mode)
(add-to-list 'auto-mode-alist '("\.scss$" . sass-mode))

;; Coffeescript mode
(require 'coffee-mode)
(add-to-list 'auto-mode-alist '("\\.coffee$" . coffee-mode))
(add-to-list 'auto-mode-alist '("Cakefile" . coffee-mode))

;; Clojure mode
(require 'clojure-mode)

;; YASnippet
(add-to-list 'load-path
              "~/.emacs.d/yasnippet")
(require 'yasnippet)
(yas/global-mode 1)

(require 'flycheck)
(add-hook 'js-mode-hook
          (lambda () (flycheck-mode t)))
(set-face-attribute 'flycheck-error nil :background "DarkRed" :underline nil)
(set-face-attribute 'flycheck-warning nil :background "orange4" :underline nil)
(set-face-attribute 'flycheck-info nil :underline t)

;; ruby mode
(add-hook 'ruby-mode-hook
          (lambda () (flycheck-mode t)))
(add-to-list 'auto-mode-alist '("\\.rake$" . ruby-mode))
(add-to-list 'auto-mode-alist '("Rakefile$" . ruby-mode))
(add-to-list 'auto-mode-alist '("\\.gemspec$" . ruby-mode))
(add-to-list 'auto-mode-alist '("\\.ru$" . ruby-mode))
(add-to-list 'auto-mode-alist '("Gemfile$" . ruby-mode))


;; rspec-mode
(require 'rspec-mode)

(require 'web-mode)
(add-to-list 'auto-mode-alist '("\\.erb\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.html\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.css\\'" . web-mode))

(defun my-web-mode-hook ()
  "Hooks for Web mode."
  (setq web-mode-markup-indent-offset 2)
  (setq web-mode-enable-auto-closing t)
  (setq web-mode-enable-auto-pairing t)
)
(add-hook 'web-mode-hook  'my-web-mode-hook)

;; expand-region
(require 'expand-region)
(global-set-key (kbd "C-]") 'er/expand-region)

;; projectile
(projectile-global-mode)

;; robe-mode
(add-hook 'ruby-mode-hook 'robe-mode)
(add-hook 'robe-mode-hook 'ac-robe-setup)

;; rvm
(require 'rvm)
(rvm-use-default)

;; Set defcustom settings
(custom-set-variables '(ledger-highlight-xact-under-point t))

;; flx-ido
(require 'flx-ido)
(ido-mode 1)
(ido-everywhere 1)
(flx-ido-mode 1)

;; ace-jump-mode
(require 'ace-jump-mode)
(define-key global-map (kbd "C-c C-j") 'ace-jump-mode)

;; disable ido faces to see flx highlights.
(setq ido-enable-flex-matching t)
(setq ido-use-faces nil)

;; Setup ansi-color
(require 'ansi-color)
;; The hook to have rake spec output colorized was hard to find
;; don't delete!
;; http://stackoverflow.com/a/20788623
(ignore-errors
  (require 'ansi-color)
  (defun my-colorize-compilation-buffer ()
    (when (eq major-mode 'compilation-mode)
      (toggle-read-only)
      (ansi-color-apply-on-region (point-min) (point-max))
      (toggle-read-only)))
  (add-hook 'compilation-filter-hook 'my-colorize-compilation-buffer))

;; smooth-scrolling
(require 'smooth-scrolling)

;; smartparens
(require 'smartparens-config)
(smartparens-global-mode t)
(show-smartparens-global-mode t)

;; ledger-mode
(add-to-list 'auto-mode-alist '("\\.ledger\\'" . ledger-mode))

;; nodejs-repl
(require 'nodejs-repl)
(put 'erase-buffer 'disabled nil)
