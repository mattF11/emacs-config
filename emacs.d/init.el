;;(setq-default mode-line-format (default-value 'mode-line-format))
  ;;(setq use-package-always-defer t)

  (require 'package)
  ;; Aggiunge MELPA come archivio di pacchetti
  (add-to-list 'package-archives '("gnu" . "https://elpa.gnu.org/packages/") t)
  (add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)

;;richiamo tabs-custom.el file dalla directory lisp
;;(load "~/.emacs.d/lisp/custom-tabs.el")

(setq native-comp-async-report-warnings-errors nil)

;;default modeline custom settings
 ;; (setq-default mode-line-format
 ;;  (list
 ;;   '(:eval (concat " " (nerd-icons major-mode) " "))
 ;;   'mode-line-buffer-identification
 ;;   "   "
 ;;   'mode-line-position
 ;;   "  "
 ;;   'mode-line-modes
 ;; 'mode-line-misc-info))

;;REPEAT:permette di ripetere il comando da tastiera premendo una sola lettera
(use-package repeat
  :custom
  (repeat-mode +1))

;;CONFIGURAZIONE DEBUGGER: Attiva GUD in tutti i linguaggi di programmazione
;; Breakpoint con C-x SPC in tutti i linguaggi (senza gud-minor-mode)
;;IL PROBLEMA Dell'hook che segue è che funziona solo nel buffer del codice,non
;;in quello di gud,come dovrebbe anche fare
;; (add-hook 'prog-mode-hook
;;           (lambda ()
;;             (local-set-key (kbd "C-x SPC") #'gud-break)))

;; ;; Tooltip variabili nel buffer GUD
;; (add-hook 'gud-mode-hook #'gud-tooltip-mode)
;; ;; ancor ameglio lo aggiungo alla menu-bar
;; (add-hook 'gud-mode-hook #'gud-menu-init)





(require 'gud)
(defun my/add-gud-menu-to-prog-mode ()
  (easy-menu-add-item
   nil
   '("Tools")
   ["GUD" gud-menu-map t]
   "Compare"))

(add-hook 'prog-mode-hook #'my/add-gud-menu-to-prog-mode)







;;aggiunta funzioni aggiuntive git in emacs mancanti a VC
(use-package git
  :ensure t)
(use-package vc-msg
  :ensure t)
;; Navigazione commit
(use-package git-timemachine
  :ensure t)
;; Modalità per file Git
(use-package git-modes
  :ensure t)

;; ;; Doom modeline
(use-package doom-modeline
  :ensure t
  :init (doom-modeline-mode 1)
(setq doom-modeline-height 28))


;;nascondere la modeline
(use-package hide-mode-line
  :ensure t
  :defer t)
(global-set-key (kbd "<f8>") #'hide-mode-line-mode)


;;Elenco di tutti i settaggi di diversi aspetti/parti della ui con relative scoriatioi che non siano
;;la modeline
  
  ;;GESTIONE UI
  (global-display-line-numbers-mode 1)
  (tool-bar-mode -1) ;disattivazione tool bar(superflua se sai i comandi)
  (scroll-bar-mode -1) ;disattivazione scrollbar(ho già indicazione nella modeline
  (menu-bar-mode 1)  ;disattivazione della menu bar
  (global-set-key (kbd "<f9>") 'menu-bar-mode)  ;; Apre/chiude la menu bar con pulsante F9
  (global-set-key (kbd "<f11>") #'toggle-frame-fullscreen) ;; Toggle-Frame-Fullscreen
  ;;(define-key corfu-map (kbd "<f11>") nil)
  ;;utilizzo di eldoc per avere tipo lsp senza lsp
  (global-eldoc-mode 1) 
  ;(global-corfu-mode 0)

;;Pacchetto fondamentale per avere un terminale che funziona bene in emacs che non sia una shell vera e propria
;;IMPOSTO BASH COME SHELL DEFAULT DI VTERM
(setq vterm-shell "/bin/bash")

  ;;DISABILITO I BACKUP E AUTOSAVE
  (setq make-backup-files nil)  ;; Disabilita i file di backup (~)
  (setq auto-save-default nil)  ;; Disabilita il salvataggio automatico


;(declare-function cape-keyword "cape")
;(declare-function emms-all "emms")
;(declare-function emms-default-players "emms")
;(declare-function emms-mpris-enable "emms")
;(declare-function c-toggle-auto-newline)


(setq native-comp-async-report-warnings-errors nil)

;; Nella sezione linguaggi è inserito tutto il codice che può riguardare i linguaggi di programmazione,
;; da org-mode a funzioni speciali.
;; Presente la configurazione di eglot e eglot-lspname(lsp),treesitter,sono stati quindi
;; integrati in emacs dalla versione 28.
;; Quando si installa un lsp,almeno che non vuoi utilizzare quel pachiderma non integrato
;; di lsp-mode,devi installare anche il pacchetto eglot del linguaggio.
;; Il folding custom delle aprentesi inserito è temporaneo,basandosi sulle mode classiche
;; con regexp magari lo tolgo ma lo perderei per tutto quello che
;; non è supportato da tree sitter: matlab,octave,avr,avr-gcc e tutti i vari tipi di
;; assembly,credo anche verilog


  
  ;;SETUP EGLOT
(use-package eglot)

;;QUANDO USO RESTORE DELLA SESSIONE TOLGO COMMENTI A QUESTO BLOCCO
;; Evita che Eglot parta durante il restore della sessione
;; (defun my/eglot-skip-during-desktop-restore ()
;;   (when (and (boundp 'desktop-restoring)
;;              desktop-restoring)
;;     (setq eglot--managed-mode nil)))

(use-package eglot-java
  :after eglot
  :ensure t
    :config
    (progn
     ;(add-hook 'java-mode-hook 'eglot-java-mode)
      ;;sostituisco hook per java-mode classico con il moderno treesitter integrato in emacs
      (add-hook 'java-ts-mode-hook 'eglot-java-mode)
      ))

  ;;evita che eglot crea workspace temporaneo ogni volta(aggiunto dopo)
  (setq eglot-workspace-configuration
        '(:java (:workspace (:path "~/.emacs.d/jdtls-workspace"))))
  ;;setup grabage collecto consigliato(aggiunto dopo)
  (setq eglot-java-server-command
        '("jdtls"
          "-XX:+UseG1GC"))



;; (use-package eglot)
;; ;; Evita che Eglot parta durante il restore della sessione
;; (defun my/eglot-skip-during-desktop-restore ()
;;   (when (and (boundp 'desktop-restoring)
;;              desktop-restoring)
;;     (setq eglot--managed-mode nil)))

;; (add-hook 'eglot-managed-mode-hook #'my/eglot-skip-during-desktop-restore)
;; (use-package eglot-java
;;   :after eglot
;;   :ensure t
;;   :config
;;   (add-hook 'java-ts-mode-hook
;;             (lambda ()
;;               (unless (bound-and-true-p desktop-restoring)
;;                 (eglot-java-mode)))))





  ;;folding delle parentesi come negli altri ide/text editor: geany/eclipse/vscode
  ;;(folding senza pacchetti esterni)
  ;;hs-minor-mode utilizzato per il folding
  ;;1) Attiva hideshow in tutti i linguaggi
  (add-hook 'prog-mode-hook #'hs-minor-mode)
  ;; 2) Simbolo custom per il blocco foldato
  (setq hs-set-up-overlay
        (lambda (ov)
          (overlay-put ov 'invisible t)     ;; nasconde tutto il blocco
          (overlay-put ov 'display " ⤷ ")   ;;  cambia qui il simbolo
          (overlay-put ov 'face '(:weight bold))))

  ;; 3) Funzione: trova la prossima { e folda/unfolda
  (defun hs-toggle-next-block ()
    "Vai alla prossima parentesi '{' e folda/unfolda il blocco con hideshow."
    (interactive)
    (let ((pos (save-excursion
                 (search-forward "{" nil t))))
      (if pos
          (progn
            (goto-char pos)
            (backward-char 1)
            (hs-toggle-hiding))
        (message "Nessuna parentesi trovata dopo il cursore."))))

  ;;4) blocco precedente
  (defun hs-toggle-previous-block ()
    "Trova la precedente '{' e folda/unfolda il blocco con hideshow."
    (interactive)
    (let ((pos (save-excursion (search-backward "{" nil t))))
      (if pos
          (progn
            (goto-char pos)
            (hs-toggle-hiding))
        (message "Nessuna parentesi trovata prima del cursore."))))

  ;; 5) Keybinding
  (define-key prog-mode-map (kbd "C-c n") #'hs-toggle-next-block)
  (define-key prog-mode-map (kbd "C-c p") #'hs-toggle-previous-block)
  (define-key prog-mode-map (kbd "C-c s") #'hs-show-all)
  (define-key prog-mode-map (kbd "C-c h") #'hs-hide-all)
     ;;    (overlay-put ov 'display " ⤷ ")  ;; ‣ ▾ ▼
  ;;(define-key prog-mode-map (kbd "C-c n") #'hs-toggle-next-block)

;;siccome tresitter è già integrato in emacs e ha delle funzioni,si sta
      ;;espandendo e tra qualche anno potrebbe
      ;;essere il nuovo default e le altre in legacy-mode,allora lo settiamo subito
      ;;dovrebbe anche essere più
      ;;veloce mentre lo si utilizza delle major mode con regexp e più preciso in parsing e
      ;;syntax highlighting
      ;;utilizza major-mode-remap-alist per sostituire le vecchie modes con quelle treesitter

      (setq major-mode-remap-alist
            '((c-mode . c-ts-mode)
              (c++-mode . c++-ts-mode)
              (java-mode . java-ts-mode)
              (sh-mode . bash-ts-mode)
              (python-mode . python-ts-mode)))

          ;; (add-hook 'java-ts-mode-hook
      ;;           (lambda ()
      ;;             (c-toggle-auto-newline 1)))

      ;;posso implementare livelli diversi di evidenziazione e identazione
      (setq treesit-font-lock-level 4)
          ;;eglot si integra con tutti gli strumenti inclusi in emacs,come
;;eglot,usiamo amche treesitter folding
      ;; (use-package ts-fold
      ;;   :hook ((c-ts-mode . ts-fold-mode)
          ;;          (java-ts-mode . ts-fold-mode)
      ;;          (bash-ts-mode . ts-fold-mode)))


      ;;MODIFICHE FONDAMENTALI
      (defun my-ts-auto-newline-and-indent ()
        "Attiva l'auto-newline e l'auto-indentazione dopo il ';' per i linguaggi C-like con Tree-sitter."
            ;; Controlla se la modalità corrente è una delle modalità TS di tipo "C-like"
        (when (memq major-mode '(c-ts-mode c++-ts-mode java-ts-mode))
          
          ;; 1. Configura electric-layout-mode per andare a capo dopo il punto e virgola
          (setq-local electric-layout-rules '((?\; . after)))
          (electric-layout-mode 1)
          
          ;; 2. Rimappa il tasto ';' solo in questo buffer per gestire
  	;;l'indentazione immediata della nuova riga
          (local-set-key (kbd ";") 
                         (lambda ()
                           (interactive)
                           (self-insert-command 1)       ; Inserisce ';' (scatta electric-layout)
                           (indent-according-to-mode)    ; Indenta la riga appena lasciata
                           (forward-line 1)              ; Si sposta sulla nuova riga vuota
                           (indent-according-to-mode)    ; La indenta subito correttamente
                           (forward-line -1)             ; Torna alla riga precedente...
                           (end-of-line)                 ; ...va alla fine...
                           (forward-line 1)              ; ...e si posiziona sulla nuova riga
    		       ;;pronto a scrivere
                           (back-to-indentation)))))

      ;; Applica la funzione a tutte le modalità di programmazione
    ;;(filtrerà da sola i linguaggi corretti)
      (add-hook 'prog-mode-hook #'my-ts-auto-newline-and-indent)

;; Attiva parentesi automatiche
(electric-pair-mode 1)
;; Indentazione automatica quando premi RET
(electric-indent-mode 1)

;;auto new line per i linguaggi di programmazione che uso
(add-hook 'c-mode-common-hook
          (lambda ()
            (c-toggle-auto-newline 1)))

;;Aggiunta del support di matlab-mode in aggiunta a octave-mode,che al momento è disattivato,averli attivi insieme funziona lo stesso ma mette il simbolo
;;errato e comuneque non gli voglio attivi magari contempoeranemante quando apro un file .m,che entrambi aprono

  ;; Impostazioni per utilizzare MATLAB/Octave in Emacs
  ;;(executable-find matlab-executable)
  ;; Aggiunta del percorso all'eseguibile
  (setq matlab-executable "/home/mattia/MATLAB/esercizi") ;;  modifica il percorso secondo la tua installazione
  (add-to-list 'exec-path "/home/mattia/MATLAB/esercizi/lavori")

  ;; Attivazione automatica di matlab-mode per file .m
  (add-to-list 'auto-mode-alist '("\\.m$" . matlab-mode))
  ;(add-to-list 'auto-mode-alist '("\\.m$" . octave-mode))

  ;; Messaggio di avvio
  (add-hook 'matlab-mode-hook
            (lambda () (message "MATLAB è stato avviato!")))

  ;; Configurazioni di indentazione
  (setq matlab-indent-function t)
  (setq matlab-block-offset 4)
  (setq matlab-fill-code nil)
  (setq matlab-verify-on-save-flag nil)

  ;; Funzione per aprire buffer MATLAB
  (defun matlab-buffer ()
    "Restituisce il nome del buffer MATLAB."
    "*MATLAB*")

  ;; Hook per aprire buffer quando si apre un .m
  (add-hook 'after-find-file-hook
            (lambda ()
              (when (and (eq major-mode 'matlab-mode)
                         (string-match "\\.m\\'" (buffer-file-name)))
                (switch-to-buffer (matlab-buffer)))))

          ;; Hook per aprire il buffer Octave quando si apre un file .m
      ;    (add-hook 'after-find-file-hook
     ;               (lambda ()
       ;               (when (and (eq major-mode 'octave-mode)
        ;                         (string-match "\\.m\\'" (buffer-file-name)))
         ;               (switch-to-buffer (octave-buffer)))))
          ;; Funzione per inviare comandi a GNU Octave
        ;  (defun octave-send-command (command)
         ;   "Invia un comando a GNU Octave, avviandolo se necessario."
          ;  (let ((octave-process (or (get-process "gnu-octave")
           ;                           (octave-start))))
            ;  (process-send-string octave-process (concat command "\n"))))

;ORG-MODE
  ;;CUSTOM/FUNZIONI PER ORG-MODE
         ;;cursore di org-mode all'inizio del file,non in fondo
         (add-hook 'find-file-hook
                   (lambda ()
                     (when (string-equal (file-name-extension buffer-file-name) "org")
                       (goto-char (point-min)))))
         ;; ;;Org-download
         ;; (use-package org-download
         ;;   :ensure t
         ;;   :defer t
         ;;   :config
         ;;   (setq org-download-directory "~/Immagini/Schermate/")
         ;;   (global-set-key (kbd "C-x C-d") 'org-download-screenshot))
         ;;pacchetto Yas-Snippet
         (use-package yasnippet
           :ensure t
           :config
           (yas-global-mode 1)
         )
         ;;pacchetto ox reveal per usare org-re-reveal/org-reveal
       ;  (use-package ox-reveal)
       ;pandoc/ox-pandoc
         (add-to-list 'exec-path "/home/Pandoc")
                                      ;ORG-MODE-LATEX-GRAFICI
         (setq org-latex-pdf-process
               '("pdflatex -interaction nonstopmode %f"
                 "pdflatex -interaction nonstopmode %f"))

         ;;visualizzare immagini con emacs per org mode
         (setq org-startup-with-inline-images t)
         (setq org-display-inline-images t)
         ;;eseguire codice matlab dentro emacs(per org mode)
         ;;matlab nodisplay nosplash matlab deve essere aggiunto al path
         (setq org-babel-matlab-command "matlab -nodisplay -nosplash -r")
         ;;(add-to-list 'org-babel-load-languages'(matlab . t))
         ;;per usare il pacchetto gnuplot  
         ;;per caricare le formule scritte in latex direttamente visibili
                    ;;ogni volta che apro i file utilizzo questo,farlo ogni volta
         ;;Ã¨ una rottura e non sono riuscito a farlo ancora in un blocco src latex
         ;;(setq org-preview-latex-default-process 'dvipng)

;;PlantUML: support alla generazione UML java
(setq org-plantuml-jar-path "/usr/share/java/plantuml.jar")

(org-babel-do-load-languages
 'org-babel-load-languages
 '((C . t)
   (shell . t)
   (java . t)
   (latex . t)
   (matlab . t)
   (python . t)
   (plantuml .t)))


;;gli metto uno nuovo che sostituisce il precedente
(use-package nerd-icons-dired
  :ensure t
  :hook (dired-mode . nerd-icons-dired-mode))
(use-package dired-single
  :load-path "~/.emacs.d/lisp"
  :bind (:map dired-mode-map
              ("RET" . dired-single-buffer)
              ("^"   . dired-single-up-directory)))

;;aggiunta di funzionalità a dired/ dired-mode
;(setq dired-mouse-drag-files t) ;;drag dentro a EMACS
;(setq mouse-drag-and-drop-region t)  ;;drag and drop dentro a dired
;(setq mouse-drag-and-drop-region-cross-program t) ;;mouse-drag-and-drop-region-cross-program

;; EMMS: musica e video con MPV
  (use-package emms
    :ensure t
    :defer t
    :config
    (require 'emms-setup)
    (require 'emms-mpris)
    (require 'emms-browser)
    ;;aggiunta delle immagini a emms:inizio
    (setq emms-browser-show-images t
          emms-browser-thumbnail-small-size 64
          emms-browser-thumbnail-medium-size 128)
    (require 'emms-info)
    (require 'emms-info-libtag)
    (setq emms-info-functions '(emms-info-libtag))
    ;;immagini aggiunte:fine
    (require 'emms-cache)
    (emms-all)
    (emms-default-players)
    (emms-mpris-enable)
    :custom
    (emms-browser-covers #'emms-browser-cache-thumbnail-async)
    :bind
    (("C-c w m b" . emms-browser)
     ("C-c w m e" . emms)
     ("C-c w m p" . emms-play-playlist )
     ("<XF86AudioPrev>" . emms-previous)
     ("<XF86AudioNext>" . emms-next)
     ("<XF86AudioPlay>" . emms-pause)))

  (defun dired-play-video-with-mpv ()
    "Riproduce il file video selezionato in Dired con MPV."
    (interactive)
    (let ((file (dired-get-file-for-visit)))
      (start-process "mpv-video" nil "mpv" "--force-window=yes" "--quiet" file)))
  ;; Imposta la directory musicale di default
  (setq emms-source-file-default-directory "~/Musica/e-onkyo music")
  ;;nascondere il titoli  dai guardoni cagacazzo è la scelta migliore
  ;; Toggle per nascondere/mostrare i titoli in EMMS
  (defun my-emms-toggle-titles ()
    "Alterna tra mostrare e nascondere i titoli delle canzoni in EMMS."
    (interactive)
        ;; Se attualmente mostra i titoli  nascondi
        (setq emms-track-description-function
              (lambda (track) ""))
      ;; Altrimenti  ripristina la visualizzazione standard
      (setq emms-track-description-function
            'emms-track-simple-description))

  ;; Scorciatoia globale (C-c t)
(global-set-key (kbd "C-c t") 'my-emms-toggle-titles)
;; Assegna la funzione al tasto V in Dired per vedere un video
(with-eval-after-load 'dired
  (define-key dired-mode-map (kbd "V") 'dired-play-video-with-mpv))

;;ZOOM:lo zoom con ctrl + rotella è impostato di default da emacs,aggiungo
;;quello senza mouse(ctrl ++ e ctrl --)
    (global-set-key (kbd "C-+") 'text-scale-increase)
    (global-set-key (kbd "C--") 'text-scale-decrease)
    ;; Abilita il supporto per il copia e incolla con il sistema
    (setq x-select-enable-clipboard t)
    ;; Visualizza il numero della colonna corrente nella barra di stato
    (column-number-mode 1)
    ;;Aumenta la soglia per garbage collector(GC) a 100MB
    (setq gc-cons-threshold (* 100 1024 1024))
    ;;imposta default valore del GC quando emacs non Ã¨ attivo
    (add-hook 'emacs-startup-hook
              (lambda ()
                (setq gc-cons-threshold (* 16 1024 1024))))

    (setq large-file-warning-threshold 100000000) ;;supporto file olte 100 MB



;;DIRED SIDEBAR MODIFICHE:lazy loaded per evitare sia caricata quando non serve
(use-package dired-sidebar
  :ensure t
  :commands (dired-sidebar-show-sidebar dired-sidebar-toggle-sidebar)
  :bind ("<f7>" . dired-sidebar-toggle-sidebar)

  ;;:init
  ;; Sidebar aperta all’avvio
  ;; (add-hook 'emacs-startup-hook
  ;;           (lambda ()
  ;;             (dired-sidebar-show-sidebar)))

  :hook
  ;; Doom modeline nella sidebar
  (dired-sidebar-mode . doom-modeline-mode)

  ;; Niente numeri di riga nella sidebar
  (dired-sidebar-mode . (lambda () (display-line-numbers-mode -1)))

  ;; Sidebar segue sempre la directory del file corrente
					;(dired-sidebar-mode . dired-sidebar-follow-file)

  :custom
  ;; Impostazioni opzionali
  (dired-sidebar-width 32)
  (dired-sidebar-use-custom-font t))






;; === SESSIONE STABILE E COMPATIBILE ===

;; ;; 1) Directory della sessione
;; (setq desktop-dirname "~/.emacs.d/session/"
;;       desktop-base-file-name "emacs-desktop"
;;       desktop-path (list desktop-dirname)
;;       desktop-save t
;;       desktop-load-locked-desktop t
;;       desktop-restore-eager 5
;;       desktop-auto-save-timeout nil)

;; ;; 2) Attiva il salvataggio della sessione
;; (desktop-save-mode 1)

;; ;; 3) Salva posizione del cursore
;; (save-place-mode 1)

;; ;; 4) Salva cronologia minibuffer, ricerche, M-x, ecc.
;; (savehist-mode 1)

;; ;; 5) Salva layout finestre
;; (winner-mode 1)

;; ;; 6) Leggi la sessione all’avvio
;; (add-hook 'emacs-startup-hook #'desktop-read)

;; ;; 7) Salva la sessione alla chiusura
;; (add-hook 'kill-emacs-hook #'desktop-save-in-desktop-dir)

;; ;; 8) Escludi TUTTI i buffer problematici (regex corretti)
;; (setq desktop-files-not-to-save
;;       (concat "\\("
;;               ;;"dired-sidebar"
;;               "\\|\\*dape-.*"
;;               ;;"\\|\\*Messages\\*"
;;               ;;"\\|\\*scratch\\*"
;;               "\\|\\*Compile-Log\\*"
;;               "\\|\\*Backtrace\\*"
;;               ;;"\\|\\*Warnings\\*"
;;               "\\)"))






    ;;file recenti attivati
    (recentf-mode 1)

    ;;projectile-mode per gestire progetto
    ;(use-package projectile
     ; :init (projectile-mode 1)
      ;:custom (projectile-project-search-path '("~/progetti/")))


    ;;pdf.tools
    (use-package pdf-tools
      :ensure t
      :defer t
      :mode ("\\.pdf\\'" . pdf-view-mode)
      :config
      
      (pdf-tools-install))

    ;;vterm
    (use-package vterm
      :ensure t
      :defer t
      :commands vterm)

    ;;Flyspell
    (use-package flyspell
      ;:disabled t
      :ensure t
      ;;:defer t
      :hook ((text-mode . flyspell-mode)
             (prog-mode . flyspell-prog-mode)))

    ;;matlab-mode e cuda-mode supporto
    (use-package matlab-mode
      :ensure t
      :defer t
      :mode ("\\.m\\'" . matlab-mode))

    (use-package cuda-mode
      :ensure t
      :defer t
      :mode ("\\.cu\\'" "\\.cuh\\'"))

      ;;per fare lo swap dei buffers
      (use-package ace-window
        :ensure t
        :defer t
      :bind
      (("M-o" . ace-swap-window))) ; esempio default
      ;;il comando di base per cambiare focus è C-x o

  ;;markdown mode
  (use-package markdown-mode
    :defer t
    :ensure t)

  ;;per avere home come buffer iniziale
  ;(setq initial-buffer-choice (lambda () (find-file "*scratch*")))

  ;;nerd-icons
  (use-package nerd-icons
    :ensure t)

  ;; ;; Abilita l'interfaccia di completamento
  ;; (use-package ivy
  ;;   :ensure t
  ;;   :config
  ;;   (ivy-mode 1))


;;ivy è più pesante e meno integrato di questi tutti assieme
(use-package vertico
  :ensure t
  :init
  (vertico-mode 1))

(use-package consult
  :ensure t)

(use-package orderless
  :ensure t)


;; Read ePub files
(use-package nov  ;;utilizza il pacchetto nov.el di Schneidermann
  :ensure t
  :defer t
    :init
    (add-to-list 'auto-mode-alist '("\\.epub\\'" . nov-mode)))

;;risoluzione di docview
;;caratteri testo di docview e antialiasing
(setq doc-view-resolution 180) ;; Imposta la risoluzione a 200

  ;; Aggiungi pacchetti LaTeX se ti servono
   (setq org-latex-packages-alist
         '(("" "graphicx")
           ("" "amsmath")
           ("" "hyperref")))

 ;; Aggiunta del percorso di Octave all'ambiente di Emacs
 ;  (add-to-list 'exec-path "/home/mattia/.config/octave")

(setq frame-inhibit-implied-resize t)
;;disattivazione controllo di vc dei buffer per verificare se
;;file git,attivo solo se trovato git
;;disattivo vc
;;(setq vc-handled-backends nil)
(setq vc-handled-backends '(Git))
(setq vc-defer-load t)




(use-package dashboard
  :ensure t
  :config
  ;; Logo: PNG in GUI, ASCII in TTY
  (if (display-graphic-p)
      (setq dashboard-startup-banner "~/.emacs.d/loghi-emacs/gnu_color.png")
    (setq dashboard-startup-banner 'logo
          dashboard-ascii-banner-centered t))

  ;; Usa project.el invece di Projectile
  (setq dashboard-projects-backend 'project-el)

  ;; Opzioni estetiche
  (setq dashboard-center-content t)
  (setq dashboard-show-shortcuts t)

  ;; Sezioni mostrate
  (setq dashboard-items '((recents  . 10)
                          (projects . 7))))

;; Attiva dashboard
(dashboard-setup-startup-hook)

;; Centra verticalmente la dashboard
(add-hook 'dashboard-after-initialize-hook
          (lambda ()
            (goto-char (point-min))
            (let* ((lines (count-lines (point-min) (point-max)))
                   (margin (max 0 (/ (- (window-height) lines) 2))))
              (insert (make-string margin ?\n)))))




;;tab-bar-mode
;;(tab-bar-mode t)


;CONFIGURIAMO ELFEED
(use-package elfeed
  :defer t
  :ensure t
  :config
  (setq elfeed-feeds
        '(
          ;; Emacs
          ("https://planet.emacslife.com/atom.xml" emacs)
          ("https://sachachua.com/blog/feed/" emacs)
          ("https://irreal.org/blog/?feed=rss2" emacs)
          ("https://www.gnu.org/software/emacs/rss.xml" emacs)

          ;; Fotografia
          ("https://www.35mmc.com/feed/" photo)
          ("https://phillipreeve.net/blog/feed/" photo)
          ("https://www.thephoblographer.com/feed/" photo)
          ("https://mrleica.com/feed/" photo)

          ;; YouTube (via RSS)
          ("https://www.youtube.com/feeds/videos.xml?channel_id=UCRte2QViSKBN5tM5YL7tTcg" youtube)
          ("https://www.youtube.com/feeds/videos.xml?channel_id=UCknMR7NOY6ZKcVbyzOxQPhw" youtube)
	  ("https://www.youtube.com/feeds/videos.xml?channel_id=UCs52U_Q9TYSHtd9oxD4WN0A" youtube)
	  ("https://www.youtube.com/feeds/videos.xml?channel_id=UCxSiyTe60iQAY1UqCylNMmw" youtube)
	  ("https://www.youtube.com/feeds/videos.xml?channel_id=UC05XpvbHZUQOfA6xk4dlmcw" youtube)
          )))

(use-package elfeed-tube
  :ensure t
  :after elfeed
  :bind (:map elfeed-show-mode-map
         ("F" . elfeed-tube-fetch)
         ([remap save-buffer] . elfeed-tube-save)
         :map elfeed-search-mode-map
         ("F" . elfeed-tube-fetch)
         ([remap save-buffer] . elfeed-tube-save)))

(with-eval-after-load 'elfeed-tube
  (elfeed-tube-setup))

(use-package elfeed-tube-mpv
  :ensure t
  :after elfeed-tube
  :bind (:map elfeed-show-mode-map
              ("C-c C-f" . elfeed-tube-mpv-follow-mode)
              ("C-c C-w" . elfeed-tube-mpv-where)))
(with-eval-after-load 'elfeed-tube-mpv
  (define-key elfeed-show-mode-map (kbd "V") #'elfeed-tube-mpv))
;;scorciatoia per elfeed
(global-set-key (kbd "C-c e") #'elfeed)
;;leggere articoli in eww come default
;(setq browse-url-browser-function #'eww-browse-url)


(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-enabled-themes '(wombat atom-dark))
 '(custom-safe-themes
   '("ca1b398ceb1b61709197478dc7f705b8337a0a9631e399948e643520c5557382"
     "166a2faa9dc5b5b3359f7a31a09127ebf7a7926562710367086fcc8fc72145da"
     "0325a6b5eea7e5febae709dab35ec8648908af12cf2d2b569bedc8da0a3a81c1"
     "fffef514346b2a43900e1c7ea2bc7d84cbdd4aa66c1b51946aade4b8d343b55a"
     "6963de2ec3f8313bb95505f96bf0cf2025e7b07cefdb93e3d2e348720d401425"
     "e4a702e262c3e3501dfe25091621fe12cd63c7845221687e36a79e17cf3a67e0"
     "4594d6b9753691142f02e67b8eb0fda7d12f6cc9f1299a49b819312d6addad1d"
     "b5fd9c7429d52190235f2383e47d340d7ff769f141cd8f9e7a4629a81abc6b19"
     "720838034f1dd3b3da66f6bd4d053ee67c93a747b219d1c546c41c4e425daf93"
     "a5c590aeb7dc5c2b8d36601a4c94a1145e46bd2291571af02807dd7a8552630c"
     default))
 '(package-selected-packages nil))


(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
(put 'completion-list-mode 'disabled t)
