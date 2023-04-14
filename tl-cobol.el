;;; tl-cobol.el --- routines d'analyse cbl- COBOL par Thomas Labbé

;;; Commentary:
;; 

(require 'cl-lib)
(require 'gv)

;; CBL-PROGRAM
;;; Code:

(cl-defstruct (cbl-program (:constructor cbl-program--create)
			   (:copier nil))
  "CBL-PROGRAM structure permettant de manipuler un programme
cobol."
  (name ""
	:documentation "nom du CBL-PROGRAM")
  (divisions nil
	     :documentation "Slot qui sera utilisé pour mémoriser la liste des différentes DIVISIONS du CBL-PROGRAM.

TODO : implémenter son initialisation dans le constructeur."
	     :type list)
  
  (paragraphs nil
	      :documentation "liste des CBL-PARAGRAPHS du CBL-PROGRAM."
	      :type list))

(cl-defun cbl-program-create (&rest args)
  "Contructeur public de la structure CBL-PROGRAM.
Il permet de s'assurer que le slot PARAGRAPHS est bien vides à la
création.  FIXME : à la création il pourrait être utile
d'initialisercette liste de PARAGRAPHS
Optional argument ARGS **TODO**."
  (apply #'cbl-program--create
	 :paragraphs (cbl-list-all-paragraphs)
	 :divisions (cbl-list-all-divisions)
	 args))

(defun cbl-program-from-buffer (&optional buffer-or-name)
  "Renvoie le CBL-PROGRAM du BUFFER-OR-NAME.
si BUFFER-OR-NAME est nil, c'est le buffer courrant qui est analysé."
  (let ((buff (if buffer-or-name buffer-or-name (buffer-name))))
  (with-current-buffer buff
    (cbl-program-create))))

;; CBL-NAMED-REGION
(cl-defstruct (cbl-named-region (:constructor cbl-named-region-create)
				(:copier nil))
  "associer un nom à une région"
  (name ""
	:documentation "nom associé à la région")
  (region nil
	  :documentation "Points marquant le début et la fin de la région"))

;; CBL-DIVISION
(cl-defstruct (cbl-division (:include cbl-named-region)
			    (:constructor cbl-division--create)
			    (:copier nil))
  "Structure definissant une Division Cobol")

(cl-defun cbl-division-create (&rest args)
  "Constructeur public d'une CBL-DIVISION.
Optional argument ARGS this is used to implement a public constructor."
  (apply #'cbl-division--create
	 args))

;; CBL-PARAGRAPH
(cl-defstruct (cbl-paragraph (:include cbl-named-region)
			     (:constructor cbl-paragraph--create)
			     (:copier nil))
  "Structure definissant un paragraphe Cobol"
  (infos ()
	 :documentation "Informations complémentaires "
 	 )
  (refs-to ()
	   :documentation "Liste de paragraphes COBOL référencés par ce CBL-PARAGRAPH"
	   :type list)
  (refs-from ()
	     :documentation "Liste de paragraphes référençant ce CBL-PARAGRAPH"
	     :type list))

(cl-defun cbl-paragraph-create (&rest args)
  "Contructeur public de la structure CBL-PARAGRAPH.
Il permet de s'assurer que les stols :REF-TO et :REF-FROM sont
bien vides à la création.
Optional argument ARGS **TODO**."
  (apply #'cbl-paragraph--create
	 :refs-to ()
	 :refs-from ()
	; :infos ()
	 args))

(cl-defstruct (cbl-ref (:constructor cbl-ref-create)
		       (:copier nil))
  "Reference dans un source cobol.
:NAME  Nom de l'objet reférencé.
:START  Début de la référence.
:END Fin de la référence."
  (type 'unknown
	:documentation "type de la référence 'ref-to ou' 'ref-from" )
  (name ""
	:documentaion "Nom de la référence:
   CBL-REF-TO-NAME : nom de l'objet référencé.
   CBL-REF-FROM-NAME : nom de l'objet contenant la référence.")
  (begin 0
	 :documentation "Début de la référence")
  (end 0
       :documentation "Fin de la référence"))

				;
;;test
;(setq test (cbl-paragraph-create :name "TOTO" :region  (list 10 20)))

(defun cbl-narrow(region)
  "Narrow sur la REGION (cl-structure-object 'CBL-NAMED-REGION')."
  (cond
   ((cbl-named-region-p region)
    (narrow-to-region
     (nth 0 (cbl-named-region-region region))
     (nth 1 (cbl-named-region-region region))))
   ((listp region)
    (narrow-to-region
     (nth 0 region)
     (nth 1 region)))))

(defvar *re-cbl-ident-in-area-a* "^...... [ ]\\{0,3\\}\\([-0-9A-Za-z]+\\)[ .].*"
  "REGEX renvoyant le premier identifiant COBOL déclaré dans l'AREA-A sur une ligne non commentée.")

(defvar *re-cbl-division* "^...... [ ]\\{0,3\\}\\([-0-9A-Za-z]+\\)[ ]+DIVISION[ .]"
  "REGEX detectant les declarations d'une DIVISION d'un CBL-PGM.")

(defun cbl-current-division()
  "Renvoie la CBL-DIVISION pour la position courante."
  (let
      ((end (- (point) 1))
       begin
       name)
    (re-search-backward *re-cbl-division* nil t)
    (setq name (substring-no-properties (match-string 1)))
    (forward-line 0)
    (setq begin (point))
    (cbl-division-create :name name :region (list begin end))))

(defun cbl-list-all-divisions()
  "Lister les CBL-DIVISION d'un CBL-PROGRAM."
  (goto-char (point-max))
  (let (div
	name
	(result ()))
    (setq name "")
    (while (not (string-equal name "IDENTIFICATION"))
      (setq div (cbl-current-division))
      (setq name (cbl-division-name div))
      (setq result (cons div result)))
    result))
    

(defun cbl-current-paragraph()
  "Renvoie le CBL-PARAGRAPH pour la position courante.

EXCLUDE-PATTERN paragraphes à ignorer ( i.e \"-FIN\\'\" => paragrapghes dont le nom fini par \"-FIN\")."
  (let ((end (- (point) 1))
	begin
	name)
    (re-search-backward *re-cbl-ident-in-area-a* nil t)
    (setq name (substring-no-properties (match-string 1)))
  ;  (message "cbl-current-paragraph (%s)" exclude-pattern)
  ;  (message "name : %s" name)
  ;  (if (and exclude-pattern
;	     (not (string-match-p exclude-pattern name)))
    
	(progn 
	  (forward-line 0)   
	 (setq begin (point))
	 (let ((linfos ()))
	   (forward-line -1)
	   (while  (eq ?* (string-to-char (substring (buffer-substring (line-beginning-position) (line-end-position)) 6 7)))
	     (add-to-list 'linfos  (string-trim
			       (string-replace ">" " "
					       (string-replace "<" " "
			       (buffer-substring (+ (line-beginning-position) 7) (- (line-end-position) 10))))) t )
;	(messaqge "name %s --> infos %s" name infos)
	(forward-line -1))
      (forward-line 1)
      (cbl-paragraph-create :name name :infos (string-join linfos " ") :region (list begin end))))))
					;)


(defun cbl-list-all-paragraphs()
  "Lister les paragraphes d'un programe cobol dans le buffer courrant."
					;(interactive)
  (save-excursion
    (widen)
    (goto-char (point-max))
    (let (parag
	  name
	  (result ()))
      (setq name "")
      (while (not (string-equal name "PROCEDURE"))
	(setq parag (cbl-current-paragraph))
	(setq name (cbl-paragraph-name parag))
	(message " cbl-list-all-paragraphs name : '%s'" name)
        (if (not (string-match-p "-FIN//'" name)) ;; ignorer les pargraphes *-FIN
	    (progn 
	      (setq result (cons parag result))
	      (message "traité '%s'" name)
	      )))
      result)))

(defun cbl-list-all-refs-to-for-pgm (pgm)
  "Lister les REFERENCES pour un PGM donné"
  (if (cbl-program-p pgm)
      (let ((paragraphs (cbl-program-paragraphs pgm)))
	    (cbl-list-all-refs-to-paragraph paragraphs))
    (message "ERREUR : cbl-list-all-refs-to-for-pgm PGM '%s' n'set pas un CBL-PROGRAM" pgm)))

(defun cbl-list-all-refs-to-paragraph(paragraphs)
  "Construit une liste de References vers les autres paragraphes.
Argument PARAGRAPHS **TODO**."
  (goto-char (point-min))
  (let ((paragraphs-names (mapcar 'cbl-paragraph-name paragraphs))
	(result ()))
    (dolist (paragraph paragraphs result)
      ;; (message "paragraph '%s'" paragraph)
      (setf (cbl-paragraph-refs-to paragraph)
	    (cbl--list-all-refs-to-for-given-paragraph paragraph paragraphs-names))
      (add-to-list 'result paragraph t)
      )
    result))

(defun cbl--list-all-refs-to-for-given-paragraph (paragraph names)
  "Dans un PARAGRAPH donné lister toutes les références vers un paragraphe de la liste NAMES."
  (save-restriction
    (cbl-narrow (cbl-paragraph-region paragraph))
  
    (let ((current-name (cbl-paragraph-name paragraph))
	  (paragraphs-names (mapcar 'cbl-paragraph-name paragraphs))
	  (result ()))
    
      (dolist (paragraph-name paragraphs-names result)
	(if (not (eq paragraph-name current-name))
	    (progn
	      (goto-char (point-min))
	      (while (re-search-forward
		      (concat "^...... .*[ ]\\(" paragraph-name "\\)[ \.]")
		      nil t)
		(add-to-list 'result (cbl-ref-create :type 'ref-to
						     :name paragraph-name
						     :begin (match-beginning 1)
						     :end (match-end 1))
			     t) ; add-to-list append == true
		)))))))
(cl-defstruct (dot-node (:constructor dot-node--create)
			(:copier nil))
"DOT-NODE structire permettant de gerer un NODE en DOT-LANG."
(attributes () :documentation "option pour rendu graphviz")
(name "" :documentation "IDENTIFIANT du noeud. 
Il permet de définir les liens (DOT-EDGE). 
Unique dans un graphe.")
(label "" :documentation "LABEL du noeud, celui qui est affiché dans le graphe. Pour les shape in (mrecord, record) il permet de décrire plus finement la structure du DOT-NODE."))

(cl-defun dot-node-create (&rest args)
  "Constructeur public d'un DOT-NODE.

FIXME : possibilité de passer différents types d'arguments dans args
 - stringp : si ce n'est qu'un string il faut le traiter comme le :LABEL
             et donc inferer le :NAME
 - plist : si c'est un PLIST pouvoir produire :LABEL à partir du :NAME et/ou inversement
 - alist
 - cbl-paragraph-p : à gerer dans une fonction mapper 
"
  (message "args : '%s'" args)
  (message "name : '%s'" (plist-get args ':name)) 
  (apply #'dot-node--create args
;	 :attributes ()
;	 :name ()
;	 :label ()
	 ))

(defun cbl-paragraph->node (p)
  "Transforme un CBL-PARAGRAPH en NODE permettre la génération pour GraphViz/Dot.
Argument P CBL-PARAGRAPH en cours d'analyse.

Retourne la descritpion une paire ( NODE ( 'NODE -> NODE-A' 'NODE -> NODE-B' ... ).
"
  (message "cbl-paragrap->node p:%s" p)
  (cond ((cbl-paragraph-p p)
	; (with-help-window "*debug*"
	   (let (name start-line end-line lines-cnt region  res)
	     (setq name (cbl-paragraph-name p))
	    ; (setq node-id (string-replace "-" "_" name))
	     (setq region (cbl-paragraph-region p))
	     (setq start-line (line-number-at-pos (nth 0 region) t))
	     (setq end-line (line-number-at-pos (nth 1 region) t))
	     (setq cnt-lines (- end-line start-line))
	     (setq res (format "\t \"%s\" [shape=box, label=\"%s\\n%s lignes\" ];" 
			       name name cnt-lines)) 
	     (format "/* raw cbl-paragraph : %s */ \n%s " p res)))
	(t (format "p is not a CBL-PARAGRAPH : %s"  (pp p))
	 )))

;(defun dot-edges)

(defun  cbl-paragraph->node--label-html-like (p)
  "generer un noeud graphviz a partir d'un cbl-paragraph

  FIXME : les références ne sont pas triées par n° de ligne.
  TODO : Verifier que les n° de ligne sont corrects
  TODO : Afficher le nombre de lignes de chaque paragraphe 
"
  (let* ((node-name (cbl-paragraph-name p))
	 (region (cbl-paragraph-region p))
	     
	 (start-line (line-number-at-pos (nth 0 region) t))
	 (end-line (line-number-at-pos (nth 1 region) t))
	 (cnt-lines (- end-line start-line))       
	 (refs  (cbl-paragraph-refs-to p))
	 (label-head  "<\n\t<TABLE BORDER=\"0\" CELLBORDER=\"1\" CELLSPACING=\"0\">")
	 (label-title (format "\t\t<tr><td>%s</td></tr>\n\t\t<tr><td>%s</td></tr>\n\t\t<tr><td>lines : %s</td></tr>" node-name  (cbl-paragraph-infos p) cnt-lines))
	 (label-tail  "\t</TABLE>\n\t\t>")
	 (rows ())
	 (edges ())
	 (res nil)
	 (pnt 0)
	 (line 0)
	 (node-spec ""))
	
    (progn   	  
      (message "%s <-- info %s" (cbl-paragraph-name p) (cbl-paragraph-infos p))   
      (dolist (ref (sort refs (lambda (a b) (< (cbl-ref-begin a)(cbl-ref-begin b)))))      	   	    
	(setq pnt (cbl-ref-begin ref))
	(setq line (line-number-at-pos pnt))        
	(add-to-list 'rows (format "<TR><TD PORT=\"%s\">ligne %s</TD></TR> "       
				   pnt line) t)		
	(add-to-list 'edges (format "\"%s\":%s -> \"%s\""  node-name pnt (cbl-ref-name ref)) t))          	  
      (setq rows (string-join rows " \n\t\t"))	  
      (setq edges (string-join edges " \n\t"))	  
      (concat "\t\"" node-name "\" [shape=plaintext, label=\n"     	      
	      "\t" label-head	      
	      "\n\t" label-title	      
	      "\n\t" rows	       	      
	      "\n\t" label-tail "]"	      
	      "\n\t" edges "\n"))))
	
(provide 'tl-cobol)

;;; tl-cobol.el ends here
