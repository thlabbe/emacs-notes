(defvar *re-cbl-ident* "[-A-Za-z0-9]+")

(defun tl/cq/trim-80()
  "Suprime les spaces au dela de la colonne 80" 
  (interactive)
  (save-excursion
    (let ((extra ""))
    (goto-char (point-min))
    (while (re-search-forward "\\(^.\\{80\\}\\)\\(.+\\)" nil t)
      (setq extra (match-string 2))
      (cond ((string= "" (string-trim extra))
	     (progn
	       (let (bol eol)
		 (beginning-of-line)
		 (setq bol (point))
		 (end-of-line)
	         (setq eol (point))
		 (delete-region (+ bol 80) eol)
		 ))))))))

(defun tl/cq/to-at-col-44()
  "Caller les 'TO' en colonne 44.fixme : verifier que rien n'est ecrasé."
  (interactive)
  (save-excursion
    (setq wpos 42)
    (setq ligne (tl/grab-line) ;(string-chop-newline (thing-at-point 'line t)))
    (setq bpos (token-position "TO" ligne))
    (setq nligne ligne)
    (cond ((< bpos wpos) ; decaler vers la droite
	   (setq nligne (concat (substring ligne 0 bpos)
			      (make-string (- wpos bpos) ?\s)
			      (substring ligne bpos (- bpos wpos))))
	  ((> bpos wpos) ; decaler vers la gauche	 
	   (setq nligne (concat
		       (substring ligne 0 wpos) 
		       (substring ligne bpos ) 
		       (make-string (- bpos wpos) ?\s)))))
    (if (not (eq bpos wpos))
	(progn
	  (delete-region (line-beginning-position) (line-end-position))
	  (insert nligne)))))))

(defun tl/grab-line()
    (buffer-substring-no-properties (line-beginning-position) (line-end-position)))

(defun tl/rr (v)
  "pour V de la forme '[(s1 r1) (s2 r2) ... (sn rn)]'
   remplace toutes les occurences de si par ri "
  (interactive)
;  (let ((pfx "YX9K-")) ; gestion du pfx a parametrer 
    (seq-doseq (item v)
      (goto-char 1)
      (setq srchd ;(concat pfx
	    (symbol-name (car item)))
					;)
      (setq rplcmt ;(concat pfx
	    (symbol-name (car (cdr item))))
					;)
      (if (not (equal srchd rplcmt)) ; ne pas faire les remplacements neutres 
	  (progn
;	   (message "srchd '%s' rplcmt '%s'" srchd rplcmt)	   

	   (while (re-search-forward srchd nil t)

	     (let ((line (tl/grab-line)))
;	       (message "avant '%s' " line)
	       (delete-region (line-beginning-position) (line-end-position))

	       (insert  (string-replace srchd rplcmt line))))))))
;)

(defun token-position(token str)
  "renvoie la position de TOKEN dans STR"
  (forward-line 0)
;  (setq bol (point))
  (setq s (concat " " token " "))
  (cl-search s str))

(defun tl/revisit-file-with-encoding-windows-1252 ()
" Re-open currently visited file with the windows-1252 coding."
  (interactive)
  (let ((coding-system-for-read 'windows-1252)
	(coding-system-for-write 'windows-1252)
	(coding-system-require-warning t)
	(current-prefix-arg nil))
    (message "tl/: reopened file with encoding set to windows-1252")
    (find-alternate-file buffer-file-name)))


(defun tla-replace-regexp-entire-buffer (pattern replacement)
  "Replace all in buffer"
  (interactive
   (let ((args (query-replace-read-args "Replace" t)))
	       (setcdr (cdr args) nil)
	       args))
     (save-excursion
       (goto-char (point-min))
       (while (re-search-forward pattern nil t)
	 (replace-match replacement))))


(defun tla-cobol-cleaner()
  "mise en forme d'un cobol pour une analyse plus automatique"
  (interactive)
  (save-excursion
    (tla-replace-regexp-entire-buffer "^\\(.\\{72\\}\\).*" "\\1")
    ; supprimer les annotation au dela de la colonne 72

    (tla-replace-regexp-entire-buffer "^\\(......\\)\\(.*\\)" " \\2")
    ; supprimer les 6 premeières colonnes
    ))

(defun tl/navigate-to-point (buffer pos)
  "positionne le point sur POS dans la fenêtre de BUFFER"
  (set-window-point (get-buffer-window buffer) pos)
  (other-window 1))

(defun tl/cbl-toc()
  "construit une table des matièere pour le cobol du buffer en cours"
  (interactive)
  ;; rechercher les DIVISION
  (let ((pattern-division "^...... .* DIVISION[ \\.]"))
    (save-excursion
      (goto-char (point-min))
      (while (re-search-forward pattern-division nil t)
      
	(message "%d <%s>" (point) (thing-at-point 'line)))
      
      )))



  
(defun tla-clean-cbl->org ()
  "mise en forme d'un clean cbl vers org"
  (interactive)
  (save-excursion
    ;;(tla-replace-regexp-entire-buffer "\\(.* DIVISION.*\\)" "* \\1")
    ;; FIXME : Capture les lignes en commentaire avec "DIVISION"
    (tla-replace-regexp-entire-buffer "^  \\(.* DIVISION.*\\)" "** \\1")
    ;    créer un Org Heading niveau 2 pour chaque DIVISION
    
    (tla-replace-regexp-entire-buffer "\\(.* SECTION.*\\)" "*** \\1")
    ; créer un Heading niveau 2 pour chaque SECTION
    
    (tla-replace-regexp-entire-buffer "^  \\([A-Z0-9-]\\{3,\\}\\)" "**** <<<\\1>>>")
    
    (tla-replace-regexp-entire-buffer "^  \\([0-9][0-9]\\)\\s+\\([a-zA-Z0-9-]+\\)\\." "***** | <<\\2>>> | |")
    
    (tla-replace-regexp-entire-buffer "[ ]+$" "  ")
    ;; supprimer les trailing splaces ( les blancs de fin de ligne ajoute 2 blancs )

    ;; mettre en gras les lignes de commentaires
    (tla-replace-regexp-entire-buffer "^ \\*[ ]*\\(.*\\)$" " /\\1/")

    (tla-replace-regexp-entire-buffer "^ [ ]*\\((IF \\|ELSE \\|END-IF).*\\)$" "****** \\1")
    ))
                            
(defun tla-indent-ifs ()
  "indentation des IF ELSE END-IF"
  (interactive)
  (save-excursion
    (tla-replace-regexp-entire-buffer "^ [ ]+\\(IF .*\\)" "****** \\1")
    (tla-replace-regexp-entire-buffer "^ [ ]+\\(ELSE.*\\)" "****** \\1")
    (tla-replace-regexp-entire-buffer "^ [ ]+\\(END-IF.*\\)" "****** \\1")))

(defun tla-shrink-cbl ()
  (interactive)
  (save-excursion
    (tla-replace-regexp-entire-buffer "      TO " " TO ")
    (tla-replace-regexp-entire-buffer "     TO " " TO ")
    (tla-replace-regexp-entire-buffer "    TO " " TO ")
    (tla-replace-regexp-entire-buffer "   TO " " TO ")
    (tla-replace-regexp-entire-buffer "  TO " " TO ")))


(defun tl/swap-move ()
  (interactive)
  (save-excursion
    (tla-replace-regexp-entire-buffer " MOVE \\([a-zA-Z0-9-\"]+\\) TO \\([a-zA-Z0-9-]+\\)" " \\2 <-- \\1" )))

;;  (while (re-search-forward pattern nil t)
;;	 (replace-match replacement))))
;;
(defun tl/ident-at-point ()
  "retourne l'identifiant Cobol sous le POINT."
  (let (p1 p2)
    (save-excursion
      (skip-chars-backward "-A-Za-z0-9")
      (setq p1 (point))
      (skip-chars-forward "-A-Za-z-0-9")
      (setq p2 (point))

      (buffer-substring-no-properties p1 p2))))

(defun tl/ff ()
  (interactive)
  (let (idt paragraphs p0)  
  (save-excursion
    (setq idt (tl/ident-at-point))
    (setq p0 (point))
    (setq paragraphs (re-search-backward "^**** <<<.*>>>"))
    
    ;; (with-output-to-temp-buffer-window
    (with-output-to-temp-buffer "**temp-output**"   
      (princ p0)
      (princ  " ")
      (princ paragraphs)))))


;; pour une position donnée:
;; - chercher le paragraphe en cours
;;  - trouver les références à ce paragraphe
;;    - rechercher les paragraphes de ces références
;;      - pour chaque paragraphe s'il n' a pas déjà été visité, rechercher les références à ce paragrahe
;;     - etc etc  

(defun tl/occur-ident()
  "execute 'list-matching-lines' on 'tl/ident-at-point' with 2 context lines"
  (interactive)
  (save-excursion
    (list-matching-lines (tl/ident-at-point) 2)))

(global-set-key (kbd "M-<f5>") 'tl/occur-ident)


;; searching-buffer-occur-mode <
;; From https://www.masteringemacs.org/article/searching-buffers-occur-modeq

(eval-when-compile
  (require 'cl))


(defun get-buffers-matching-mode (mode)
  "Returns a list of buffers where their major-mode is equal to MODE"
  (let ((buffer-mode-matches '()))
    (dolist (buf (buffer-list))
      (with-current-buffer buf
        (when (eq mode major-mode)
          (push buf buffer-mode-matches))))
    buffer-mode-matches))


(defun multi-occur-in-this-mode ()
  "Show all lines matching REGEXP in buffers with this major mode."
  (interactive)
  (multi-occur
   (get-buffers-matching-mode major-mode)
   (car (occur-read-primary-args))))

;; global key for `multi-occur-in-this-mode' - you should change this.
(global-set-key (kbd "C-<f5>") 'multi-occur-in-this-mode)



(defconst *tl/cbl-start-line-no-comment* "^.\\{6\\} " "Regex pour identifier une ligne COBOL sans commentaire")
(defconst *tl/cbl-start-line-comment* "^.\\{6\\}[*].*" "Regex pour identifier une ligne COBOL en commentaire")
(defconst *tl/cbl-re-division* (concat *tl/cbl-start-line-no-comment*
				       ".* DIVISION[ .]"))
(defconst *tl/cbl-re-section* (concat *tl/cbl-start-line-no-comment*
				      ".* SECTION[ .]"))


(defvar *test* *tl/cbl-start-line-comment*)

(defun tl/msg-point()
  "affiche le point dans le mini-buffer"
  (interactive)
  (message "point %d" (point)))

(global-set-key (kbd "<f6>") 'tl/msg-point)

;;; utilitaires

(defun gg(n)
  "Utilitaire - se positionne au point N du buffer. M-x gg"
  (interactive "nEnter point to reach :")
  (goto-char n))


(defun ww()
  "Utilitaire - affiche le POINT courant"
  (interactive)
  (message "current poin: %d" (point)))


(defun tt ()
  "test Analyse PARAGRAPHS + REF-TO"
  (interactive)
  (save-excursion
    (message "go")
    (setq prgs (tl/list-all-paragraphs-regions))

    (setq refs-to (tl/list-all-paragraphs-ref-to prgs))

    (message "length prgs : %d" (length prgs))
    (message "length refs : %d" (length refs-to))
    (message "refs : ")
    (pp refs-to)
    (message "-done-")
    ))


					;(
;(tl/cbl->dot refs-to)
; path to GraphViz utilities : c:/LOGICIELS/MicroFocus/MFED_50/eclipse/graphviz-2.38/release/bin/
(defun tl/cbl->dot(refs-to)
  "genererr un dot (GraphViz) a partir des REF-TO"
  (interactive)
  (with-help-window "*dot-output*"
    (princ "digraph G {\n")
    (let ((names (mapcar 'caar refs-to))
	  (refs-from ()))
      (princ "\t /* graph */ \n")
      (princ "\t graph [concentrate=\"true\", rankdir=\"LR\"];\n")
      (princ "\t /* nodes */\n")
      (princ "\t node [shape=\"box\"];\n")
     ; (dolist (name names)
     ;	(princ (concat "\t \"" name "\" [shape=\"box\"];\n")))
      (princ "\t /* edges */\n")
      (dolist (ref-to-data refs-to refs-from)
      ;(message "ref-to-data :'%s' " ref-to-data)
	(let ((prg-from (car (car ref-to-data)))
	    (ref-to (cdr ref-to-data)))
	  (dolist (to (mapcar 'car (car ref-to)))
	    (princ  (concat  "\t\"" prg-from  "\" -> \"" to "\"\n"))
	    ))))
  (princ "}\n")))

;;; manips cobol
(defun tl/paragraphs-region ()
  "Obtenir le debut et la fin d'un paragraphe cobol.
Renvoie une liste (NOM-PARAGRAPHE START END)"
  (let ((re-procedure "^...... [ ]\\{0,3\\}\\([-0-9A-Za-z]+\\)[ .].*")
      (end (- (point) 1))
      begin
      name)

  (re-search-backward re-procedure nil t)
  (setq name
	(substring-no-properties
	      (match-string 1)))
  (forward-line 0)
  (setq begin (point))
  (list name begin end)))

(defun tl/list-all-paragraphs-regions ()
  "Lister les paragraphes d'un programme cobol."
  (interactive)
  (goto-char (point-max)) ; on se positionne à la fin du programme
   (let (para 
	 name
	 (list-paragraphs ()))
     (setq name "")
     (while (not ( string-equal name "PROCEDURE")) ; on continue tanque l'on n'est pas sur la PROCEDURE
       (setq para (tl/paragraphs-region))
       (setq list-paragraphs
	     (cons para list-paragraphs))
       (setq name (nth 0 para )))
     list-paragraphs))

(defun tl/narrow-parag(paragraph)
  "Narrow sur PARAGRAPH."
  (narrow-to-region (nth 1 paragraph)
		    (nth 2 paragraph)))

(defun tl/list-all-paragraphs-ref-to (paragraphs)
  "Pour chaque paragraphe de PARAGRAPHS lister les REF-TO vers les autres paragraphes"
  (goto-char 1)
  (let ((names  (mapcar 'car paragraphs))
	(ref-to ()))

    (dolist (para paragraphs ref-to)
      (tl/narrow-parag para)
      (let ((inner-ref-to ()))
	(dolist (name names inner-ref-to)
	  (if (not (eq name (car para)))
	      (progn

		(goto-char (point-min))

		(while (re-search-forward
			(concat "^......  .*[ ]\\(" name "\\)[ \.]") nil t)
		  (push (list name
			      (match-beginning 1)
			      (match-end 1))
		    inner-ref-to)))))
	(setq ref-to (cons (list para inner-ref-to) ref-to)) 
	(widen)))))



(defun tl/map-copybook (copybook-path)
  "ouvre FILE et liste les lignes avec un PICTURE"
  (with-temp-buffer 
    (insert-file-contents copybook-path)
    (goto-char 1)
    (while (not (eobp))
	    
      (if (re-search-forward cobol--pic-type-re nil t)
;      (if (match-string 0)
	  (progn

	    (setq ligne (tl/grab-line))
	    (message "match\t%s\t%s" (match-string 0) ligne)) 
	)
      (forward-line 1)
    ))
   )

(defun test-tl/map-copybook()
  (interactive)
  (tl/map-copybook "d:\\REPO_Git\\Branche_A\\ZCobol_S2405_SF_EXPOSITION_MOTEUR_CREDIT\\ZCobol_S2405_SF_EXPOSITION_MOTEUR_CREDIT_Sources_programmes_ZCobol\\.copy\\ZAYX9KAR.cpy"))


  

