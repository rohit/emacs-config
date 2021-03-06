;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Emacs config of Rohit Arondekar. Under heave adaptation ;;
;; and change. Don't look!                                 ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Temporarily ignore emacs.d in load path warning
(defadvice display-warning
    (around no-warn-.emacs.d-in-load-path (type message &rest unused) activate)
  "Ignore the warning about the `.emacs.d' directory being in `load-path'."
  (unless (and (eq type 'initialization)
               (string-prefix-p "Your `load-path' seems to contain\nyour `.emacs.d' directory"
                                message t))
    ad-do-it))

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
    ruby-mode
    go-mode
    yaml-mode
    robe
    rspec-mode
    yasnippet
    flx-ido
    clojure-mode
    elixir-mode
    company
    alchemist
    coffee-mode
    haml-mode
    sass-mode
    handlebars-mode
    markdown-mode
    nodejs-repl
    js2-mode
    json-mode
    tern
    tern-auto-complete
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
    color-theme-solarized
    paredit
    clojure-mode-extra-font-locking
    cider
    smex
    tagedit
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
(set-face-background 'hl-line "#555555")
(set-face-underline 'hl-line nil)

;; Use zenburn theme
(load-theme 'zenburn t)
(set-face-attribute 'region nil :background "#222222")

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
(add-to-list 'ac-dictionary-directories "~/.emacs.d/elpa/auto-complete-20150225.715/dict/")
(ac-config-default)
(setq ac-quick-help-delay 1)
(setq-default ac-dwim nil) ; To get pop-ups with docs even if a word is uniquely completed

;; cucumber mode
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

;; YASnippet
(add-to-list 'load-path
              "~/.emacs.d/yasnippet")
(require 'yasnippet)
(yas/global-mode 1)

(require 'flycheck)
(add-hook 'js-mode-hook
          (lambda () (flycheck-mode t)))
(add-hook 'js2-mode-hook flycheck-mode)
;; (set-face-attribute 'flycheck-error nil :background "DarkRed" :underline nil)
;; (set-face-attribute 'flycheck-warning nil :background "orange4" :underline nil)
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

;; Web Mode
(require 'web-mode)
(add-to-list 'auto-mode-alist '("\\.erb\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.html\\'" . web-mode))

;; CSS property completion not working with latest web mode and auto complete
;; Using CSS mode for time being
(eval-after-load 'auto-complete
  (dolist (hook '(css-mode-hook sass-mode-hook))
    (add-hook hook 'ac-css-mode-setup)))

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

;; js2-mode
(add-to-list 'auto-mode-alist '("\\.js\\'" . js2-mode))

;; tern mode
(add-hook `js2-mode-hook (lambda () (tern-mode t)))
(eval-after-load `tern
  `(progn
     (require `tern-auto-complete)
     (tern-ac-setup)))

;; yaml mode
(require 'yaml-mode)

;; ruby mode from melpa
(require 'ruby-mode)

;; json mode
(require 'json-mode)

;; Elixir
(add-hook 'elixir-mode-hook (lambda () (company-mode t)))
(add-hook 'elixir-mode-hook (lambda () (alchemist-mode t)))

;; Go
(require `go-mode)

;; Turn on recent file mode so that you can more easily switch to
;; recently edited files when you first start emacs
(setq recentf-save-file (concat user-emacs-directory ".recentf"))
(require 'recentf)
(recentf-mode 1)
(setq recentf-max-menu-items 40)

;; Enhances M-x to allow easier execution of commands. Provides
;; a filterable list of possible commands in the minibuffer
;; http://www.emacswiki.org/emacs/Smex
(setq smex-save-file (concat user-emacs-directory ".smex-items"))
(smex-initialize)
(global-set-key (kbd "M-x") 'smex)

;; Clojure
;; Enable paredit for Clojure
(add-hook 'clojure-mode-hook 'enable-paredit-mode)

;; This is useful for working with camel-case tokens, like names of
;; Java classes (e.g. JavaClassName)
(add-hook 'clojure-mode-hook 'subword-mode)

;; A little more syntax highlighting
(require 'clojure-mode-extra-font-locking)

;; syntax hilighting for midje
(add-hook 'clojure-mode-hook
          (lambda ()
            (setq inferior-lisp-program "lein repl")
            (font-lock-add-keywords
             nil
             '(("(\\(facts?\\)"
                (1 font-lock-keyword-face))
               ("(\\(background?\\)"
                (1 font-lock-keyword-face))))
            (define-clojure-indent (fact 1))
            (define-clojure-indent (facts 1))))

;; Cider
;; provides minibuffer documentation for the code you're typing into the repl
(add-hook 'cider-mode-hook 'cider-turn-on-eldoc-mode)

;; go right to the REPL buffer when it's finished connecting
(setq cider-repl-pop-to-buffer-on-connect t)

;; When there's a cider error, show its buffer and switch to it
(setq cider-show-error-buffer t)
(setq cider-auto-select-error-buffer t)

;; Where to store the cider history.
(setq cider-repl-history-file "~/.emacs.d/cider-history")

;; Wrap when navigating history.
(setq cider-repl-wrap-history t)

;; enable paredit in your REPL
(add-hook 'cider-repl-mode-hook 'paredit-mode)

;; Use clojure mode for other extensions
(add-to-list 'auto-mode-alist '("\\.edn$" . clojure-mode))
(add-to-list 'auto-mode-alist '("\\.boot$" . clojure-mode))
(add-to-list 'auto-mode-alist '("\\.cljs.*$" . clojure-mode))
(add-to-list 'auto-mode-alist '("lein-env" . enh-ruby-mode))


;; key bindings
;; these help me out with the way I usually develop web apps
(defun cider-start-http-server ()
  (interactive)
  (cider-load-current-buffer)
  (let ((ns (cider-current-ns)))
    (cider-repl-set-ns ns)
    (cider-interactive-eval (format "(println '(def server (%s/start))) (println 'server)" ns))
    (cider-interactive-eval (format "(def server (%s/start)) (println server)" ns))))


(defun cider-refresh ()
  (interactive)
  (cider-interactive-eval (format "(user/reset)")))

(defun cider-user-ns ()
  (interactive)
  (cider-repl-set-ns "user"))

(eval-after-load 'cider
  '(progn
     (define-key clojure-mode-map (kbd "C-c C-v") 'cider-start-http-server)
     (define-key clojure-mode-map (kbd "C-M-r") 'cider-refresh)
     (define-key clojure-mode-map (kbd "C-c u") 'cider-user-ns)
     (define-key cider-mode-map (kbd "C-c u") 'cider-user-ns)))


;; No cursor blinking, it's distracting
(blink-cursor-mode 0)
