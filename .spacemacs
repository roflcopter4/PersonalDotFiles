                                        ; -*- mode: emacs-lisp -*-
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
   ;;455354 Paths must have a trailing slash (i.e. `~/.mycontribs/')
   dotspacemacs-configuration-layer-path '()


   ;; --------------------------------------------------------------------------
   ;; --------------------------------------------------------------------------


   ;; List of configuration layers to load.
   dotspacemacs-configuration-layers
   '(
     ;;coq
     ;;ocaml
     auto-completion
     better-defaults
     bibtex
     c-c++
     csharp
     emacs-lisp
     git
     github
     go
     haskell
     helm
     html
     javascript
     latex
     markdown
     org
     python
     racket
     ranger
     shell
     shell-scripts
     syntax-checking
     ;; themes-megapack
     version-control
     vimscript
     windows-scripts
     yaml

     ;; ivy
     rust
     cscope
     gtags
     colors

     (shell :variables
            shell-default-height 30
            shell-default-position 'bottom)

     ;; (shell :variables
     ;;        shell-default-height 30
     ;; 	    mom shell-default-position 'bottom)
     ;;spell-checking
     )


   ;; List of additional packages that will be installed without being
   ;; wrap; (;;###autoloadped in a layer. If you need some configuration for these
   ;; packages, then cons;;;###autoloadider creating a layer. You can also put the
   ;; configuration in `dotspacemacs/user-config'.
   dotspacemacs-additional-packages
   '(
     ;;Some-Things
     (myMolokai-theme
      :location (recipe :fetcher github
                        :repo "roflcopter4/YetAnotherEmacsMolokaiTheme"))

     (tabbar-mode
      :location (recipe :fetcher github
                        :repo "dholm/tabbar"))

     ;; (highlight-quoted-vars
     ;;  :location (recipe :fetcher github-browse-commit
     ;;                    :repo "czipperz/highlight-quoted-vars.el"))
     dtrt-indent
     ninja-mode
     highlight-escape-sequences
     sage-shell-mode
     darkokai-theme
     )


   ;; --------------------------------------------------------------------------
   ;; A list of packages that cannot be updated.
   dotspacemacs-frozen-packages '()

   ;; --------------------------------------------------------------------------
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

;; ==============================================================================
;; ==============================================================================


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
   dotspacemacs-check-for-update t

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
   dotspacemacs-editing-style 'vim

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
   dotspacemacs-startup-lists '((recents . 5)
                                (projects . 7))

   ;; True if the home buffer should respond to resize events.
   dotspacemacs-startup-buffer-responsive t

   ;; Default major mode of the scratch buffer (default `text-mode')
   dotspacemacs-scratch-mode 'text-mode

   ;; List of themes, the first of the list is loaded when spacemacs starts.
   ;; Press <SPC> T n to cycle to the next theme in the list (works great
   ;; with 2 themes variants, one dark and one light)
   dotspacemacs-themes '(
                         myMolokai
                         molokai
                         darkokai
                         deeper-blue
                         spacemacs-dark
                         spacemacs-light
                         midnight
                         classic
                         cobalt
                         )
   
   ;; If non nil the cursor color matches the state color in GUI Emacs.
   dotspacemacs-colorize-cursor-according-to-state t

   ;; Default font, or prioritized list of fonts. `powerline-scale' allows to
   ;; quickly tweak the mode-line size to make separators look not too crappy.
   dotspacemacs-default-font '("DinaPowerline"
                               :size 10
                               :weight normal
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
   dotspacemacs-remap-Y-to-y$ t

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
   dotspacemacs-fullscreen-at-startup nil

   ;; If non nil `spacemacs/toggle-fullscreen' will not use native fullscreen.
   ;; Use to disable fullscreen animations in OSX. (default nil)
   dotspacemacs-fullscreen-use-non-native nil

   ;; If non nil the frame is maximized when Emacs starts up.
   ;; Takes effect only if `dotspacemacs-fullscreen-at-startup' is nil.
   ;; (default nil) (Emacs 24.4+ only)
   dotspacemacs-maximized-at-startup nil

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
   dotspacemacs-line-numbers t

   ;; Code folding method. Possible values are `evil' and `origami'.
   ;; (default 'evil)
   dotspacemacs-folding-method 'evil

   ;; If non-nil smartparens-strict-mode will be enabled in programming modes.
   ;; (default nil)
   dotspacemacs-smartparens-strict-mode nil

   ;; If non-nil pressing the closing parenthesis `)' key in insert mode passes
   ;; over any automatically added closing parenthesis, bracket, quote, etc…
   ;; This can be temporary disabled by pressing `C-q' before `)'. (default nil)
   dotspacemacs-smart-closing-parenthesis 1

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
   ;; `trailing' to delete only the whitespace at end of lines, `changed'to
   ;; delete only whitespace for changed lines or `nil' to disable cleanup.
   ;; (default nil)
   dotspacemacs-whitespace-cleanup nil

   ))


;; ==============================================================================================================================
;; ==============================================================================================================================
;; ==============================================================================================================================


(defun dotspacemacs/user-init ()
  "Initialization function for user code.
   It is called immediately after `dotspacemacs/init', before layer configuration executes.
   This function is mostly useful for variables that need to be set before packages are loaded.
   If you are unsure, you should try in setting them in `dotspacemacs/user-config' first."

  ;; ---------------------------------------------------------------
  ;; HIGHLIGHTING VARIABLES IN SHELL SCRIPTS
  (defun sh-script-extra-font-lock-match-var-in-double-quoted-string (limit)
    "Search for variables in double-quoted strings."
    (let (res)
      (while
          (and (setq res (progn (if (eq (get-byte) ?$) (backward-char))
                                (re-search-forward
                                 "[^\\]\\$\\({#?\\)?\\([[:alpha:]_][[:alnum:]_]*\\|[-#?@!]\\|[[:digit:]]+\\)"
                                 limit t)))
               (not (eq (nth 3 (syntax-ppss)) ?\")))) res))

  (defvar sh-script-extra-font-lock-keywords
    '((sh-script-extra-font-lock-match-var-in-double-quoted-string
       (2 font-lock-variable-name-face prepend))))

  (defun sh-script-extra-font-lock-activate ()
    (interactive)
    (font-lock-add-keywords nil sh-script-extra-font-lock-keywords)
    (if (fboundp 'font-lock-flush)
        (font-lock-flush)
      (when font-lock-mode (with-no-warnings (font-lock-fontify-buffer)))))

  (add-hook 'sh-mode-hook     'sh-script-extra-font-lock-activate)
  (add-hook 'perl-mode-hook   'sh-script-extra-font-lock-activate)
  (add-hook 'python-mode-hook 'sh-script-extra-font-lock-activate)

  ;; ---------------------------------------------------------------
  ;; HIGHLIGHTING FOR PRINTF FORMATS IN C
  (defface my-backslash-escape-backslash-face
    '((t :inherit font-lock-regexp-grouping-backslash))
    "Face for the back-slash component of a back-slash escape."
    :group 'font-lock-faces)

  (defface my-backslash-escape-char-face
    '((t :inherit font-lock-regexp-grouping-construct))
    "Face for the charcter component of a back-slash escape."
    :group 'font-lock-faces)

  (defface my-format-code-format-face
    '((t :inherit font-lock-regexp-grouping-backslash))
    "Face for the % component of a printf format code."
    :group 'font-lock-faces)

  (defface my-format-code-directive-face
    '((t :inherit font-lock-regexp-grouping-construct))
    "Face for the directive component of a printf format code."
    :group 'font-lock-faces)

  (font-lock-add-keywords 'c-mode
                          '(("\\(\\\\\\)." 1 'my-backslash-escape-backslash-face prepend)
                            ("\\\\\\(.\\)" 1 'my-backslash-escape-char-face      prepend)
                            ("\\(%\\)\\(\\(\\([-0 #\\+]\\)?\\([0-9]+\\|\\*\\)?\\(\\.\\*\\|\\.[0-9]+\\)?\\([hljztL]\\|l\\{2\\}\\|h\\{2\\}\\)?\\([diuoxXfFeEgGaAcspn]\\)\\)\\|%\\)"
                             (1 'my-format-code-format-face         prepend)
                             (2 'my-format-code-directive-face      prepend))))


  ;; ---------------------------------------------------------------
  ;; HIGHLIGHTING #if (0) AS A COMMENT IN C
  (defun my-c-mode-font-lock-if0 (limit)
    (save-restriction
      (widen)
      (save-excursion
	(goto-char (point-min))
	(let ((depth 0) str start start-depth)
	  (while (re-search-forward "^\\s-*#\\s-*\\(if\\|else\\|endif\\)" limit 'move)
	    (setq str (match-string 1))
	    (if (string= str "if")
		(progn
		  (setq depth (1+ depth))
		  (when (and (null start) (looking-at "\\s-+0"))
		    (setq start (match-end 0)
			  start-depth depth)))
	      (when (and start (= depth start-depth))
		(c-put-font-lock-face start (match-beginning 0) 'font-lock-comment-face)
		(setq start nil))
	      (when (string= str "endif")
		(setq depth (1- depth)))))
	  (when (and start (> depth 0))
	    (c-put-font-lock-face start (point) 'font-lock-comment-face)))))
    nil)

  (defun my-c-mode-common-hook ()
    (font-lock-add-keywords
     nil
     '((my-c-mode-font-lock-if0 (0 font-lock-comment-face prepend))) 'add-to-end))

  (add-hook 'c-mode-common-hook 'my-c-mode-common-hook)

  )


;; ==============================================================================================================================
;; ==============================================================================================================================
;; ==============================================================================================================================
;; ==============================================================================================================================


(defun dotspacemacs/user-config ()
  "Configuration function for user code.
   This function is called at the very end of Spacemacs initialization after layers configuration.
   This is the place where most of your configurations should be done. Unless it
   is explicitly specified that a variable should be set before a package is loaded,
   you should place your code here."

  ;; (hes-mode t)

  (global-hl-line-mode -1) ; Disable current line highlight
  ;; (global-linum-mode) ; Show line numbers by default
  (global-aggressive-indent-mode t)
  (global-auto-complete-mode t)
  ;; (global-flycheck-mode)
  (indent-guide-global-mode t)
  (setq-default indent-tabs-mode t)
  (setq-default tab-width 8)

  ;; ================================================================================
  ;; C/C++ style
  (setq c-default-style "K&R"
	c-basic-offset 8)
  ;; Clang support (clang-format & clang-complete snippets)
  (setq c-c++-enable-clang-support t)
  ;; Flycheck and clang arugments for syntax checking in C/C++
  (add-hook
   'c++-mode-hook
   (lambda ()
     (setq flycheck-clang-language-standard "c++11")
     (setq company-clang-arguments '("-Weverything"))
     (setq company-c-headers-path-user '("../include" "./include" "." "../../include" "../inc" "../../inc" "inc"))
     (setq flycheck-clang-include-path '("../include" "./include" "." "../../include" "../inc" "../../inc" "inc"))))
  (add-hook
   'c-mode-hook
   (lambda ()
     (setq flycheck-clang-language-standard "gnu99")
     (setq company-clang-arguments '("-Weverything"))
     (setq company-c-headers-path-user '("../include" "./include" "." "../../include" "../inc" "../../inc"))
     (setq flycheck-clang-include-path '("../include" "./include" "." "../../include" "../inc" "../../inc"))))

  ;; Powerline separator config
  (setq powerline-default-separator 'arrow)
  ;; Scroll compilation output to first error
  (setq compilation-scroll-output t)
  (setq compilation-scroll-output #'first-error)
  ;; TODO highlighting
  ;; (defun highlight-todos ()
  ;;   (font-lock-add-keywords nil '(("\\<\\(NOTE\\|TODO\\|HACK\\|BUG\\):" 1 font-lock-warning-face t))))
  ;; (add-hook 'prog-mode-hook #'highlight-todos)
  ;; Autocomplete docstring tooltips
  (setq auto-completion-enable-help-tooltip t)
  (setq syntax-checking-enable-tooltips t)
  ;; Global basic auto complete
  (global-company-mode)
  ;; Guess indentation
  (dtrt-indent-mode)
  ;; Stop dtrt-indent from cluttering modeline, this might not be the best way
  ;; to do this but it works
  (add-hook 'buffer-list-update-hook (lambda () (setq dtrt-indent-mode-line-info nil)))
  ;; I don't use bidi fonts so turning them off might improve render times
  (setq bidi-display-reordering nil)
  ;; Faster scrolling with C-e/C-y
  (setq-default evil-scroll-line-count 3)
  ;; Keep tooltip from closing when hovering over flycheck error
  (setq flycheck-pos-tip-timeout 1000)
  ;; Make the compilation window close automatically if no errors
  (setq compilation-finish-functions
        (lambda (buf str)
          (if (null (string-match ".*exited abnormally.*" str))
              (progn
                (run-at-time
                 "1 sec" nil 'delete-windows-on
                 (get-buffer-create "*compilation*"))
                (message "No Compilation Errors")))))


  ;; ==============================================================================================================================
  ;; ==============================================================================================================================
  ;; Clang-format style
  ;; (setq clang-format-style "{BasedOnStyle: LLVM,
  ;;                            AlignEscapedNewlinesLeft: true,
  ;;                            AlignTrailingComments: true,
  ;;                            AllowAllParametersOfDeclarationOnNextLine: true,
  ;;                            AllowShortBlocksOnASingleLine: false,
  ;;                            AllowShortFunctionsOnASingleLine: None,
  ;;                            AllowShortIfStatementsOnASingleLine: false,
  ;;                            AllowShortLoopsOnASingleLine: false,
  ;;                            AlwaysBreakTemplateDeclarations: true,

  ;;                            BreakBeforeBraces: Linux,
  ;;                            IndentWidth: 8,
  ;;                            ColumnLimit: 0,
  ;; 	                     TabWidth: 8,
  ;;                            UseTab: Never,
  ;;                            IndentCaseLabels: false,

  ;;                            MaxEmptyLinesToKeep: 2,
  ;;                            SpaceBeforeAssignmentOperators: true,
  ;;                            SpaceBeforeParens: ControlStatements,
  ;;                            Standard: Auto}"
  ;; 	)
  ;; (setq clang-format-style "{BasedOnStyle: LLVM, AlignEscapedNewlinesLeft: true, AlignTrailingComments: true, AllowAllParametersOfDeclarationOnNextLine: true, AllowShortBlocksOnASingleLine: false, AllowShortFunctionsOnASingleLine: None, AllowShortIfStatementsOnASingleLine: false, AllowShortLoopsOnASingleLine: false, AlwaysBreakTemplateDeclarations: true, BreakBeforeBraces: Linux, IndentWidth: 8, ColumnLimit: 100, TabWidth: 8, UseTab: Never, IndentCaseLabels: false, MaxEmptyLinesToKeep: 2, SpaceBeforeAssignmentOperators: true, SpaceBeforeParens: ControlStatements, Standard: Auto}")
  )


;; ==============================================================================================================================
;; ==============================================================================================================================
;; ==============================================================================================================================
;; ==============================================================================================================================

;; Do not write anything past this comment. This is where Emacs will
;; auto-generate custom variable definitions.
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(ansi-color-names-vector
   ["#0a0814" "#f2241f" "#67b11d" "#b1951d" "#4f97d7" "#a31db1" "#28def0" "#b2b2b2"])
 '(custom-safe-themes
   (quote
    ("b8c7784696f81b35598135171705c0d955216178bf9590d3e0231d969af7c71e" default)))
 '(evil-want-Y-yank-to-eol t)
 '(package-selected-packages
   (quote
    (company-quickhelp tabbar-mode zenburn-theme zen-and-art-theme white-sand-theme wgrep underwater-theme ujelly-theme twilight-theme twilight-bright-theme twilight-anti-bright-theme toxi-theme toml-mode tao-theme tangotango-theme tango-plus-theme tango-2-theme sunny-day-theme sublime-themes subatomic256-theme subatomic-theme spacegray-theme soothe-theme solarized-theme soft-stone-theme soft-morning-theme soft-charcoal-theme smyx-theme smex seti-theme reverse-theme rebecca-theme rainbow-mode rainbow-identifiers railscasts-theme racer purple-haze-theme professional-theme planet-theme phoenix-dark-pink-theme phoenix-dark-mono-theme organic-green-theme omtose-phellack-theme oldlace-theme occidental-theme obsidian-theme noctilux-theme naquadah-theme mustang-theme monochrome-theme moe-theme minimal-theme material-theme majapahit-theme madhat2r-theme lush-theme light-soap-theme jbeans-theme jazz-theme ivy-hydra ir-black-theme inkpot-theme heroku-theme hemisu-theme helm-gtags helm-cscope xcscope hc-zenburn-theme gruvbox-theme gruber-darker-theme grandshell-theme gotham-theme ggtags gandalf-theme flycheck-rust flatui-theme flatland-theme farmhouse-theme exotica-theme espresso-theme dracula-theme django-theme darktooth-theme autothemer darkmine-theme darkburn-theme dakrone-theme cyberpunk-theme counsel-projectile counsel swiper color-theme-sanityinc-tomorrow color-theme-sanityinc-solarized color-identifiers-mode clues-theme cherry-blossom-theme cargo rust-mode busybee-theme bubbleberry-theme birds-of-paradise-plus-theme badwolf-theme apropospriate-theme anti-zenburn-theme ample-zen-theme ample-theme alect-themes afternoon-theme org-mime ghub sage-shell-mode deferred let-alist highlight-escape-sequences go-guru go-eldoc company-go go-mode auctex-latexmk ninja-mode myMolokai-theme-theme dtrt-indent yaml-mode web-mode web-beautify utop tuareg caml tagedit slim-mode scss-mode sass-mode ranger racket-mode faceup pug-mode org-ref pdf-tools key-chord ivy tablist ocp-indent merlin magit-gh-pulls livid-mode skewer-mode simple-httpd less-css-mode json-mode json-snatcher json-reformat js2-refactor multiple-cursors js2-mode js-doc intero hlint-refactor hindent helm-hoogle helm-css-scss helm-bibtex parsebib haskell-snippets haml-mode github-search github-clone github-browse-file gist gh marshal logito pcache ht flycheck-haskell emmet-mode disaster company-web web-completion-data company-tern tern company-ghci company-ghc ghc haskell-mode company-cabal company-c-headers company-auctex coffee-mode cmm-mode cmake-mode clang-format biblio biblio-core auctex myMolokai-theme YetAnotherEmacsMolokaiTheme molokai-2-theme dash-functional powershell shut-up csharp-mode omnisharp deeper_blue-theme org-pdfview insert-shebang fish-mode company-shell monokai-alt-theme monokai-theme darkokai-theme color-theme-approximate airline-themes vimrc-mode dactyl-mode commify xterm-color unfill smeargle shell-pop orgit org-projectile org-category-capture org-present org-pomodoro alert log4e gntp org-download mwim multi-term mmm-mode markdown-toc markdown-mode magit-gitflow htmlize helm-gitignore helm-company helm-c-yasnippet gnuplot gitignore-mode gitconfig-mode gitattributes-mode git-timemachine git-messenger git-link git-gutter-fringe+ git-gutter-fringe fringe-helper git-gutter+ git-gutter gh-md fuzzy flyspell-correct-helm flyspell-correct flycheck-pos-tip pos-tip flycheck evil-magit magit magit-popup git-commit with-editor eshell-z eshell-prompt-extras esh-help diff-hl company-statistics company-anaconda company auto-yasnippet yasnippet auto-dictionary ac-ispell auto-complete molokai-theme yapfify pyvenv pytest pyenv-mode py-isort pip-requirements live-py-mode hy-mode helm-pydoc cython-mode anaconda-mode pythonic ws-butler winum which-key volatile-highlights vi-tilde-fringe uuidgen use-package toc-org spaceline powerline restart-emacs request rainbow-delimiters popwin persp-mode pcre2el paradox spinner org-plus-contrib org-bullets open-junk-file neotree move-text macrostep lorem-ipsum linum-relative link-hint info+ indent-guide hydra hungry-delete hl-todo highlight-parentheses highlight-numbers parent-mode highlight-indentation hide-comnt help-fns+ helm-themes helm-swoop helm-projectile helm-mode-manager helm-make projectile pkg-info epl helm-flx helm-descbinds helm-ag google-translate golden-ratio flx-ido flx fill-column-indicator fancy-battery eyebrowse expand-region exec-path-from-shell evil-visualstar evil-visual-mark-mode evil-unimpaired evil-tutor evil-surround evil-search-highlight-persist evil-numbers evil-nerd-commenter evil-mc evil-matchit evil-lisp-state smartparens evil-indent-plus evil-iedit-state iedit evil-exchange evil-escape evil-ediff evil-args evil-anzu anzu evil goto-chg undo-tree eval-sexp-fu highlight elisp-slime-nav dumb-jump f s diminish define-word column-enforce-mode clean-aindent-mode bind-map bind-key auto-highlight-symbol auto-compile packed dash aggressive-indent adaptive-wrap ace-window ace-link ace-jump-helm-line helm avy helm-core popup async))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
