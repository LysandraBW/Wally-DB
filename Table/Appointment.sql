USE WALTRONICS;
GO

DROP TABLE Appointment.ID;

CREATE TABLE Appointment.ID (
	AppointmentID	UNIQUEIDENTIFIER NOT NULL DEFAULT NEWSEQUENTIALID(),
	CustomerID		UNIQUEIDENTIFIER NOT NULL,
	PRIMARY KEY (AppointmentID),
	FOREIGN KEY (CustomerID) REFERENCES Customer.Customer (CustomerID) ON DELETE CASCADE
);

ALTER TABLE Appointment.ID
ADD CONSTRAINT DK_App 
DEFAULT NEWSEQUENTIALID() FOR AppointmentID;

DROP TABLE Appointment.Date;

CREATE TABLE Appointment.Date (
	AppointmentID	UNIQUEIDENTIFIER NOT NULL,
	CreationDate	DATETIME NOT NULL,
	UpdationDate	DATETIME NOT NULL,
	StartDate		DATETIME,
	EndDate			DATETIME,
	CHECK (StartDate <= EndDate),
	CHECK (CreationDate <= UpdationDate),
	PRIMARY KEY (AppointmentID),
	FOREIGN KEY (AppointmentID) REFERENCES Appointment.ID (AppointmentID) ON DELETE CASCADE
);

DROP TABLE Appointment.Status;

CREATE TABLE Appointment.Status (
	AppointmentID	UNIQUEIDENTIFIER NOT NULL,
	StatusID		INT	NOT NULL,
	PRIMARY KEY (AppointmentID),
	FOREIGN KEY (StatusID) REFERENCES Info.Status (StatusID) ON DELETE CASCADE
);

DROP TABLE Appointment.Vehicle;

CREATE TABLE Appointment.Vehicle (
	AppointmentID	UNIQUEIDENTIFIER NOT NULL,
	Make			VARCHAR(50) NOT NULL,
	Model			VARCHAR(50) NOT NULL,
	ModelYear		INT			NOT NULL,
	VIN				VARCHAR(17),
	Mileage			INT,
	LicensePlate	VARCHAR(8),
	CHECK (
		VIN	LIKE '[0-9A-Z][0-9A-Z][0-9A-Z][0-9A-Z][0-9A-Z][0-9A-Z][0-9A-Z][0-9A-Z][0-9A-Z][0-9A-Z][0-9A-Z][0-9A-Z][0-9A-Z][0-9A-Z][0-9A-Z][0-9A-Z][0-9A-Z]' AND
		VIN	NOT LIKE '%[OIQ]%'),
	CHECK (ModelYear > 1980 AND ModelYear < 2030),
	CHECK (LicensePlate NOT LIKE '%[^A-Z0-9]%'),
	PRIMARY KEY (AppointmentID),
	FOREIGN KEY (Make) REFERENCES Info.Make (Make),
	FOREIGN KEY (AppointmentID) REFERENCES Appointment.ID (AppointmentID) ON DELETE CASCADE
);

DROP TABLE Appointment.Service;

CREATE TABLE Appointment.Service (
	ServiceID		INT	NOT NULL IDENTITY(1,1),
	AppointmentID	UNIQUEIDENTIFIER NOT NULL,
	Class			VARCHAR(50)	NOT NULL,
	Division		VARCHAR(50)	NOT NULL,
	Service			VARCHAR(50)	NOT NULL,
	CHECK (Class	NOT LIKE '%[^A-Za-z0-9 -/]%'),
	CHECK (Division	NOT LIKE '%[^A-Za-z0-9 -/]%'),
	CHECK (Service	NOT LIKE '%[^A-Za-z0-9 -/]%'),
	PRIMARY KEY (ServiceID),
	FOREIGN KEY (AppointmentID) REFERENCES Appointment.ID (AppointmentID) ON DELETE CASCADE
);

DROP TABLE Appointment.Payment;

CREATE TABLE Appointment.Payment (
	PaymentID		INT					NOT NULL IDENTITY (1, 1),
	AppointmentID	UNIQUEIDENTIFIER	NOT NULL,
	Payment			MONEY				NOT NULL,
	PaymentDate		DATETIME			NOT NULL,
	CHECK (Payment > 0),
	PRIMARY KEY (PaymentID),
	FOREIGN KEY (AppointmentID) REFERENCES Appointment.ID (AppointmentID) ON DELETE CASCADE
);

DROP TABLE Appointment.CreditCard;

CREATE TABLE Appointment.CreditCard (
	PaymentID	INT				NOT NULL,
	Name		VARCHAR(100)	NOT NULL,
	Type		VARCHAR(10)		NOT NULL,
	CCN			CHAR(4)			NOT NULL,
	EXP			CHAR(4)			NOT NULL,
	CHECK (Type	NOT LIKE '%[^A-Za-z]%'),
	CHECK (CCN	LIKE '[0-9][0-9][0-9][0-9]'),
	CHECK (EXP	LIKE '[0-9][0-9][0-9][0-9]'),
	PRIMARY KEY (PaymentID),
	FOREIGN KEY (PaymentID) REFERENCES Appointment.Payment (PaymentID) ON DELETE CASCADE
);

DROP TABLE Appointment.Cost;

CREATE TABLE Appointment.Cost (
	AppointmentID	UNIQUEIDENTIFIER NOT NULL,
	Cost			MONEY,
	PRIMARY KEY (AppointmentID),
	FOREIGN KEY (AppointmentID) REFERENCES Appointment.ID (AppointmentID) ON DELETE CASCADE
);

DROP TABLE Appointment.Label;

CREATE TABLE Appointment.Label (
	AppointmentID	UNIQUEIDENTIFIER NOT NULL,
	EmployeeID		UNIQUEIDENTIFIER NOT NULL,
	LabelID			INT	NOT NULL,
	Value			BIT DEFAULT 0 NOT NULL,
	PRIMARY KEY (AppointmentID, EmployeeID, LabelID),
	FOREIGN KEY (AppointmentID) REFERENCES Appointment.ID (AppointmentID) ON DELETE CASCADE,
	FOREIGN KEY (EmployeeID) REFERENCES Employee.Employee (EmployeeID) ON DELETE CASCADE,
	FOREIGN KEY (LabelID) REFERENCES Info.Label (LabelID) ON DELETE CASCADE
);

DROP TABLE Appointment.Part;

CREATE TABLE Appointment.Part (
	PartID			INT					NOT NULL IDENTITY (1,1),
	AppointmentID	UNIQUEIDENTIFIER	NOT NULL,
	PartName		VARCHAR(50)			NOT NULL,
	PartNumber		VARCHAR(50)			NOT NULL,
	Quantity		INT					NOT NULL,
	UnitCost		MONEY				NOT NULL,
	CHECK (Quantity > 0),
	CHECK (UnitCost > 0),
	PRIMARY KEY (PartID),
	FOREIGN KEY (AppointmentID) REFERENCES Appointment.ID (AppointmentID) ON DELETE CASCADE
);

DROP TABLE Appointment.Note;

CREATE TABLE Appointment.Note (
	NoteID			INT					NOT NULL IDENTITY (1,1),
	EmployeeID		UNIQUEIDENTIFIER	NOT NULL,
	AppointmentID	UNIQUEIDENTIFIER	NOT NULL,
	Head			VARCHAR(100)		NOT NULL,
	Body			VARCHAR(500)		NOT NULL,
	ShowCustomer	BIT DEFAULT 0		NOT NULL,
	CreationDate	DATETIME			NOT NULL,
	UpdationDate	DATETIME			NOT NULL,
	CHECK (CreationDate <= UpdationDate),
	PRIMARY KEY (NoteID),
	FOREIGN KEY (EmployeeID) REFERENCES Employee.Employee (EmployeeID) ON DELETE CASCADE,
	FOREIGN KEY (AppointmentID) REFERENCES Appointment.ID (AppointmentID) ON DELETE CASCADE
);

DROP TABLE Appointment.NoteAttachment;

CREATE TABLE Appointment.NoteAttachment (
	AttachmentID	INT	NOT NULL IDENTITY (1,1),
	NoteID			INT	NOT NULL,
	Name			VARCHAR(100),
	URL				VARCHAR(500) CHECK (LEN(URL) > 1),
	FOREIGN KEY (NoteID) REFERENCES Appointment.Note (NoteID) ON DELETE CASCADE
);


DROP TABLE Appointment.SharedNote;

CREATE TABLE Appointment.SharedNote (
	NoteID		INT	NOT NULL,
	EmployeeID	UNIQUEIDENTIFIER NOT NULL,
	PRIMARY KEY (NoteID, EmployeeID),
	FOREIGN KEY (NoteID) REFERENCES Appointment.Note (NoteID) ON DELETE CASCADE,
	FOREIGN KEY (EmployeeID) REFERENCES Employee.Employee (EmployeeID),
);

DROP TABLE Appointment.Diagnosis;

CREATE TABLE Appointment.Diagnosis (
	DiagnosisID		INT					NOT NULL IDENTITY (1,1),
	AppointmentID	UNIQUEIDENTIFIER	NOT NULL,
	Code			VARCHAR(20)			NOT NULL,
	Message			VARCHAR(500)		NOT NULL,
	PRIMARY KEY (DiagnosisID),
	FOREIGN KEY (AppointmentID) REFERENCES Appointment.ID (AppointmentID) ON DELETE CASCADE
);

DROP TABLE Appointment.Repair;

CREATE TABLE Appointment.Repair (
	RepairID		INT					NOT NULL IDENTITY (1, 1),
	AppointmentID	UNIQUEIDENTIFIER	NOT NULL,
	Repair			VARCHAR(500)		NOT NULL,
	PRIMARY KEY (RepairID),
	FOREIGN KEY (AppointmentID) REFERENCES Appointment.ID (AppointmentID) ON DELETE CASCADE
);

DROP TABLE Appointment.Deleted;

CREATE TABLE Appointment.Deleted (
	AppointmentID UNIQUEIDENTIFIER NOT NULL,
	PRIMARY KEY (AppointmentID)
);

DROP TABLE Appointment.Session;

CREATE TABLE Appointment.Session (
	AppointmentID UNIQUEIDENTIFIER	NOT NULL,
	SessionID	CHAR(36)			NOT NULL UNIQUE,
	LoginDate	DATETIME			NOT NULL DEFAULT GETDATE(),
	PRIMARY KEY (AppointmentID, SessionID),
	FOREIGN KEY (AppointmentID) REFERENCES Appointment.ID (AppointmentID) ON DELETE CASCADE
);