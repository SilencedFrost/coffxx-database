create database QL_COFFXX;
go

use QL_COFFXX
go

create table Users
(
	userid int not null identity(1, 1),
	username nvarchar(100) not null unique,
	email varchar(100) not null unique,
	pass char(64) not null,
	SDT varchar(12),
	diachi nvarchar(200),
	sa bit,
	primary key (userid)
);

create table BankingCard
(
	userid int,
	cardnum varchar(19),
	cvv varchar(4),
	expdate date,
	ownnername varchar(100),
	primary key (cardnum)
);

create table Bill
(
	userid int not null,
	billid int not null identity(1, 1),
	paymethod varchar(10),
	amount float
	primary key (billid, userid)
);

create table BillDrinks
(
	billid int not null,
	drinkid int not null,
	size char(1),
	primary key (billid, drinkid)
);

create table Drinks
(
	drinkid int not null identity(1, 1),
	drinkname nvarchar(100) not null unique,
	decscription nvarchar(200),
	typ nvarchar(50),
	primary key (drinkid)
);

create table DrinkSizes
(
	drinkid int not null,
	size char(1) not null,
	price float,
	primary key (drinkid, size)
);

create table BestSeller
(
	pos nvarchar(20) not null,
	drinkid int not null,
	primary key (drinkid)
);

create table Cart
(
	userid int not null,
	drinkid int not null,
	size char,
	quantity int,
	primary key (userid, drinkid)
);

create table Rating
(
	drinkid int not null,
	userid int not null,
	ratestar float check (ratestar between 0 and 5),
	comment nvarchar(1000),
	primary key(drinkid, userid)
);

go

alter table CreditCard
	add constraint FK_userid_CreditCard
		foreign key (userid) references Users(userid);

alter table Bill
	add constraint FK_userid_Bill
		foreign key (userid) references Users(userid);

alter table BillDrinks
	add constraint FK_billid_BillDrinks
		foreign key (billid) references Bill(billid),
	constraint FK_drinkid_BillDrinks
		foreign key (drinkid) references Drinks(drinkid);

alter table DrinkSizes
	add constraint FK_drinkid_DrinkSizes
		foreign key (drinkid) references Drinks(drinkid);

alter table BestSeller
	add constraint FK_drinkid_BestSeller
		foreign key (drinkid) references Drinks(drinkid);

alter table Cart
	add constraint FK_userid_Cart
		foreign key (userid) references Users(userid),
	constraint FK_drinkid_Cart
		foreign key (drinkid) references Drinks(drinkid);

alter table Rating
	add constraint FK_drinkid_Rating
		foreign key (drinkid) references Drinks(drinkid),
	constraint FK_userid_Rating
		foreign key (userid) references Users(userid);
go

-- ==============================

-- Triggers

-- ==============================

-- Views

create or alter view Drink_Size
as
select A.drinkid, A.drinkname, A.typ, B.price, B.size, A.decscription
from Drinks A
join DrinkSizes B
on A.drinkid = B.drinkid
go


select * from Drink_Size
go

-- =============================

-- Stored Procs

create or alter proc Add_Drinks 
@Drinkname nvarchar(100),
@Size char,
@Price float,
@Description nvarchar(200),
@Typ nvarchar(50)
as
begin
	if not exists(Select * from Drink_Size where drinkname like @Drinkname and size like @Size)
	begin
		if not exists(Select * from Drinks where drinkname like @Drinkname)
		begin
			insert into Drinks(drinkname, decscription, typ) values (@Drinkname, @Description, @Typ);
		end
		insert into DrinkSizes(drinkid, size, price) values ((select drinkid from Drinks where drinkname like @Drinkname), @Size, @Price);
		print N'Thêm th?c u?ng thành công'
	end
	else
	begin
		print N'?ã t?n t?i lo?i th?c u?ng này ? kích th??c này'
	end
end
go

create or alter proc Register
@Username nvarchar(100),
@Email varchar(100),
@Password varchar(32)
as
begin
	if not exists(select * from Users where username like @Username or email like @Email)
		begin
		insert into Users(username, email, pass) values (@Username, @Email, HASHBYTES('SHA2_256', @Password))
		print N'??ng ký thành công'
		end
	else
		begin
		print N'??ng ký th?t b?i, ?ã có thông tin ng??i dùng này'
		end
end;
go

create or alter proc MakeAdmin
@Username nvarchar(100),
@Userid int
as
begin
	update Users
	set ad = 1
	where username like @Username
	      or userid = @Userid
end;
go

create or alter proc RemoveAdmin
@Username nvarchar(100),
@Userid int
as
begin
	update Users
	set ad = 0
	where username like @Username
	      or userid = @Userid
end;
go


-- ==================================

-- Functions

create or alter function UserLogin
(
@Emailname nvarchar(100),
@Password varchar(32)
)
returns bit
as
begin
	if exists(select * from Users where (username like @Emailname OR email like @Emailname) AND pass like HASHBYTES('SHA2_256', @Password))
	begin
		return 1
	end
	return 0
end;
go
-- ===============

-- executions
