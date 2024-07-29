USE WALTRONICS;
GO

DROP PROCEDURE Info.Statuses;
GO

CREATE PROCEDURE Info.Statuses
AS
BEGIN
	SET NOCOUNT ON;
	SELECT		StatusID,
				Status
	FROM		Info.Status
	ORDER BY	StatusID ASC;
END;
GO

DROP PROCEDURE Info.Services;
GO

CREATE PROCEDURE Info.Services
AS
BEGIN
	SET NOCOUNT ON;
	SELECT		Class,
				Division,
				Service,
				Info.ServiceClass.ClassID,
				Info.ServiceDivision.DivisionID,
				ServiceID
	FROM		Info.Service
	JOIN		Info.ServiceDivision			ON	Info.Service.DivisionID = Info.ServiceDivision.DivisionID
	JOIN		Info.ServiceClass				ON	Info.ServiceDivision.ClassID = Info.ServiceClass.ClassID
	ORDER BY	Info.ServiceClass.Class			ASC,
				Info.ServiceDivision.Division	ASC,
				Info.Service.Service			ASC;
END;
GO

DROP PROCEDURE Info.Labels;
GO

CREATE PROCEDURE Info.Labels
AS
BEGIN
	SET NOCOUNT ON;
	SELECT	LabelID,
			Label
	FROM	Info.Label;
END;
GO

DROP PROCEDURE Info.Makes;
GO

CREATE PROCEDURE Info.Makes
AS
BEGIN
	SET NOCOUNT ON;
	SELECT	Make
	FROM	Info.Make;
END;
GO

DROP PROCEDURE Info.SessionID;
GO

CREATE PROCEDURE Info.SessionID (
	@SessionID CHAR(36) OUTPUT
)
AS
BEGIN
	SELECT @SessionID = CONVERT(CHAR(36), NEWID());
END;
GO

DROP PROCEDURE Info.BeginCommit;
GO

CREATE PROCEDURE Info.BeginCommit
AS
BEGIN
	SET NOCOUNT ON;
	SET XACT_ABORT ON;
	BEGIN TRANSACTION;
END;
GO

DROP PROCEDURE Info.EndCommit;
GO

CREATE PROCEDURE Info.EndCommit
AS
BEGIN
	COMMIT TRANSACTION;
END;
GO