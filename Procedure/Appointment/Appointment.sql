USE WALTRONICS;
GO

DROP PROCEDURE Appointment.InsertAppointment;
GO

CREATE PROCEDURE Appointment.InsertAppointment (
	@SessionID		CHAR(36) = NULL,
	@FName			VARCHAR(50),
	@LName			VARCHAR(50),
	@Email			VARCHAR(320),
	@Phone			VARCHAR(25),
	@Make			VARCHAR(50),
	@Model			VARCHAR(50),
	@ModelYear		INT,
	@VIN			VARCHAR(17)	= NULL
)
AS
BEGIN
	SET NOCOUNT ON;
	SET XACT_ABORT ON;
	BEGIN TRANSACTION;

	DECLARE @TCustomerID TABLE (ID UNIQUEIDENTIFIER);

	INSERT INTO Customer.Customer (
		CustomerID,
		FName,
		LName,
		Email,
		Phone
	)
	OUTPUT inserted.CustomerID INTO @TCustomerID
	VALUES (
		DEFAULT,
		@FName, 
		@LName, 
		@Email, 
		@Phone
	);

	DECLARE @CustomerID UNIQUEIDENTIFIER;
	SELECT	@CustomerID = ID
	FROM	@TCustomerID;
	
	DECLARE @TAppointmentID TABLE (ID UNIQUEIDENTIFIER);

	INSERT INTO Appointment.ID  (
		AppointmentID,
		CustomerID
	)
	OUTPUT inserted.AppointmentID INTO @TAppointmentID
	VALUES (
		DEFAULT,
		@CustomerID
	);

	DECLARE @AppointmentID UNIQUEIDENTIFIER;
	SELECT	@AppointmentID = ID
	FROM	@TAppointmentID;

	INSERT INTO Appointment.Date 
	VALUES (
		@AppointmentID, 
		GETDATE(), 
		GETDATE(),
		NULL,
		NULL
	);

	INSERT INTO Appointment.Vehicle 
	VALUES (
		@AppointmentID, 
		@Make, 
		@Model, 
		@ModelYear, 
		@VIN,
		NULL,
		NULL
	);

	INSERT INTO Appointment.Cost 
	VALUES (
		@AppointmentID,
		NULL
	);

	INSERT INTO Appointment.Status
	VALUES (
		@AppointmentID,
		0
	);

	IF (@SessionID IS NOT NULL)
	BEGIN
		DECLARE @SessionEmployeeID UNIQUEIDENTIFIER;
		EXEC	Employee.AuthenticateSession 
				@SessionID, 
				@SessionEmployeeID OUTPUT;

		EXEC	Employee.LogModification 
				@SessionID, 
				@AppointmentID, 
				'Inserted Appointment';
	END;

	SELECT @AppointmentID AS AppointmentID;
	COMMIT TRANSACTION;
END;
GO

DROP PROCEDURE Appointment.Get;
GO

CREATE PROCEDURE Appointment.Get (
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

	SELECT		AppointmentID.AppointmentID,
				AppointmentID.CustomerID,
				Customer.Customer.FName,
				Customer.Customer.LName,
				Customer.Customer.Email,
				Customer.Customer.Phone,
				Appointment.Date.CreationDate,
				Appointment.Date.UpdationDate,
				Appointment.Date.StartDate,
				Appointment.Date.EndDate,
				Appointment.Vehicle.Make,
				Appointment.Vehicle.Model,
				Appointment.Vehicle.ModelYear,
				Appointment.Vehicle.VIN,
				Appointment.Vehicle.Mileage,
				Appointment.Vehicle.LicensePlate,
				AppointmentStatus.StatusID,
				InfoStatus.Status,
				Appointment.Cost.Cost
	FROM		Appointment.ID						AS AppointmentID
	JOIN		Customer.Customer											ON	AppointmentID.CustomerID		= Customer.CustomerID
	JOIN		Appointment.Date											ON	AppointmentID.AppointmentID		= Appointment.Date.AppointmentID
	JOIN		Appointment.Vehicle											ON	AppointmentID.AppointmentID		= Appointment.Vehicle.AppointmentID
	JOIN		Appointment.Status					AS AppointmentStatus	ON	AppointmentID.AppointmentID		= AppointmentStatus.AppointmentID
	JOIN		Info.Status							AS InfoStatus			ON	InfoStatus.StatusID				= AppointmentStatus.StatusID
	JOIN		Appointment.Cost											ON	AppointmentID.AppointmentID		= Appointment.Cost.AppointmentID
	WHERE		AppointmentID.AppointmentID = @AppointmentID;

	EXEC	Appointment.GetServices 
			NULL,
			@AppointmentID;

	EXEC	Appointment.GetDiagnoses
			NULL,
			@AppointmentID;

	EXEC	Appointment.GetRepairs
			NULL,
			@AppointmentID;

	EXEC	Appointment.GetParts
			@AppointmentID;

	EXEC	Appointment.GetPayments
			@AppointmentID;

	EXEC	Appointment.GetLabels
			@SessionID,
			@AppointmentID

	EXEC	Appointment.GetEmployeeNotes
			@SessionID,
			@AppointmentID

	COMMIT TRANSACTION;
END;
GO

DROP PROCEDURE Appointment.GetSummary;
GO

CREATE PROCEDURE Appointment.GetSummary (
	@SessionID		CHAR(36) = NULL,
	@AppointmentID	UNIQUEIDENTIFIER
)
AS
BEGIN
	SET NOCOUNT ON;
	SET XACT_ABORT ON;
	BEGIN TRANSACTION;

	IF (USER_NAME() = 'Customer')
	BEGIN
		EXEC	Appointment.AuthorizeSession
				@SessionID,
				@AppointmentID
	END;

	SELECT	AppointmentID.AppointmentID,
			AppointmentID.CustomerID,
			Customer.Customer.FName,
			Customer.Customer.LName,
			Customer.Customer.Email,
			Customer.Customer.Phone,
			Appointment.Date.CreationDate,
			Appointment.Date.UpdationDate,
			Appointment.Date.StartDate,
			Appointment.Date.EndDate,
			Appointment.Vehicle.Make,
			Appointment.Vehicle.Model,
			Appointment.Vehicle.ModelYear,
			Appointment.Vehicle.VIN,
			Appointment.Vehicle.Mileage,
			Appointment.Vehicle.LicensePlate,
			AppointmentStatus.StatusID,
			InfoStatus.Status,
			Appointment.Cost.Cost
	FROM	Appointment.ID		AS AppointmentID
	JOIN	Customer.Customer								ON	AppointmentID.CustomerID	= Customer.CustomerID
	JOIN	Appointment.Date								ON	AppointmentID.AppointmentID = Appointment.Date.AppointmentID
	JOIN	Appointment.Vehicle								ON	AppointmentID.AppointmentID = Appointment.Vehicle.AppointmentID
	JOIN	Appointment.Status	AS AppointmentStatus		ON	AppointmentID.AppointmentID	= AppointmentStatus.AppointmentID
	JOIN	Info.Status			AS InfoStatus				ON	InfoStatus.StatusID			= AppointmentStatus.StatusID
	JOIN	Appointment.Cost								ON	AppointmentID.AppointmentID = Appointment.Cost.AppointmentID
	WHERE	AppointmentID.AppointmentID = @AppointmentID;

	EXEC	Appointment.GetServices 
			@SessionID,
			@AppointmentID;

	EXEC	Appointment.GetDiagnoses
			@SessionID,
			@AppointmentID;

	EXEC	Appointment.GetRepairs
			@SessionID,
			@AppointmentID;

	EXEC	Appointment.GetCustomerNotes
			@SessionID,
			@AppointmentID

	COMMIT TRANSACTION;
END;
GO

DROP PROCEDURE Appointment.GetAll;
GO

CREATE PROCEDURE Appointment.GetAll (
	@SessionID					CHAR(36),
	@PageNumber					INT				= 1,
	@PageSize					INT				= 50,
	@LookAhead					INT				= 3,
	@Search						VARCHAR(320)	= NULL,
	@Deleted					BIT				= 0,
	@LabelID					INT				= NULL,
	@StatusID					INT				= NULL,
	@FName						BIT				= NULL,
	@LName						BIT				= NULL,
	@Make						BIT				= NULL,
	@Model						BIT				= NULL,
	@ModelYear					BIT				= NULL,
	@CreationDate				BIT				= NULL,
	@StartDate					BIT				= NULL,
	@EndDate					BIT				= NULL,
	@Cost						BIT				= NULL
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

	SET @Search = '%'+@Search+'%';

	DECLARE @Table TABLE (
		AppointmentID UNIQUEIDENTIFIER,
		CustomerID UNIQUEIDENTIFIER,
		FName VARCHAR(50),
		LName VARCHAR(50),
		Email VARCHAR(50),
		Phone VARCHAR(50),
		Cost MONEY,
		CreationDate DATETIME,
		UpdationDate DATETIME,
		StartDate DATETIME,
		EndDate DATETIME,
		Make VARCHAR(50),
		Model VARCHAR(50),
		ModelYear INT,
		VIN VARCHAR(17),
		Mileage INT,
		LicensePlate VARCHAR(10),
		StatusID INT,
		Status VARCHAR(50)
	)

	INSERT INTO @Table
	SELECT		Appointment.ID.AppointmentID,
				Appointment.ID.CustomerID,
				Customer.Customer.FName,
				Customer.Customer.LName,
				Customer.Customer.Email,
				Customer.Customer.Phone,
				Appointment.Cost.Cost,
				Appointment.Date.CreationDate,
				Appointment.Date.UpdationDate,
				Appointment.Date.StartDate,
				Appointment.Date.EndDate,
				Appointment.Vehicle.Make,
				Appointment.Vehicle.Model,
				Appointment.Vehicle.ModelYear,
				Appointment.Vehicle.VIN,
				Appointment.Vehicle.Mileage,
				Appointment.Vehicle.LicensePlate,
				AppointmentStatus.StatusID,
				InfoStatus.Status
	FROM		Appointment.ID
	LEFT JOIN	Customer.Customer							ON	Appointment.ID.CustomerID		= Customer.Customer.CustomerID
	LEFT JOIN	Appointment.Date							ON	Appointment.ID.AppointmentID	= Appointment.Date.AppointmentID
	LEFT JOIN	Appointment.Vehicle							ON	Appointment.ID.AppointmentID	= Appointment.Vehicle.AppointmentID
	LEFT JOIN	Appointment.Status	AS AppointmentStatus	ON	Appointment.ID.AppointmentID	= AppointmentStatus.AppointmentID
	LEFT JOIN	Info.Status			AS InfoStatus			ON	InfoStatus.StatusID				= AppointmentStatus.StatusID
	LEFT JOIN	Appointment.Cost							ON	Appointment.ID.AppointmentID	= Appointment.Cost.AppointmentID
	WHERE		
				-- Deleted v Not Deleted
				((@Deleted = 1 AND Appointment.ID.AppointmentID IN (SELECT AppointmentID FROM Appointment.Deleted))
				OR
				((@Deleted = 0 OR @Deleted IS NULL) AND Appointment.ID.AppointmentID NOT IN (SELECT AppointmentID FROM Appointment.Deleted)))
				AND
				-- Status, if Specified
				((@StatusID IS NULL)
				OR
				(@StatusID IS NOT NULL AND AppointmentStatus.StatusID = @StatusID))
				AND
				-- Matching Label
				((@LabelID IS NULL)
				OR
				(@LabelID IS NOT NULL AND @LabelID >= 0 AND EXISTS (SELECT 1 FROM Appointment.Label WHERE AppointmentID = Appointment.ID.AppointmentID AND LabelID = @LabelID AND Value = 1 AND EmployeeID = @SessionEmployeeID))
				OR
				(@LabelID IS NOT NULL AND @LabelID <= 0 AND NOT EXISTS (SELECT 1 FROM Appointment.Label WHERE AppointmentID = Appointment.ID.AppointmentID AND LabelID = ABS(@LabelID) AND Value = 1 AND EmployeeID = @SessionEmployeeID)))
				AND
				-- Matching Search
				(
					@Search IS NULL  OR @Search = '' OR
					LOWER(Appointment.ID.AppointmentID)							LIKE @Search OR
					LOWER(Customer.Customer.FName)								LIKE @Search OR
					LOWER(Customer.Customer.LName)								LIKE @Search OR
					LOWER(Customer.Customer.FName + ' ' + Customer.LName)		LIKE @Search OR
					LOWER(Customer.Customer.Email)								LIKE @Search OR
					LOWER(Customer.Customer.Phone)								LIKE @Search OR
					LOWER(CONVERT(VARCHAR, Appointment.Date.CreationDate))		LIKE @Search OR
					LOWER(CONVERT(VARCHAR, Appointment.Date.StartDate))			LIKE @Search OR
					LOWER(CONVERT(VARCHAR, Appointment.Date.EndDate))			LIKE @Search OR
					LOWER(CONVERT(VARCHAR, Appointment.Cost.Cost))				LIKE @Search OR
					LOWER(Appointment.Vehicle.Make)								LIKE @Search OR
					LOWER(Appointment.Vehicle.Model)							LIKE @Search OR
					LOWER(CONVERT(CHAR(4), Appointment.Vehicle.ModelYear))		LIKE @Search OR
					LOWER(Appointment.Vehicle.VIN)								LIKE @Search OR
					LOWER(Appointment.Vehicle.LicensePlate)						LIKE @Search
				)
	
	IF (@LookAhead IS NULL)
	BEGIN
		SELECT	*
		FROM	@Table
		ORDER BY
				CASE WHEN @FName = 1		THEN FName			END ASC,
				CASE WHEN @FName = 0		THEN FName			END DESC,
				CASE WHEN @LName = 1		THEN LName			END ASC,
				CASE WHEN @LName = 0		THEN LName			END DESC,
				CASE WHEN @Make = 1			THEN Make			END ASC,
				CASE WHEN @Make = 0			THEN Make			END DESC,
				CASE WHEN @Model = 1		THEN Model			END ASC,
				CASE WHEN @Model = 0		THEN Model			END DESC,
				CASE WHEN @ModelYear = 1	THEN ModelYear		END ASC,
				CASE WHEN @ModelYear = 0	THEN ModelYear		END DESC,
				CASE WHEN @CreationDate = 1 THEN CreationDate	END ASC,
				CASE WHEN @CreationDate = 0 THEN CreationDate	END DESC,
				CASE WHEN @StartDate = 1	THEN StartDate		END ASC,
				CASE WHEN @StartDate = 0	THEN StartDate		END DESC,
				CASE WHEN @EndDate = 1		THEN EndDate		END ASC,
				CASE WHEN @EndDate = 0		THEN EndDate		END DESC,
				CASE WHEN @Cost = 1			THEN Cost			END ASC,
				CASE WHEN @Cost = 0			THEN Cost			END DESC
	END;
	ELSE
	BEGIN
		SELECT	*
		FROM	@Table
		ORDER BY
				CASE WHEN @FName = 1		THEN FName			END ASC,
				CASE WHEN @FName = 0		THEN FName			END DESC,
				CASE WHEN @LName = 1		THEN LName			END ASC,
				CASE WHEN @LName = 0		THEN LName			END DESC,
				CASE WHEN @Make = 1			THEN Make			END ASC,
				CASE WHEN @Make = 0			THEN Make			END DESC,
				CASE WHEN @Model = 1		THEN Model			END ASC,
				CASE WHEN @Model = 0		THEN Model			END DESC,
				CASE WHEN @ModelYear = 1	THEN ModelYear		END ASC,
				CASE WHEN @ModelYear = 0	THEN ModelYear		END DESC,
				CASE WHEN @CreationDate = 1 THEN CreationDate	END ASC,
				CASE WHEN @CreationDate = 0 THEN CreationDate	END DESC,
				CASE WHEN @StartDate = 1	THEN StartDate		END ASC,
				CASE WHEN @StartDate = 0	THEN StartDate		END DESC,
				CASE WHEN @EndDate = 1		THEN EndDate		END ASC,
				CASE WHEN @EndDate = 0		THEN EndDate		END DESC,
				CASE WHEN @Cost = 1			THEN Cost			END ASC,
				CASE WHEN @Cost = 0			THEN Cost			END DESC
		OFFSET ((@PageNumber - 1) * @PageSize) ROWS
		FETCH NEXT (@PageSize + (@LookAhead * @PageSize)) ROWS ONLY;
	END;

	SELECT COUNT(*) AS Count FROM @Table;

	EXEC	Appointment.GetAllLabels
			@SessionID;

	COMMIT TRANSACTION;
END;
GO