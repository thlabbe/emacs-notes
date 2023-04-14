(defun xx ()
  (interactive)
  (let ((ws (window-total-height (selected-window))))
    
    (message "%s" ws)
    )
  )

(defun pp ()
  "Commande pour afficher le POINT"
  (interactive)
  (message "current point : %d" 
	   (point)))
(defun oo2 ()
  (interactive)
  (let ((text-to-save "XXXXXX XXXXX"))
      (with-temp-buffer-window
	(switch-to-buffer-other-window (generate-new-buffer "*extract*"))
	(insert text-to-save)
	(unwind-protect (save-buffer)
			(kill-buffer)
			)
	;(save-buffer)
	
	)))


(defcustom cbl-directory "~/org/mia/"
  "repertoire où trouver un source COBOL")

(defcustom cbl-current-fname "VB513G.cbl"
  "source COBOL a étudier")

(defun cbl-path (dir fname)
  (message "%s" (concat cbl-directory cbl-current-fname)))

(defun tt ()
  (interactive)
  (let ((cbl-file (cbl-path cbl-directory cbl-current-fname)))
    
    (message "%s" cbl-file)))



;;;; tests : 


(defun tt ()
  (interactive)
  (set-up-tooltip)) 


(defun set-up-tooltip ()
  ;; search for the text to be highlighted ...
  (looking-at "DIVISION")
  (add-text-properties (match-beginning 0)
		       (match-end 0)
		       '(mouse-face highlight
				    help-echo (get-help-text (match-beginning 0)))))

(defun get-help-text (txt)
  (save-excursion
    (with-temp-buffer
      (find-file-noselect (cbl-path))
      (looking-at txt))))


(defun ll ()
  (interactive)
  (message "%s" (looking-at "DIVISION")) ;; looking-at renvoie TRUE si le point est sur le debut de la REGEX
)


"PRODECURE  DIVISION "

;;; DIVISION 

(defun lister-divisions-old 
 ()
 "renvoie la liste des division d'un programme COBOL"		  
 (let (procedure-div 
       data-div 
       environment-div 
       identifiaction-div
       start
       stop)
  
   (save-excursion
       (widen)
         (progn
	   
	   (setq stop (point-max))
	   ;; PROCEDURE DIVISION
	   (goto-char stop)
	   (re-search-backward "^......\s+PROCEDURE\s+DIVISION[ \.]")
	   (setq procedure-div (list (point) stop))
	       
	   ;; DATA DIVISION
	   (setq stop (- (point) 1))
	   (re-search-backward "^......\s+DATA\s+DIVISION\.")
	   (setq data-div 
		 (list 
	          (point) 
		  stop))
	   
	   ;; ENVIRONMENT DIVISION
	   (setq stop (- (point) 1))
	   (re-search-backward "^......\s+ENVIRONMENT\s+DIVISION\.")
	   (setq environment-div 
		 (list 
	          (point) 
		  stop))
	   
	   ;; IDENTIFICATION DIVISION
	   (setq stop (- (point) 1))
	   (re-search-backward "^......\s+IDENTIFICATION\s+DIVISION\.")
	   (setq identification-div 
		 (list 
	          (point) 
		  stop))

	   (message "data : %s\nprocedure : %s" data-div procedure-div)
           (list identification-div environment-div data-div procedure-div)

	   
	   ))))

(defun division-bounds (name &optional before-point)
  "Revoie la division du nom NAME.

Si BEFORE-POINT est `nil' commence la recherche depuis POINT-MAX
"
  (message "%S" name )
  (let (division 
	(stop (if (not (integerp before-point))
		  (point-max)
		(- before-point 1)))
	(*re-search* (concat "^......\s+" name "\s+DIVISION[ \.]")))
    (goto-char stop)
    (re-search-backward *re-search*)
    (setq division (list name (point) stop))))

(defun ff ()
  (interactive)
  (message "%s" (lister-divisions)))

(defun lister-divisions ()
  "renvoie les 4 division d'un programme COBOL"
  (interactive)
  (let (identification-div environment-div data-div procedure-div)
    (setq procedure-div (division-bounds "PROCEDURE"))    
    (setq data-div (division-bounds "DATA" (point)))
    (setq environment-div (division-bounds "ENVIRONMENT" (point)))
    (setq identification-div (division-bounds "IDENTIFICATION" (point)))
    
    ;;; (message "%s" (list identification-div environment-div data-div procedure-div))

    (list identification-div environment-div data-div procedure-div)))

(defun give-division-region (div-name divisions)
  ;; (message "%s" divisions)
  ;;(message "%s" (car divisions))
  (progn
    (message "%S %S %S" div-name (car (car divisions)) divisions)
    (cond
     ((null (car divisions)) nil)
     ((string= div-name (car (car divisions))) ;;; TODO : FIXME Symbol != String
      (car divisions)) 
     (t (give-division-region div-name (cdr divisions))))))

(defun clone-indirect-buffer-other-frame (newname display-flag &optional norecord)
  "Like `clone-indirect-buffer' but display in another window."
  (interactive
   (progn
     (if (get major-mode 'no-clone-indirect)
     (error "Cannot indirectly clone a buffer in %s mode" mode-name))
     (list (if current-prefix-arg
           (read-buffer "Name of indirect buffer: " (current-buffer)))
       t)))
  (let ((pop-up-frames t)) 
    (clone-indirect-buffer newname display-flag norecord)))

(defun xx ()
  (interactive)
  (let ((data-buffer-name "*cobol DATA*")
	(data-region ()))
    
    (progn
      (lister-divisions)
      (setq data-region (give-division-region "DATA" (lister-divisions)))
      
      (clone-indirect-buffer-other-frame data-buffer-name t)
      (narrow-to-region 
       (nth 1 data-region) 
       (nth 2 data-region))
      
      (goto-char (point-max))
      (let ((identifiers ()))
	(while (ignore-errors 
		 (re-search-backward "^......\s*[0-9][0-9]\s+\\([-A-Z0-9]+\\)"))
	  (push (match-string 1) identifiers))
	(message "%S" identifiers)
	)
      )))

(defun ww ()
  (interactive
   (progn
  ;;; 1/ verifier que l'on est sur un COBOL sinon fin en erreur
  ;;; 
     
     )
   ))



(defvar mia-identifiant-data-re "^......\s+[0-9][0-9]\s+\\([-A-Z0-9]+\\)"
  "regex permettant de capturer les identifant dans la DATA DIVISION d'un source COBOL"
  )
(defun mia-list-identifiants ()
  (let ((fnd nil)
	(fnds ())
	))
  )         

(defun rr()
	"r echercher dans le buffer toutes les ocurences de `ma-regex'.
    Retourne la liste des POINTS ou `ma-regex' a matché et la liste des chaînes capturées "
	(interactive)
	(save-excursion
	  (widen)
	  (goto-char (point-max))
	  (let ((founding nil)
		(foundings ()))
	  (while
	      (ignore-errors  
		(re-search-backward ma-regex))
	    (setq founding (cons (match-string-no-properties 1) (point)))
	    (push founding foundings))
	  (message "%S" foundings))))
