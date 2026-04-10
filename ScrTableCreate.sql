CREATE TABLE Patient (
    PatientID INT PRIMARY KEY IDENTITY,
    FullName VARCHAR(255) NOT NULL,
    DateOfBirth DATE NOT NULL,
    Gender VARCHAR(10) NOT NULL,
    PhoneNumber VARCHAR(20) NOT NULL,
    Address VARCHAR(255) NOT NULL,
    Height DECIMAL(5, 2) NOT NULL,
    Weight DECIMAL(5, 2) NOT NULL,
    BloodGroup VARCHAR(10) NOT NULL
);

CREATE TABLE Department (
    DepartmentID INT PRIMARY KEY IDENTITY,
    DepartmentName VARCHAR(255) NOT NULL,
    NumberOfBeds INT NOT NULL
);

CREATE TABLE Doctors (
    DoctorID INT PRIMARY KEY IDENTITY,
    DoctorFullName VARCHAR(255) NOT NULL,
    DepartmentID INT NOT NULL,
    Specialty VARCHAR(255) NOT NULL,
    DoctorPhoneNumber VARCHAR(20) NOT NULL,
    DoctorEmail VARCHAR(255) NOT NULL,
    WorkExperience INT NOT NULL,
    FOREIGN KEY (DepartmentID) REFERENCES Department(DepartmentID)
);

CREATE TABLE Wards (
    WardID INT PRIMARY KEY IDENTITY,
    DepartmentID INT NOT NULL,
    WardNumber INT NOT NULL,
    WardGender VARCHAR(10) NOT NULL,
    WardNumberOfBeds INT NOT NULL,
    IsOccupied BIT DEFAULT 0, -- Флаг занятости: 0 = свободна, 1 = занята
    FOREIGN KEY (DepartmentID) REFERENCES Department(DepartmentID)
);



CREATE TABLE Admission (
    AdmissionID INT PRIMARY KEY IDENTITY,
    PatientID INT NOT NULL,
    DateOfAdmission DATE NOT NULL,
    DateOfDischarge DATE,
    WardID INT NOT NULL,
    FOREIGN KEY (PatientID) REFERENCES Patient(PatientID),
    FOREIGN KEY (WardID) REFERENCES Wards(WardID)
);



CREATE TABLE DiagnosisType (
    DiagnosisID INT PRIMARY KEY IDENTITY,
    DiagnosisName VARCHAR(255) NOT NULL,
    DescriptionOfDiagnosis TEXT
);

CREATE TABLE MedicalHistory (
    HistoryID INT PRIMARY KEY IDENTITY,
    AdmissionID INT NOT NULL,
    DoctorID INT NOT NULL,
    TreatmentDate DATE NOT NULL,
    TreatmentPlan TEXT NOT NULL,
    DiagnosisID INT NOT NULL,
    FOREIGN KEY (AdmissionID) REFERENCES Admission(AdmissionID),
    FOREIGN KEY (DoctorID) REFERENCES Doctors(DoctorID),
    FOREIGN KEY (DiagnosisID) REFERENCES DiagnosisType(DiagnosisID)
);

CREATE TABLE Bill (
    BillID INT PRIMARY KEY IDENTITY,
    AdmissionID INT NOT NULL,
    BillDate DATE NOT NULL,
    BillAmount DECIMAL(10, 2) NOT NULL,
    IsPaid BIT DEFAULT 0, -- Флаг оплаты: 0 = не оплачено, 1 = оплачено
    PaymentTerm VARCHAR(50) NOT NULL,
    FOREIGN KEY (AdmissionID) REFERENCES Admission(AdmissionID),
);


CREATE TABLE ProceduresPrice (
    ProcedureTypeID INT PRIMARY KEY IDENTITY,
    ProcedureName VARCHAR(255) NOT NULL,
    DescriptionOfProcedure TEXT,
    ProcedureCost DECIMAL(10, 2) NOT NULL
);

CREATE TABLE Procedures (
    ProcedureID INT PRIMARY KEY IDENTITY,
    HistoryID INT NOT NULL,
    ProcedureData DATE NOT NULL,
    ProcedureTypeID INT NOT NULL,
    FOREIGN KEY (HistoryID) REFERENCES MedicalHistory(HistoryID),
    FOREIGN KEY (ProcedureTypeID) REFERENCES ProceduresPrice(ProcedureTypeID)
);

