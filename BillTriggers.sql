CREATE TRIGGER trg_AfterDischargeDateUpdat
ON Admission
AFTER UPDATE
AS
BEGIN
    DECLARE @AdmissionID INT;
    DECLARE @DischargeDate DATE;
    DECLARE @BillAmount DECIMAL(18, 2);
    DECLARE @BillDate DATE = GETDATE();  -- Текущая дата для счета
    DECLARE @PaymentTerm DATE = DATEADD(MONTH, 1, GETDATE());  -- Срок оплаты через 1 месяц
    DECLARE @IsPaid BIT = 0;  -- Счет не оплачен по умолчанию
    -- Получаем данные о том, что изменилось
    SELECT @AdmissionID = AdmissionID, @DischargeDate = DateOfDischarge
    FROM INSERTED;
    -- Проверяем, что дата выписки была установлена
    IF @DischargeDate IS NOT NULL
    BEGIN
        -- Рассчитываем сумму счета на основе времени пребывания пациента в палате
        SET @BillAmount = dbo.CalculatePatientBillByStayDuration(@AdmissionID);
        -- Добавляем новую запись в таблицу Bill
        INSERT INTO Bill (AdmissionID, BillDate, BillAmount, IsPaid, PaymentTerm)
        VALUES (@AdmissionID, @BillDate, @BillAmount, @IsPaid, @PaymentTerm);
        PRINT 'Bill of duration record added successfully.';
    END
    ELSE
    BEGIN
        PRINT 'Error: Discharge date not set.';
    END
END;

EXEC DischargePatient @PatientID = 6;

SELECT * FROM [dbo].[Bill]

GO
CREATE TRIGGER trg_AfterDischargeUpdateBillProcedures
ON Admission
AFTER UPDATE
AS
BEGIN
    DECLARE @AdmissionID INT;
    DECLARE @PatientID INT;
    DECLARE @BillDate DATE = GETDATE();  -- Текущая дата для счета
    DECLARE @PaymentTerm DATE = DATEADD(MONTH, 1, GETDATE());  -- Срок оплаты через 1 месяц
    DECLARE @IsPaid BIT = 0;  -- Счет не оплачен по умолчанию
    DECLARE @BillAmount DECIMAL(18, 2);
    -- Проверяем, была ли обновлена дата выписки
    IF NOT UPDATE(DateOfDischarge)
        RETURN;
    -- Получаем данные из обновленных записей
    SELECT 
        @AdmissionID = A.AdmissionID,
        @PatientID = A.PatientID
    FROM INSERTED A
    WHERE A.DateOfDischarge IS NOT NULL;
    -- Рассчитываем сумму счета, используя функцию CalculatePatientBill
    SET @BillAmount = dbo.CalculatePatientBill(@AdmissionID);
    -- Если сумма счета равна нулю, пропускаем создание счета
    IF @BillAmount = 0
    BEGIN
        PRINT 'No procedures found for this admission. Bill will not be created.';
        RETURN;
    END;

    -- Добавляем новую запись в таблицу Bill
    INSERT INTO Bill (AdmissionID, BillDate, BillAmount, IsPaid, PaymentTerm)
    VALUES (@AdmissionID, @BillDate, @BillAmount, @IsPaid, @PaymentTerm);
    PRINT 'Bill record of procedures created successfully.';
END;
GO


EXEC DischargePatient @PatientID = 3; 

select * from Admission
select * from [dbo].[MedicalHistory]
Select * from [dbo].[Procedures]
select * from [dbo].[Bill]



