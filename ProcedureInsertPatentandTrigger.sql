CREATE TRIGGER trg_UpdateWardAvailability
ON Admission
AFTER INSERT
AS
BEGIN
    -- Увеличение количества занятых коек
    UPDATE Wards
    SET IsOccupied = IsOccupied + 1
    FROM Wards
    INNER JOIN Inserted ON Wards.WardID = Inserted.WardID;
END;

GO
CREATE PROCEDURE AddNewPatient
    @FullName NVARCHAR(100),
    @DateOfBirth DATE,
    @Gender NVARCHAR(10),
    @PhoneNumber NVARCHAR(20),
    @Address NVARCHAR(200),
    @Height DECIMAL(5,2),
    @Weight DECIMAL(5,2),
    @BloodGroup NVARCHAR(10),
    @PreferredWardType INT,
    @DepartmentName NVARCHAR(50)
AS
BEGIN
    DECLARE @WardID INT;
    DECLARE @DepartmentID INT;
    DECLARE @PatientID INT;
    -- Получаем ID отделения по названию
    SELECT @DepartmentID = DepartmentID
    FROM Department
    WHERE DepartmentName = @DepartmentName;

    IF @DepartmentID IS NULL
    BEGIN
        PRINT 'Error: Invalid department name.';
        RETURN;
    END
    -- Проверяем, существует ли пациент с таким именем и датой рождения
    SELECT @PatientID = PatientID
    FROM Patient
    WHERE FullName = @FullName AND DateOfBirth = @DateOfBirth;
    -- Логика выбора палаты
    IF @PreferredWardType IN (1, 2, 3, 4)
    BEGIN
        SELECT TOP 1 @WardID = WardID
        FROM Wards
        WHERE WardGender = @Gender
          AND WardNumberOfBeds = @PreferredWardType
          AND DepartmentID = @DepartmentID
          AND IsOccupied < WardNumberOfBeds
        ORDER BY WardID;

        IF @WardID IS NULL
        BEGIN
            PRINT 'Error: No available rooms for the selected type, gender, and department.';
            RETURN;
        END
    END
    ELSE
    BEGIN
        PRINT 'Error: Incorrect ward type. Acceptable values: 1, 2, 3, 4.';
        RETURN;
    END
    -- Если пациент уже существует
    IF @PatientID IS NOT NULL
    BEGIN
        PRINT 'Patient already exists. Creating a new admission for the existing patient.';
    END
    ELSE
    BEGIN
        -- Добавляем нового пациента, если он не существует
        INSERT INTO Patient (FullName, DateOfBirth, Gender, PhoneNumber, Address, Height, Weight, BloodGroup)
        VALUES (@FullName, @DateOfBirth, @Gender, @PhoneNumber, @Address, @Height, @Weight, @BloodGroup);
        SET @PatientID = SCOPE_IDENTITY();
        
        IF @PatientID IS NULL
        BEGIN
            PRINT 'Error: Unable to insert new patient record.';
            RETURN;
        END
    END
    -- Создаем запись о госпитализации для пациента
    INSERT INTO Admission (PatientID, DateOfAdmission, WardID)
    VALUES (@PatientID, GETDATE(), @WardID);

    PRINT 'The patient has been successfully admitted.';
END;

EXEC AddNewPatient
    @FullName = 'Anna Borodina',
    @DateOfBirth = '1990-08-22',
    @Gender = 'Female',
    @PhoneNumber = '+79876543210',
    @Address = '10 Tveskyay Street, Moscow',
    @Height = 160.5,
    @Weight = 55.3,
    @BloodGroup = 'A+',
    @PreferredWardType = 4,  -- 3 - Three-bed room
    @DepartmentName = 'Traumatology';


select * from [dbo].[Patient]
SELECT * from [dbo].[Admission]
select * from [dbo].[Wards]

EXEC AddNewPatient
    @FullName = 'Maria Petrova',
    @DateOfBirth = '1992-07-08',
    @Gender = 'Female',
    @PhoneNumber = '+74952345678',
    @Address = '456 Oak Avenue, Saint Petersburg',
    @Height = 165.40,
    @Weight = 60.50,
    @BloodGroup = 'A-',
    @PreferredWardType =1, 
    @DepartmentName = 'Ophthalmology';

EXEC AddNewPatient
    @FullName = 'Alexey Smirnov',
    @DateOfBirth = '1980-02-15',
    @Gender = 'Male',
    @PhoneNumber = '+74959876543',
    @Address = '789 Maple Road, Novosibirsk',
    @Height = 175.20,
    @Weight = 82.40,
    @BloodGroup = 'B+',
    @PreferredWardType = 2, 
    @DepartmentName = 'Ophthalmology';

