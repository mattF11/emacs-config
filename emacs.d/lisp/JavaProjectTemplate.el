;;RIMANDA PROJECTILE AL TEMPLATE DEL PROGETTO COPIATO DA ECLIPSE
;;per aggiungere progetto template usi M-x projectile-create-project
 (defun JavaProjectTemplate ()
  (interactive)
  (let* ((name (read-string "Nome progetto: "))
         (dir (read-directory-name "Dove salvarlo: "))
         (dest (concat dir "/" name))
         ;; Package OBBLIGATORIO
         (package-name (read-string "Nome del package: "))
         (template "~/.emacs.d/templates/eclipse-java"))

    ;; 1) Copia il template base
    (copy-directory template dest)

    ;; 2) Genera un nome modulo valido (minuscolo)
    (let* ((raw-name name)
           (module-name (downcase
                         (replace-regexp-in-string
                          "[^A-Za-z0-9_]" "_" raw-name)))
           (module-file (concat dest "/src/module-info.java")))
      (with-temp-file module-file
        (insert (format "module %s {\n" module-name))
        (insert (format "    exports %s;\n" package-name))
        (insert "}\n")))

    ;; 3) Gestione src e package (OBBLIGATORIO)
    (let* ((src-dir (concat dest "/src"))
           (pkg-dir (concat src-dir "/" package-name))
           (main-file (concat pkg-dir "/Main.java"))
           (pkg-info-file (concat pkg-dir "/package-info.java")))
      (make-directory pkg-dir t)

      ;; 4) Crea Main.java
      (with-temp-file main-file
        (insert (format "package %s;\n\npublic class Main {\n    public static void main(String[] args) {\n        System.out.println(\"Hello\");\n    }\n}\n" package-name)))

      ;; 5) Crea package-info.java
      (with-temp-file pkg-info-file
        (insert (format "package %s;\n" package-name))))

    ;; 6) Makefile corretto
    (with-temp-file (concat dest "/Makefile")
      (insert "MAIN_CLASS := $(shell grep -Rsl \"public static void main\" src | sed 's/src\\///; s/\\.java//; s/\\//./g')\n")
      (insert "MODULE := $(shell basename $(CURDIR) | tr 'A-Z' 'a-z')\n\n")
      (insert "build:\n\tjavac -d bin $(shell find src -name \"*.java\")\n\n")
      (insert "run:\n\tjava -p bin -m $(MODULE)/$(MAIN_CLASS)\n\n")
      (insert "clean:\n\trm -rf bin/*\n"))

    ;; 7) Sostituisce ${project-name} nel file .project
    (let* ((project-file (concat dest "/.project"))
           (content (with-temp-buffer
                      (insert-file-contents project-file)
                      (buffer-string))))
      (with-temp-file project-file
        (insert (replace-regexp-in-string "\\${project-name}" name content))))

    ;; 8) Genera .classpath con JDK rilevato
    (let* ((classpath-file (concat dest "/.classpath"))
           (version-str (shell-command-to-string "java -version 2>&1 | head -n 1"))
           (jdk-version (replace-regexp-in-string ".*\"\\([0-9]+\\).*" "\\1" version-str))
           (jdk-name (format "JDK %s" jdk-version)))
      (with-temp-file classpath-file
        (insert "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n")
        (insert "<classpath>\n")
        (insert "    <classpathentry kind=\"src\" path=\"src\"/>\n")
        (insert (format "    <classpathentry kind=\"con\" path=\"org.eclipse.jdt.launching.JRE_CONTAINER/org.eclipse.jdt.internal.debug.ui.launcher.StandardVMType/%s\"/>\n" jdk-name))
        (insert "    <classpathentry kind=\"output\" path=\"bin\"/>\n")
        (insert "</classpath>\n")))

    ;; 9) Genera org.eclipse.jdt.core.prefs
    (let* ((prefs-dir (concat dest "/.settings"))
           (prefs-file (concat prefs-dir "/org.eclipse.jdt.core.prefs"))
           (version-str (shell-command-to-string "java -version 2>&1 | head -n 1"))
           (jdk-version (replace-regexp-in-string ".*\"\\([0-9]+\\).*" "\\1" version-str)))
      (make-directory prefs-dir t)
      (with-temp-file prefs-file
        (insert "eclipse.preferences.version=1\n")
        (insert (format "org.eclipse.jdt.core.compiler.codegen.targetPlatform=%s\n" jdk-version))
        (insert "org.eclipse.jdt.core.compiler.codegen.unusedLocal=preserve\n")
        (insert (format "org.eclipse.jdt.core.compiler.compliance=%s\n" jdk-version))
        (insert "org.eclipse.jdt.core.compiler.debug.lineNumber=generate\n")
        (insert "org.eclipse.jdt.core.compiler.debug.localVariable=generate\n")
        (insert "org.eclipse.jdt.core.compiler.debug.sourceFile=generate\n")
        (insert "org.eclipse.jdt.core.compiler.problem.enablePreviewFeatures=disabled\n")
        (insert "org.eclipse.jdt.core.compiler.problem.reportPreviewFeatures=warning\n")
        (insert "org.eclipse.jdt.core.compiler.release=enabled\n")
        (insert (format "org.eclipse.jdt.core.compiler.source=%s\n" jdk-version))))

    ;; 10) Aggiungi a Projectile
    (projectile-add-known-project dest)

    (message "Progetto creato: %s" dest)))
