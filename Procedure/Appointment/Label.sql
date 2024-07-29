USE WALTRONICS;
GO

DROP PROCEDURE Appointment.UpdateLabel;
GO

CREATE PROCEDURE Appointment.UpdateLabel (
	@SessionID		CHAR(36),
	@AppointmentID	UNIQUEIDENTIFIER,
	@LabelID		INT
)
AS
BEGIN
	SET NOCOUNT ON;
	SET XACT_ABORT ON;
	BEGIN TRANSACTION;

	DECLARE @SessionEmployeeID UNIQUEIDENTIFIER;
	EXEC	Employee.AuthenticateSession 
			@SessionID, 
			@SessionEmployeeID OUTPUT;

	IF (NOT EXISTS(
			SELECT	* 
			FROM	Appointment.Label 
			WHERE	AppointmentID	= @AppointmentID AND
					EmployeeID		= @SessionEmployeeID AND
					LabelID			= @LabelID
	))
	BEGIN
		INSERT Appointment.Label 
		VALUES (
			@AppointmentID, 
			@SessionEmployeeID,
			@LabelID,
			0
		);
	END;

	UPDATE	Appointment.Label
	SET		Value = ~Value
	WHERE	AppointmentID = @AppointmentID AND
			EmployeeID = @SessionEmployeeID AND
			LabelID = @LabelID;

	COMMIT TRANSACTION;
END;
GO

DROP PROCEDURE Appointment.GetLabels;
GO

CREATE PROCEDURE Appointment.GetLabels (
	@SessionID		CHAR(36),
	@AppointmentID	UNIQUEIDENTIFIER
)
AS
BEGIN
	SET NOCOUNT ON;
	SET XACT_ABORT ON;
	BEGIN TRANSACTION;

	DECLARE @SessionEmployeeID UNIQUEIDENTIFIER;
	EXEC	Employee.AuthenticateSession 
			@SessionID, 
			@SessionEmployeeID OUTPUT;

	SELECT		DISTINCT
				Info.Label.Label,
				Info.Label.LabelID,
				'Value' =
				CASE
					WHEN AppointmentLabel.Value IS NULL THEN 0 
					ELSE AppointmentLabel.Value
				END
	FROM		Appointment.ID
	CROSS JOIN	Info.Label
	LEFT JOIN	Appointment.Label AS AppointmentLabel ON AppointmentLabel.AppointmentID = Appointment.ID.AppointmentID AND Info.Label.LabelID = AppointmentLabel.LabelID
	WHERE		Appointment.ID.AppointmentID = @AppointmentID AND
				(AppointmentLabel.EmployeeID = @SessionEmployeeID OR AppointmentLabel.EmployeeID IS NULL);

	COMMIT TRANSACTION;
END;
GO

DROP PROCEDURE Appointment.GetAllLabels;
GO

CREATE PROCEDURE Appointment.GetAllLabels (
	@SessionID		CHAR(36)
)
AS
BEGIN
	SET NOCOUNT ON;
	SET XACT_ABORT ON;
	BEGIN TRANSACTION;

	DECLARE @SessionEmployeeID UNIQUEIDENTIFIER;
	EXEC	Employee.AuthenticateSession 
			@SessionID, 
			@SessionEmployeeID OUTPUT;

	SELECT	AppLabel.AppointmentID,
			AppLabel.LabelID,
			InfoLabel.Label,
			AppLabel.Value
	FROM	Appointment.Label AS AppLabel
	JOIN	Info.Label AS InfoLabel ON AppLabel.LabelID = InfoLabel.LabelID
	WHERE	AppLabel.EmployeeID = @SessionEmployeeID;

	COMMIT TRANSACTION;
END;
GO