CREATE TRIGGER trg_AddMedicalHistory
ON Admission
AFTER INSERT
AS
BEGIN
    DECLARE @AdmissionID INT;
    DECLARE @DoctorID INT;
    DECLARE @DiagnosisID INT;
    DECLARE @TreatmentPlan NVARCHAR(1000);
    DECLARE @TreatmentDate DATETIME;
    -- Получаем AdmissionID из вставленной записи
    SELECT @AdmissionID = AdmissionID
    FROM inserted;
    -- Получаем первого доступного врача из того же отделения, что и пациент
    SELECT TOP 1 @DoctorID = DoctorID
    FROM Doctors
    WHERE DepartmentID = (SELECT DepartmentID FROM Admission WHERE AdmissionID = @AdmissionID)
    ORDER BY DoctorID; 
    -- Диагноз по 
    SELECT TOP 1 @DiagnosisID = DiagnosisID
    FROM DiagnosisType
    ORDER BY DiagnosisID; 
    -- Пример плана лечения
    SET @TreatmentPlan = 'Initial treatment plan for patient based on diagnosis';
    SET @TreatmentDate = GETDATE();
    -- Добавляем запись в таблицу MedicalHistory
    INSERT INTO MedicalHistory (AdmissionID, DoctorID, TreatmentDate, TreatmentPlan, DiagnosisID)
    VALUES (@AdmissionID, @DoctorID, @TreatmentDate, @TreatmentPlan, @DiagnosisID);

    PRINT 'A new medical history record has been created for the patient.';
END;


EXEC AddNewPatient
    @FullName = 'Anastasia Ivanova',       
    @DateOfBirth = '1992-03-15',       
    @Gender = 'Female',              
    @PhoneNumber = '+79876543210',    
    @Address = 'Moscow, Tverskaya 30',
    @Height = 168.5,                 
    @Weight = 62.0,                  
    @BloodGroup = 'A+',          
    @PreferredWardType = 2,           
    @DepartmentName = 'Ophthalmology';   
SELECT * from [dbo].[Patient]
SELECT * from [dbo].[Admission]
SELECT * FROM [dbo].[MedicalHistory]
SELECT * from [dbo].[Wards]



GO 
CREATE PROCEDURE UpdateMedicalHistory
    @HistoryID INT,            
    @NewDoctorID INT = NULL, 
    @NewDiagnosisID INT = NULL, 
    @NewTreatmentPlan NVARCHAR(MAX) = NULL
AS
BEGIN
    -- Проверяем, существует ли запись в MedicalHistory
    IF NOT EXISTS (SELECT 1 FROM MedicalHistory WHERE HistoryID = @HistoryID)
    BEGIN
        PRINT 'Error: Medical history record not found.';
        RETURN;
    END

    UPDATE MedicalHistory
    SET DoctorID = COALESCE(@NewDoctorID, DoctorID),          -- Обновляем DoctorID, если указан
        DiagnosisID = COALESCE(@NewDiagnosisID, DiagnosisID), -- Обновляем DiagnosisID, если указан
        TreatmentPlan = COALESCE(@NewTreatmentPlan, TreatmentPlan) -- Обновляем TreatmentPlan, если указан
    WHERE HistoryID = @HistoryID;
    -- Проверяем, были ли внесены изменения
    IF @@ROWCOUNT = 0
    BEGIN
        PRINT 'Error: No rows were updated.';
        RETURN;
    END
    PRINT 'Medical history record updated successfully.';
END;



EXEC UpdateMedicalHistory
    @HistoryID = 12,         
    @NewDoctorID = 2,      
    @NewDiagnosisID = 3,  
    @NewTreatmentPlan = 'Start physical therapy twice a week.';

EXEC UpdateMedicalHistory
    @HistoryID = 200,      
    @NewDoctorID = 2,   
    @NewDiagnosisID = 3,  
    @NewTreatmentPlan = 'Initiated diuretic therapy and regular echocardiograms.';


INSERT INTO MedicalHistory (AdmissionID, DoctorID, TreatmentDate, TreatmentPlan, DiagnosisID)
VALUES
(16, 1, '2024-12-23', 'Prescribed antihypertensive medication and lifestyle modifications.', 1)

