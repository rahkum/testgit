 DEFINE VARIABLE cSource       AS CHARACTER   NO-UNDO. 
 DEFINE VARIABLE cDestination  AS CHARACTER   NO-UNDO.  
 DEFINE VARIABLE cFileTypes    AS CHARACTER   NO-UNDO. 
 
 ASSIGN cSource      = "C:\Users\rahul.sharma\Desktop\gitPro\testgit\"
        cDestination = "C:\Users\rahul.sharma\Desktop\gitPro\compilefile\"
        cFileTypes   = "*.p,*.w".

 /*cFileTypes   = "*.p,*.r".*/

 RUN directoryRead (INPUT cSource).
 
/*
**
*/
 PROCEDURE directoryRead:
 
   DEFINE INPUT PARAMETER ipcPath  AS CHARACTER NO-UNDO.
 
   DEFINE VARIABLE cFileName     AS CHARACTER   NO-UNDO. 
   DEFINE VARIABLE cFile         AS CHARACTER   NO-UNDO.
   DEFINE VARIABLE cExtension    AS CHARACTER   NO-UNDO.
   DEFINE VARIABLE cSourcePath   AS CHARACTER   NO-UNDO.
   DEFINE VARIABLE cDestPath     AS CHARACTER   NO-UNDO.
   
   INPUT FROM OS-DIR (ipcPath) ECHO.
 
   REPEAT:

     IMPORT cFileName.
     FILE-INFO:FILE-NAME = ipcPath + cFileName.

     IF cFileName BEGINS ".":U THEN
       NEXT.

     /*
     ** Checks processed file is without extension or not.   
     */
     IF FILE-INFO:FILE-TYPE BEGINS "F":U AND INDEX(FILE-INFO:FULL-PATHNAME, ".") = 0 THEN 
       NEXT.
 
     IF FILE-INFO:FILE-TYPE BEGINS "F":U THEN
     DO:
       ASSIGN cFile      = ENTRY(NUM-ENTRIES(FILE-INFO:FULL-PATHNAME, "\":U), FILE-INFO:FULL-PATHNAME, "\":U)
              cExtension = "*.":U + ENTRY(2, cFile, ".":U).

       IF cFileTypes <> '':U AND LOOKUP(cExtension,cFileTypes) = 0 THEN
         NEXT.
 
       /*
       ** Creates copy of source file and placed it at destination location.
       */
       ASSIGN cSourcePath = FILE-INFO:FULL-PATHNAME
              cDestPath   = cDestination + REPLACE(FILE-INFO:FILE-NAME, cSource, "":U).
       
       compile VALUE(cSourcePath) SAVE INTO VALUE(cDestination).
 
     END. /* IF FILE-INFO:FILE-TYPE BEGINS "F":U THEN */
 
     /*
     ** If the currenty processed file is folder.
     */
     IF FILE-INFO:FILE-TYPE BEGINS "D":U  THEN
     DO:
       /*
       ** create folder at destination location.
       */
       OS-CREATE-DIR VALUE(cDestination + REPLACE(FILE-INFO:FILE-NAME, cSource, "":U)).
       /*
       ** Recursively fetch another files or folder.
       */
       RUN directoryRead (INPUT FILE-INFO:FULL-PATHNAME + "\":U). 
 
     END. /* IF FILE-INFO:FILE-TYPE BEGINS "D":U  THEN */
 
   END. /* Repeat */
 
 END PROCEDURE. /* PROCEDURE directoryRead: */
