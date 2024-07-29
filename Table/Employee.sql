USE WALTRONICS;
GO

DROP TABLE Employee.Employee;

CREATE TABLE Employee.Employee (
	EmployeeID	UNIQUEIDENTIFIER	NOT NULL	DEFAULT NEWSEQUENTIALID(),
	FName		VARCHAR(50)			NOT NULL,
	LName		VARCHAR(50)			NOT NULL,
	Email		VARCHAR(320)		NOT NULL,
	Phone		VARCHAR(25)			NOT NULL,
	CHECK (FName NOT LIKE '%[^A-Za-z -]%'),
	CHECK (LName NOT LIKE '%[^A-Za-z -]%'),
	CHECK (Email LIKE '%[A-Za-z0-9]@[A-Za-z0-9][A-Za-z0-9]%.[A-Za-z0-9][A-Za-z0-9]%'),
	CHECK (Phone NOT LIKE '%[^0-9-+()]%'),
	PRIMARY KEY (EmployeeID)
);

ALTER TABLE Employee.Employee
ADD CONSTRAINT DK_Employee 
DEFAULT NEWSEQUENTIALID() FOR EmployeeID;

ALTER TABLE Employee.Employee
DROP CONSTRAINT CK__Employee__Email__69D19EED

ALTER TABLE Employee.Employee
ADD CONSTRAINT CK_Email CHECK (Email LIKE '%[A-Za-z0-9]@[A-Za-z0-9][A-Za-z0-9]%.[A-Za-z0-9][A-Za-z0-9]%')

DROP TABLE Employee.Login;

CREATE TABLE Employee.Login (
	EmployeeID	UNIQUEIDENTIFIER	NOT NULL,
	Username	VARCHAR(50)			NOT NULL UNIQUE,
	Password	VARCHAR(255)		NOT NULL
	PRIMARY KEY (EmployeeID),
	FOREIGN KEY (EmployeeID) REFERENCES	Employee.Employee (EmployeeID) ON DELETE CASCADE
);

DROP TABLE Employee.Modification;

CREATE TABLE Employee.Modification (
	ModificationID	INT					NOT NULL	IDENTITY (1,1),
	EmployeeID		UNIQUEIDENTIFIER	NOT NULL,
	AppointmentID	UNIQUEIDENTIFIER	NOT NULL,
	Modification	VARCHAR(400)		NOT NULL,
	CreationDate	DATETIME			NOT NULL
	PRIMARY KEY (ModificationID)
);

DROP TABLE Employee.Session;

CREATE TABLE Employee.Session (
	EmployeeID	UNIQUEIDENTIFIER	NOT NULL,
	SessionID	CHAR(36)			NOT NULL UNIQUE,
	LoginDate	DATETIME			NOT NULL DEFAULT GETDATE(),
	PRIMARY KEY (EmployeeID),
	FOREIGN KEY (EmployeeID) REFERENCES Employee.Employee (EmployeeID) ON DELETE CASCADE
);

ALTER TABLE Employee.Session
ADD CONSTRAINT DK_Session
DEFAULT GETDATE() FOR LoginDate;

ALTER TABLE Employee.Session
ALTER COLUMN SessionID VARBINARY(MAX)

DROP TABLE Employee.Event;

CREATE TABLE Employee.Event (
	EventID		INT					NOT NULL IDENTITY (1,1),
	EmployeeID	UNIQUEIDENTIFIER	NOT NULL,
	Name		VARCHAR(100)		NOT NULL,
	Date		DATETIME2,
	Summary		VARCHAR(500),
	PRIMARY KEY (EventID),
	FOREIGN KEY (EmployeeID) REFERENCES Employee.Employee (EmployeeID) ON DELETE CASCADE
);

DROP TABLE Employee.SharedEvent;

CREATE TABLE Employee.SharedEvent (
	EventID		INT	NOT NULL,
	EmployeeID	UNIQUEIDENTIFIER NOT NULL,
	PRIMARY KEY (EventID, EmployeeID),
	FOREIGN KEY (EventID) REFERENCES Employee.Event (EventID) ON DELETE CASCADE,
	FOREIGN KEY (EmployeeID) REFERENCES Employee.Employee (EmployeeID)
);