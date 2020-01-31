SELECT [name]
FROM [dbo].[sysobjects] obj
INNER JOIN [dbo].[syscomments] cmt
ON obj.[id] = cmt.[id]
where cmt.[text] like '%cast%'