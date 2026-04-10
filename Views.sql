CREATE VIEW FreeBedsInWardsByGender AS 
SELECT d.DepartmentName, w.WardID, w.WardNumber,w.WardGender,w.WardNumberOfBeds, w.WardNumberOfBeds-w.IsOccupied AS FreeBeds
FROM Wards AS w 
JOIN Department AS d 
ON w.DepartmentID=d.DepartmentID
WHERE w.WardNumberOfBeds>w.IsOccupied

SELECT * FROM [dbo].[FreeBedsInWardsByGender]


go 
CREATE VIEW PatientMedicalHistory AS
SELECT 
    P.PatientID,P.FullName AS PatientName, P.DateOfBirth, P.Gender,P.PhoneNumber AS PatientPhone,
    A.DateOfAdmission,A.DateOfDischarge,
    D.DepartmentName,
    Doc.DoctorFullName AS DoctorName, Doc.Specialty AS DoctorSpecialty,
    MH.TreatmentDate,MH.TreatmentPlan,
    DT.DiagnosisName, DT.DescriptionOfDiagnosis
FROM Patient P
JOIN Admission A 
ON P.PatientID = A.PatientID
JOIN MedicalHistory MH 
ON A.AdmissionID = MH.AdmissionID
JOIN Doctors Doc 
ON MH.DoctorID = Doc.DoctorID
JOIN Department D 
ON Doc.DepartmentID = D.DepartmentID
JOIN DiagnosisType DT 
ON MH.DiagnosisID = DT.DiagnosisID

SELECT * FROM [dbo].[PatientMedicalHistory]

GO
CREATE VIEW PatientDischargeArchive AS
SELECT 
    P.PatientID, P.FullName AS PatientName, P.DateOfBirth, P.Gender, P.PhoneNumber AS PatientPhone,
    A.DateOfAdmission, A.DateOfDischarge,
    D.DepartmentName,
    W.WardNumber, W.WardGender
FROM Patient P
JOIN Admission A 
ON P.PatientID = A.PatientID
JOIN Wards W 
ON A.WardID = W.WardID
JOIN Department D 
ON W.DepartmentID = D.DepartmentID
WHERE A.DateOfDischarge IS NOT NULL; -- Только пациенты с датой выписки

SELECT * FROM [dbo].[PatientDischargeArchive]

GO
CREATE VIEW DoctorsAndPatients AS
SELECT 
    Doc.DoctorID,Doc.DoctorFullName AS DoctorName,Doc.Specialty AS DoctorSpecialty, 
    P.PatientID, P.FullName AS PatientName,P.DateOfBirth AS PatientDB, P.Gender AS PatientGender,
    A.DateOfAdmission,A.DateOfDischarge
FROM Doctors Doc
JOIN MedicalHistory MH ON Doc.DoctorID = MH.DoctorID
JOIN Patient P ON MH.AdmissionID = P.PatientID
JOIN Admission A ON P.PatientID = A.PatientID

SELECT * FROM[dbo].[DoctorsAndPatients]

 
GO
CREATE VIEW DiagnosisView AS
SELECT DiagnosisID, DiagnosisName, DescriptionOfDiagnosis
FROM DiagnosisType;

SELECT * FROM DiagnosisView
