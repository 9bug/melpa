;;; code-stats.el --- Code::Stats plugin             -*- lexical-binding: t; -*-

;; Copyright (C) 2018  Xu Chunyang

;; Author: Xu Chunyang <mail@xuchunyang.me>
;; Homepage: https://github.com/xuchunyang/code-stats-emacs
;; Package-Requires: ((emacs "25") (request "0.3.0"))
;; Package-Version: 20201209.2135
;; Package-Commit: 9a467dfd6a3cef849468623e1c085cbf59dac154
;; Created: 2018-07-13T13:29:18+08:00
;; Version: 0.1

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <https://www.gnu.org/licenses/>.

;;; Commentary:

;; Code::Stats plugin for Emacs
;;
;; See https://github.com/xuchunyang/code-stats-emacs for more info

;;; Code:

(require 'cl-lib)
(require 'request)
(require 'json)

;; Set it to https://beta.codestats.net for testing
(defvar code-stats-url "https://codestats.net")

(defvar code-stats-token nil)

(defvar-local code-stats-xp 0
  "XP for the current buffer.")

(defvar code-stats-xp-cache nil
  "XP for the killed buffers.")

(defun code-stats-post-self-insert ()
  (cl-incf code-stats-xp))

(defun code-stats-cache-xp ()
  (when (> code-stats-xp 0)
    (push (cons (code-stats-get-language)
                code-stats-xp)
          code-stats-xp-cache)))

;;;###autoload
(define-minor-mode code-stats-mode
  "Code Stats Minor Mode."
  :init-value nil
  :lighter " Code::Stats"
  (if code-stats-mode
      (progn
        (add-hook 'post-self-insert-hook #'code-stats-post-self-insert :append :local)
        (add-hook 'kill-buffer-hook #'code-stats-cache-xp nil :local))
    (remove-hook 'post-self-insert-hook #'code-stats-post-self-insert :local)
    (remove-hook 'kill-buffer-hook #'code-stats-cache-xp :local)))

(defvar code-stats-languages-by-mode
  '((c++-mode . "C++")
    (c-mode . "C")
    (cperl-mode . "Perl")
    (emacs-lisp-mode . "Emacs Lisp")
    (lisp-interaction-mode . "Emacs Lisp")
    (html-mode . "HTML")
    (mhtml-mode . "HTML")
    (js2-mode . "JavaScript")
    (sh-mode . "Shell"))
  "Alist of mapping `major-mode' to language name.")

(defvar code-stats-languages-by-extension
  '((ada . "Ada")
    (ansible . "Ansible")
    (ansible_hosts . "Ansible")
    (ansible_template . "Ansible")
    (c . "C")
    (cs . "C#")
    (clojure . "Clojure")
    (cmake . "CMake")
    (coffee . "CoffeeScript")
    (cpp . "C++")
    (css . "CSS")
    (dart . "Dart")
    (diff . "Diff")
    (eelixir . "HTML (EEx)")
    (elixir . "Elixir")
    (elm . "Elm")
    (erlang . "Erlang")
    (fish . "Shell Script (fish)")
    (fsharp . "F#")
    (gitcommit . "Git Commit Message")
    (gitconfig . "Git Config")
    (gitrebase . "Git Rebase Message")
    (glsl . "GLSL")
    (go . "Go")
    (haskell . "Haskell")
    (html . "HTML")
    (htmldjango . "HTML (Django)")
    (java . "Java")
    (javascript . "JavaScript")
    (json . "JSON")
    (jsp . "JSP")
    (jsx . "JavaScript (JSX)")
    (kotlin . "Kotlin")
    (markdown . "Markdown")
    (objc . "Objective-C")
    (objcpp . "Objective-C++")
    (ocaml . "OCaml")
    (pascal . "Pascal")
    (perl . "Perl")
    (perl6 . "Perl 6")
    (pgsql . "SQL (PostgreSQL)")
    (php . "PHP")
    (plsql . "PL/SQL")
    (puppet . "Puppet")
    (purescript . "PureScript")
    (python . "Python")
    (ruby . "Ruby")
    (rust . "Rust")
    (scala . "Scala")
    (scheme . "Scheme")
    (scss . "SCSS")
    (sh . "Shell Script")
    (sql . "SQL")
    (sqloracle . "SQL (Oracle)")
    (tcl . "Tcl")
    (tcsh . "Shell Script (tcsh)")
    (tex . "TeX")
    (toml . "TOML")
    (typescript . "TypeScript")
    (vb . "Visual Basic")
    (vbnet . "Visual Basic .NET")
    (vim . "VimL")
    (yaml . "YAML")
    (zsh . "Shell Script (Zsh)")
    (2html . "2html")
    (Jenkinsfile . "Jenkinsfile")
    (a2ps . "a2ps")
    (a65 . "a65")
    (aap . "aap")
    (abap . "abap")
    (abaqus . "abaqus")
    (abc . "abc")
    (abel . "abel")
    (acedb . "acedb")
    (aflex . "aflex")
    (ahdl . "ahdl")
    (alsaconf . "alsaconf")
    (amiga . "amiga")
    (aml . "aml")
    (ampl . "ampl")
    (ant . "ant")
    (antlr . "antlr")
    (apache . "apache")
    (apachestyle . "apachestyle")
    (apiblueprint . "apiblueprint")
    (applescript . "applescript")
    (aptconf . "aptconf")
    (arch . "arch")
    (arduino . "arduino")
    (art . "art")
    (asciidoc . "asciidoc")
    (asm . "asm")
    (asm68k . "asm68k")
    (asmh8300 . "asmh8300")
    (asn . "asn")
    (aspperl . "aspperl")
    (aspvbs . "aspvbs")
    (asterisk . "asterisk")
    (asteriskvm . "asteriskvm")
    (atlas . "atlas")
    (autohotkey . "autohotkey")
    (autoit . "autoit")
    (automake . "automake")
    (ave . "ave")
    (avra . "avra")
    (awk . "awk")
    (ayacc . "ayacc")
    (b . "b")
    (baan . "baan")
    (basic . "basic")
    (bc . "bc")
    (bdf . "bdf")
    (bib . "bib")
    (bindzone . "bindzone")
    (blade . "blade")
    (blank . "blank")
    (bst . "bst")
    (btm . "btm")
    (bzl . "bzl")
    (bzr . "bzr")
    (cabal . "cabal")
    (caddyfile . "caddyfile")
    (calendar . "calendar")
    (catalog . "catalog")
    (cdl . "cdl")
    (cdrdaoconf . "cdrdaoconf")
    (cdrtoc . "cdrtoc")
    (cf . "cf")
    (cfg . "cfg")
    (ch . "ch")
    (chaiscript . "chaiscript")
    (change . "change")
    (changelog . "changelog")
    (chaskell . "chaskell")
    (cheetah . "cheetah")
    (chill . "chill")
    (chordpro . "chordpro")
    (cl . "cl")
    (clean . "clean")
    (clipper . "clipper")
    (cmusrc . "cmusrc")
    (cobol . "cobol")
    (coco . "coco")
    (colortest . "colortest")
    (conaryrecipe . "conaryrecipe")
    (conf . "conf")
    (config . "config")
    (context . "context")
    (cql . "cql")
    (crm . "crm")
    (crontab . "crontab")
    (cryptol . "cryptol")
    (crystal . "crystal")
    (csc . "csc")
    (csdl . "csdl")
    (csh . "csh")
    (csp . "csp")
    (cterm . "cterm")
    (ctrlh . "ctrlh")
    (cucumber . "cucumber")
    (cuda . "cuda")
    (cupl . "cupl")
    (cuplsim . "cuplsim")
    (cvs . "cvs")
    (cvsrc . "cvsrc")
    (cweb . "cweb")
    (cynlib . "cynlib")
    (cynpp . "cynpp")
    (d . "d")
    (datascript . "datascript")
    (dcd . "dcd")
    (dcl . "dcl")
    (debchangelog . "debchangelog")
    (debcontrol . "debcontrol")
    (debsources . "debsources")
    (def . "def")
    (denyhosts . "denyhosts")
    (desc . "desc")
    (desktop . "desktop")
    (dictconf . "dictconf")
    (dictdconf . "dictdconf")
    (dircolors . "dircolors")
    (dirpager . "dirpager")
    (diva . "diva")
    (django . "django")
    (dns . "dns")
    (dnsmasq . "dnsmasq")
    (docbk . "docbk")
    (docbksgml . "docbksgml")
    (docbkxml . "docbkxml")
    (dockerfile . "dockerfile")
    (dosbatch . "dosbatch")
    (dosini . "dosini")
    (dot . "dot")
    (doxygen . "doxygen")
    (dracula . "dracula")
    (dsl . "dsl")
    (dtd . "dtd")
    (dtml . "dtml")
    (dtrace . "dtrace")
    (dts . "dts")
    (dylan . "dylan")
    (dylanintr . "dylanintr")
    (dylanlid . "dylanlid")
    (ecd . "ecd")
    (edif . "edif")
    (eiffel . "eiffel")
    (elf . "elf")
    (elinks . "elinks")
    (elmfilt . "elmfilt")
    (ember-script . "ember-script")
    (emblem . "emblem")
    (eruby . "eruby")
    (esmtprc . "esmtprc")
    (esqlc . "esqlc")
    (esterel . "esterel")
    (eterm . "eterm")
    (euphoria3 . "euphoria3")
    (euphoria4 . "euphoria4")
    (eviews . "eviews")
    (exim . "exim")
    (expect . "expect")
    (exports . "exports")
    (falcon . "falcon")
    (fan . "fan")
    (fasm . "fasm")
    (fdcc . "fdcc")
    (fetchmail . "fetchmail")
    (fgl . "fgl")
    (flexwiki . "flexwiki")
    (focexec . "focexec")
    (form . "form")
    (forth . "forth")
    (fortran . "fortran")
    (foxpro . "foxpro")
    (framescript . "framescript")
    (freebasic . "freebasic")
    (fstab . "fstab")
    (fvwm . "fvwm")
    (fvwm2m4 . "fvwm2m4")
    (gdb . "gdb")
    (gdmo . "gdmo")
    (gedcom . "gedcom")
    (git . "git")
    (gitolite . "gitolite")
    (gitsendemail . "gitsendemail")
    (gkrellmrc . "gkrellmrc")
    (gmpl . "gmpl")
    (gnash . "gnash")
    (gnuplot . "gnuplot")
    (godefstack . "godefstack")
    (godoc . "godoc")
    (gohtmltmpl . "gohtmltmpl")
    (gotexttmpl . "gotexttmpl")
    (gp . "gp")
    (gpg . "gpg")
    (gprof . "gprof")
    (grads . "grads")
    (gretl . "gretl")
    (groff . "groff")
    (groovy . "groovy")
    (group . "group")
    (grub . "grub")
    (gsp . "gsp")
    (gtkrc . "gtkrc")
    (haml . "haml")
    (hamster . "hamster")
    (haste . "haste")
    (hastepreproc . "hastepreproc")
    (haxe . "haxe")
    (hb . "hb")
    (help . "help")
    (hercules . "hercules")
    (hex . "hex")
    (hgcommit . "hgcommit")
    (hitest . "hitest")
    (hog . "hog")
    (hostconf . "hostconf")
    (hostsaccess . "hostsaccess")
    (htmlcheetah . "htmlcheetah")
    (htmlm4 . "htmlm4")
    (htmlos . "htmlos")
    (i3 . "i3")
    (ia64 . "ia64")
    (ibasic . "ibasic")
    (icemenu . "icemenu")
    (icon . "icon")
    (idl . "idl")
    (idlang . "idlang")
    (indent . "indent")
    (inform . "inform")
    (initex . "initex")
    (initng . "initng")
    (inittab . "inittab")
    (ipfilter . "ipfilter")
    (ishd . "ishd")
    (iss . "iss")
    (ist . "ist")
    (j . "j")
    (jal . "jal")
    (jam . "jam")
    (jargon . "jargon")
    (jasmine . "jasmine")
    (javacc . "javacc")
    (jess . "jess")
    (jgraph . "jgraph")
    (jinja2 . "jinja2")
    (jovial . "jovial")
    (jproperties . "jproperties")
    (jst . "jst")
    (julia . "julia")
    (kconfig . "kconfig")
    (kivy . "kivy")
    (kix . "kix")
    (kscript . "kscript")
    (kwt . "kwt")
    (lace . "lace")
    (latextoc . "latextoc")
    (latte . "latte")
    (ld . "ld")
    (ldapconf . "ldapconf")
    (ldif . "ldif")
    (less . "less")
    (lex . "lex")
    (lftp . "lftp")
    (lhaskell . "lhaskell")
    (libao . "libao")
    (lifelines . "lifelines")
    (lilo . "lilo")
    (limits . "limits")
    (liquid . "liquid")
    (lisp . "lisp")
    (litcoffee . "litcoffee")
    (lite . "lite")
    (litestep . "litestep")
    (loginaccess . "loginaccess")
    (logindefs . "logindefs")
    (logtalk . "logtalk")
    (lotos . "lotos")
    (lout . "lout")
    (lpc . "lpc")
    (lprolog . "lprolog")
    (ls . "ls")
    (lscript . "lscript")
    (lsl . "lsl")
    (lss . "lss")
    (lua . "lua")
    (lynx . "lynx")
    (m4 . "m4")
    (mail . "mail")
    (mailaliases . "mailaliases")
    (mailcap . "mailcap")
    (make . "make")
    (mako . "mako")
    (mallard . "mallard")
    (man . "man")
    (manconf . "manconf")
    (manual . "manual")
    (maple . "maple")
    (masm . "masm")
    (mason . "mason")
    (master . "master")
    (matlab . "matlab")
    (maxima . "maxima")
    (mel . "mel")
    (messages . "messages")
    (mf . "mf")
    (mgl . "mgl")
    (mgp . "mgp")
    (mib . "mib")
    (mix . "mix")
    (mma . "mma")
    (mmix . "mmix")
    (mmp . "mmp")
    (modconf . "modconf")
    (model . "model")
    (modsim3 . "modsim3")
    (modula2 . "modula2")
    (modula3 . "modula3")
    (monk . "monk")
    (moo . "moo")
    (mp . "mp")
    (mplayerconf . "mplayerconf")
    (mrxvtrc . "mrxvtrc")
    (msidl . "msidl")
    (msmessages . "msmessages")
    (msql . "msql")
    (mupad . "mupad")
    (murphi . "murphi")
    (mush . "mush")
    (mustache . "mustache")
    (muttrc . "muttrc")
    (mysql . "mysql")
    (n1ql . "n1ql")
    (named . "named")
    (nanorc . "nanorc")
    (nasm . "nasm")
    (nastran . "nastran")
    (natural . "natural")
    (ncf . "ncf")
    (netrc . "netrc")
    (netrw . "netrw")
    (nginx . "nginx")
    (nim . "nim")
    (ninja . "ninja")
    (nix . "nix")
    (nosyntax . "nosyntax")
    (nqc . "nqc")
    (nroff . "nroff")
    (nsis . "nsis")
    (obj . "obj")
    (occam . "occam")
    (octave . "octave")
    (omnimark . "omnimark")
    (opencl . "opencl")
    (openroad . "openroad")
    (openscad . "openscad")
    (opl . "opl")
    (ora . "ora")
    (pamconf . "pamconf")
    (papp . "papp")
    (passwd . "passwd")
    (pcap . "pcap")
    (pccts . "pccts")
    (pdf . "pdf")
    (pf . "pf")
    (pfmain . "pfmain")
    (phtml . "phtml")
    (pic . "pic")
    (pike . "pike")
    (pilrc . "pilrc")
    (pine . "pine")
    (pinfo . "pinfo")
    (plaintex . "plaintex")
    (plantuml . "plantuml")
    (pli . "pli")
    (plm . "plm")
    (plp . "plp")
    (po . "po")
    (pod . "pod")
    (postscr . "postscr")
    (pov . "pov")
    (povini . "povini")
    (ppd . "ppd")
    (ppwiz . "ppwiz")
    (prescribe . "prescribe")
    (privoxy . "privoxy")
    (procmail . "procmail")
    (progress . "progress")
    (prolog . "prolog")
    (promela . "promela")
    (proto . "proto")
    (protocols . "protocols")
    (ps1 . "ps1")
    (ps1xml . "ps1xml")
    (psf . "psf")
    (ptcap . "ptcap")
    (pug . "pug")
    (purifylog . "purifylog")
    (pyrex . "pyrex")
    (qf . "qf")
    (qml . "qml")
    (quake . "quake")
    (r . "r")
    (racc . "racc")
    (racket . "racket")
    (radiance . "radiance")
    (ragel . "ragel")
    (raml . "raml")
    (ratpoison . "ratpoison")
    (rc . "rc")
    (rcs . "rcs")
    (rcslog . "rcslog")
    (readline . "readline")
    (rebol . "rebol")
    (redif . "redif")
    (registry . "registry")
    (remind . "remind")
    (resolv . "resolv")
    (reva . "reva")
    (rexx . "rexx")
    (rhelp . "rhelp")
    (rib . "rib")
    (rmd . "rmd")
    (rnc . "rnc")
    (rng . "rng")
    (rnoweb . "rnoweb")
    (robots . "robots")
    (rpcgen . "rpcgen")
    (rpl . "rpl")
    (rrst . "rrst")
    (rspec . "rspec")
    (rst . "rst")
    (rtf . "rtf")
    (samba . "samba")
    (sas . "sas")
    (sass . "sass")
    (sather . "sather")
    (sbt . "sbt")
    (scilab . "scilab")
    (screen . "screen")
    (sd . "sd")
    (sdc . "sdc")
    (sdl . "sdl")
    (sed . "sed")
    (sendpr . "sendpr")
    (sensors . "sensors")
    (services . "services")
    (setserial . "setserial")
    (sgml . "sgml")
    (sgmldecl . "sgmldecl")
    (sgmllnx . "sgmllnx")
    (sicad . "sicad")
    (sieve . "sieve")
    (simula . "simula")
    (sinda . "sinda")
    (sindacmp . "sindacmp")
    (sindaout . "sindaout")
    (sisu . "sisu")
    (skill . "skill")
    (sl . "sl")
    (slang . "slang")
    (slice . "slice")
    (slim . "slim")
    (slpconf . "slpconf")
    (slpreg . "slpreg")
    (slpspi . "slpspi")
    (slrnrc . "slrnrc")
    (slrnsc . "slrnsc")
    (sm . "sm")
    (smarty . "smarty")
    (smcl . "smcl")
    (smil . "smil")
    (smith . "smith")
    (sml . "sml")
    (snnsnet . "snnsnet")
    (snnspat . "snnspat")
    (snnsres . "snnsres")
    (snobol4 . "snobol4")
    (solidity . "solidity")
    (spec . "spec")
    (specman . "specman")
    (spice . "spice")
    (splint . "splint")
    (spup . "spup")
    (spyce . "spyce")
    (sqlanywhere . "sqlanywhere")
    (sqlforms . "sqlforms")
    (sqlhana . "sqlhana")
    (sqlinformix . "sqlinformix")
    (sqlj . "sqlj")
    (sqr . "sqr")
    (squid . "squid")
    (srec . "srec")
    (sshconfig . "sshconfig")
    (sshdconfig . "sshdconfig")
    (st . "st")
    (stata . "stata")
    (stp . "stp")
    (strace . "strace")
    (stylus . "stylus")
    (sudoers . "sudoers")
    (svg . "svg")
    (svn . "svn")
    (swift . "swift")
    (sxhkdrc . "sxhkdrc")
    (syncolor . "syncolor")
    (synload . "synload")
    (syntax . "syntax")
    (sysctl . "sysctl")
    (systemd . "systemd")
    (systemverilog . "systemverilog")
    (tads . "tads")
    (tags . "tags")
    (tak . "tak")
    (takcmp . "takcmp")
    (takout . "takout")
    (tap . "tap")
    (tar . "tar")
    (taskdata . "taskdata")
    (taskedit . "taskedit")
    (tasm . "tasm")
    (teraterm . "teraterm")
    (terminfo . "terminfo")
    (terraform . "terraform")
    (texinfo . "texinfo")
    (texmf . "texmf")
    (textile . "textile")
    (tf . "tf")
    (thrift . "thrift")
    (tidy . "tidy")
    (tilde . "tilde")
    (tli . "tli")
    (tmux . "tmux")
    (tomdoc . "tomdoc")
    (tpp . "tpp")
    (trasys . "trasys")
    (treetop . "treetop")
    (trustees . "trustees")
    (tsalt . "tsalt")
    (tsscl . "tsscl")
    (tssgm . "tssgm")
    (tssop . "tssop")
    (tt2 . "tt2")
    (tt2html . "tt2html")
    (tt2js . "tt2js")
    (twig . "twig")
    (uc . "uc")
    (udevconf . "udevconf")
    (udevperm . "udevperm")
    (udevrules . "udevrules")
    (uil . "uil")
    (updatedb . "updatedb")
    (upstart . "upstart")
    (upstreamdat . "upstreamdat")
    (upstreaminstalllog . "upstreaminstalllog")
    (upstreamlog . "upstreamlog")
    (upstreamrpt . "upstreamrpt")
    (usserverlog . "usserverlog")
    (usw2kagtlog . "usw2kagtlog")
    (vala . "vala")
    (valgrind . "valgrind")
    (vcl . "vcl")
    (velocity . "velocity")
    (vera . "vera")
    (verilog . "verilog")
    (verilogams . "verilogams")
    (vgrindefs . "vgrindefs")
    (vhdl . "vhdl")
    (vifm . "vifm")
    (vimgo . "vimgo")
    (viminfo . "viminfo")
    (virata . "virata")
    (vmasm . "vmasm")
    (voscm . "voscm")
    (vrml . "vrml")
    (vroom . "vroom")
    (vsejcl . "vsejcl")
    (vue . "vue")
    (wdiff . "wdiff")
    (web . "web")
    (webmacro . "webmacro")
    (wget . "wget")
    (whitespace . "whitespace")
    (winbatch . "winbatch")
    (wml . "wml")
    (wsh . "wsh")
    (wsml . "wsml")
    (wvdial . "wvdial")
    (xbl . "xbl")
    (xdefaults . "xdefaults")
    (xf86conf . "xf86conf")
    (xhtml . "xhtml")
    (xinetd . "xinetd")
    (xkb . "xkb")
    (xmath . "xmath")
    (xml . "xml")
    (xmodmap . "xmodmap")
    (xpm . "xpm")
    (xpm2 . "xpm2")
    (xquery . "xquery")
    (xs . "xs")
    (xsd . "xsd")
    (xsl . "xsl")
    (xslt . "xslt")
    (xxd . "xxd")
    (yacc . "yacc")
    (z8a . "z8a")
    (zimbu . "zimbu"))
  "List of languages by its extensions, extracted from https://gitlab.com/code-stats/code-stats-vim/blob/master/plugin/codestats_filetypes.py")

(defun code-stats-add-language (pair)
  (push pair code-stats-languages-by-extension))

(defun code-stats-get-language ()
  (or (if (buffer-file-name)
          (cdr (assoc-string (file-name-extension buffer-file-name) code-stats-languages-by-extension t)))
      (alist-get major-mode code-stats-languages-by-mode)
      (if (stringp mode-name)
          mode-name
        (replace-regexp-in-string "-mode\\'" "" (symbol-name major-mode)))))

(defun code-stats-xps-merge (xps)
  (cl-loop for (language . xp) in xps
           with new-xps = '()
           if (assoc language new-xps)
           do (cl-incf (cdr (assoc language new-xps)) xp)
           else
           do (push (cons language xp) new-xps)
           finally return (sort new-xps (lambda (a b) (string< (car a) (car b))))))

;; (("Emacs-Lisp" . 429) ("Racket" . 18))
(defun code-stats-collect-xps ()
  (let (xps)
    (dolist (buf (buffer-list))
      (with-current-buffer buf
        (when (and code-stats-mode (> code-stats-xp 0))
          (let ((language (code-stats-get-language)))
            (push (cons language code-stats-xp) xps)))))
    (code-stats-xps-merge (append code-stats-xp-cache xps))))

(defun code-stats-reset-xps ()
  (dolist (buf (buffer-list))
    (with-current-buffer buf
      (when code-stats-mode
        (setq code-stats-xp 0))))
  (setq code-stats-xp-cache nil))

(defun code-stats-build-pulse ()
  (let ((xps (code-stats-collect-xps)))
    (when xps
      `((coded_at . ,(format-time-string "%FT%T%z"))
        (xps . [,@(cl-loop for (language . xp) in xps
                           collect `((language . ,language)
                                     (xp . ,xp)))])))))

;; TODO: Log sent pulse
;;;###autoload
(defun code-stats-sync (&optional wait)
  "Sync with Code::Stats.
If WAIT is non-nil, block Emacs until the process is done."
  (let ((pulse (code-stats-build-pulse)))
    (when pulse
      (when wait
        (message "[code-stats] Syncing Code::Stats..."))
      (request (concat code-stats-url "/api/my/pulses")
               :sync wait
               :type "POST"
               :headers `(("X-API-Token"  . ,code-stats-token)
                          ("User-Agent"   . "code-stats-emacs")
                          ("Content-Type" . "application/json"))
               :data (json-encode pulse)
               :parser #'json-read
               :error (cl-function
                       (lambda (&key data error-thrown &allow-other-keys)
                         (message "[code-stats] Got error: %S - %S"
                                  error-thrown
                                  (cdr (assq 'error data)))))
               :success (cl-function
                         (lambda (&key _data &allow-other-keys)
                           ;; (message "%s" (cdr (assq 'ok data)))
                           (code-stats-reset-xps)))))))

(provide 'code-stats)
;;; code-stats.el ends here
