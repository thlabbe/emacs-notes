; digraph {
;rankdir=LR;
;
;/* ;
;		  #s(cbl-paragraph "ENTREE-PROGRAMME"
;				   (103908 104231)
;				   (#s(cbl-ref ref-to "DEBUT-PROGRAMME" 104008 104023)
;				      #s(cbl-ref ref-to "DEBUT-PROGRAMME-FIN" 104035 104054)
;				      #s(cbl-ref ref-to "TRAITEMENTS" 104089 104100)
;				      #s(cbl-ref ref-to "TRAITEMENTS-FIN" 104116 104131))
;*/
;ENTREE_PROGRAMME [shape=record,
;label="<top>ENTREE-PROGRAMME|...|<104008>104008|...|<104035>104035|...|<104089>104089|...|<104116>104116|..."]
; 
;DEBUT_PROGRAMME [shape=record,
;label="<top>DEBUT-PROGRAMME|..."];;;;
;
;DEBUT_PROGRAMME_FIN [shape=record,
;label="<top>DEBUT-PROGRAMME-FIN|..."];
;
;
;TRAITEMENTS [shape=record,
;label="<top>TRAITEMENTS|..."]

;TRAITEMENTS_FIN [shape=record,
;label="<top>TRAITEMENTS-FIN|..."]
;
;ENTREE_PROGRAMME:104008 -> DEBUT_PROGRAMME:top
;ENTREE_PROGRAMME:104035 -> DEBUT_PROGRAMME_FIN:top
;ENTREE_PROGRAMME:104089 -> TRAITEMENTS:top
;ENTREE_PROGRAMME:104116 -> TRAITEMENTS_FIN:top
;}

(defun cbl-test-list-all-paragraph()
  (interactive)
; (save-excursion
    (let ((parags ())) 
    (with-help-window "*debug*"
      (setq parags (cbl-list-all-paragraphs))
      (pp parags))
    (message "%s" (cbl-paragraph-region (car parags)))
    (cbl-narrow (cbl-paragraph-region (car parags)))
     ))
      ;

(defun cbl-test-pgm-with-paragraphs()
  (interactive)
  (save-excursion
  (let ((pg-name (buffer-name)))
    (let ((pgm (cbl-program-create :name pg-name)))
      (with-help-window (concat "*debug-" pg-name "*")
	(pp pgm)
	))))) 

(defun cbl-test-paragraph->node()
  (interactive)
  (save-excursion
    (let ((pg-name (buffer-name)))
      (let ((pgm (cbl-program-create :name pg-name))
	    (parags ())
	    (details ""))
	
	  
	(setq parags (cbl-list-all-refs-to-for-pgm pgm))
	(dolist (p parags)	      
	  (setq details (concat details (cbl-paragraph->node--label-html-like p))))
	
	(with-help-window (concat "*debug-" pg-name "-parags*")
	 ; (pp (cbl-list-all-refs-to-paragraph parags )))
	(pp pgm))
;	(let ((temp ())
;	      (nodes ())
;	      (edges ()))
;
	(with-help-window  "*debug*" 
	      (princ "digraph { rankdir=LR ")
	      (princ details)
	      (princ "}")
	      (read-only-mode -1))	
       ))))
  
(defun cbl-test-program-from-buffer ()
  (interactive)
  (let ((pgm (cbl-program-from-buffer)))
     (cbl-list-all-refs-to-for-pgm pgm)))

;; 
(defun lister-nodes-and-links()
  (interactive)
  (let ((edges ())
	(nodes ())
	(refs ())
	(pgm ())
	)
    (setq pgm (cbl-program-from-buffer))
    (setq refs (cbl-list-all-refs-to-for-pgm pgm))
    ;; nodes : doit servir à produire la liste des noeuds du graphe
    ;;    donc un node doit avoir un nom ( valide pour DOT language )
    ;;    un label : egal au nom COBOL
    (setq nodes (cbl-refs->dot-nodes refs))
    ))

(defun cbl-refs->dot-nodes (refs)
  (let ((nodes ()))
  (dolist (p refs nodes)
    (add-to-list 'nodes (mapcar 'car (cbl-paragraph->dot-node p)
    )))))

(defun cbl-paragraph->dot-node (p)
  (list :name (string-replace "-" "_" (cbl-paragraph-name p))       
	:label (cbl-paragraph-name p)
	))
  
