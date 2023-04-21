INSERT INTO tblChucvu (MaCV, TenCV)
VALUES ('BV', 'Bảo Vệ'), ('GD', 'Giám Đốc'), ('HC', 'Hành Chính'), ('KT', 'Kế Toán'), ('TQ', 'Thủ Quỹ'), ('VC', 'Vệ Sinh');

INSERT INTO tblSinhVien (MaNV, MaCV, TenNV, NgaySinh, LuongCanBan, NgayCong, PhuCap)
VALUES 
  ('NV01', 'GD', 'Trần Ngọc Khánh', '1977-12-12', 700000, 25, 500000),
  ('NV02', 'BV', 'Phạm Hồng Mai', '1978-10-10', 400000, 24, 100000),
  ('NV03', 'KT', 'Lê Cẩm Tú', '1977-09-09', 600000, 26, 400000),
  ('NV04', 'VS', 'Nguyễn Hoàng Hải', '1980-10-10', 300000, 26, 300000),
  ('NV05', 'HC', 'Hoàng Ngọc Thảo', '1979-10-10', 500000, 27, 200000);