(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(column-number-mode t)
 '(custom-enabled-themes '(modus-vivendi))
 '(exec-path
   '("c:\\LOGICIELS\\Git\\usr\\bin" "c:/Program Files/Volta/" "C:/Program Files (x86)/Common Files/Oracle/Java/javapath" "C:/windows/system32" "C:/windows" "C:/windows/System32/Wbem" "C:/windows/System32/WindowsPowerShell/v1.0/" "C:/windows/System32/OpenSSH/" "C:/CAT_EXPLOITATION/CATLIB/lib" "C:/Program Files (x86)/Plantronics/Spokes3G/" "C:/Logiciels/Git/cmd" "C:/LOGICIELS/Rational/common" "C:/LOGICIELS/Rumba/" "C:/LOGICIELS/Rumba/System" "C:/Program Files (x86)/Microsoft SQL Server/Client SDK/ODBC/130/Tools/Binn/" "C:/Program Files (x86)/Microsoft SQL Server/140/Tools/Binn/" "C:/Program Files (x86)/Microsoft SQL Server/140/DTS/Binn/" "C:/Program Files (x86)/Microsoft SQL Server/140/Tools/Binn/ManagementStudio/" "C:/PROGRA~2/IBM/SQLLIB/BIN" "C:/PROGRA~2/IBM/SQLLIB/FUNCTION" "C:/PROGRA~2/IBM/SQLLIB/SAMPLES/REPL" "C:/LOGICIELS/VSCode/bin" "C:/Users/etpd254/AppData/Local/Microsoft/WindowsApps" "." "C:/Users/etpd254/AppData/Local/Volta/tools/image/node/%VOLTA_NODE_VERSION%" "c:/tools/emacs-28.1/libexec/emacs/28.1/x86_64-w64-mingw32"))
 '(find-program "c:/LOGICIELS/Git/usr/bin/find.exe" t)
 '(global-display-line-numbers-mode t)
 '(grep-program "c:/LOGICIELS/Git/usr/bin/grep.exe" t)
 '(ido-create-new-buffer 'always)
 '(ido-everywhere t)
 '(ido-use-faces t)
 '(ido-use-filename-at-point 'guess)
 '(inhibit-startup-screen t)
 '(package-selected-packages '(rainbow-delimiters)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(default ((t (:family "Consolas" :foundry "outline" :slant normal :weight normal :height 108 :width normal))))
 '(ido-first-match ((t (:underline (:color foreground-color :style wave) :foreground "spring green" :background "dark slate gray" :inherit bold))))
 '(mode-line ((t (:background "dark slate blue" :foreground "lemon chiffon" :box (:line-width (1 . 1) :color "cornflower blue") :overline nil :underline nil)))))
;; Setup load-path, autoloads and your lisp system
;; Not needed if you install SLIME via MELPA
(add-to-list 'load-path "~/emacs-packages-repos/slime-master")
(require 'slime-autoloads)
(setq inferior-lisp-program "C:/tools/ccl/ccl/wx86cl64")

;; utiliser git-bash pour grep et find
(setenv "PATH"
	(concat
	 "c:/LOGICIELS/Git/usr/bin;"
	 (getenv "PATH")))

;; backups : ne pas faire les backups dans le repertoire copurrant
(setq backup-directory-alist '(("." . "~/.config/emacs/backups")))
(setq delete-old-versions -1)
(setq version-control t)
(setq vc-make-backup-files t)
(setq auto-save-file-name-transforms '((".*" "~/.config/emacs/auto-save-list/" t)))

;; history
(setq savehist-file "~/.config/emacs/savehist")
(savehist-mode 1)
(setq history-length t)
(setq history-delete-duplicates t)
(setq savehist-save-minibuffer-history 1)
(setq savehist-additional-variables
      '(kill-ring
        search-ring
        regexp-search-ring))

;; heure dans la mode-line
(display-time-mode t)

;; remplacer 
(fset 'yes-or-no-p 'y-or-n-p)

(require 'recentf)
(setq recentf-max-saved-items 200
      recentf-max-menu-items 15)
(recentf-mode)

;; rainbow-delimiters:
(add-hook 'prog-mode-hook #'rainbow-delimiters-mode)

;; configuration god-mode ( https://github.com/emacsorphanage/god-mode )
;;(message "Le chargement de god-mode ne fonctionne pas ? %s " load-path)
(add-to-list 'load-path "~/emacs-package-repos/god-mode")
(load "~/emacs-packages-repos/god-mode/god-mode.el")

;; ESC pour entrer / sortie du god-mode
(global-set-key (kbd "<escape>") #'god-local-mode)

;; visual indicator
;; cursor
(defun my-god-mode-update-cursor-type ()
  (setq cursor-type (if (or god-local-mode buffer-read-only) 'box 'hollow)))

(add-hook 'post-command-hook #'my-god-mode-update-cursor-type)

(defun my-god-mode-update-mode-line ()
  (cond
   (god-local-mode
    (set-face-attribute 'mode-line nil
                        :foreground "#604000"
                        :background "#fff29a")
    (set-face-attribute 'mode-line-inactive nil
                        :foreground "#3f3000"
                        :background "#fff3da"))
   (t
    (set-face-attribute 'mode-line nil
			:foreground "#0a0a0a"
			:background "slate blue")
    (set-face-attribute 'mode-line-inactive nil
			:background "dark slate blue"
			:foreground "lemon chiffon"
					;:foreground "#404148"
					;:background "#efefef"
			))))

(add-hook 'post-command-hook 'my-god-mode-update-mode-line)



;;(global-hl-line-mode nil)
;;(set-face-background 'hl-line "009999")
;;(set-face-foreground 'highlight nil)

(add-hook 'prog-mode-hook 'display-line-numbers-mode)

;; rebinds
;; ==<f5>== -> occurs 
(global-set-key (kbd "<f5>") 'list-matching-lines) 
(put 'upcase-region 'disabled nil)



;; prérequis pour Helm : emacs-async et popup

(add-to-list 'load-path "~/emacs-packages-repos/emacs-async-master")
(load "~/emacs-packages-repos/emacs-async-master/async.el")
(load "~/emacs-packages-repos/emacs-async-master/dired-async.el")
(dired-async-mode 1)

(add-to-list 'load-path "~/emacs-packages-repos/popup")
(load "~/emacs-packages-repos/popup/popup.el")

;; FIXEME : pour helm il faut pouvoir executer le make
;;  le make doit générer helm-autoloads.el mais on n'a pas helm au CA-TS :/ ....

;;(add-to-list 'load-path "~/emacs-packages-repos/helm-3.8.6")
;;(require 'helm)
;;(require 'helm-config)


;; activation de ido
(require 'ido)
(ido-mode t)

;; which-key
(add-to-list 'load-path "~/emacs-packages-repos/which-key")
(require 'which-key)
(setq which-key-idle-delay 0.25 ;; Default is 1.0
      which-key-idle-secondary-delay 0.05) ;; Default is nil
(which-key-mode)

;;; Install paredit by placing `paredit.el' in `/path/to/elisp', a
;;; directory of your choice, and adding to your .emacs file:
;;;
(add-to-list 'load-path "~/emacs-packages-repos/paredit")
   (autoload 'enable-paredit-mode "paredit"
     "Turn on pseudo-structural editing of Lisp code."
     t)

(add-hook 'emacs-lisp-mode-hook       #'enable-paredit-mode)
(add-hook 'eval-expression-minibuffer-setup-hook #'enable-paredit-mode)
(add-hook 'ielm-mode-hook             #'enable-paredit-mode)
(add-hook 'lisp-mode-hook             #'enable-paredit-mode)
(add-hook 'lisp-interaction-mode-hook #'enable-paredit-mode)
(add-hook 'scheme-mode-hook           #'enable-paredit-mode)
          ;; Stop SLIME's REPL from grabbing DEL,
          ;; which is annoying when backspacing over a '('
(defun override-slime-repl-bindings-with-paredit ()
  (define-key slime-repl-mode-map    
    (read-kbd-macro paredit-backward-delete-key) nil))
(add-hook 'slime-repl-mode-hook 'override-slime-repl-bindings-with-paredit)

;; electric return ( from https://www.emacswiki.org/emacs/ParEdit )
  (defvar electrify-return-match
    "[\]}\)\"]"
    "If this regexp matches the text after the cursor, do an \"electric\"
  return.")

  (defun electrify-return-if-match (arg)
    "If the text after the cursor matches `electrify-return-match' then
  open and indent an empty line between the cursor and the text.  Move the
  cursor to the new line."
    (interactive "P")
    (let ((case-fold-search nil))
      (if (looking-at electrify-return-match)
      (save-excursion (newline-and-indent)))
      (newline arg)
      (indent-according-to-mode)))
  ;; Using local-set-key in a mode-hook is a better idea.
(global-set-key (kbd "RET") 'electrify-return-if-match)

 ;;; ParEdit, and extreme barfarge and slurpage
 (defun paredit-barf-all-the-way-backward ()
    (interactive)
    (paredit-split-sexp)
    (paredit-backward-down)
    (paredit-splice-sexp))
  (defun paredit-barf-all-the-way-forward ()
    (interactive)
    (paredit-split-sexp)
    (paredit-forward-down)
    (paredit-splice-sexp)
    (if (eolp) (delete-horizontal-space)))
  (defun paredit-slurp-all-the-way-backward ()
    (interactive)
    (catch 'done
      (while (not (bobp))
        (save-excursion
          (paredit-backward-up)
          (if (eq (char-before) ?\()
              (throw 'done t)))
        (paredit-backward-slurp-sexp))))
  (defun paredit-slurp-all-the-way-forward ()
    (interactive)
    (catch 'done
      (while (not (eobp))
        (save-excursion
          (paredit-forward-up)
          (if (eq (char-after) ?\))
              (throw 'done t)))
        (paredit-forward-slurp-sexp))))
;  (nconc paredit-commands
;         '("Extreme Barfage & Slurpage"
;           (("C-M-)")
;                        paredit-slurp-all-the-way-forward
;                        ("(foo (bar |baz) quux zot)"
;                         "(foo (bar |baz quux zot))")
;                        ("(a b ((c| d)) e f)"
;                         "(a b ((c| d)) e f)"))
;           (("C-M-}" "M-F")
;                        paredit-barf-all-the-way-forward
;                        ("(foo (bar |baz quux) zot)"
;                         "(foo (bar|) baz quux zot)"))
;           (("C-M-(")
;                        paredit-slurp-all-the-way-backward
;                        ("(foo bar (baz| quux) zot)"
;                         "((foo bar baz| quux) zot)")
;                        ("(a b ((c| d)) e f)"
;                        "(a b ((c| d)) e f)"))
;           (("C-M-{" "M-B")
;                        paredit-barf-all-the-way-backward
;                        ("(foo (bar baz |quux) zot)"
;                          "(foo bar baz (|quux) zot)"))))
;  (paredit-define-keys)
; (paredit-annotate-mode-with-examples)
;  (paredit-annotate-functions-with-examples)
;; ---------------


;; fonctions perso
(load "~/.emacs.d/tl.el")

; activer 'narrow-to-region' sinon pas disponible depuis <M-x>
(put 'narrow-to-region 'disabled nil)


; charger 'cobol.el' et declencher le cobol-mode sur les fichiers cobol
(load "~/.emacs.d/cobol.el")
(autoload 'cobol-mode "cobol-mode" "Major mode for highlighting COBOL files." t nil)
(setq auto-mode-alist
      (append
       '(("\\.cob\\'" . cobol-mode)
         ("\\.cbl\\'" . cobol-mode)
         ("\\.cpy\\'" . cobol-mode))
       auto-mode-alist))

