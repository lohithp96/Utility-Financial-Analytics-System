USE [SONGS]
GO
ALTER DATABASE SONGS MODIFY FILE (Name=SONGS_Log,MAXSIZE=250);
GO