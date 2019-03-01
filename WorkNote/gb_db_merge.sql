DECLARE @SRCDB_NAME VARCHAR(255);
DECLARE @DESTDB_NAME VARCHAR(255);
SET @SRCDB_NAME = 'by_actor_1';
SET @DESTDB_NAME = 'by_actor_2';

PRINT '************修改数据库名字****************************************************'
use master
exec sp_renamedb @dbname=@SRCDB_NAME, @newname='merge_src_db';
exec sp_renamedb @dbname=@DESTDB_NAME, @newname='merge_dest_db';

PRINT '************合并 Tbl_Org******************************************************'
INSERT into merge_dest_db.dbo.Tbl_Org select * from merge_src_db.dbo.Tbl_Org

PRINT '************合并 Tbl_OrgMember******************************************************'
INSERT into merge_dest_db.dbo.Tbl_OrgMember select * from merge_src_db.dbo.Tbl_OrgMember

PRINT '************合并 Tbl_Prince******************************************************'
INSERT into merge_dest_db.dbo.Tbl_Prince select * from merge_src_db.dbo.Tbl_Prince

PRINT '************合并 Tbl_Officer******************************************************'
INSERT into merge_dest_db.dbo.Tbl_Officer select * from merge_src_db.dbo.Tbl_Officer

PRINT '************合并 Tbl_Player******************************************************'
INSERT into merge_dest_db.dbo.Tbl_Player select * from merge_src_db.dbo.Tbl_Player

PRINT '************合并 Tbl_PlayerBaseInfo******************************************************'
INSERT into merge_dest_db.dbo.Tbl_PlayerBaseInfo select * from merge_src_db.dbo.Tbl_PlayerBaseInfo

PRINT '************合并 Tbl_OrgSkill******************************************************'
INSERT into merge_dest_db.dbo.Tbl_OrgSkill select * from merge_src_db.dbo.Tbl_OrgSkill

PRINT '************合并 Tbl_Princess******************************************************'
INSERT into merge_dest_db.dbo.Tbl_Princess select * from merge_src_db.dbo.Tbl_Princess


PRINT '************合并 Tbl_City******************************************************'
INSERT into merge_dest_db.dbo.Tbl_City select * from merge_src_db.dbo.Tbl_City

PRINT '************合并 Tbl_Card******************************************************'
INSERT into merge_dest_db.dbo.Tbl_Card select * from merge_src_db.dbo.Tbl_Card

PRINT '************合并 Tbl_Skill******************************************************'
INSERT into merge_dest_db.dbo.Tbl_Skill select * from merge_src_db.dbo.Tbl_Skill

PRINT '************合并 Tbl_TimeSet******************************************************'
INSERT into merge_dest_db.dbo.Tbl_TimeSet select * from merge_src_db.dbo.Tbl_TimeSet

PRINT '************合并 Tbl_OrgLog******************************************************'
INSERT into merge_dest_db.dbo.Tbl_OrgLog select * from merge_src_db.dbo.Tbl_OrgLog

PRINT '************合并 Tbl_Item******************************************************'
INSERT into merge_dest_db.dbo.Tbl_Item select * from merge_src_db.dbo.Tbl_Item

PRINT '************合并 Tbl_Task******************************************************'
INSERT into merge_dest_db.dbo.Tbl_Task select * from merge_src_db.dbo.Tbl_Task

PRINT '************合并 Tbl_OrgApply******************************************************'
INSERT into merge_dest_db.dbo.Tbl_OrgApply select * from merge_src_db.dbo.Tbl_OrgApply

PRINT '************合并 Tbl_OrgGift******************************************************'
INSERT into merge_dest_db.dbo.Tbl_OrgGift select * from merge_src_db.dbo.Tbl_OrgGift

PRINT '************合并 Tbl_Player_Deleted******************************************************'
INSERT into merge_dest_db.dbo.Tbl_Player_Deleted select * from merge_src_db.dbo.Tbl_Player_Deleted

PRINT '************合并 Tbl_Boss******************************************************'
INSERT into merge_dest_db.dbo.Tbl_Boss select * from merge_src_db.dbo.Tbl_Boss

PRINT '************合并 Tbl_BossRank******************************************************'
INSERT into merge_dest_db.dbo.Tbl_BossRank select * from merge_src_db.dbo.Tbl_BossRank

PRINT '************合并 Tbl_BossBattle******************************************************'
INSERT into merge_dest_db.dbo.Tbl_BossBattle select * from merge_src_db.dbo.Tbl_BossBattle


PRINT '************合并 Tbl_Dinner******************************************************'
Exec merge_dest_db.dbo.Sp_Merge_Dinner

PRINT '************合并 Tbl_MailList******************************************************'
Exec merge_dest_db.dbo.Sp_Merge_MailList

PRINT '************还原数据库名字****************************************************'
exec sp_renamedb @dbname='merge_src_db', @newname=@SRCDB_NAME;
exec sp_renamedb @dbname='merge_dest_db', @newname=@DESTDB_NAME;
