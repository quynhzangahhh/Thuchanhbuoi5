﻿--Cau3a--
CREATE TRIGGER trg_nhatkybanhang_insert
ON NHATKYBANHANG
AFTER INSERT
AS
BEGIN
	UPDATE MATHANG
	SET soluong = MATHANG.soluong - inserted.soluong
	FROM MATHANG
	INNER JOIN inserted ON MATHANG.mahang = inserted.mahang
	END;

	--Cau3b--
	CREATE TRIGGER trg_nhatkybanhang_update
	ON NHATKYBANHANG
	AFTER UPDATE
	AS
	BEGIN
		IF UPDATE(soluong)
		BEGIN
		UPDATE MATHANG
		SET soluong = MATHANG.soluong + deleted.soluong - inserted.soluong
		FROM MATHANG
		INNER JOIN deleted ON MATHANG.mahang = deleted.mahang
		INNER JOIN inserted ON MATHANG.mahang = inserted.mahang
	END
END;

--Cau3c--
CREATE TRIGGER trg_nhatkybanhang_insert1
ON NHATKYBANHANG
FOR INSERT
AS
BEGIN
	DECLARE @mahang INT, @soluong INT, @soluong_hien_co INT

	SELECT @mahang = mahang, @soluong = soluong
	FROM inserted

	SELECT @soluong_hien_co = soluong
	FROM MATHANG
	WHERE mahang = @mahang

	IF @soluong <= @soluong_hien_co
	BEGIN
		UPDATE MATHANG
		SET soluong = soluong - @soluong
		WHERE mahang = @mahang
		END
		ELSE
		BEGIN
		RAISERROR('Số lượng hàng bán ra phải nhỏ hơn hoặc bằng số lượng hàng hiện có!', 16, 1)
		ROLLBACK TRANSACTION
	END
END;

--Cau3d--
CREATE TRIGGER trg_nhatkybanhang_update2
ON NHATKYBANHANG
FOR UPDATE
AS
BEGIN
IF (SELECT COUNT(*) FROM inserted) > 1
BEGIN
	RAISERROR('Chỉ được cập nhật 1 bản ghi tại một thời điểm!', 16, 1)
	ROLLBACK TRANSACTION
	END
	ELSE
	BEGIN
		DECLARE @mahang INT, @soluong INT, @soluong_hien_co INT
		SELECT @mahang = mahang, @soluong = soluong
		FROM inserted

		SELECT @soluong_hien_co = soluong
		FROM MATHANG
		WHERE mahang = @mahang

		UPDATE MATHANG
		SET soluong = soluong + (SELECT soluong FROM deleted) - @soluong
		WHERE mahang = @mahang
	END
END;

--Cau3e--
CREATE TRIGGER trg_nhatkybanhang_delete3
ON NHATKYBANHANG
FOR DELETE
AS
BEGIN
	IF (SELECT COUNT(*) FROM deleted) > 1
	BEGIN
		RAISERROR('Chỉ được xóa 1 bản ghi tại một thời điểm!', 16, 1)
		ROLLBACK TRANSACTION
		END
		ELSE
		BEGIN
		DECLARE @mahang INT, @soluong INT
		SELECT @mahang = mahang, @soluong = soluong
		FROM deleted
		UPDATE MATHANG
		SET soluong = soluong + @soluong
		WHERE mahang = @mahang
	END
END;

--Cau3f--
CREATE TRIGGER trg_nhatkybanhang_update4
ON NHATKYBANHANG
FOR UPDATE
AS
BEGIN
	DECLARE @mahang INT, @soluong INT, @soluong_hien_co INT

	SELECT @mahang = mahang, @soluong = soluong
	FROM inserted

	SELECT @soluong_hien_co = soluong
	FROM MATHANG
	WHERE mahang = @mahang

	IF @soluong > @soluong_hien_co
	BEGIN
		RAISERROR('Số lượng cập nhật không được vượt quá số lượng hiện có!', 16, 1)
		ROLLBACK TRANSACTION
	END
	ELSE IF @soluong = @soluong_hien_co
	BEGIN
		RAISERROR('Không cần cập nhật số lượng!', 16, 1)
		ROLLBACK TRANSACTION
	END
	ELSE
	BEGIN
		UPDATE MATHANG
		SET soluong = soluong + (SELECT soluong FROM deleted) - @soluong
		WHERE mahang = @mahang
	END
END;

--Cau3g--
CREATE PROCEDURE sp_xoa_mathang5
@mahang INT
AS
BEGIN
IF NOT EXISTS (SELECT * FROM MATHANG WHERE mahang = @mahang)
BEGIN
PRINT 'Mã hàng không tồn tại!'
RETURN
END

BEGIN TRANSACTION

DELETE FROM NHATKYBANHANG WHERE mahang = @mahang
DELETE FROM MATHANG WHERE mahang = @mahang

COMMIT TRANSACTION

PRINT 'Xóa mặt hàng thành công!'
END

--Cau3h--
CREATE FUNCTION fn_tongtien_hang
(@tenhang NVARCHAR(50))
RETURNS MONEY
AS
BEGIN
DECLARE @tongtien MONEY

SELECT @tongtien = SUM(@tongtien)
FROM NHATKYBANHANG nk
JOIN MATHANG mh ON nk.mahang = mh.mahang
WHERE mh.tenhang = @tenhang

RETURN @tongtien
END

--Cau3i--
-- Test cho câu 2
SELECT * FROM MATHANG
SELECT * FROM NHATKYBANHANG
-- Test cho câu 3a
INSERT INTO NHATKYBANHANG (stt, ngay, nguoimua, mahang, soluong, giaban)
VALUES
(6, '2022-04-22', 'Biện Như Ý', 1, 3, 15000)
SELECT * FROM MATHANG
-- Test cho câu 3b
UPDATE NHATKYBANHANG SET soluong = 2 WHERE stt = 2
SELECT * FROM MATHANG
-- Test cho câu 3c
INSERT INTO NHATKYBANHANG (stt, ngay, nguoimua, mahang, soluong, giaban)
VALUES
(7, '2022-04-23', 'Biện Tấn Công', 2, 10, 12000)
SELECT * FROM MATHANG
-- Test cho câu 3d
UPDATE NHATKYBANHANG SET soluong = 1 WHERE stt = 3
SELECT * FROM MATHANG
-- Test cho câu 3e
DELETE FROM NHATKYBANHANG WHERE stt = 4
SELECT * FROM MATHANG
-- Test cho câu 3f
UPDATE NHATKYBANHANG SET soluong = 7 WHERE stt = 5
SELECT * FROM MATHANG
-- Test cho câu 3g
EXEC sp_xoa_mathang 3
SELECT * FROM MATHANG
SELECT * FROM NHATKYBANHANG
-- Test cho câu 3h
SELECT dbo.fn_tongtien_hang('Sữa tươi Vinamilk') AS 'Tổng tiền Sữa tươi Vinamilk'
SELECT dbo.fn_tongtien_hang('Bánh mì phô mai') AS 'Tổng tiền Bánh mì phô mai'