# powershell_fileScanner
A Powershell Script to log Changes on FileSystems in a SQL Database

# Überblick
FileScan.ps1 ist ein PowerShell-Skript, das Informationen über Dateien und Verzeichnisse eines angegebenen Laufwerks sammelt und diese Daten dann in eine SQL-Datenbank überträgt.

# Beschreibung
Zielsetzung des Projektes ist es, dass die Dateien auf einem Laufwerk gescannt werden mit (GEt-ChildItem) und dann in einer
SQL-Datenbank gespeichert werden. Dort wird dann eine Historie aufgebaut und über mehrer Festplatten/Rechner auch getrackt, 
welche Dateien doppelt vorhanden sind. 

# Autor:
Erhard Rainer

Erstellt am: 15.03.2017

Dateiname: FileScan.ps1

Beschreibung:
Das Skript durchsucht ein Laufwerk (standardmäßig das aktuelle Laufwerk, auf dem das Skript ausgeführt wird) und sammelt Informationen über alle gefundenen Dateien und Verzeichnisse. Diese Informationen werden dann in eine vorgefertigte SQL-Datenbank hochgeladen, wobei der Code zurzeit einen SQL-Server mit dem Namen "SQLServer" und eine Datenbank namens "externalMedia" verwendet.

# Funktionsweise
Das Skript überprüft zunächst, ob ein Laufwerk als Parameter angegeben wurde. Wenn nicht, wird das aktuelle Laufwerk als Standard verwendet.
Informationen über das Laufwerk werden gesammelt.
Alle Dateien und Verzeichnisse auf dem Laufwerk werden in ein DataTable-Objekt aufgenommen.
Diese Daten werden dann in Stapeln (bisher auf 100.000 Dateien beschränkt) in die SQL-Datenbank hochgeladen.
Verwendung:
Das Skript kann aus der PowerShell-Umgebung oder über eine andere Methode ausgeführt werden, die die Ausführung von PowerShell-Skripten ermöglicht.

Beispiel:

.\FileScan.ps1 -currentDrive C

In diesem Beispiel wird das Skript angewiesen, das Laufwerk C:\ zu scannen und die Daten in die SQL-Datenbank zu übertragen.

# Abhängigkeiten:
Zugriff auf den SQL-Server ist erforderlich.
Die Datenbank "externalMedia" muss auf dem SQL-Server vorhanden sein und sollte das gespeicherte Prozedurverfahren [dbo].[usp_InsertExternalMedia] haben, das zum Einfügen der Daten verwendet wird.
Ausreichende Berechtigungen, um Daten in der SQL-Datenbank einzufügen.

# Fehlerbehandlung:
Das Skript fängt Fehler während des Einfügens der Daten in die Datenbank ab und gibt eine Warnmeldung aus. Es wird empfohlen, die Ausgabe und eventuelle Fehlermeldungen zu überwachen, um sicherzustellen, dass die Daten korrekt übertragen werden.
