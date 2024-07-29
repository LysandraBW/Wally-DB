USE WALTRONICS;
GO

DROP PROCEDURE Appointment.UpdateVehicle;
GO

CREATE PROCEDURE Appointment.UpdateVehicle (
	@SessionID		CHAR(36),
	@AppointmentID	UNIQUEIDENTIFIER,
	@Make			VARCHAR(50)	=	NULL,
	@Model			VARCHAR(50)	=	NULL,
	@ModelYear		INT			=	NULL,
	@VIN			VARCHAR(17)	=	NULL,
	@Mileage		INT			=	NULL,
	@LicensePlate	VARCHAR(8)	=	NULL
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

	IF (@Make IS NOT NULL)
	BEGIN
		UPDATE	Appointment.Vehicle
		SET		Make			= @Make
		WHERE	AppointmentID	= @AppointmentID;

		DECLARE @M1 VARCHAR(400) = 'Updated Make to ''' + @Make + '''';
		EXEC	Employee.LogModification 
				@SessionID, 
				@AppointmentID, 
				@M1;
	END;

	IF (@Model IS NOT NULL)
	BEGIN
		UPDATE	Appointment.Vehicle
		SET		Model			= @Model
		WHERE	AppointmentID	= @AppointmentID;

		DECLARE @M2 VARCHAR(400) = 'Updated Model to ''' + @Model + '''';
		EXEC	Employee.LogModification 
				@SessionID, 
				@AppointmentID, 
				@M2;
	END;

	IF (@ModelYear IS NOT NULL)
	BEGIN
		UPDATE	Appointment.Vehicle
		SET		ModelYear		= @ModelYear
		WHERE	AppointmentID	= @AppointmentID;

		DECLARE @M3 VARCHAR(400) = 'Updated Model Year to ''' + CAST(@ModelYear AS VARCHAR) + '''';
		EXEC	Employee.LogModification 
				@SessionID, 
				@AppointmentID, 
				@M3;
	END;

	IF (@VIN IS NOT NULL)
	BEGIN
		UPDATE	Appointment.Vehicle
		SET		VIN				= @VIN
		WHERE	AppointmentID	= @AppointmentID;

		DECLARE @M4 VARCHAR(400) = 'Updated VIN to ''' + @VIN + '''';
		EXEC	Employee.LogModification 
				@SessionID, 
				@AppointmentID, 
				@M4;
	END;

	IF (@Mileage IS NOT NULL)
	BEGIN
		UPDATE	Appointment.Vehicle
		SET		Mileage			= @Mileage
		WHERE	AppointmentID	= @AppointmentID;

		DECLARE @M5 VARCHAR(400) = 'Updated Mileage to ''' + CAST(@Mileage AS VARCHAR) + '''';
		EXEC	Employee.LogModification 
				@SessionID, 
				@AppointmentID, 
				@M5;
	END;

	IF (@LicensePlate IS NOT NULL)
	BEGIN
		UPDATE	Appointment.Vehicle
		SET		LicensePlate	= @LicensePlate
		WHERE	AppointmentID	= @AppointmentID;

		DECLARE @M6 VARCHAR(400) = 'Updated License Plate to ''' + @LicensePlate + '''';
		EXEC	Employee.LogModification 
				@SessionID, 
				@AppointmentID, 
				@M6;
	END;

	COMMIT TRANSACTION;
END;
GO