CREATE TRIGGER trg_DischargePatient
ON Admission
AFTER UPDATE
AS
BEGIN
    -- Проверка, что была добавлена дата выписки
    IF UPDATE(DateOfDischarge)
    BEGIN
        DECLARE @WardID INT;
        -- Получаем идентификатор палаты из таблицы Admission, где был добавлен статус выписки
        SELECT @WardID = WardID
        FROM inserted;
        -- Обновляем количество занятых мест в палате (уменьшаем на 1)
        UPDATE Wards
        SET IsOccupied = IsOccupied - 1
        WHERE WardID = @WardID;

        PRINT 'Room has been freed. Available beds have been updated.';
    END
END;

GO
CREATE PROCEDURE DischargePatient
    @PatientID INT
AS
BEGIN
    -- Переменные для хранения данных о госпитализации и палате
    DECLARE @WardID INT;
    -- Проверка, существует ли запись о госпитализации для пациента
    SELECT @WardID = WardID
    FROM Admission
    WHERE PatientID = @PatientID AND DateOfDischarge IS NULL;  -- Только те, у которых нет даты выписки

    IF @WardID IS NULL
    BEGIN
        PRINT 'Error: No active admission record found for the patient.';
        RETURN;
    END
    -- Обновление даты выписки для пациента
    UPDATE Admission
    SET DateOfDischarge = GETDATE()
    WHERE PatientID = @PatientID AND DateOfDischarge IS NULL;
    -- Проверка, что обновление прошло успешно
    IF @@ROWCOUNT = 0
    BEGIN
        PRINT 'Error: Unable to update the discharge date for the patient.';
        RETURN;
    END
    PRINT 'Patient has been successfully discharged.';
END;

EXEC DischargePatient @PatientID = 2;  

SELECT * from [dbo].[Patient]
SELECT * from [dbo].[Admission]
SELECT * from [dbo].[Wards]

EXEC DischargePatient @PatientID = 13;
